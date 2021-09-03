//
//  SBIViewModel.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

open class SBIViewModel: SBViewModel
{
    open var authUserService: SBAuthUserServiceProtocol! { nil }
    open var downloadService: SBDowloadServiceProtocol! { nil }
    
    public init()
    {
        super.init( parent: nil )
        
        if let authUserService = authUserService
        {
            Bind( from: authUserService.rxIsLogin, to: rxIsLogin )
        }
    }
    
    override open func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        preconditionFailure( "There is no such view model \(id)" )
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

open class SBIPageViewModel: SBIViewModel, SBPagesViewModel
{
    open var pageViewModelsArray: [SBViewModel] { preconditionFailure( "You hate implement the pageViewModelsArray property" ) }
    
    public let rxPageIndex = BehaviorRelay<Int>( value: 0 )
}
