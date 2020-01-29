//
//  SBEntityObservableCollection.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 25/11/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

struct SBWeakObjectObservable<Entity: SBEntity>
{
    weak var ref: SBEntityObservable<Entity>?
}

open class SBEntityObservableCollection<Entity: SBEntity>
{
    var items = [SBWeakObjectObservable<Entity>]()
    var sharedEntities = [SBEntityKey: Entity]()
    
    let queue: OperationQueueScheduler
    let dispBag = DisposeBag()
    
    public convenience init( operationQueue: OperationQueue )
    {
        self.init( queue: OperationQueueScheduler( operationQueue: operationQueue ) )
    }
    
    public init( queue: OperationQueueScheduler )
    {
        self.queue = queue
        self.queue.operationQueue.maxConcurrentOperationCount = 1
    }
    
    func Add( object: SBEntityObservable<Entity> )
    {
        items.append( SBWeakObjectObservable( ref: object ) )
    }
    
    func Remove( object: SBEntityObservable<Entity> )
    {
        items.removeAll( where: { object.uuid == $0.ref?.uuid } )
    }
    
    public func CreateSingle( start: Bool = true, _ fetch: @escaping (SBSingleParams<SBEntityExtraParamsEmpty>) -> Single<Entity> ) -> SBSingleObservable<Entity>
    {
        return SBSingleObservable<Entity>( holder: self, start: start, observeOn: queue, fetch: fetch )
    }
    
    public func CreateSingleExtra<Extra>( extra: Extra? = nil, start: Bool = true, _ fetch: @escaping (SBSingleParams<Extra>) -> Single<Entity> ) -> SBSingleObservableExtra<Entity, Extra>
    {
        return SBSingleObservableExtra<Entity, Extra>( holder: self, extra: extra, start: start, observeOn: queue, fetch: fetch )
    }
    
    public func CreateArray( start: Bool = true, _ fetch: @escaping (SBPageParams<SBEntityExtraParamsEmpty>) -> Single<[Entity]> ) -> SBArrayObservable<Entity>
    {
        return SBArrayObservableExtra<Entity, SBEntityExtraParamsEmpty>( holder: self, start: start, observeOn: queue, fetch: fetch )
    }
    
    public func CreateArrayExtra<Extra>( extra: Extra? = nil, start: Bool = true, _ fetch: @escaping (SBPageParams<Extra>) -> Single<[Entity]> ) -> SBArrayObservableExtra<Entity, Extra>
    {
        return SBArrayObservableExtra<Entity, Extra>( holder: self, extra: extra, start: start, observeOn: queue, fetch: fetch )
    }
    
    public func CreatePaginator( perPage: Int = 35, start: Bool = true, _ fetch: @escaping (SBPageParams<SBEntityExtraParamsEmpty>) -> Single<[Entity]> ) -> SBPaginatorObservable<Entity>
    {
        return SBPaginatorObservableExtra<Entity, SBEntityExtraParamsEmpty>( holder: self, perPage: perPage, start: start, observeOn: queue, fetch: fetch )
    }
    
    public func CreatePaginatorExtra<Extra>( extra: Extra? = nil, perPage: Int = 35, start: Bool = true, _ fetch: @escaping (SBPageParams<Extra>) -> Single<[Entity]> ) -> SBPaginatorObservableExtra<Entity, Extra>
    {
        return SBPaginatorObservableExtra<Entity, Extra>( holder: self, extra: extra, perPage: perPage, start: start, observeOn: queue, fetch: fetch )
    }
    
    public func RxRequestForUpdate( source: String = "", key: SBEntityKey, update: @escaping (Entity) -> Entity ) -> Single<Entity?>
    {
        return Single.create
            {
                [weak self] in
                
                if let entity = self?.sharedEntities[key]
                {
                    let new = update( entity )
                    self?.Update( source: source, entity: update( entity ) )
                    $0( .success( new ) )
                }
                else
                {
                    $0( .success( nil ) )
                }
                
                return Disposables.create()
            }
            .observeOn( queue )
            .subscribeOn( queue )
    }
    
    public func RxRequestForUpdate( source: String = "", keys: [SBEntityKey], update: @escaping (Entity) -> Entity ) -> Single<[Entity]>
    {
        return Single.create
            {
                [weak self] in
                
                var updArr = [Entity](), updMap = [SBEntityKey: Entity]()
                keys.forEach
                {
                    if let entity = self?.sharedEntities[$0]
                    {
                        let new = update( entity )
                        self?.sharedEntities[$0] = new
                        updArr.append( new )
                        updMap[$0] = new
                    }
                }
                
                self?.items.forEach { $0.ref?.Update( source: source, entities: updMap ) }
                $0( .success( updArr ) )
                return Disposables.create()
            }
            .observeOn( queue )
            .subscribeOn( queue )
    }
    
