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
    
    public func Bind( loader: BehaviorRelay<Bool> )
    {
        rxLoader.bind( to: loader ).disposed( by: dispBag )
    }
    
    public func Bind( error: PublishRelay<Error> )
    {
        rxError.bind( to: error ).disposed( by: dispBag )
    }
    
    func Update( source: String, entity: Entity )
    {
        
    }
    
    func Update( source: String, entities: [SBEntityKey: Entity] )
    {
        
    }
}
