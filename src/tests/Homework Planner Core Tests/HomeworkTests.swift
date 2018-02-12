//
//  HomeworkTests.swift
//  Homework Planner Core Tests
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Homework_Planner_Core
import XCTest

class HomeworkTests: XCTestCase {
    private var subjectA: Subject!
    private var subjectB: Subject!
    
    private var lowPriorityCompletedSubjectA: Homework!
    private var lowPriorityCompletedSubjectB: Homework!
    
    private var lowPriorityNotCompletedSubjectA: Homework!
    private var lowPriorityNotCompletedSubjectB: Homework!
    
    private var highPriorityNotCompletedSubjectA: Homework!
    private var highPriorityNotCompletedSubjectB: Homework!
    
    private var highPriorityCompletedSubjectA: Homework!
    private var highPriorityCompletedSubjectB: Homework!
    
    private var lowPriorityCompletedDateA: Homework!
    private var lowPriorityCompletedDateB: Homework!
    
    private var lowPriorityNotCompletedDateA: Homework!
    private var lowPriorityNotCompletedDateB: Homework!
    
    private var highPriorityNotCompletedDateA: Homework!
    private var highPriorityNotCompletedDateB: Homework!
    
    private var highPriorityCompletedDateA: Homework!
    private var highPriorityCompletedDateB: Homework!
    
    override func setUp() {
        super.setUp()

        let context = CoreDataStorage.shared.context
        
        subjectA = Subject(context: context)
        subjectA.name = "A"
        
        subjectB = Subject(context: context)
        subjectB.name = "B"
        
        lowPriorityCompletedSubjectA = Homework(context: context)
        lowPriorityCompletedSubjectA.priority = false
        lowPriorityCompletedSubjectA.completed = true
        lowPriorityCompletedSubjectA.subject = subjectA
        
        lowPriorityCompletedSubjectB = Homework(context: context)
        lowPriorityCompletedSubjectB.priority = false
        lowPriorityCompletedSubjectB.completed = true
        lowPriorityCompletedSubjectB.subject = subjectB
        
        lowPriorityNotCompletedSubjectA = Homework(context: context)
        lowPriorityNotCompletedSubjectA.priority = false
        lowPriorityNotCompletedSubjectA.completed = false
        lowPriorityNotCompletedSubjectA.subject = subjectA
        
        lowPriorityNotCompletedSubjectB = Homework(context: context)
        lowPriorityNotCompletedSubjectB.priority = false
        lowPriorityNotCompletedSubjectB.completed = false
        lowPriorityNotCompletedSubjectB.subject = subjectB
        
        highPriorityNotCompletedSubjectA = Homework(context: context)
        highPriorityNotCompletedSubjectA.priority = true
        highPriorityNotCompletedSubjectA.completed = false
        highPriorityNotCompletedSubjectA.subject = subjectA
        
        highPriorityNotCompletedSubjectB = Homework(context: context)
        highPriorityNotCompletedSubjectB.priority = true
        highPriorityNotCompletedSubjectB.completed = false
        highPriorityNotCompletedSubjectB.subject = subjectB
        
        highPriorityCompletedSubjectA = Homework(context: context)
        highPriorityCompletedSubjectA.priority = true
        highPriorityCompletedSubjectA.completed = true
        highPriorityCompletedSubjectA.subject = subjectA
        
        highPriorityCompletedSubjectB = Homework(context: context)
        highPriorityCompletedSubjectB.priority = true
        highPriorityCompletedSubjectB.completed = true
        highPriorityCompletedSubjectB.subject = subjectB
        
        let dateA = Date()
        let dateB = Calendar.current.date(byAdding: .day, value: 1, to: dateA)
        
        lowPriorityCompletedDateA = Homework(context: context)
        lowPriorityCompletedDateA.priority = false
        lowPriorityCompletedDateA.completed = true
        lowPriorityCompletedDateA.dueDate = dateA
        
        lowPriorityCompletedDateB = Homework(context: context)
        lowPriorityCompletedDateB.priority = false
        lowPriorityCompletedDateB.completed = true
        lowPriorityCompletedDateB.dueDate = dateB
        
        lowPriorityNotCompletedDateA = Homework(context: context)
        lowPriorityNotCompletedDateA.priority = false
        lowPriorityNotCompletedDateA.completed = false
        lowPriorityNotCompletedDateA.dueDate = dateA
        
        lowPriorityNotCompletedDateB = Homework(context: context)
        lowPriorityNotCompletedDateB.priority = false
        lowPriorityNotCompletedDateB.completed = false
        lowPriorityNotCompletedDateB.dueDate = dateB
        
        highPriorityNotCompletedDateA = Homework(context: context)
        highPriorityNotCompletedDateA.priority = true
        highPriorityNotCompletedDateA.completed = false
        highPriorityNotCompletedDateA.dueDate = dateA
        
        highPriorityNotCompletedDateB = Homework(context: context)
        highPriorityNotCompletedDateB.priority = true
        highPriorityNotCompletedDateB.completed = false
        highPriorityNotCompletedDateB.dueDate = dateB
        
        highPriorityCompletedDateA = Homework(context: context)
        highPriorityCompletedDateA.priority = true
        highPriorityCompletedDateA.completed = true
        highPriorityCompletedDateA.dueDate = dateA
        
        highPriorityCompletedDateB = Homework(context: context)
        highPriorityCompletedDateB.priority = true
        highPriorityCompletedDateB.completed = true
        highPriorityCompletedDateB.dueDate = dateB
    }

