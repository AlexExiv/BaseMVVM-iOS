//
//  SBCollectionDataProvider.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 22.04.2022.
//  Copyright © 2022 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

public protocol SBCollectionSectionProtocol
{
    associatedtype K: Hashable
    associatedtype VM: SBDiffEntity
    
    var count: Int { get }
    var indices: [K] { get }
    subscript( index: K ) -> [VM] { get }
}

public struct SBArrayCollectionSection<VM: SBDiffEntity>: SBCollectionSectionProtocol
{
    let items: [[VM]]
    public let indices: [Int]
    
    public var count: Int { items.count }
    
    public init( items: [[VM]] )
    {
        self.items = items
        self.indices = Array( items.indices )
    }
    
    public subscript( index: Int ) -> [VM]
    {
        items[index]
    }
}

public struct SBMapCollectionSection<K: Hashable, VM: SBDiffEntity>: SBCollectionSectionProtocol
{
    let items: [K: [VM]]
    public let indices: [K]
    
    public var count: Int { items.count }
    
    public init( items: [K: [VM]], indices: [K] )
    {
        self.items = items
        self.indices = indices
    }
    
    public subscript( index: K ) -> [VM]
    {
        items[index]!
    }
}

public struct SBPairCollectionSection<HVM, VM: SBDiffEntity>: SBCollectionSectionProtocol
{
    let items: [(HVM, [VM])]
    public let indices: [Int]
    
    public var count: Int { items.count }
    
    public init( items: [(HVM, [VM])] )
    {
        self.items = items
        self.indices = Array( items.indices )
    }
    
    public subscript( index: Int ) -> [VM]
    {
        items[index].1
    }
}


public class SBCollectionDataProvider<CollectionSection: SBCollectionSectionProtocol>
{
    public typealias VM = CollectionSection.VM
    
    public private(set) var items: CollectionSection? = nil
    private var swapItems: CollectionSection? = nil
    public private(set) var startReload = true
    
    private(set) var changedItems: [SBDiffItem] = []
    private(set) var insertedItems: [SBDiffItem] = []
    private(set) var movedItems: [SBDiffItem] = []
    private(set) var deletedItems: [SBDiffItem] = []
    
    let logging: Bool
    
    public var indices: [CollectionSection.K]
    {
        items?.indices ?? []
    }
    
    public var count: Int
    {
        items?.count ?? 0
    }
    
    public init( logging: Bool = false )
    {
        self.logging = logging
    }
    
    public subscript( index: CollectionSection.K ) -> [VM]
    {
        items![index]
    }
    
    public func Set( items: CollectionSection )
    {
        self.items = items
        startReload = false
    }
    
    public func CalculateChanges( newItems: CollectionSection )
    {
        guard let oldItems = items else {
            Set( items: newItems )
            return
        }
                
        var wasItems = [Int: [Int: Bool]]()
        for secOInd in 0..<oldItems.indices.count
        {
            let secO = oldItems.indices[secOInd]
            for o in 0..<oldItems[secO].count
            {
                let item = CheckItems( oldItems: oldItems, newItems: newItems, oldSec: secOInd, oldI: o )
                switch item.state
                {
                case .changed:
                    changedItems.append( item )
                case .moved, .movedChanged:
                    movedItems.append( item )
                case .deleted:
                    deletedItems.append( item )
                default:
                    break
                }
                
                if item.state != .deleted
                {
                    var w = wasItems[item.newSec] ?? [:]
                    w[item.newI] = true
                    wasItems[item.newSec] = w
                }
            }
        }
        
        for secNInd in 0..<newItems.indices.count
        {
            let secN = newItems.indices[secNInd]
            for n in 0..<newItems[secN].count
            {
                if wasItems[secNInd]?[n] == nil
                {
                    insertedItems.append( SBDiffItem( oldSec: 0, oldI: 0, newSec: secNInd, newI: n, state: .inserted ) )
                }
            }
        }
        
        swapItems = newItems
    }
    
    public func CommitChanges()
    {
        items = swapItems
        swapItems = nil
        
        changedItems.removeAll()
        insertedItems.removeAll()
        movedItems.removeAll()
        deletedItems.removeAll()
    }

    private func CheckItems( oldItems: CollectionSection, newItems: CollectionSection, oldSec: Int, oldI: Int ) -> SBDiffItem
    {
        for secNInd in 0..<newItems.indices.count
        {
            let secN = newItems.indices[secNInd]
            if newItems[secN].count > oldI, let item = CheckItems( oldItems: oldItems, newItems: newItems, oldSec: oldSec, oldI: oldI, newSec: secNInd, newI: oldI )
            {
                return item
            }
            
            for n in 0..<newItems[secN].count
            {
                if let item = CheckItems( oldItems: oldItems, newItems: newItems, oldSec: oldSec, oldI: oldI, newSec: secNInd, newI: n )
                {
                    return item
                }
            }
        }
        
        return SBDiffItem( oldSec: oldSec, oldI: oldI, newSec: 0, newI: 0, state: .deleted )
    }
    
    private func CheckItems( oldItems: CollectionSection, newItems: CollectionSection, oldSec: Int, oldI: Int, newSec: Int, newI: Int ) -> SBDiffItem?
    {
        let olds = oldItems[oldItems.indices[oldSec]]
        let news = newItems[newItems.indices[newSec]]
        let old = olds[oldI]
        let new = news[newI]

        if old.IsTheSame( entity: new )
        {
            var state = SBDiffState.nothing
            if oldSec == newSec && oldI == newI
            {
                if old.IsContentChanged( entity: new )
                {
                    state = .changed
                }
            }
            else
            {
                state = old.IsContentChanged( entity: new ) ? .movedChanged : .moved
            }
            
            return SBDiffItem( oldSec: oldSec, oldI: oldI, newSec: newSec, newI: newI, state: state )
        }
        
        return nil
    }
}

public typealias SBArrayDataProvider<VM: SBDiffEntity> = SBCollectionDataProvider<SBArrayCollectionSection<VM>>
public typealias SBDictionaryDataProvider<K: Hashable, VM: SBDiffEntity> = SBCollectionDataProvider<SBMapCollectionSection<K, VM>>
public typealias SBPairDataProvider<HVM, VM: SBDiffEntity> = SBCollectionDataProvider<SBPairCollectionSection<HVM, VM>>
