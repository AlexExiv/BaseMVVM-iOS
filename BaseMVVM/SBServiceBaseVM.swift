//
//  SBServiceBaseVM.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 21/08/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

public class SBServiceBaseVM<SF: SBServiceFactoryProtocol>: SBBaseVM
{
    public var serviceParent: SBServiceViewModel<SF>?
    {
        return parent as? SBServiceViewModel<SF>
    }
    
    public init( parent: SBServiceViewModel<SF>? = nil )
    {
        super.init( parent: parent )
    }
    
    public func RxDownloadImage( url: String, width: Int = 0, height: Int = 0 ) -> Single<String>
    {
        return serviceParent!
            .RxDownloadImage( url: url, width: width, height: height )
    }
}
