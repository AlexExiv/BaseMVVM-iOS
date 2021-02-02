//
//  SBDefaultServiceFactory.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.02.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

public class SBDefaultServiceFactory: SBServiceFactoryProtocol
{
    let userService: SBAuthUserServiceProtocol
    let downloadService: SBDowloadServiceProtocol
    
    public init()
    {
        userService = SBDefaultUserService( login: false )
        downloadService = SBDefaultDowloadService()
    }
    
    public func ProvideAuthUserService() -> SBAuthUserServiceProtocol
    {
        userService
    }
    
    public func ProvideDownloadService() -> SBDowloadServiceProtocol
    {
        downloadService
    }
}
