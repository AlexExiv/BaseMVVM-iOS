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

public class SBServiceViewModel<SF: SBServiceFactoryProtocol>: SBViewModel
{
    public let serviceFactory: SF
    public let authUserService: SBAuthUserServiceProtocol!
    public let imageDownloadService: SBImageDowloadServiceProtocol!
    
    public let rxIsLogin = BehaviorRelay( value: false )
    
    init( serviceFactory: SF, parent: SBViewModel? = nil )
    {
        self.serviceFactory = serviceFactory
        authUserService = serviceFactory.authUserService
        imageDownloadService = serviceFactory.imageDownloadService
        
        super.init( parent: parent )
        
        Bind( from: authUserService.rxIsLogin, to: rxIsLogin )
    }
    
    override public func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        assertionFailure( "There is no such view model \(id)" )
        return SBServiceViewModel<SF>( serviceFactory: serviceFactory, parent: self )
    }
    
    func RxDownloadImage( url: String, width: Int = 0, height: Int = 0 ) -> Single<String>
    {
        if let imageDownloadService = imageDownloadService
        {
            return imageDownloadService
                .RxDownload( url: url, width: width, height: height )
                .catchErrorJustReturn( "" )
                .observeOn( bindScheduler )
        }
        
        return Single.just( "" )
    }
}
