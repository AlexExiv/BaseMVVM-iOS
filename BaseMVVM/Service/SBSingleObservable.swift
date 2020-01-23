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

public class SBSingleObservable<Entity: SBEntity>: SBEntityObservable<Entity>, ObservableType
{
    public typealias Element = Entity
    
    let rxRefresh = PublishRelay<Bool>()
    let rxPublish = BehaviorSubject<Entity?>( value: nil )
    
    public var entity: Entity?
    {
        return try! rxPublish.value()
    }
    
    public init( holder: SBEntityObservableCollection<Entity>, observeOn: ImmediateSchedulerType, fetch: @escaping () -> Single<Entity> )
    {
        super.init( holder: holder )
        
        weak var _self = self
        rxRefresh
            .do( onNext: { _ in _self?.rxLoader.accept( true ) } )
            .flatMapLatest { _ in fetch() }
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
        
        Refresh()
    }
    
    override func Update( source: String, entity: Entity )
    {
        if let key = self.entity?.key, key == entity.key, source != uuid
        {
            rxPublish.onNext( entity )
        }
    }
    
    override func Update( source: String, entities: [SBEntityKey: Entity] )
    {
        if let key = entity?.key, let entity = entities[key], source != uuid
        {
            rxPublish.onNext( entity )
        }
    }
    
    public func Refresh()
    {
        rxRefresh.accept( true )
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
