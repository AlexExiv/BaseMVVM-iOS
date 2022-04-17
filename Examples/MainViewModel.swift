//
//  MainViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.02.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay
import BaseMVVM

class MainViewModel: ViewModel
{
    static let MESSAGE_SHOW_DIALOG = 1000
    
    @Inject( singleton: false, lazy: true )
    var animal: Animal
    
    let rxDialogResult = BehaviorRelay<String>( value: "None" )
    let rxUserLogin = BehaviorRelay<String>( value: "" )
    
    override init()
    {
        super.init()
        
        BindT( from: rxIsLogin, to: rxUserLogin, map: { $0 ? "YES" : "NO" } )
    }
    
    override func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        switch id
        {
        case "PagesMainController":
            return PagesMainViewModel()
        case "StepPagesMainController":
            return StepPagesMainViewModel()
        default:
            return super.GetChildVM( id: id )
        }
    }
    
    func ShowDialog()
    {
        ShowAlertText(title: "Title", message: "Message", positive: "Set", negative: "Cancel", placeholder: "Placeholder", text: "" ) { [weak self] in self?.rxDialogResult.accept( $0.btn == .positive ? $0.text : "Canceled" ) }
    }
    
    func ShowTestAlert()
    {
        ShowAlert( title: "Test", message: "Message", positive: "Yes", negative: "No" ) { [weak self] in self?.rxDialogResult.accept( $0 == .positive ? "Positive" : "Negative" ) }
    }
    
    func ToggleLogin()
    {
        print( "ANIMAL NAME - \(animal.name)" )
        userService.rxIsLogin.accept( !userService.rxIsLogin.value )
    }
}
