//
//  SBDefaultDowloadService.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.02.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

class SBDefaultDowloadService: SBDowloadServiceProtocol
{
    func RxDownload( url: String ) -> Single<String>
    {
        Single.just( "" )
    }
    
    func RxDownloadImage( url: String, width: Int, height: Int ) -> Single<String>
    {
        Single.just( "" )
    }
}
