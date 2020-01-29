//
//  SBArrayObservable.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 29/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

import Foundation
import RxSwift
import RxRelay

public let PAGINATOR_END = -1000

public struct SBPageParams<Extra>
{
    public let page: Int
    public let perPage: Int
    public let refreshing: Bool
    public let resetCache: Bool
    public let first: Bool
    public let extra: Extra?
    
    init( page: Int, perPage: Int, refreshing: Bool = false, resetCache: Bool = false, first: Bool = false, extra: Extra? = nil )
    {
        self.page = page
        self.perPage = perPage
        self.refreshing = refreshing
        self.resetCache = resetCache
        self.first = first
        self.extra = extra
    }
}

public class SBArrayObservableExtra<Entity: SBEntity, Extra>: SBEntityObservable<Entity>, ObservableType
{
    public typealias Element = [Entity]
    
    let rxPublish = BehaviorSubject<Element?>( value: nil )
    let rxPage = PublishRelay<SBPageParams<Extra>>()
    let queue: OperationQueueScheduler

    public private(set) var page = -1
    public private(set) var perPage = 999999
    public private(set) var extra: Extra? = nil
    
    var started = false
    
    public var entities: [Entity]?
    {
        return try! rxPublish.value()
    }
    
    public var entitiesNotNil: [Entity]
    {
        return entities ?? []
    }
        
    init( holder: SBEntityObservableCollection<Entity>, extra: Extra? = nil, perPage: Int = 999999, start: Bool = true, observeOn: OperationQueueScheduler, fetch: @escaping (SBPageParams<Extra>) -> Single<Element> )
    {
        self.queue = observeOn
        self.extra = extra
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

        if start
        {
            started = true
            rxPage.accept( SBPageParams( page: 0, perPage: perPage, first: true, extra: extra ) )
        }
    }
    
    override func Update( source: String, entity: Entity )
    {
        assert( queue.operationQueue == OperationQueue.current, "Paginator observable can be updated only from the same queue with the parent collection" )
        
        if var entities = self.entities, let i = entities.firstIndex( where: { entity.key == $0.key } ), source != uuid
        {
            entities[i] = entity
            rxPublish.onNext( entities )
        }
    }
    
    override func Update( source: String, entities: [SBEntityKey: Entity] )
    {
        assert( queue.operationQueue == OperationQueue.current, "Paginator observable can be updated only from the same queue with the parent collection" )
        
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
    
    public func Refresh( resetCache: Bool = false, extra: Extra? = nil )
    {
        Single<Bool>.create
            {
                [weak self] in
                
                self?._Refresh( resetCache: resetCache, extra: extra )
                $0( .success( true ) )
                return Disposables.create()
            }
            .observeOn( queue )
            .subscribeOn( queue )
            .subscribe()
            .disposed( by: dispBag )
    }
    
    func _Refresh( resetCache: Bool = false, extra: Extra? = nil )
    {
        assert( queue.operationQueue == OperationQueue.current, "_Refresh can be updated only from the specified in the constructor OperationQueue" )
        
        self.extra = extra ?? self.extra
        page = -1
        rxPublish.onNext( [] )
        rxPage.accept( SBPageParams( page: page + 1, perPage: perPage, refreshing: true, resetCache: resetCache, first: !started, extra: self.extra ) )
        started = true
    }
    
    override func RefreshData( resetCache: Bool )
    {
        _Refresh( resetCache: resetCache )
    }
    
    func Append( entities: [Entity] ) -> [Entity]
    {
        assert( queue.operationQueue == OperationQueue.current, "Append can be updated only from the specified in the constructor OperationQueue" )
        page = PAGINATOR_END
        return entities
    }
    
    func Set( page: Int )
    {
        self.page = page
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

public typealias SBArrayObservable<Entity: SBEntity> = SBArrayObservableExtra<Entity, SBEntityExtraParamsEmpty>

extension ObservableType
{
    public func bind<Entity: SBEntity>( refresh: SBArrayObservableExtra<Entity, Element>, resetCache: Bool = false ) -> Disposable
    {
        return observeOn( refresh.queue )
            .subscribe( onNext: { refresh._Refresh( resetCache: resetCache, extra: $0 ) } )
    }
}
