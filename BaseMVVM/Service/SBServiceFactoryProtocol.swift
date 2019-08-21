//
//  SBServiceFactoryProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 21/08/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

public protocol SBServiceFactoryProtocol
{
    var authUserService: SBAuthUserServiceProtocol! { get }
    var imageDownloadService: SBImageDowloadServiceProtocol! { get }
}
