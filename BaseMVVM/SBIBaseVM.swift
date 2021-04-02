//
//  SBIBaseVM.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

open class SBIBaseVM: SBBaseVM
{
    public var serviceParent: SBIViewModel?
    {
        return parent as? SBIViewModel
    }
    
    public init( parent: SBIViewModel? = nil )
    {
        super.init( parent: parent )
    }
    
    public func RxDownloadImage( url: String, width: Int = 0, height: Int = 0 ) -> Single<String>
    {
        return serviceParent?
            .RxDownloadImage( url: url, width: width, height: height ) ?? Single.just( "" )
    }
}
