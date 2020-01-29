//
//  SBSingleObservable.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 22/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public struct SBSingleParams<Extra>
{
    public let refreshing: Bool
    public let resetCache: Bool
    public let first: Bool
    public let extra: Extra?
    
    init( refreshing: Bool = false, resetCache: Bool = false, first: Bool = false, extra: Extra? = nil )
    {
        self.refreshing = refreshing
        self.resetCache = resetCache
        self.first = first
        self.extra = extra
    }
}

public class SBSingleObservableExtra<Entity: SBEntity, Extra>: SBEntityObservable<Entity>, ObservableType
{
    public typealias Element = Entity
    
    let queue: OperationQueueScheduler
    let _rxRefresh = PublishRelay<SBSingleParams<Extra>>()
    let rxPublish = BehaviorSubject<Entity?>( value: nil )
    
    public private(set) var extra: Extra? = nil
    var started = false
    
    public var entity: Entity?
    {
        return try! rxPublish.value()
    }
    
    init( holder: SBEntityObservableCollection<Entity>, extra: Extra? = nil, start: Bool = true, observeOn: OperationQueueScheduler, fetch: @escaping (SBSingleParams<Extra>) -> Single<Entity> )
    {
        self.queue = observeOn
        self.extra = extra
        
        super.init( holder: holder )
        
        weak var _self = self
        _rxRefresh
            .do( onNext: { _ in _self?.rxLoader.accept( true ) } )
            .flatMapLatest { fetch( $0 ) }
            .catchError
            {
                e -> Observable<Entity> in
                _self?.rxError.accept( e )
                _self?.rxLoader.accept( false )
                return Observable.empty()
            }
            .do( onNext: { _ in _self?.rxLoader.accept( false ) } )
            .flatMapLatest { _self?.collection?.RxUpdate( entity: $0 ).asObservable() ?? Observable.empty() }
            .observeOn( observeOn )
            .bind( to: rxPublish )
            .disposed( by: dispBag )
        
        if start
        {
            started = true
            _rxRefresh.accept( SBSingleParams( first: true, extra: extra ) )
        }
    }
    
    override func Update( source: String, entity: Entity )
    {
        assert( queue.operationQueue == OperationQueue.current, "Single observable can be updated only from the same queue with the parent collection" )
        
        if let key = self.entity?.key, key == entity.key, source != uuid
        {
            rxPublish.onNext( entity )
        }
    }
    
    override func Update( source: String, entities: [SBEntityKey: Entity] )
    {
        assert( queue.operationQueue == OperationQueue.current, "Single observable can be updated only from the same queue with the parent collection" )
        
        if let key = entity?.key, let entity = entities[key], source != uuid
        {
            rxPublish.onNext( entity )
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
            .subscribeOn( queue )
            .observeOn( queue )
            .subscribe()
            .disposed( by: dispBag )
    }
    
    public func _Refresh( resetCache: Bool = false, extra: Extra? = nil )
    {
        assert( queue.operationQueue == OperationQueue.current, "_Refresh can be updated only from the specified in the constructor OperationQueue" )
        
        self.extra = extra ?? self.extra
        _rxRefresh.accept( SBSingleParams( refreshing: true, resetCache: resetCache, first: !started, extra: self.extra ) )
        started = true
    }
    
    override func RefreshData( resetCache: Bool )
    {
        _Refresh( resetCache: resetCache )
    }
    
    //MARK: - ObservableType
    public func subscribe<Observer: ObserverType>( _ observer: Observer ) -> Disposable where Observer.Element == Element
    {
        return rxPublish
            .filter { $0 != nil }
            .map { $0! }
            .subscribe( observer )
    }
    
    public func asObservable() -> Observable<Entity>
    {
        return rxPublish
            .filter { $0 != nil }
            .map { $0! }
            .asObservable()
    }
}

public typealias SBSingleObservable<Entity: SBEntity> = SBSingleObservableExtra<Entity, SBEntityExtraParamsEmpty>

extension ObservableType
{
    public func bind<Entity: SBEntity>( refresh: SBSingleObservableExtra<Entity, Element>, resetCache: Bool = false ) -> Disposable
    {
        return observeOn( refresh.queue )
            .subscribe( onNext: { refresh._Refresh( resetCache: resetCache, extra: $0 ) } )
    }
}
