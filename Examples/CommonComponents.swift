//
//  CommonComponents.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import BaseMVVM

class CommonComponents
{
    init( initial: Bool )
    {
        ComponentsResolver.shared.Register( type: UserServiceProtocol.self, lazy: false ) { UserService( login: initial ) }
        ComponentsResolver.shared.Register( type: Animal.self ) { Cat( name: "TOM" ) }
    }
}
