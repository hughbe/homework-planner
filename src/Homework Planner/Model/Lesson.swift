//
//  Lesson.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public extension Lesson {
    public var day: Day? {
        get {
            return Day(dayOfWeek: Int(dayOfWeek), week: Int(week))
        }
    }
    
    public var startDate: Date? {
        get {
            var dateComponents = DateComponents()
            dateComponents.hour = Int(startHour)
            dateComponents.minute = Int(startMinute)

            return Calendar.current.date(from: dateComponents)
        }
    }
    
    public var endDate: Date? {
        get {
            var dateComponents = DateComponents()
            dateComponents.hour = Int(endHour)
            dateComponents.minute = Int(endMinute)
            
            return Calendar.current.date(from: dateComponents)
        }
    }
    
    public var hasStartTime: Bool {
        get {
            return startHour != -1 && startMinute != -1
        }
    }
    
    public var hasEndTime: Bool {
        get {
            return endHour != -1 && endMinute != -1
        }
    }
}
