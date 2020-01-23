//
//  SBEntity.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 22/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

public typealias SBEntityKey = AnyHashable

public protocol SBEntity
{
    var key: SBEntityKey { get }
}
