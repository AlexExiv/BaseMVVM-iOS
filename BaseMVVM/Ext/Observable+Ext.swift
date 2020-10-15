//
//  Observable+Ext.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15.10.2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

extension ObservableType
{
    public func bindDistinct( to relay: BehaviorRelay<Element>, compare: @escaping (Element, Element) -> Bool ) -> Disposable
    {
        subscribe( onNext:
            {
                if !compare( $0, relay.value )
                {
                    relay.accept( $0 )
                }
            } )
    }
}

extension ObservableType where Element: Equatable
{
    public func bindDistinct( to relay: BehaviorRelay<Element> ) -> Disposable
    {
        bindDistinct( to: relay, compare: { $0 == $1 } )
    }
}

extension ObservableType where Element == Float
{
    public func bindDistinct( to relay: BehaviorRelay<Element>, eps: Float = 0.001 ) -> Disposable
    {
        bindDistinct( to: relay, compare: { abs( $0 - $1 ) < eps } )
    }
}

extension ObservableType where Element == Double
{
    public func bindDistinct( to relay: BehaviorRelay<Element>, eps: Double = 0.001 ) -> Disposable
    {
        bindDistinct( to: relay, compare: { abs( $0 - $1 ) < eps } )
    }
}
