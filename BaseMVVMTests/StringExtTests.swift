
//
//  StringExtTests.swift
//  BaseMVVMTests
//
//  Created by ALEXEY ABDULIN on 15/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import XCTest
@testable import BaseMVVM

class StringExtTests: XCTestCase
{
    func test()
    {
        let testHttp = "http://test.speakerbox.pro/topics/comments/test-question-0-217.png"
        let testHttps = "https://test.speakerbox.pro/topics/comments/test-question-0-217.png"
        let testRelative0 = "topics/comments/test-question-0-217.png"
        let testRelative1 = "/topics/comments/test-question-0-217.png"
        
        XCTAssertEqual( testHttp.urlPath, "topics/comments" )
        XCTAssertEqual( testHttps.urlPath, "topics/comments" )
        XCTAssertEqual( testRelative0.urlPath, "topics/comments" )
        XCTAssertEqual( testRelative1.urlPath, "topics/comments" )
        
        XCTAssertEqual( testHttp.lastURLComponent, "test-question-0-217.png" )
        XCTAssertEqual( testHttps.lastURLComponent, "test-question-0-217.png" )
        XCTAssertEqual( testRelative0.lastURLComponent, "test-question-0-217.png" )
        XCTAssertEqual( testRelative1.lastURLComponent, "test-question-0-217.png" )
        
        
        let test1Http = "http://test.speakerbox.pro/comments/test-question-0-217.png"
        let test1Https = "https://test.speakerbox.pro/comments/test-question-0-217.png"
        let test1Relative0 = "comments/test-question-0-217.png"
        let test1Relative1 = "/comments/test-question-0-217.png"
        
        XCTAssertEqual( test1Http.urlPath, "comments" )
        XCTAssertEqual( test1Https.urlPath, "comments" )
        XCTAssertEqual( test1Relative0.urlPath, "comments" )
        XCTAssertEqual( test1Relative1.urlPath, "comments" )
    }
}
