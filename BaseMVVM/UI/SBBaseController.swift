//
//  CPBaseController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

open class SBBaseController<VM: SBViewModel>: UIViewController, SBMVVMHolderProtocol, SBMVVMHolderUIBase
{
    public var preloaderView: SBPreloaderView!
    public var screenPreloaderCntrl: SBPreloaderController!
    
    public let dispBag = DisposeBag()
    public let bindScheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    
    private(set) public var viewModel: VM! = nil
    private(set) public var isInitRx = false
    private var messagesDisp: Disposable? = nil
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        isInitRx = isInitRx || InvokeInitRx( b: viewModel != nil )
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
    }
    
    public func BindVM( vm: SBViewModel )
    {
        viewModel = (vm as! VM)
        isInitRx = isInitRx || InvokeInitRx( b: isViewLoaded )
    }
    
    open func DispatchMessage( message: SBViewModel.Message )
    {
        _DispatchMessage( message: message )
    }
    
    open func CreatePreloaderView()
    {
        preloaderView = SBPreloaderView( withStyle: .gray )
    }
    
    open func CreateScreenPreloaderCntrl()
    {
        screenPreloaderCntrl = SBPreloaderController.Create()
    }
    
    //MARK: - SEGUE
    override open func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        prepareVM( for: segue, sender: sender )
    }
}
