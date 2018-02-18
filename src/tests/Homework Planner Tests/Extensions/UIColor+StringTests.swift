//
//  UIColorStringTests.swifts
//  Homework Planner Tests
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import XCTest

class UIColorStringTests: XCTestCase {
    func testStringRepresentation() {
        let color = UIColor.purple
        XCTAssertEqual("[0.5, 0.0, 0.5, 1.0]", color.stringRepresentation)
    }
    
    func testInitString() {
        XCTAssertEqual(UIColor.purple, UIColor(string: "[0.5, 0.0, 0.5, 1.0]"))
        XCTAssertEqual(UIColor.purple, UIColor(string: "[[[0.5, 0.[]0[], 0[.5, 1.]0]]]]]"))
        XCTAssertEqual(UIColor.purple, UIColor(string: "0.5, 0.0, 0.5, 1.0"))
        
        XCTAssertEqual(nil, UIColor(string: ""))
        XCTAssertEqual(nil, UIColor(string: "0.5"))
        XCTAssertEqual(nil, UIColor(string: "0.5, 0.0"))
        XCTAssertEqual(nil, UIColor(string: "0.5, 0.0, 0.5"))
        XCTAssertEqual(nil, UIColor(string: "0.5, 0.0, 0.5, 1.0, 1.0"))
    }
}
