//
//  SBBasePageController.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

open class SBBasePageController<VM: SBViewModel & SBPagesViewModel>: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, SBMVVMHolderProtocol, SBMVVMHolderUIBase
{
    public var preloaderView: SBPreloaderView!
    public var screenPreloaderCntrl: SBPreloaderControllerProtocol!
    
    public let dispBag = DisposeBag()
    open var bindScheduler: SchedulerType = MainScheduler.asyncInstance
    
    private(set) public var viewModel: VM! = nil
    private(set) public var isInitRx = false
    private var messagesDisp: Disposable? = nil
    
    public var canScroll: Bool
    {
        set
        {
            for v in view.subviews
            {
                if let sv = v as? UIScrollView
                {
                    sv.isScrollEnabled = newValue
                    break
                }
            }
        }
        get
        {
            for v in view.subviews
            {
                if let sv = v as? UIScrollView
                {
                    return sv.isScrollEnabled
                }
            }
            return true
        }
    }
    
    public var controllers: [UIViewController] = []
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        isInitRx = isInitRx || InvokeInitRx( b: viewModel != nil )
        
        InitViewControllers()
        BindPagesVMs( vms: viewModel.pageViewModelsArray )
        setViewControllers( [controllers[0]], direction: .forward, animated: false, completion: nil )
    }
    
    override open func viewWillAppear( _ animated: Bool )
    {
        super.viewWillAppear( animated )
        messagesDisp = InvokeInitMessages()
    }
    
    override open func viewWillDisappear( _ animated: Bool )
    {
        super.viewWillDisappear(animated)
        messagesDisp?.dispose()
    }
    
    //MARK: - MVVM
    open func InitRx()
    {
        BindScreenLoading()
        
        Observable
            .zip( viewModel.rxPageIndex, viewModel.rxPageIndex.skip( 1 ) )
            .filter { $0.0 != $0.1 }
            .observe( on: bindScheduler )
            .subscribe( onNext: { [weak self] in
                guard let self = self else { return }
                if let cntrl = self.viewControllers?.first, let index = self.controllers.firstIndex( of: cntrl ), index != $0.1
                {
                    self.setViewControllers( [self.controllers[$0.1]], direction: $0.0 > $0.1 ? .reverse : .forward, animated: true, completion: nil )
                }
            } )
            .disposed( by: dispBag )
    }
    
    open func InitViewControllers()
    {
        
    }
    
    public func BindVM( vm: SBViewModel )
    {
        viewModel = (vm as! VM)
        isInitRx = isInitRx || InvokeInitRx( b: isViewLoaded )
    }

    public func BindPagesVMs( vms: [SBViewModel] )
    {
        precondition( vms.count == controllers.count, "The number of tabs view models is not equals to the number of view controllers" )
        controllers.enumerated().forEach { ($0.element as? SBMVVMHolderProtocol)?.BindVM( vm: vms[$0.offset] ) }
    }

    open func DispatchMessage( message: SBViewModel.Message )
    {
        _DispatchMessage( message: message )
    }
    
    open func RouteTo( tag: Int, sender: Any? )
    {
        
    }
    
    open func CreatePreloaderView()
    {
        preloaderView = SBPreloaderView( withStyle: .gray )
    }
    
    open func CreateScreenPreloaderCntrl()
    {
        screenPreloaderCntrl = SBPreloaderController.Create()
    }

    //MARK: - UIPageViewControllerDelegate
    open func pageViewController( _ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController ) -> UIViewController?
    {
        guard let index = controllers.firstIndex( of: viewController ) else { return nil }
        if (index - 1) < 0
        {
            return nil
        }
        
        return controllers[index - 1]
    }
    
    open func pageViewController( _ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController ) -> UIViewController?
    {
        guard let index = controllers.firstIndex( of: viewController ) else { return nil }
        
        let i = index + 1
        if i >= controllers.count
        {
            return nil
        }

        return controllers[i]
    }

    open func pageViewController( _ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool )
    {
        print( "End animation" )
        if let cntrl = viewControllers?.first, let index = controllers.firstIndex( of: cntrl )
        {
            viewModel.rxPageIndex.accept( index )
        }
    }
    
    //MARK: - SEGUE
    override open func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        prepareVM( for: segue, sender: sender )
    }
}
