//
//  SBDefaultUserService.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.02.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay

class SBDefaultUserService: SBAuthUserServiceProtocol
{
    var isLogin = false
    {
        didSet
        {
            rxIsLogin.accept( isLogin )
        }
    }
    
    var rxIsLogin = BehaviorRelay<Bool>( value: false )
    
    init( login: Bool )
    {
        isLogin = login
    }
}
