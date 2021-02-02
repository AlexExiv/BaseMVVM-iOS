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

public extension ObservableType
{
    func bindDistinct( to relay: BehaviorRelay<Element>, compare: @escaping (Element, Element) -> Bool ) -> Disposable
    {
        subscribe( onNext:
            {
                if !compare( $0, relay.value )
                {
                    relay.accept( $0 )
                }
            } )
    }
    
    func bind( loader: BehaviorRelay<String>, message: String ) -> Observable<Element>
    {
        return `do`( onSubscribe: { loader.accept( message ) }, onDispose: { loader.accept( "" ) } )
    }
}

public extension ObservableType where Element: Equatable
{
    func bindDistinct( to relay: BehaviorRelay<Element> ) -> Disposable
    {
        bindDistinct( to: relay, compare: { $0 == $1 } )
    }
}

public extension ObservableType where Element == Float
{
    func bindDistinct( to relay: BehaviorRelay<Element>, eps: Float = 0.001 ) -> Disposable
    {
        bindDistinct( to: relay, compare: { abs( $0 - $1 ) < eps } )
    }
}

public extension ObservableType where Element == Double
{
    func bindDistinct( to relay: BehaviorRelay<Element>, eps: Double = 0.001 ) -> Disposable
    {
        bindDistinct( to: relay, compare: { abs( $0 - $1 ) < eps } )
    }
}

public extension PrimitiveSequenceType where Self.Trait == RxSwift.SingleTrait
{
    func bind( loader: BehaviorRelay<String>, message: String ) -> Single<Element>
    {
        return `do`( onSubscribe: { loader.accept( message ) }, onDispose: { loader.accept( "" ) } )
    }
    
    func bind( loader: BehaviorRelay<Bool> ) -> Single<Element>
    {
        return `do`( onSubscribe: { loader.accept( true ) }, onDispose: { loader.accept( false ) } )
    }
}

