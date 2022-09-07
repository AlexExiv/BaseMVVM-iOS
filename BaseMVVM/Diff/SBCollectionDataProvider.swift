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
    associatedtype H
    associatedtype VM: SBDiffEntity
    
    var count: Int { get }
    var indices: [K] { get }
    
    subscript( index: K ) -> (header: H, items: [VM]) { get }
}

public struct SBArrayCollectionSection<VM: SBDiffEntity>: SBCollectionSectionProtocol
{
    let items: [[VM]]
    public var count: Int { items.count }
    public let indices: [Int]
    
    public init( items: [[VM]] )
    {
        self.items = items
        self.indices = Array( items.indices )
    }
    
    public subscript( index: Int ) -> (header: Int, items: [VM])
    {
        (index, items[index])
    }
}

public struct SBMapCollectionSection<K: Hashable, VM: SBDiffEntity>: SBCollectionSectionProtocol
{
    let items: [K: [VM]]
    public var count: Int { items.count }
    public let indices: [K]
    
    public init( items: [K: [VM]], indices: [K] )
    {
        self.items = items
        self.indices = indices
    }
    
    public subscript( index: K ) -> (header: K, items: [VM])
    {
        (index, items[index]!)
    }
}

public struct SBPairCollectionSection<HVM, VM: SBDiffEntity>: SBCollectionSectionProtocol
{
    let items: [(HVM, [VM])]
    public var count: Int { items.count }
    public let indices: [Int]
    
    public init( items: [(HVM, [VM])] )
    {
        self.items = items
        self.indices = Array( items.indices )
    }
    
    public subscript( index: Int ) -> (header: HVM, items: [VM])
    {
        items[index]
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
    
    private(set) var insertedSections: [Int] = []
    private(set) var deleteSections: [Int] = []
    
    let reverse: Bool
    let logging: Bool
    
    public var indices: [CollectionSection.K]
    {
        items?.indices ?? []
    }
    
    public var count: Int
    {
        items?.count ?? 0
    }
    
    public init( reverse: Bool = false, logging: Bool = false )
    {
        self.reverse = reverse
        self.logging = logging
    }
    
    public subscript( index: CollectionSection.K ) -> (header: CollectionSection.H, items: [VM])
    {
        items![index]
    }
    
    public func Set( items: CollectionSection )
    {
        if items.count == 0
        {
            return
        }
        
        self.items = items
        startReload = false
    }
    
    public func CalculateChanges( newItems: CollectionSection )
    {
        if newItems.count == 0 && items == nil
        {
            return
        }
        
        guard let oldItems = items else
        {
            Set( items: newItems )
            return
        }
        
        if newItems.count > oldItems.count
        {
            if reverse
            {
                insertedSections.append( contentsOf: (0..<(newItems.count - oldItems.count)) )
            }
            else
            {
                insertedSections.append( contentsOf: (oldItems.count..<newItems.count) )
            }
        }
        else if newItems.count < oldItems.count
        {
            deleteSections.append( contentsOf: (newItems.count..<oldItems.count) )
        }
     
        var wasItems = [Int: [Int: Bool]]()
        for secOInd in 0..<oldItems.indices.count
        {
            let secO = oldItems.indices[secOInd]
            for o in 0..<oldItems[secO].items.count
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
            for n in 0..<newItems[secN].items.count
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
        
        insertedSections.removeAll()
        deleteSections.removeAll()
    }

    private func CheckItems( oldItems: CollectionSection, newItems: CollectionSection, oldSec: Int, oldI: Int ) -> SBDiffItem
    {
        for secNInd in 0..<newItems.indices.count
        {
            let secN = newItems.indices[secNInd]
            if newItems[secN].items.count > oldI, let item = CheckItems( oldItems: oldItems, newItems: newItems, oldSec: oldSec, oldI: oldI, newSec: secNInd, newI: oldI )
            {
                return item
            }
            
            for n in 0..<newItems[secN].items.count
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
        let old = olds.items[oldI]
        let new = news.items[newI]

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
