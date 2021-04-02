//
//  UserService.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxRelay

class UserService: UserServiceProtocol
{
    var rxIsLogin = BehaviorRelay<Bool>( value: false )
    
    init( login: Bool )
    {
        rxIsLogin.accept( login )
    }
}
