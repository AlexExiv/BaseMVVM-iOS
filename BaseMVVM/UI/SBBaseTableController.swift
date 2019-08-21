//
//  CPBaseTableController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

public class SBBaseTableController<VM: SBViewModel>: UITableViewController, SBMVVMHolderProtocol, SBMVVMHolderUIBase
{
    public var preloaderView: SBPreloaderView!
    public var screenPreloaderCntrl: SBPreloaderController!
    
    public let dispBag = DisposeBag()
    public let bindScheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    
    private(set) public var viewModel: VM! = nil
    private(set) public var isInitRx = false
    private var messagesDisp: Disposable? = nil
    
    var cellHeights = [Int: CGFloat]()
    private var _tableView: UITableView? = nil
    private var footer: UIView? = nil
    private var footerHeight: CGFloat = 0.0
    
    override public var tableView: UITableView!
    {
        get
        {
            return _tableView == nil ? super.tableView : _tableView!;
        }
        set
        {
            super.tableView = newValue;
        }
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        isInitRx = isInitRx || InvokeInitRx( b: viewModel != nil )
    }
    
    override public func viewWillAppear( _ animated: Bool )
    {
        super.viewWillAppear( animated )
        messagesDisp = InvokeInitMessages()
    }
    
    override public func viewWillDisappear( _ animated: Bool )
    {
        super.viewWillDisappear(animated)
        messagesDisp?.dispose()
    }
    
    //MARK: - MVVM
    public func InitRx()
    {
        BindLoading( table: tableView )
        BindScreenLoading()
    }
    
    public func BindVM( vm: SBViewModel )
    {
        viewModel = (vm as! VM)
        isInitRx = isInitRx || InvokeInitRx( b: isViewLoaded )
    }
    
    public func BindReload<T>( rxEvent: Observable<T> )
    {
        BindReload( rxEvent: rxEvent, table: tableView )
    }
    
    public func BindReload<T>( rxEvent: BehaviorRelay<T> )
    {
        BindReload( rxEvent: rxEvent.asObservable(), table: tableView )
    }
    
    public func BindRefresh()
    {
        tableView.refreshControl = UIRefreshControl()
        BindRefresh( refresh: tableView.refreshControl!, scrollView: tableView )
    }
    
    public func DispatchMessage( message: SBViewModel.Message )
    {
        _DispatchMessage( message: message )
    }
    
    public func CreatePreloaderView()
    {
        preloaderView = SBPreloaderView( withStyle: .gray )
    }
    
    public func CreateScreenPreloaderCntrl()
    {
        screenPreloaderCntrl = SBPreloaderController.Create()
    }
    
    //MARK: - EXCHANGE VIEWS
    func ExchangeTableView()
    {
        _tableView = tableView;
        _tableView?.removeFromSuperview();
        
        view = UIView();
        view.backgroundColor = UIColor.white;
        view.addSubview( _tableView! );
    }
    
    func UpdateConstaints( table2bottom bTable2Bottom: Bool = false )
    {
        guard let _tableView = _tableView else
        {
            return;
        }
        
        _tableView.translatesAutoresizingMaskIntoConstraints = false;
        view.addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[_tableView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["_tableView": _tableView] ) );
        
        if let footer = footer
        {
            footer.translatesAutoresizingMaskIntoConstraints = false;
            view.addSubview( footer );
            
            view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "H:|-(0)-[footer]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["footer": footer] ) );
            if bTable2Bottom
            {
                view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|-(0)-[_tableView]-(0)-|", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["_tableView": _tableView] ) );
                view.addConstraint( NSLayoutConstraint( item: footer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: footerHeight ) );
            }
            else
            {
                view.addConstraints( NSLayoutConstraint.constraints( withVisualFormat: "V:|-(0)-[_tableView]-(0)-[footer(\(footerHeight))]", options: NSLayoutConstraint.FormatOptions( rawValue: 0 ), metrics: nil, views: ["footer": footer, "_tableView": _tableView] ) );
            }
            footer.bottomAnchor.constraint( equalTo: BottomGuide ).isActive = true;
        }
        else
        {
            view.addConstraint( NSLayoutConstraint( item: _tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0 ) );
            view.addConstraint( NSLayoutConstraint( item: _tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0 ) );
        }
    }
    
    public func Add( footer footer_: UIView, height: CGFloat, table2bottom: Bool = false )
    {
        footer = footer_;
        footerHeight = height;
        ExchangeTableView();
        UpdateConstaints( table2bottom: table2bottom );
        updateViewConstraints();
    }
    
    //MARK - UITableViewDelegate
    override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return cellHeights[indexPath.section*10000 + indexPath.row] ?? UITableView.automaticDimension;
    }

    override public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cellHeights[indexPath.section*10000 + indexPath.row] = cell.bounds.size.height;
    }
    
    //MARK: - SEGUE
    override public func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        prepareVM( for: segue, sender: sender )
    }
}
