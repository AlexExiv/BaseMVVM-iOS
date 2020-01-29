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

public class SBPaginatorObservableExtra<Entity: SBEntity, Extra>: SBArrayObservableExtra<Entity, Extra>
{
    public typealias Element = [Entity]
    
    override init( holder: SBEntityObservableCollection<Entity>, extra: Extra? = nil, perPage: Int = 30, start: Bool = true, observeOn: OperationQueueScheduler, fetch: @escaping (SBPageParams<Extra>) -> Single<Element> )
    {
        super.init( holder: holder, extra: extra, perPage: perPage, start: start, observeOn: observeOn, fetch: fetch )
    }

    public func Next()
    {
        if started
        {
            rxPage.accept( SBPageParams( page: page + 1, perPage: perPage, extra: extra ) )
        }
        else
        {
            Refresh()
        }
    }
    
    override func Append( entities: [Entity] ) -> [Entity]
    {
        assert( queue.operationQueue == OperationQueue.current, "Append can be updated only from the specified in the constructor OperationQueue" )
        
        var _entities = self.entities ?? []
        _entities.append( contentsOf: entities )
        Set( page: entities.count == perPage ? page + 1 : PAGINATOR_END )
        return _entities
    }
}

public typealias SBPaginatorObservable<Entity: SBEntity> = SBPaginatorObservableExtra<Entity, SBEntityExtraParamsEmpty>
