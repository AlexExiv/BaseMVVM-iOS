//
//  PageViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay

class PageViewModel: ViewModel
{
    let rxLabel = BehaviorRelay( value: "" )
    
    init( l: String )
    {
        rxLabel.accept( l )
    }
}
