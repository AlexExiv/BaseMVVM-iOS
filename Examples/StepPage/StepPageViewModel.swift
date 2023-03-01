//
//  StepPageViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay

class StepPageViewModel: ViewModel
{
    let rxLabel = BehaviorRelay( value: "" )
    let rxHideLabel = BehaviorRelay( value: false )
    
    init( l: String )
    {
        rxLabel.accept( l )
    }
    
    func ToggleHide()
    {
        rxHideLabel.accept( !rxHideLabel.value )
    }
}
