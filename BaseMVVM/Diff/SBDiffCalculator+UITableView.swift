//
//  SBDiffCalculator+UITableView.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

extension SBDiffItem
{
    var oldIndex: IndexPath
    {
        return IndexPath( row: oldI, section: oldSec )
    }
    
    var newIndex: IndexPath
    {
        return IndexPath( row: newI, section: newSec )
    }
}

extension SBDiffCalculator
{
    public func Dispatch( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil )
    {
        print( "CHANGES: - \(changedItems)" )
        print( "MOVES: - \(movedItems)" )
        print( "INSERTS: - \(insertedItems)" )
        print( "DELETES: - \(deletedItems)" )

        if #available(iOS 11.0, *)
        {
            to.performBatchUpdates( { [weak self] in self?._ProcessUpdates( to: to, change: change, insert: insert, delete: delete, all: all ) }, completion: nil )
        }
        else
        {
            to.beginUpdates()
            _ProcessUpdates( to: to, change: change, insert: insert, delete: delete, all: all )
            to.endUpdates()
        }
    }
    
    private func _ProcessUpdates( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil )
    {
        let changeIndeces = changedItems.map { $0.newIndex }
        let deleteIndeces = deletedItems.map { $0.oldIndex }
        let insertIndeces = insertedItems.map { $0.newIndex }
        
        to.reloadRows( at: changeIndeces, with: all ?? change )
        movedItems.forEach
        {
            if deleteIndeces.contains( $0.oldIndex ) || deleteIndeces.contains( $0.newIndex ) || insertIndeces.contains( $0.newIndex ) || insertIndeces.contains( $0.oldIndex ) || $0.state == .movedChanged
            {
                to.deleteRows( at: [$0.oldIndex], with: .automatic )
                to.insertRows( at: [$0.newIndex], with: .automatic )
            }
            else
            {
                //to.reloadRows( at: [$0.oldIndex], with: .none )
                to.moveRow( at: $0.oldIndex, to: $0.newIndex )
            }
        }
        
        to.deleteRows( at: deleteIndeces, with: all ?? delete )
        to.insertRows( at: insertIndeces, with: all ?? insert )
    }
}
