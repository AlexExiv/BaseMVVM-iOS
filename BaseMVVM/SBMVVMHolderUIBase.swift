//
//  CPMVVMHolderUIBase.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay

public protocol SBMVVMHolderUIBase: SBMVVMHolderBase, SBBindUIProtocol
{
    var preloaderView: SBPreloaderView! { get }
    var screenPreloaderCntrl: SBPreloaderControllerProtocol! { get }
    
    func CreatePreloaderView()
    func CreateScreenPreloaderCntrl()
    
    func RouteTo( tag: Int, sender: Any? )
}

public extension SBMVVMHolderUIBase where Self: UIViewController
{
    func prepareVM( for segue: UIStoryboardSegue, sender: Any? )
    {
        prepareVM( for: segue.identifier, vmHolder: segue.destination as? SBMVVMHolderProtocol, sender: sender )
    }
    
    func _DispatchMessage( message: ViewModel.Message )
    {
        switch message
        {
        case .Close:
            if let nav = navigationController
            {
                if nav.viewControllers.count == 1
                {
                    presentingViewController?.dismiss( animated: true, completion: nil )
                }
                else
                {
                    nav.popViewController( animated: true );
                }
            }
            else
            {
                dismiss( animated: true, completion: nil )
            }
            
        case .CloseScenario:
            presentingViewController?.dismiss( animated: true, completion: nil )
            
        case .Close2Top:
            UIApplication.shared.keyWindow?.rootViewController?.dismiss( animated: true, completion: nil )
            (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.popToRootViewController( animated: false )
            
        case .Error( let error ):
            let alert = UIAlertController.DialogText( title: NSLocalizedString( "Ошибка", comment: "" ), message: error )
            alert.Show( cntrl: self )
            
        case .Message( let title, let message ):
            let alert = UIAlertController.DialogText( title: title, message: message )
            alert.Show( cntrl: self )
            
        case .Show( let tag, let sender ):
            RouteTo( tag: tag, sender: sender )
            
        case .Alert( let title, let message, let buttons, let placeholder, let text, let result ):
            let alert = UIAlertController( title: title, message: message, preferredStyle: .alert )
            if let text = text
            {
                alert.addTextField
                {
                    $0.text = text
                    $0.placeholder = placeholder
                }
            }
            
            buttons.enumerated().forEach { b in alert.addAction( UIAlertAction( title: b.element, style: .default, handler: { _ in result( (b.offset, alert.textFields?.first?.text ?? "") ) } ) ) }
            alert.Show( cntrl: self )
            
        default:
            break
        }
    }
    
    func RouteTo( tag: Int, sender: Any? )
    {
        
    }
    
    func BindReload<O: ObservableType>( from: O, table: UITableView )
    {
        BindAction( from: from, action: { _ in table.reloadData() } )
    }
    
    func BindUpdates<O: ObservableType, E: SBDiffEntity>( from: O, table: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) where O.Element == Array<E>
    {
        SBDiffCalculator.BindUpdates( from: from, table: table, change: change, insert: insert, delete: delete, all: all, scheduler: bindScheduler, dispBag: dispBag )
    }
    
    func BindReload<O: ObservableType>( from: O, collection: UICollectionView )
    {
        from
            .observeOn( bindScheduler )
            .subscribe( onNext: { _ in collection.reloadData() } )
            .disposed( by: dispBag )
    }
    
    func BindUpdates<O: ObservableType, E: SBDiffEntity>( from: O, collection: UICollectionView ) where O.Element == Array<E>
    {
        SBDiffCalculator.BindUpdates( from: from, collection: collection, scheduler: bindScheduler, dispBag: dispBag )
    }
    
    func BindRefresh( refresh: UIRefreshControl, scrollView: UIScrollView )
    {
        scrollView.addSubview( refresh );
        
        refresh
            .rx
            .controlEvent( .valueChanged )
            .do( onNext: { _ in refresh.endRefreshing() } )
            .subscribe( onNext: { [weak self] _ in self?.viewModel.RefreshData() } )
            .disposed( by: dispBag );
    }

    func BindLoading( table: UITableView )
    {
        BindAction( from: viewModel.rxLoading, action:
        {
            [weak self] in
            guard let self = self else { return }
            
            if self.preloaderView == nil, $0
            {
                self.CreatePreloaderView()
            }
            table.tableFooterView = $0 ? self.preloaderView : UIView()
            self.preloaderView?.animating = true
        })
    }
    
    func BindScreenLoading()
    {
        BindAction( from: viewModel.rxScreenLoading, action:
        {
            [weak self] in
            guard let self = self else { return }
            
            if self.screenPreloaderCntrl == nil && !$0.isEmpty
            {
                self.CreateScreenPreloaderCntrl()
            }
            
            if !$0.isEmpty
            {
                self.screenPreloaderCntrl?.Show( title: $0 )
            }
            else
            {
                self.screenPreloaderCntrl?.Hide()
            }
        })
    }
}

public extension SBMVVMHolderUIBase where Self: UITableViewController
{
    func BindReloadTable<O: ObservableType>( from: O )
    {
        BindReload( from: from, table: tableView )
    }
    
    func BindUpdates<O: ObservableType, E: SBDiffEntity>( from: O, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) where O.Element == Array<E>
    {
        BindUpdates( from: from, table: tableView, change: change, insert: insert, delete: delete, all: all )
    }
    
    func BindRefreshTable( refresh: UIRefreshControl )
    {
        BindRefresh( refresh: refresh, scrollView: tableView )
    }

    func BindLoadingTable()
    {
        BindLoading( table: tableView )
    }
}
