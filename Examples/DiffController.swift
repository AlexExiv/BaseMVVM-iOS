//
//  ViewController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import BaseMVVM

struct Item: SBDiffEntity
{
    let id: Int
    let value: String
    
    func IsTheSame( entity: SBDiffEntity ) -> Bool
    {
        guard let n = entity as? Item else { return false }
        return n.id == id
    }
    
    func IsContentChanged( entity: SBDiffEntity ) -> Bool
    {
        guard let n = entity as? Item else { return false }
        return n.value != value
    }
}

class DiffController: UITableViewController
{
    let allItems = [[Item( id: 1, value: "Test 1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 3, value: "Test 3" ),
                    Item( id: 4, value: "Test 4" )],
                    
                    [Item( id: 3, value: "Test 3" ),
                     Item( id: 1, value: "Test 1" ),
                     Item( id: 4, value: "Test 4" ),
                     Item( id: 2, value: "Test 2" )],
    
                    [Item( id: 1, value: "Test new1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 4, value: "Test new4" ),
                    Item( id: 5, value: "Test 5" )],
                    
                    
                    [Item( id: 1, value: "Test new1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 3, value: "Test new3" ),
                    Item( id: 5, value: "Test 5" )],
                    
                    [Item( id: 1, value: "Test new1" ),
                    Item( id: 2, value: "Test 2" ),
                    Item( id: 4, value: "Test new4" ),
                    Item( id: 5, value: "Test 5" ),
                    Item( id: 6, value: "Test 6" ),
                    Item( id: 7, value: "Test 7" )],
    
                    [Item( id: 3, value: "Test new1" ),
                    Item( id: 1, value: "Test 2" ),
                    Item( id: 4, value: "Test new4" ),
                    Item( id: 2, value: "Test 5" ),
                    Item( id: 6, value: "Test 6" ),
                    Item( id: 9, value: "Test 7" )]]

    var curInd = 0
    var curItems: [Item]! = nil
    var maxGenValue = 100
    var rxP = PublishRelay<[Item]>()
    let dispBag = DisposeBag()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Reset( nil )
        SBDiffCalculator.BindUpdates( from: rxP, table: tableView, scheduler: MainScheduler.asyncInstance, dispBag: dispBag )
    }

    @IBAction func Reset(_ sender: Any?)
    {
        curInd = 0
        curItems = allItems[0]
        tableView.reloadData()
    }
    
    @IBAction func Left(_ sender: Any)
    {
        curInd = (allItems.count + curInd - 1)%allItems.count
        SetData( items: allItems[curInd] )
    }
    
    @IBAction func Right(_ sender: Any)
    {
        curInd = (allItems.count + curInd + 1)%allItems.count
        SetData( items: allItems[curInd] )
    }
    
    func SetData( items: [Item] )
    {
        let calc = SBDiffCalculator( oldItems: curItems, newItems: items )
        curItems = items
        calc.Calc()
        calc.Dispatch( to: tableView )
    }
    
    func AddData( items: [Item] )
    {
        let old = curItems ?? []
        curItems.append( contentsOf: items )
        let calc = SBDiffCalculator( oldItems: old, newItems: curItems )
        //curItems = items
        calc.Calc()
        calc.Dispatch( to: tableView )
    }
    
    //MARK: -
    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int
    {
        return curItems?.count ?? 0
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell( withIdentifier: "Cell", for: indexPath )
        cell.textLabel?.text = curItems[indexPath.row].value
        return cell
    }
    
    override func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath )
    {
        if indexPath.row == curItems.count - 1
        {
            DispatchQueue.main.async {
                let items = Array( self.maxGenValue..<(self.maxGenValue + 100) ).map { Item( id: $0, value: "Generate \($0)" ) }
                self.AddData( items: items )
                self.maxGenValue += 100
            }
        }
    }
}

