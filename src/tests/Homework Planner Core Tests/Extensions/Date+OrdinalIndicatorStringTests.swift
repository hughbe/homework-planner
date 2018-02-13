//
//  Date+OrdinalIndicatorStringTests.swift
//  Homework Planner Core Tests
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Homework_Planner_Core
import XCTest

class DateOrdinalIndicatorStringTests: XCTestCase {
    func testOrdinalIndicatorString() {
        var components = DateComponents()
        components.year = 2018
        components.month = 1

        // 1st
        components.day = 1
        XCTAssertEqual("st", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 2nd
        components.day = 2
        XCTAssertEqual("nd", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 3nd
        components.day = 3
        XCTAssertEqual("rd", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 4th
        components.day = 24
        XCTAssertEqual("th", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 21st
        components.day = 21
        XCTAssertEqual("st", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 22nd
        components.day = 22
        XCTAssertEqual("nd", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 23nd
        components.day = 23
        XCTAssertEqual("rd", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 24th
        components.day = 24
        XCTAssertEqual("th", Calendar.current.date(from: components)!.ordinalIndicatorString)
        
        // 31st
        components.day = 31
        XCTAssertEqual("st", Calendar.current.date(from: components)!.ordinalIndicatorString)
    }
}
