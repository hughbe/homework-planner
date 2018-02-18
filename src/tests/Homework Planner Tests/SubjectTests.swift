//
//  SubjectTests.swift
//  Homework Planner Tests
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import XCTest

class SubjectTests: XCTestCase {
    private var subject: Subject!
    
    override func setUp() {
        super.setUp()

        subject = Subject(context: CoreDataStorage.shared.context)
    }
    
    override func tearDown() {
        super.tearDown()

        CoreDataStorage.shared.context.delete(subject)
    }

    func testGetUiColor() {
        subject.color = "[0.5, 0.0, 0.5, 1.0]"
        XCTAssertEqual(UIColor.purple, subject.uiColor)

        subject.color = "[[[0.5, 0.[]0[], 0[.5, 1.]0]]]]]"
        XCTAssertEqual(UIColor.purple, subject.uiColor)
        
        subject.color = "0.5, 0.0, 0.5, 1.0"
        XCTAssertEqual(UIColor.purple, subject.uiColor)
        
        subject.color = ""
        XCTAssertNil(subject.uiColor)
        
        subject.color = "0.5"
        XCTAssertNil(subject.uiColor)
        
        subject.color = "0.5, 0.0"
        XCTAssertNil(subject.uiColor)
        
        subject.color = "0.5, 0.0, 0.5"
        XCTAssertNil(subject.uiColor)
        
        subject.color = "0.5, 0.0, 0.5, 1.0, 1.0"
        XCTAssertNil(subject.uiColor)
    }

    func testSetUiColor() {
        subject.uiColor = UIColor.purple
        XCTAssertEqual(UIColor.purple, subject.uiColor)
        XCTAssertEqual("[0.5, 0.0, 0.5, 1.0]", subject.color)
    }
}
