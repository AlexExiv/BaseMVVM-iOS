//
//  FBindProtocol.swift
//  Speaker Box Lite
//
//  Created by ALEXEY ABDULIN on 06/03/2019.
//  Copyright © 2019 Алексей Абдулин. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public protocol SBBindProtocol
{
    var dispBag: DisposeBag { get }
    var bindScheduler: SchedulerType { get }
}

public extension SBBindProtocol
{
    func BindT<V, T> ( from: BehaviorRelay<V>, to: BehaviorRelay<T>, map: @escaping (V) -> T, dispBag: DisposeBag? = nil )
    {
        BindT( from: from.asObservable(), to: to, map: map, dispBag: dispBag )
    }
    
    func BindT<V, T> ( from: Observable<V>, to: BehaviorRelay<T>, map: @escaping (V) -> T, dispBag: DisposeBag? = nil )
    {
        from
            .observeOn( bindScheduler )
            .map( { map( $0 ) } )
            .bind( to: to )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func Bind<V> ( from: BehaviorRelay<V>, to: BehaviorRelay<V>, dispBag: DisposeBag? = nil )
    {
        BindT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    func Bind<V> ( from: Observable<V>, to: BehaviorRelay<V>, dispBag: DisposeBag? = nil )
    {
        BindT( from: from, to: to, map: { $0 }, dispBag: dispBag )
    }
    
    func BindAction<V> ( from: BehaviorRelay<V>, action: @escaping (V) -> Void, dispBag: DisposeBag? = nil )
    {
        BindAction( from: from.asObservable(), action: action, dispBag: dispBag )
    }
    
    func BindAction<V> ( from: Observable<V>, action: @escaping (V) -> Void, dispBag: DisposeBag? = nil )
    {
        from
            .observeOn( bindScheduler )
            .subscribe( onNext: { action( $0 ) } )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    //MARK: - 2WAY
    func BindT2Way<V: Equatable, T: Equatable> ( from: BehaviorRelay<V>, to: BehaviorRelay<T>, mapFrom: @escaping (V) -> T, mapTo: @escaping (T) -> V, dispBag: DisposeBag? = nil )
    {
        from
            .asObservable()
            .observeOn( bindScheduler )
            .distinctUntilChanged()
            .map( { mapFrom( $0 ) } )
            .bind( to: to )
            .disposed( by: dispBag ?? self.dispBag )
        
        to
            .asObservable()
            .observeOn( bindScheduler )
            .distinctUntilChanged()
            .skip( 1 )
            .map( { mapTo( $0 ) } )
            .filter( { from.value != $0 } )
            .bind( to: from )
            .disposed( by: dispBag ?? self.dispBag )
    }
    
    func Bind2Way<V: Equatable> ( from: BehaviorRelay<V>, to: BehaviorRelay<V>, dispBag: DisposeBag? = nil )
    {
        BindT2Way( from: from, to: to, mapFrom: { $0 }, mapTo: { $0 }, dispBag: dispBag )
    }
}
