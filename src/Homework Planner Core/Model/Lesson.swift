//
//  Lesson.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public extension Lesson {
    private var startDate: Date? {
        var dateComponents = DateComponents()
        dateComponents.hour = Int(startHour)
        dateComponents.minute = Int(startMinute)

        return Calendar.current.date(from: dateComponents)
   }
    
    private var endDate: Date? {
        var dateComponents = DateComponents()
        dateComponents.hour = Int(endHour)
        dateComponents.minute = Int(endMinute)
        
        return Calendar.current.date(from: dateComponents)
    }

    public var hasStartTime: Bool {
        return startHour != -1 && startMinute != -1
    }

    public var hasEndTime: Bool {
        return endHour != -1 && endMinute != -1
    }

    public var formattedDuration: String {
        if let startDate = startDate, let endDate = endDate {
            let startTime = DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .short)
            let endTime = DateFormatter.localizedString(from: endDate, dateStyle: .none, timeStyle: .short)
            
            return startTime + " - " + endTime
        } else {
            return "No Time"
        }
    }

    public var isCurrent: Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let hour = components.hour!
        let minute = components.minute!
        if hour < startHour || (hour == startHour && minute < startMinute) {
            return false
        }

        if hour > endHour || (hour == endHour && minute > endMinute) {
            return false
        }

        return true
    }
}
