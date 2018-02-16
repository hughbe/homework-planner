//
//  Day.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Date_WithoutTime
import Foundation

public struct Day {
    public let dayOfWeek: Int
    public let week: Int
    public let date: Date
    
    public init(dayOfWeek: Int, week: Int) {
        var components = DateComponents()
        components.weekOfMonth = week - 1
        components.day = dayOfWeek - 2
        
        let date = Calendar.current.date(byAdding: components, to: Timetable.shared.weekStart)!
        self.init(date: date, modifyIfWeekend: true)
    }
    
    public init(date: Date, modifyIfWeekend: Bool) {
        var date = date
        if modifyIfWeekend {
            while !Timetable.shared.includeWeekends && Calendar.current.isDateInWeekend(date) {
                date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            }
        }

        let weekStart = Timetable.shared.weekStart.withoutTime
        let weekEnd = Timetable.shared.weekEnd.withoutTime
        let weeksLength = Calendar.current.dateComponents([.day], from: weekStart, to: weekEnd).day!
        let difference = Calendar.current.dateComponents([.day], from: weekStart, to: date).day!
        let daysInAWeek = Calendar.current.range(of: .weekday, in: .weekOfMonth, for: date)!.count

        let totalDifference = difference % weeksLength
        let weekday = Calendar.current.component(.weekday, from: date.withoutTime)
        
        var components = DateComponents()
        components.day = totalDifference

        let adjustedDate: Date
        if totalDifference > 0 {
            adjustedDate = Calendar.current.date(byAdding: components, to: weekStart)!
        } else {
            adjustedDate = Calendar.current.date(byAdding: components, to: weekEnd)!
        }

        self.date = adjustedDate.withoutTime
        week = totalDifference / daysInAWeek + 1
        dayOfWeek = weekday
    }
    
    public var previousDay: Day {
        var previousDate = date

        repeat {
            previousDate = Calendar.current.date(byAdding: .day, value: -1, to: previousDate)!
        } while !Timetable.shared.includeWeekends && Calendar.current.isDateInWeekend(previousDate)

        return Day(date: previousDate, modifyIfWeekend: false)
    }
    
    public var nextDay: Day {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        return Day(date: nextDate, modifyIfWeekend: true)
    }
    
    public var name: String {
        let day = Day(date: Date().withoutTime, modifyIfWeekend: false)
        let difference = Calendar.current.dateComponents([.day], from: day.date, to: date)

        let dayName: String
        if difference.day! == 0 {
            dayName = NSLocalizedString("Today", comment: "Today")
        } else if difference.day! == 1 {
            dayName = NSLocalizedString("Tomorrow", comment: "Tomorrow")
        } else {
            dayName = Calendar.current.weekdaySymbols[dayOfWeek - 1]
        }
        
        if Timetable.shared.numberOfWeeks != 1 {
            return dayName + " - " + NSLocalizedString("Week", comment: "Week") + " " + String(week)
        }
        
        return dayName
    }
}
