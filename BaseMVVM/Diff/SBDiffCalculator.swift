//
//  SBDiffEntityProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

public protocol SBDiffEntity
{
    func IsTheSame( entity: SBDiffEntity ) -> Bool
    func IsContentChanged( entity: SBDiffEntity ) -> Bool
}

public protocol SBDiffEntitySection
{
    @inlinable subscript( index: Int ) -> [SBDiffEntity] { get }
    var count: Int { get }
}

enum SBDiffState
{
    case nothing, inserted, moved, movedChanged, changed, deleted
}

struct SBDiffItem
{
    let oldSec: Int
    let oldI: Int
    
    let newSec: Int
    let newI: Int
    
    let state: SBDiffState
    
    var description: String
    {
        return "[OLD: (\(oldSec), \(oldI)), NEW: (\(newSec), \(newI)), STATE: \(state)]"
    }
}

struct SBDefaultSection: SBDiffEntitySection
{
    let items: [[SBDiffEntity]]
    
    subscript(index: Int) -> [SBDiffEntity]
    {
        return items[index]
    }
    
    var count: Int
    {
        return items.count
    }
}

public class SBDiffCalculator
{
    private(set) var oldItems: SBDiffEntitySection
    private(set) var newItems: SBDiffEntitySection
    
    private(set) var changedItems: [SBDiffItem] = []
    private(set) var insertedItems: [SBDiffItem] = []
    private(set) var movedItems: [SBDiffItem] = []
    private(set) var deletedItems: [SBDiffItem] = []
    
    public init( oldItems: SBDiffEntitySection, newItems: SBDiffEntitySection )
    {
        self.oldItems = oldItems
        self.newItems = newItems
    }
    
    public convenience init( oldItems: [[SBDiffEntity]], newItems: [[SBDiffEntity]] )
    {
        self.init( oldItems: SBDefaultSection( items: oldItems ), newItems: SBDefaultSection( items: newItems ) )
    }
    
    public convenience init( oldItems: [SBDiffEntity], newItems: [SBDiffEntity] )
    {
        self.init( oldItems: [oldItems], newItems: [newItems] )
    }
    
    public func Calc()
    {
        var wasItems = [Int: [Int: Bool]]()
        for secO in 0..<oldItems.count
        {
            for o in 0..<oldItems[secO].count
            {
                let item = CheckItems( oldSec: secO, oldI: o )
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
        
        for secN in 0..<newItems.count
        {
            for n in 0..<newItems[secN].count
            {
                if wasItems[secN]?[n] == nil
                {
                    insertedItems.append( SBDiffItem( oldSec: 0, oldI: 0, newSec: secN, newI: n, state: .inserted ) )
                }
            }
        }
    }
    
    public func AsyncCalc( _ completion: @escaping (SBDiffCalculator) -> Void )
    {
        DispatchQueue.global().async
        {
            self.Calc()
            DispatchQueue.main.async
            {
                completion( self )
            }
        }
    }
    
    func CheckItems( oldSec: Int, oldI: Int ) -> SBDiffItem
    {
        for secN in 0..<newItems.count
        {
            if newItems[secN].count > oldI, let item = CheckItems( oldSec: oldSec, oldI: oldI, newSec: secN, newI: oldI )
            {
                return item
            }
            
            for n in 0..<newItems[secN].count
            {
                if let item = CheckItems( oldSec: oldSec, oldI: oldI, newSec: secN, newI: n )
                {
                    return item
                }
            }
        }
        
        return SBDiffItem( oldSec: oldSec, oldI: oldI, newSec: 0, newI: 0, state: .deleted )
    }
    
    func CheckItems( oldSec: Int, oldI: Int, newSec: Int, newI: Int ) -> SBDiffItem?
    {
        let olds = oldItems[oldSec]
        let news = newItems[newSec]
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
