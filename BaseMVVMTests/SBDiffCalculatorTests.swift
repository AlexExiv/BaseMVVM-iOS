//
//  SBDiffCalculatorTests.swift
//  BaseMVVMTests
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import XCTest

@testable import BaseMVVM

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

class ItemsDatasource: NSObject, UITableViewDataSource
{
    var data: [Item]?

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data?[indexPath.row].value
        return cell
    }
}

class SBDiffCalculatorTests: XCTestCase
{
    func testCase0()
    {
        let oldItems = [Item( id: 1, value: "1" ),
                        Item( id: 2, value: "2" ),
                        Item( id: 3, value: "3" ),
                        Item( id: 4, value: "4" )]
        let newItems = [Item( id: 1, value: "new1" ),
                        Item( id: 2, value: "2" ),
                        Item( id: 4, value: "new4" ),
                        Item( id: 5, value: "5" )]
        let calculator = SBDiffCalculator( oldItems: oldItems, newItems: newItems )
        calculator.Calc()
        
        XCTAssertEqual( calculator.changedItems.count, 1 )
        XCTAssertEqual( calculator.insertedItems.count, 1 )
        XCTAssertEqual( calculator.deletedItems.count, 1 )
        XCTAssertEqual( calculator.movedItems.count, 1 )
        
        XCTAssertEqual( calculator.changedItems[0].newI, 0 )
    }
    
    func testCase1()
    {
        let oldItems = [Item( id: 1, value: "Test new1" ),
                        Item( id: 4, value: "Test new4" ),
                        Item( id: 2, value: "Test 2" ),
                        Item( id: 5, value: "Test 5" )]
        
        let newItems = [Item( id: 3, value: "Test 3" ),
                        Item( id: 1, value: "Test 1" ),
                        Item( id: 4, value: "Test 4" ),
                        Item( id: 2, value: "Test 2" )]
        
        let calculator = SBDiffCalculator( oldItems: oldItems, newItems: newItems )
        calculator.Calc()
        
        XCTAssertEqual( calculator.changedItems.count, 0 )
        XCTAssertEqual( calculator.insertedItems.count, 1 )
        XCTAssertEqual( calculator.deletedItems.count, 1 )
        XCTAssertEqual( calculator.movedItems.count, 3 )
        
        XCTAssertEqual( calculator.insertedItems[0].newI, 0 )
    }
    
    func testSections()
    {
        let oldItems = [[Item( id: 1, value: "1" ),
                        Item( id: 2, value: "2" ),
                        Item( id: 3, value: "3" ),
                        Item( id: 4, value: "4" )],
                        
                        [Item( id: 10, value: "1" ),
                        Item( id: 11, value: "2" ),
                        Item( id: 12, value: "3" ),
                        Item( id: 13, value: "4" )]]
        
        let newItems = [Item( id: 1, value: "new1" ),
                        Item( id: 2, value: "2" ),
                        Item( id: 4, value: "new4" ),
                        Item( id: 5, value: "5" )]
        
        let calculator = SBDiffCalculator( oldItems: oldItems, newItems: [newItems] )
        calculator.Calc()
        
        XCTAssertEqual( calculator.changedItems.count, 1 )
        XCTAssertEqual( calculator.insertedItems.count, 1 )
        XCTAssertEqual( calculator.deletedItems.count, 5 )
        XCTAssertEqual( calculator.movedItems.count, 1 )
        
        XCTAssertEqual( calculator.changedItems[0].newI, 0 )
        XCTAssertEqual( calculator.deletedItems[0].oldI, 2 )
        XCTAssertEqual( calculator.deletedItems[1].oldSec, 1 )
        XCTAssertEqual( calculator.deletedItems[1].oldI, 0 )
    }
    
    func testTableView()
    {
        let oldItems = [Item( id: 1, value: "1" ),
                        Item( id: 2, value: "2" ),
                        Item( id: 3, value: "3" ),
                        Item( id: 4, value: "4" )]
        
        let itemsDatasource = ItemsDatasource()
        
        itemsDatasource.data = oldItems
        
        let tableView = UITableView()
        tableView.register( UITableViewCell.self, forCellReuseIdentifier: "Cell" )
        tableView.dataSource = itemsDatasource

        tableView.reloadData()
        
        XCTAssertEqual( itemsDatasource.tableView( tableView, numberOfRowsInSection: 0 ), 4 )
        
        let newItems = [Item( id: 1, value: "new1" ),
                        Item( id: 2, value: "2" ),
                        Item( id: 4, value: "new4" ),
                        Item( id: 5, value: "5" ),
                        Item( id: 6, value: "6" )]
        
        itemsDatasource.data = newItems
        
        let calculator = SBDiffCalculator( oldItems: oldItems, newItems: newItems )
        calculator.Calc()
        calculator.Dispatch( to: tableView )
        
        XCTAssertEqual( itemsDatasource.tableView( tableView, numberOfRowsInSection: 0 ), 5 )
    }
}
