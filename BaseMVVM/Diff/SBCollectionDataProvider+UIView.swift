//
//  SBCollectionDataProvider+UIView.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 12.05.2022.
//  Copyright © 2022 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

extension SBCollectionDataProvider
{
    public func Dispatch( newItems: CollectionSection, to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil )
    {
        if startReload
        {
            Set( items: newItems )
            to.reloadData()
        }
        else
        {
            CalculateChanges( newItems: newItems )
            
            if logging
            {
                print( "CHANGES: - \(changedItems)" )
                print( "MOVES: - \(movedItems)" )
                print( "INSERTS: - \(insertedItems)" )
                print( "DELETES: - \(deletedItems)" )
            }
            
            if #available(iOS 11.0, *)
            {
                to.performBatchUpdates(
                {
                    [weak self] in
                    self?._ProcessUpdates( to: to, change: change, insert: insert, delete: delete, all: all )
                    self?.CommitChanges()
                }, completion: nil )
            }
            else
            {
                to.beginUpdates()
                _ProcessUpdates( to: to, change: change, insert: insert, delete: delete, all: all )
                CommitChanges()
                to.endUpdates()
            }
        }
    }
    
    private func _ProcessUpdates( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil )
    {
        let changeIndeces = changedItems.map { $0.newRow }
        let deleteIndeces = deletedItems.map { $0.oldRow }
        let insertIndeces = insertedItems.map { $0.newRow }
        
        to.reloadRows( at: changeIndeces, with: all ?? change )
        movedItems.forEach
        {
            if deleteIndeces.contains( $0.oldRow ) || deleteIndeces.contains( $0.newRow ) || insertIndeces.contains( $0.newRow ) || insertIndeces.contains( $0.oldRow ) || $0.state == .movedChanged
            {
                to.deleteRows( at: [$0.oldRow], with: .automatic )
                to.insertRows( at: [$0.newRow], with: .automatic )
            }
            else
            {
                //to.reloadRows( at: [$0.oldIndex], with: .none )
                to.moveRow( at: $0.oldRow, to: $0.newRow )
            }
        }
        
        to.deleteRows( at: deleteIndeces, with: all ?? delete )
        to.insertRows( at: insertIndeces, with: all ?? insert )
    }
}


extension SBCollectionDataProvider
{
    public func Dispatch( newItems: CollectionSection, to: UICollectionView )
    {
        if startReload
        {
            Set( items: newItems )
            to.reloadData()
        }
        else
        {
            CalculateChanges( newItems: newItems )
            
            if logging
            {
                print( "CHANGES: - \(changedItems)" )
                print( "MOVES: - \(movedItems)" )
                print( "INSERTS: - \(insertedItems)" )
                print( "DELETES: - \(deletedItems)" )
            }
            
            to.performBatchUpdates(
            {
                [weak self] in
                
                self?._ProcessUpdates( to: to )
                self?.CommitChanges()
            }, completion: nil )
        }
    }
    
    private func _ProcessUpdates( to: UICollectionView )
    {
        let changeIndeces = changedItems.map { $0.newItem }
        let deleteIndeces = deletedItems.map { $0.oldItem }
        let insertIndeces = insertedItems.map { $0.newItem }
        
        to.reloadItems( at: changeIndeces )
        movedItems.forEach
        {
            if deleteIndeces.contains( $0.oldItem ) || deleteIndeces.contains( $0.newItem ) || insertIndeces.contains( $0.newItem ) || insertIndeces.contains( $0.oldItem ) || $0.state == .movedChanged
            {
                to.deleteItems( at: [$0.oldItem] )
                to.insertItems( at: [$0.newItem] )
            }
            else
            {
                //to.reloadRows( at: [$0.oldIndex], with: .none )
                to.moveItem( at: $0.oldItem, to: $0.newItem )
            }
        }
        
        to.deleteItems( at: deleteIndeces )
        to.insertItems( at: insertIndeces )
    }
}
