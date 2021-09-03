//
//  PagesViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay
import BaseMVVM

class PagesViewModel: ViewModel, SBPagesViewModel
{
    var pageViewModelsArray: [SBViewModel]  = [PageViewModel( l: "1" ), PageViewModel( l: "2" ), PageViewModel( l: "3" ), PageViewModel( l: "4" )]
    var rxPageIndex = BehaviorRelay( value: 0 )
}
