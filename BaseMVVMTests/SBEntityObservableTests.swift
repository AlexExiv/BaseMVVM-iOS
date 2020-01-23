//
//  SBEntityObservableTests.swift
//  BaseMVVMTests
//
//  Created by ALEXEY ABDULIN on 22/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import XCTest

import RxSwift
import RxTest
import RxBlocking

@testable import BaseMVVM

struct TestEnity: SBEntity
{
    var key: SBEntityKey { return SBEntityKey( id ) }
    
    let id: String
    let value: String
    
    func Modified( value: String ) -> TestEnity
    {
        return TestEnity( id: id, value: value )
    }
}

class SBEntityObservableTests: XCTestCase
{
    func test()
    {
        let collection = SBEntityObservableCollection<TestEnity>( queue: OperationQueueScheduler( operationQueue: OperationQueue() ) )
        let single = collection.CreateSingle { Single.just( TestEnity( id: "1", value: "2" ) ) }
        let f = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f.id, "1" )
        XCTAssertEqual( f.value, "2" )
        
        let pages = collection.CreatePaginator { _ in Single.just( [TestEnity( id: "1", value: "3" ), TestEnity( id: "2", value: "4" )] ) }
        let arr = try! pages
            .toBlocking()
            .first()!
        
        XCTAssertEqual( pages.page, PAGINATOR_END )
        
        XCTAssertEqual( arr[0].id, "1" )
        XCTAssertEqual( arr[0].value, "3" )
        XCTAssertEqual( arr[1].id, "2" )
        XCTAssertEqual( arr[1].value, "4" )
        
        let f0 = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f0.id, "1" )
        XCTAssertEqual( f0.value, "3" )
        
        _ = try! collection
            .RxRequestForUpdate( key: SBEntityKey( "1" ) ) { $0.Modified( value: "10" ) }
            .toBlocking()
            .first()!
        
        let f1 = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f1.id, "1" )
        XCTAssertEqual( f1.value, "10" )
        
        let arr1 = try! pages
            .toBlocking()
            .first()!
        
        XCTAssertEqual( arr1[0].id, "1" )
        XCTAssertEqual( arr1[0].value, "10" )
        XCTAssertEqual( arr1[1].id, "2" )
        XCTAssertEqual( arr1[1].value, "4" )
        
        _ = try! collection
            .RxRequestForUpdate( keys: [SBEntityKey( "1" ), SBEntityKey( "2" )] ) { $0.Modified( value: "1\($0.id)" ) }
            .toBlocking()
            .first()!
        
        let f2 = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f2.id, "1" )
        XCTAssertEqual( f2.value, "1\(f2.id)" )
        
        let arr2 = try! pages
            .toBlocking()
            .first()!
        
        XCTAssertEqual( arr2[0].id, "1" )
        XCTAssertEqual( arr2[0].value, "1\(arr2[0].id)" )
        XCTAssertEqual( arr2[1].id, "2" )
        XCTAssertEqual( arr2[1].value, "1\(arr2[1].id)" )
        
        let f3_ = try! collection
            .RxUpdate( entity: TestEnity( id: "1", value: "25" ) )
            .toBlocking()
            .first()!
        
        let f3 = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f3.id, "1" )
        XCTAssertEqual( f3.value, "25" )
        XCTAssertEqual( f3.id, f3_.id )
        XCTAssertEqual( f3.value, f3_.value )
        
        single.Refresh()
        Thread.sleep( forTimeInterval: 0.5 )
        
        let f4 = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f4.id, "1" )
        XCTAssertEqual( f4.value, "2" )
        
        pages.Refresh()
        Thread.sleep( forTimeInterval: 0.5 )
        
        let f5 = try! single
            .toBlocking()
            .first()!
        
        XCTAssertEqual( f5.id, "1" )
        XCTAssertEqual( f5.value, "3" )
    }
}
