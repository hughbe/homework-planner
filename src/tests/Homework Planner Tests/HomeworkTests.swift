//
//  HomeworkTests.swift
//  Homework Planner Tests
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

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
    
    func testOrderSubject() {
        // Not Priority/Completed vs Not Priority/Completed
        XCTAssertEqual(.before, lowPriorityCompletedSubjectA.order(other: lowPriorityCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(.after, lowPriorityCompletedSubjectB.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.equal, lowPriorityCompletedSubjectA.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))

        // Not Priority/Completed vs Not Priority/Not Completed
        XCTAssertEqual(.after, lowPriorityCompletedSubjectA.order(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.before, lowPriorityNotCompletedSubjectA.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(.after, lowPriorityCompletedSubjectA.order(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.before, highPriorityCompletedSubjectA.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Priority/Not Completed
        XCTAssertEqual(.after, lowPriorityCompletedSubjectA.order(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.before, highPriorityNotCompletedSubjectA.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(.after, lowPriorityCompletedSubjectA.order(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.before, highPriorityCompletedSubjectA.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))

        // Not Priority/Not Completed vs Not Priority/Not Completed
        XCTAssertEqual(.before, lowPriorityNotCompletedSubjectA.order(other: lowPriorityNotCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(.after, lowPriorityNotCompletedSubjectB.order(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.equal, lowPriorityNotCompletedSubjectA.order(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(.after, lowPriorityNotCompletedSubjectA.order(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.before, highPriorityNotCompletedSubjectA.order(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Not Priority/Completed
        XCTAssertEqual(.before, lowPriorityNotCompletedSubjectA.order(other: lowPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.after, lowPriorityCompletedSubjectA.order(other: lowPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Not Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(.before, lowPriorityNotCompletedSubjectA.order(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.after, lowPriorityCompletedSubjectA.order(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))

        // Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(.before, highPriorityNotCompletedSubjectA.order(other: highPriorityNotCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(.after, highPriorityNotCompletedSubjectB.order(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.equal, highPriorityNotCompletedSubjectA.order(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))

        // Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(.before, highPriorityNotCompletedSubjectA.order(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.after, highPriorityCompletedSubjectA.order(other: highPriorityNotCompletedSubjectA, comparisonType: .subject))
        
        // Priority/Completed vs Priority/Completed
        XCTAssertEqual(.before, highPriorityCompletedSubjectA.order(other: highPriorityCompletedSubjectB, comparisonType: .subject))
        XCTAssertEqual(.after, highPriorityCompletedSubjectB.order(other: highPriorityCompletedSubjectA, comparisonType: .subject))
        XCTAssertEqual(.equal, highPriorityCompletedSubjectA.order(other: highPriorityCompletedSubjectA, comparisonType: .subject))
    }

    func testOrderDate() {
        // Not Priority/Completed vs Not Priority/Completed
        XCTAssertEqual(.before, lowPriorityCompletedDateA.order(other: lowPriorityCompletedDateB, comparisonType: .date))
        XCTAssertEqual(.after, lowPriorityCompletedDateB.order(other: lowPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.equal, lowPriorityCompletedDateA.order(other: lowPriorityCompletedDateA, comparisonType: .date))

        // Not Priority/Completed vs Not Priority/Not Completed
        XCTAssertEqual(.after, lowPriorityCompletedDateA.order(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.before, lowPriorityNotCompletedDateA.order(other: lowPriorityCompletedDateA, comparisonType: .date))

        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(.after, lowPriorityCompletedDateA.order(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.before, highPriorityCompletedDateA.order(other: lowPriorityCompletedDateA, comparisonType: .date))

        // Not Priority/Completed vs Priority/Not Completed
        XCTAssertEqual(.after, lowPriorityCompletedDateA.order(other: highPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.before, highPriorityNotCompletedDateA.order(other: lowPriorityCompletedDateA, comparisonType: .date))

        // Not Priority/Completed vs Priority/Completed
        XCTAssertEqual(.after, lowPriorityCompletedDateA.order(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.before, highPriorityCompletedDateA.order(other: lowPriorityCompletedDateA, comparisonType: .date))

        // Not Priority/Not Completed vs Not Priority/Not Completed
        XCTAssertEqual(.before, lowPriorityNotCompletedDateA.order(other: lowPriorityNotCompletedDateB, comparisonType: .date))
        XCTAssertEqual(.after, lowPriorityNotCompletedDateB.order(other: lowPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.equal, lowPriorityNotCompletedDateA.order(other: lowPriorityNotCompletedDateA, comparisonType: .date))

        // Not Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(.after, lowPriorityNotCompletedDateA.order(other: highPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.before, highPriorityNotCompletedDateA.order(other: lowPriorityNotCompletedDateA, comparisonType: .date))

        // Not Priority/Not Completed vs Not Priority/Completed
        XCTAssertEqual(.before, lowPriorityNotCompletedDateA.order(other: lowPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.after, lowPriorityCompletedDateA.order(other: lowPriorityNotCompletedDateA, comparisonType: .date))

        // Not Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(.before, lowPriorityNotCompletedDateA.order(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.after, lowPriorityCompletedDateA.order(other: highPriorityNotCompletedDateA, comparisonType: .date))

        // Priority/Not Completed vs Priority/Not Completed
        XCTAssertEqual(.before, highPriorityNotCompletedDateA.order(other: highPriorityNotCompletedDateB, comparisonType: .date))
        XCTAssertEqual(.after, highPriorityNotCompletedDateB.order(other: highPriorityNotCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.equal, highPriorityNotCompletedDateA.order(other: highPriorityNotCompletedDateA, comparisonType: .date))

        // Priority/Not Completed vs Priority/Completed
        XCTAssertEqual(.before, highPriorityNotCompletedDateA.order(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.after, highPriorityCompletedDateA.order(other: highPriorityNotCompletedDateA, comparisonType: .date))

        // Priority/Completed vs Priority/Completed
        XCTAssertEqual(.before, highPriorityCompletedDateA.order(other: highPriorityCompletedDateB, comparisonType: .date))
        XCTAssertEqual(.after, highPriorityCompletedDateB.order(other: highPriorityCompletedDateA, comparisonType: .date))
        XCTAssertEqual(.equal, highPriorityCompletedDateA.order(other: highPriorityCompletedDateA, comparisonType: .date))
    }
}
