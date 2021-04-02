//
//  Inject.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Inject<Component>
{
    var component: Component? = nil
    var lock = NSRecursiveLock()
    var singleton: Bool
    var lazy: Bool
    
    public var wrappedValue: Component
    {
        set { component = newValue }
        mutating get
        {
            if !lazy
            {
                return component!
            }
            
            lock.lock()
            defer { lock.unlock() }
            
            if let c = component
            {
                return c
            }
            
            print( "INIT LAZY" )
            Create()
            return component!
            
        }
    }
    
    public init( singleton: Bool = true, lazy: Bool = false )
    {
        self.singleton = singleton
        self.lazy = lazy
        
        if !lazy
        {
            Create()
        }
    }
    
    mutating func Create()
    {
        component = ComponentsResolver.shared.Provide( type: Component.self, singleton: singleton )
    }
}
