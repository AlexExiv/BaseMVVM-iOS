//
//  DictionaryExtTests.swift
//  BaseMVVMTests
//
//  Created by ALEXEY ABDULIN on 14/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import XCTest
@testable import BaseMVVM

class DictionaryExtTests: XCTestCase
{
    func test()
    {
        let map: [String: Any] = [
            "int": 100,
            "float": 100.1,
            "double": 100.1,
            "bool": false,
            "string": "text",
            "stringArr": ["0", "1"],
            "intArr": [0, 1],
            "doubleArr": [0.5, 1.5]]
        
        XCTAssertEqual( map.GetInt( "int" ), 100 )
        XCTAssertEqual( map.GetDouble( "int" ), 100 )
        XCTAssertEqual( map.GetBool( "int" ), true )
        
        XCTAssertEqual( map.GetDouble( "double" ), 100.1 )
        XCTAssertEqual( map.GetInt( "double" ), 100 )
        
        XCTAssertEqual( map.GetBool( "bool" ), false )
        XCTAssertEqual( map.GetInt( "bool" ), 0 )
        
        XCTAssertEqual( map.GetStringArray( "stringArr" ), ["0", "1"] )
        XCTAssertEqual( map.GetIntArray( "stringArr" ), [0, 1] )
        XCTAssertEqual( map.GetDoubleArray( "stringArr" ), [0.0, 1.0] )
        
        XCTAssertEqual( map.GetIntArray( "intArr" ), [0, 1] )
        XCTAssertEqual( map.GetStringArray( "intArr" ), ["0", "1"] )
        
        XCTAssertEqual( map.GetDoubleArray( "doubleArr" ), [0.5, 1.5] )
        XCTAssertEqual( map.GetIntArray( "doubleArr" ), [0, 1] )
        XCTAssertEqual( map.GetStringArray( "doubleArr" ), ["0.5", "1.5"] )
    }
}
