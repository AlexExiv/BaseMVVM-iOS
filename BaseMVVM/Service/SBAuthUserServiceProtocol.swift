//
//  SBAuthUserServiceProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 21/08/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public protocol SBAuthUserServiceProtocol
{
    var rxIsLogin: BehaviorRelay<Bool> { get }
}
