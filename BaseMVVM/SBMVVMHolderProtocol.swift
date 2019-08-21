//
//  CPControllerMVVMProtocol.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 17/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

public protocol SBMVVMHolderProtocol
{
    func BindVM( vm: SBViewModel )
}

public protocol SBMVVMHolderBase
{
    associatedtype ViewModel: SBViewModel
    
    var viewModel: ViewModel! { get }
    var isInitRx: Bool { get }
    var bindScheduler: ImmediateSchedulerType { get }
    
    func InitRx()
    func DispatchMessage( message: ViewModel.Message )
}

extension SBMVVMHolderBase where Self: AnyObject
{
    func InvokeInitRx( b: Bool ) -> Bool
    {
        if b && !isInitRx
        {
            DispatchQueue.main.async { [weak self] in self?.InitRx() }
            return true
        }
        return false
    }
    
    func InvokeInitMessages() -> Disposable
    {
        return viewModel
            .rxMessages
            .asObservable()
            .observeOn( bindScheduler )
            .subscribe( onNext: { [weak self] in self?.DispatchMessage( message: $0 ) } )
    }
    
    func prepareVM( for id: String?, vmHolder: SBMVVMHolderProtocol?, sender: Any? )
    {
        if let id = id
        {
            vmHolder?.BindVM( vm: viewModel.GetChildVM( id: id, sender: sender ) )
        }
    }
}