    public func RxRequestForUpdate( source: String = "", update: @escaping (Entity) -> Entity ) -> Single<[Entity]>
    {
        return RxRequestForUpdate( source: source, keys: sharedEntities.keys.map { $0 }, update: update )
    }
    
    public func RxRequestForUpdate<EntityS: SBEntity>( source: String = "", entities: [SBEntityKey: EntityS], underPathes: [KeyPath<Entity, SBEntity>], update: @escaping (Entity, EntityS) -> Entity ) -> Single<[Entity]>
    {
        return Single.create
            {
                [weak self] in
                
                var updArr = [Entity](), updMap = [SBEntityKey: Entity]()
                let Update: (Entity, EntityS) -> Void = {
                    let new = update( $0, $1 )
                    self?.sharedEntities[$0.key] = new
                    updArr.append( new )
                    updMap[$0.key] = new
                }
                self?.sharedEntities.forEach
                {
                    e0 in
                    
                    underPathes.forEach
                    {
                        if let v = e0.value[keyPath: $0] as? EntityS, let es = entities[v.key]
                        {
                            Update( e0.value, es )
                        }
                        else if let arr = e0.value[keyPath: $0] as? [EntityS]
                        {
                            arr.forEach
                            {
                                e1 in
                                if let es = entities[e1.key]
                                {
                                    Update( e0.value, es )
                                }
                            }
                        }
                    }
                }
                
                self?.items.forEach { $0.ref?.Update( source: source, entities: updMap ) }
                $0( .success( updArr ) )
                return Disposables.create()
            }
            .observeOn( queue )
            .subscribeOn( queue )
    }
    
    public func RxUpdate( source: String = "", entity: Entity ) -> Single<Entity>
    {
        return Single.create
            {
                [weak self] in
                
                self?.Update( source: source, entity: entity )
                $0( .success( entity ) )
                
                return Disposables.create()
            }
            .observeOn( queue )
            .subscribeOn( queue )
    }
    
    public func RxUpdate( source: String = "", entities: [Entity] ) -> Single<[Entity]>
    {
        return Single.create
            {
                [weak self] in
                
                self?.Update( source: source, entities: entities )
                $0( .success( entities ) )
                
                return Disposables.create()
            }
            .observeOn( queue )
            .subscribeOn( queue )
    }
    
    open func Update( source: String = "", entity: Entity )
    {
        assert( queue.operationQueue == OperationQueue.current, "Observable objects collection can be updated only from the specified in the constructor OperationQueue" )
        
        sharedEntities[entity.key] = entity
        items.forEach { $0.ref?.Update( source: source, entity: entity ) }
    }
    
    open func Update( source: String = "", entities: [Entity] )
    {
        assert( queue.operationQueue == OperationQueue.current, "Observable objects collection can be updated only from the specified in the constructor OperationQueue" )
        
        entities.forEach { sharedEntities[$0.key] = $0 }
        items.forEach { $0.ref?.Update( source: source, entities: self.sharedEntities ) }
    }
    
    public func DispatchUpdates<EntityS: SBEntity>( to: SBEntityObservableCollection, withPathes: [KeyPath<EntityS, SBEntity>] )
    {
        
    }
    
    public func DispatchUpdates<V>( to: SBEntityObservableCollection, fromPathes: [KeyPath<Entity, V>], apply: (V) -> Entity )
    {
        
    }
    
    public func Refresh( resetCache: Bool = false )
    {
        Single<Bool>.create
            {
                [weak self] in
                
                self?._Refresh( resetCache: resetCache )
                $0( .success( true ) )
                
                return Disposables.create()
            }
            .subscribeOn( queue )
            .observeOn( queue )
            .subscribe()
            .disposed( by: dispBag )
    }
    
    func _Refresh( resetCache: Bool = false )
    {
        assert( queue.operationQueue == OperationQueue.current, "_Refresh can be called only from the specified in the constructor OperationQueue" )
        items.forEach { $0.ref?.RefreshData( resetCache: resetCache ) }
    }
}

extension ObservableType
{
    func bind<Entity: SBEntity>( refresh: SBEntityObservableCollection<Entity>, resetCache: Bool = false ) -> Disposable
    {
        return observeOn( refresh.queue )
            .subscribe( onNext: { _ in refresh._Refresh( resetCache: resetCache ) } )
    }
}
