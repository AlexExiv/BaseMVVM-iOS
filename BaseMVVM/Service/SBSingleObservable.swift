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
    public let first: Bool
    public let extra: Extra?
    
    init( refreshing: Bool = false, first: Bool = false, extra: Extra? = nil )
    {
        self.refreshing = refreshing
        self.first = first
        self.extra = extra
    }
}

public class SBSingleObservableExtra<Entity: SBEntity, Extra>: SBEntityObservable<Entity>, ObservableType
{
    public typealias Element = Entity
    
    public let rxRefresh = PublishRelay<Extra?>()
    let _rxRefresh = PublishRelay<SBSingleParams<Extra>>()
    let rxPublish = BehaviorSubject<Entity?>( value: nil )
    
    public private(set) var extra: Extra? = nil
    
    public var entity: Entity?
    {
        return try! rxPublish.value()
    }
    
    public init( holder: SBEntityObservableCollection<Entity>, extra: Extra? = nil, observeOn: ImmediateSchedulerType, fetch: @escaping (SBSingleParams<Extra>) -> Single<Entity> )
    {
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
        
        _rxRefresh.accept( SBSingleParams( first: true, extra: extra ) )
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
    
    public func Refresh( extra: Extra? = nil )
    {
        self.extra = extra ?? self.extra
        _rxRefresh.accept( SBSingleParams( refreshing: true, extra: self.extra ) )
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
    public func bind<Entity: SBEntity>( refresh: SBSingleObservableExtra<Entity, Element> ) -> Disposable
    {
        return bind( to: refresh.rxRefresh )
    }
}
