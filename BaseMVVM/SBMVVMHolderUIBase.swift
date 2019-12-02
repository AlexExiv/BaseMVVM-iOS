//
//  CPMVVMHolderUIBase.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

public protocol SBMVVMHolderUIBase: SBMVVMHolderBase, SBBindUIProtocol
{
    var preloaderView: SBPreloaderView! { get }
    var screenPreloaderCntrl: SBPreloaderController! { get }
    
    func CreatePreloaderView()
    func CreateScreenPreloaderCntrl()
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
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss( animated: true, completion: nil )
            (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)?.popToRootViewController( animated: false )
            
        case .Error( let error ):
            let alert = UIAlertController.DialogText( title: NSLocalizedString( "Ошибка", comment: "" ), message: error )
            alert.Show( cntrl: self )
            
        case .Message( let title, let message ):
            let alert = UIAlertController.DialogText( title: title, message: message )
            alert.Show( cntrl: self )
            
        default:
            break
        }
    }
    
    func BindReload<T>( rxEvent: Observable<T>, table: UITableView )
    {
        BindAction( from: rxEvent, action: { _ in table.reloadData() } )
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
            
            if self.screenPreloaderCntrl == nil, $0
            {
                self.CreateScreenPreloaderCntrl()
            }
            
            if $0
            {
                self.screenPreloaderCntrl?.Show( title: "" )
            }
            else
            {
                self.screenPreloaderCntrl?.Hide()
            }
        })
    }
}
