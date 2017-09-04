//
//  DemoTests.swift
//  Final Project
//
//  Created by Aanya Jhaveri on 9/2/17.
//  Copyright © 2017 Aanya Jhaveri. All rights reserved.
//

import XCTest

@testable import Final_Project

class DemoTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHello() {
        let d = Demo()
        XCTAssertEqual(d.hello(), "hello")
    }

    
}
