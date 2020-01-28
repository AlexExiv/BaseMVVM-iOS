//
//  SBObjectObservable.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 22/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public struct SBEntityExtraParamsEmpty
{
    
}

public class SBEntityObservable<Entity: SBEntity>
{
    let rxLoader = BehaviorRelay<Bool>( value: false )
    let rxError = PublishRelay<Error>()
    
    let dispBag = DisposeBag()
    
    public let uuid = UUID().uuidString
    public private(set) weak var collection: SBEntityObservableCollection<Entity>? = nil
    
    init( holder: SBEntityObservableCollection<Entity> )
    {
        self.collection = holder
        holder.Add( object: self )
    }
    
    deinit
    {
        collection?.Remove( object: self )
        print( "EntityObservable has been deleted. UUID - \(uuid)" )
    }

    func Update( source: String, entity: Entity )
    {
        
    }
    
    func Update( source: String, entities: [SBEntityKey: Entity] )
    {
        
    }
}

extension SBEntityObservable
{
    public func bind( loader: BehaviorRelay<Bool> ) -> Disposable
    {
        return rxLoader.bind( to: loader )
    }
    
    public func bind( error: PublishRelay<Error> ) -> Disposable
    {
        return rxError.bind( to: error )
    }
}
