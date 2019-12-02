//
//  SBObjectObservableProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 25/11/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

protocol SUObjectObservableProtocol: ObservableConvertibleType
{
    associatedtype Entity: Equatable
    
    var uuid: String { get }
    
    func Bind( loader: BehaviorRelay<Bool> )
    func Bind( error: BehaviorRelay<Error> )
    func Update( entity: Entity )
    func Update( entities: [Entity] )
}

protocol SUPaginatorObservableProtocol: SUObjectObservableProtocol
{
    var data: [Entity] { get }
    
    func Next()
    func Reset()
}

class SUPaginatorObservable<Entity: Equatable>: SUPaginatorObservableProtocol
{
    typealias Element = [Entity]
    
    let rxPublish = PublishRelay<Element>()
    let rxNext = PublishRelay<Int>()
    let rxLoader = BehaviorRelay<Bool>( value: false )
    let rxError = PublishRelay<Error>()
    let dispBag = DisposeBag()
        
    let uuid = UUID().uuidString
    var page = 0
    var perPage = 30
    var data = [Entity]()
    
    init( perPage: Int = 30, observeOn: ImmediateSchedulerType, fetchBlock: @escaping (Int, Int) -> Single<Element> )
    {
        self.perPage = perPage
        
        weak var _self = self
        rxNext
            .do( onNext: { _ in _self?.rxLoader.accept( true ) } )
            .flatMapLatest( { fetchBlock( $0, _self?.perPage ?? 30 ) } )
            .observeOn( observeOn )
            .catchError( {
                _self?.rxError.accept( $0 )
                return Observable.just( [] )
            } )
            .map( { _self?.Append( data: $0 ) ?? [] } )
            .do( onNext: { _ in _self?.rxLoader.accept( false ) } )
            .bind( to: rxPublish )
            .disposed( by: dispBag )
    }
    
    func Next()
    {
        rxNext.accept( page + 1 )
    }
    
    func Reset()
    {
        page = 0
        data.removeAll()
        Next()
    }
    
    func Bind( loader: BehaviorRelay<Bool> )
    {
        rxLoader.bind( to: loader ).disposed( by: dispBag )
    }
    
    func Bind( error: BehaviorRelay<Error> )
    {
        rxError.bind( to: error ).disposed( by: dispBag )
    }
    
    func Update( entity: Entity )
    {
        if let i = data.firstIndex( of: entity )
        {
            data[i] = entity
            rxPublish.accept( data )
        }
    }
    
    func Update( entities: [Entity] )
    {
        var was = false
        for i in 0..<entities.count
        {
            if let j = data.firstIndex( of: entities[i] )
            {
                data[j] = entities[i]
                was = true
            }
        }
        
        if was
        {
            rxPublish.accept( data )
        }
    }
    
    private func Append( data: [Entity] ) -> [Entity]
    {
        self.data.append( contentsOf: data )
        page += 1
        return self.data
    }
    
    //MARK: - ObservableConvertibleType
    func asObservable() -> Observable<Element>
    {
        return rxPublish.asObservable()
    }
}
