//
//  ViewModel.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.02.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import BaseMVVM

class ViewModel: SBServiceViewModel<SBDefaultServiceFactory>
{
    override init( serviceFactory: SBDefaultServiceFactory, parent: SBViewModel? = nil )
    {
        super.init( serviceFactory: serviceFactory, parent: parent )
    }
}
