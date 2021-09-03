//
//  StepPagesViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay
import BaseMVVM

class StepPagesViewModel: ViewModel, SBPagesViewModel
{
    var pageViewModelsArray: [SBViewModel]  = []
    var rxPageIndex = BehaviorRelay( value: 0 )
    
    func GetPageVM( i: Int ) -> SBViewModel
    {
        if i < 4
        {
            return StepPageViewModel( l: "\(i)" )
        }
        
        preconditionFailure()
    }
}
