//
//  SBServiceViewModel.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 21/08/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

open class SBServiceViewModel<SF: SBServiceFactoryProtocol>: SBViewModel
{
    public let serviceFactory: SF
    public let authUserService: SBAuthUserServiceProtocol!
    public let downloadService: SBDowloadServiceProtocol!
    
    public init( serviceFactory: SF, parent: SBViewModel? = nil )
    {
        self.serviceFactory = serviceFactory
        authUserService = serviceFactory.ProvideAuthUserService()
        downloadService = serviceFactory.ProvideDownloadService()
        
        super.init( parent: parent )
        
        Bind( from: authUserService.rxIsLogin, to: rxIsLogin )
    }
    
    override open func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        assertionFailure( "There is no such view model \(id)" )
        return SBServiceViewModel<SF>( serviceFactory: serviceFactory, parent: self )
    }
    
    open func RxDownload( url: String ) -> Single<String>
    {
        if let downloadService = downloadService
        {
            return downloadService
                .RxDownload( url: url )
                .catchAndReturn( "" )
                .observe( on: bindScheduler )
        }
        
        return Single.just( "" )
    }
    
    open func RxDownloadImage( url: String, width: Int = 0, height: Int = 0 ) -> Single<String>
    {
        if let downloadService = downloadService
        {
            return downloadService
                .RxDownloadImage( url: url, width: width, height: height )
                .catchAndReturn( "" )
                .observe( on: bindScheduler )
        }
        
        return Single.just( "" )
    }
}
