//
//  Date+FormattedDayNameTests.swift
//  Homework Planner Core Tests
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Homework_Planner_Core
import XCTest

class DateFormattedDayNameTests: XCTestCase {
    func testFormattedDayName() {
        var components = DateComponents()
        components.year = 2018
        components.month = 2
        components.day = 10
        
        XCTAssertEqual("Today", Date().formattedDayName)
        XCTAssertEqual("Tomorrow", Calendar.current.date(byAdding: .day, value: 1, to: Date())!.formattedDayName)
        XCTAssertEqual("Saturday 10th Feb", Calendar.current.date(from: components)!.formattedDayName)
    }
}
