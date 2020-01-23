//
//  SBPaginatorObservable.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 22/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public let PAGINATOR_END = -1000

public struct SBPageParams
{
    let page: Int
    let perPage: Int
    let refreshing: Bool
    let first: Bool
    
    init( page: Int, perPage: Int, refreshing: Bool = false, first: Bool = false )
    {
        self.page = page
        self.perPage = perPage
        self.refreshing = refreshing
        self.first = first
    }
}

public class SBPaginatorObservable<Entity: SBEntity>: SBEntityObservable<Entity>, ObservableType
{
    public typealias Element = [Entity]
    
    let rxPublish = BehaviorSubject<Element?>( value: nil )
    let rxPage = PublishRelay<SBPageParams>()

    public private(set) var page = -1
    public private(set) var perPage = 30
    
    public var entities: [Entity]?
    {
        return try! rxPublish.value()
    }
    
    public var entitiesNotNil: [Entity]
    {
        return entities ?? []
    }
        
    public init( holder: SBEntityObservableCollection<Entity>, perPage: Int = 30, observeOn: ImmediateSchedulerType, fetch: @escaping (SBPageParams) -> Single<Element> )
    {
        self.perPage = perPage
        super.init( holder: holder )
        
        weak var _self = self
        rxPage
            .filter { $0.page >= 0 }
            .do( onNext: { _ in _self?.rxLoader.accept( true ) } )
            .flatMapLatest( { fetch( $0 ) } )
            .catchError
            {
                _self?.rxError.accept( $0 )
                return Observable.just( [] )
            }
            .flatMap( { _self?.collection?.RxUpdate( source: _self?.uuid ?? "", entities: $0 ) ?? Single.just( [] ) } )
            .observeOn( observeOn )
            .map( { _self?.Append( entities: $0 ) ?? [] } )
            .do( onNext: { _ in _self?.rxLoader.accept( false ) } )
            .bind( to: rxPublish )
            .disposed( by: dispBag )
        
        rxPage.accept( SBPageParams( page: 0, perPage: perPage, first: true ) )
    }
    
    override func Update( source: String, entity: Entity )
    {
        if var entities = self.entities, let i = entities.firstIndex( where: { entity.key == $0.key } ), source != uuid
        {
            entities[i] = entity
            rxPublish.onNext( entities )
        }
    }
    
    override func Update( source: String, entities: [SBEntityKey: Entity] )
    {
        guard var _entities = self.entities, source != uuid else { return }
        
        var was = false
        for i in 0..<_entities.count
        {
            let e = _entities[i]
            if let ne = entities[e.key]
            {
                _entities[i] = ne
                was = true
            }
        }
        
        if was
        {
            rxPublish.onNext( _entities )
        }
    }
    
    public func Next()
    {
        rxPage.accept( SBPageParams( page: page + 1, perPage: perPage ) )
    }
    
    public func Refresh()
    {
        page = -1
        rxPublish.onNext( nil )
        rxPage.accept( SBPageParams( page: page + 1, perPage: perPage, refreshing: true ) )
    }

    private func Append( entities: [Entity] ) -> [Entity]
    {
        var _entities = self.entities ?? []
        _entities.append( contentsOf: entities )
        page = entities.count == perPage ? page + 1 : PAGINATOR_END
        return _entities
    }
    
    //MARK: - ObservableType
    public func subscribe<Observer: ObserverType>( _ observer: Observer ) -> Disposable where Observer.Element == Element
    {
        return rxPublish
            .filter { $0 != nil }
            .map { $0! }
            .subscribe( observer )
    }
    
    public func asObservable() -> Observable<Element>
    {
        return rxPublish
            .filter { $0 != nil }
            .map { $0! }
            .asObservable()
    }
}
