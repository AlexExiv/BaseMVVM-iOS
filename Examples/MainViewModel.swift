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
    
    let rxDialogResult = BehaviorRelay<String>( value: "None" )
    
    func ShowDialog()
    {
        RouteTo( tag: MainViewModel.MESSAGE_SHOW_DIALOG )
    }
}
