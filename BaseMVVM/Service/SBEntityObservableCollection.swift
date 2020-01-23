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

    public init( queue: OperationQueueScheduler )
    {
        self.queue = queue
        queue.operationQueue.maxConcurrentOperationCount = 1
    }
    
    func Add( object: SBEntityObservable<Entity> )
    {
        items.append( SBWeakObjectObservable( ref: object ) )
    }
    
    func Remove( object: SBEntityObservable<Entity> )
    {
        items.removeAll( where: { object.uuid == $0.ref?.uuid } )
    }
    
    public func CreateSingle( _ fetch: @escaping () -> Single<Entity> ) -> SBSingleObservable<Entity>
    {
        return SBSingleObservable<Entity>( holder: self, observeOn: queue, fetch: fetch )
    }
    
    public func CreatePaginator( perPage: Int = 35, _ fetch: @escaping (Int, Int) -> Single<[Entity]> ) -> SBPaginatorObservable<Entity>
    {
        return SBPaginatorObservable<Entity>( holder: self, perPage: perPage, observeOn: queue, fetch: fetch )
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
        assert( queue.operationQueue == OperationQueue.current, "Observable objects collestion can be updated only from the specified in the constructor OperationQueue" )
        
        sharedEntities[entity.key] = entity
        items.forEach { $0.ref?.Update( source: source, entity: entity ) }
    }
    
    open func Update( source: String = "", entities: [Entity] )
    {
        assert( queue.operationQueue == OperationQueue.current, "Observable objects collestion can be updated only from the specified in the constructor OperationQueue" )
        
        entities.forEach { sharedEntities[$0.key] = $0 }
        items.forEach { $0.ref?.Update( source: source, entities: self.sharedEntities ) }
    }
}