    override func tearDown() {
        super.tearDown()

        let context = CoreDataStorage.shared.context
        
        context.delete(lowPriorityCompletedSubjectA)
        context.delete(lowPriorityCompletedSubjectB)
        
        context.delete(lowPriorityNotCompletedSubjectA)
        context.delete(lowPriorityNotCompletedSubjectB)
        
        context.delete(highPriorityNotCompletedSubjectA)
        context.delete(highPriorityNotCompletedSubjectB)

        context.delete(highPriorityCompletedSubjectA)
        context.delete(highPriorityCompletedSubjectB)
        
        context.delete(lowPriorityCompletedDateA)
        context.delete(lowPriorityCompletedDateB)
        
        context.delete(lowPriorityNotCompletedDateA)
        context.delete(lowPriorityNotCompletedDateB)
        
        context.delete(highPriorityNotCompletedDateA)
        context.delete(highPriorityNotCompletedDateB)
        
        context.delete(highPriorityCompletedDateA)
        context.delete(highPriorityCompletedDateB)
    }
    
    func testIsGreaterThanSubject() {
        // Not Priority/Completed vs Not Priority/Completed
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(true, lowPriorityCompletedSubjectB.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Not Priority/Not Completed
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(true, lowPriorityNotCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(true, highPriorityCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Priority/Not Completed
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(true, highPriorityNotCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(true, highPriorityCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Not Priority/Not Completed
        XCTAssertEqual(false, lowPriorityNotCompletedSubjectA.isGreaterThan(other: lowPriorityNotCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(true, lowPriorityNotCompletedSubjectB.isGreaterThan(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, lowPriorityNotCompletedSubjectA.isGreaterThan(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(false, lowPriorityNotCompletedSubjectA.isGreaterThan(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(true, highPriorityNotCompletedSubjectA.isGreaterThan(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Not Priority/Completed
        XCTAssertEqual(true, lowPriorityNotCompletedSubjectA.isGreaterThan(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(true, lowPriorityNotCompletedSubjectA.isGreaterThan(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, lowPriorityCompletedSubjectA.isGreaterThan(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))

        // Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(false, highPriorityNotCompletedSubjectA.isGreaterThan(other: highPriorityNotCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(true, highPriorityNotCompletedSubjectB.isGreaterThan(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, highPriorityNotCompletedSubjectA.isGreaterThan(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(true, highPriorityNotCompletedSubjectA.isGreaterThan(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, highPriorityCompletedSubjectA.isGreaterThan(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Priority/Completed vs Priority/Completed
        XCTAssertEqual(false, highPriorityCompletedSubjectA.isGreaterThan(other: highPriorityCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(true, highPriorityCompletedSubjectB.isGreaterThan(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(false, highPriorityCompletedSubjectA.isGreaterThan(other: highPriorityCompletedSubjectA, comparisonType: .subject))
    }

    func testIsGreaterThanDate() {
        // Not Priority/Completed vs Not Priority/Completed
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateB, comparisonType: .date))
        XCTAssertEqual(true, lowPriorityCompletedDateB.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        
        // Not Priority/Completed vs Not Priority/Not Completed
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(true, lowPriorityNotCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        
        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(true, highPriorityCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        
        // Not Priority/Completed vs Priority/Not Completed
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: highPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(true, highPriorityNotCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        
        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(true, highPriorityCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        
        // Not Priority/Not Completed vs Not Priority/Not Completed
        XCTAssertEqual(false, lowPriorityNotCompletedDateA.isGreaterThan(other: lowPriorityNotCompletedDateB, comparisonType: .date))
        XCTAssertEqual(true, lowPriorityNotCompletedDateB.isGreaterThan(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, lowPriorityNotCompletedDateA.isGreaterThan(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        
        // Not Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(false, lowPriorityNotCompletedDateA.isGreaterThan(other: highPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(true, highPriorityNotCompletedDateA.isGreaterThan(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        
        // Not Priority/Not Completed vs Not Priority/Completed
        XCTAssertEqual(true, lowPriorityNotCompletedDateA.isGreaterThan(other: lowPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        
        // Not Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(true, lowPriorityNotCompletedDateA.isGreaterThan(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, lowPriorityCompletedDateA.isGreaterThan(other: highPriorityNotCompletedDateA, comparisonType: .date))
        
        // Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(false, highPriorityNotCompletedDateA.isGreaterThan(other: highPriorityNotCompletedDateB, comparisonType: .date))
        XCTAssertEqual(true, highPriorityNotCompletedDateB.isGreaterThan(other: highPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, highPriorityNotCompletedDateA.isGreaterThan(other: highPriorityNotCompletedDateA, comparisonType: .date))
        
        // Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(true, highPriorityNotCompletedDateA.isGreaterThan(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, highPriorityCompletedDateA.isGreaterThan(other: highPriorityNotCompletedDateA, comparisonType: .date))
        
        // Priority/Completed vs Priority/Completed
        XCTAssertEqual(false, highPriorityCompletedDateA.isGreaterThan(other: highPriorityCompletedDateB, comparisonType: .date))
        XCTAssertEqual(true, highPriorityCompletedDateB.isGreaterThan(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(false, highPriorityCompletedDateA.isGreaterThan(other: highPriorityCompletedDateA, comparisonType: .date))
    }
}
