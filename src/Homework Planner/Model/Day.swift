//
//  Day.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public struct Day {
    public var dayOfWeek: Int
    public var week: Int
    public var date: Date
    
    public init?(dayOfWeek: Int, week: Int) {
        self.dayOfWeek = dayOfWeek
        self.week = week
        
        var components = DateComponents()
        components.weekOfMonth = week
        components.weekday = dayOfWeek
        
        guard let date = Calendar.current.date(byAdding: components, to: Settings.weekStart) else {
            return nil
        }
        
        self.date = date.day
    }
    
    public init(date: Date) {
        let weekStart = Settings.weekStart
        let weeksLength = Calendar.current.dateComponents([.day], from: weekStart, to: Settings.weekEnd).day!
        let difference = Calendar.current.dateComponents([.day], from: weekStart, to: date).day!
        
        let totalDifference = difference % weeksLength
        let weekday = Calendar.current.component(.weekday, from: date)
        
        var components = DateComponents()
        components.day = totalDifference
        let adjustedDate = Calendar.current.date(byAdding: components, to: weekStart)!

        self.date = adjustedDate.day
        week = totalDifference / weeksLength + 1
        dayOfWeek = weekday
    }
    
    public var previousDay: Day {
        get {
            let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
            return Day(date: previousDate)
        }
    }
    
    public var nextDay: Day {
        get {
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            return Day(date: nextDate)
        }
    }
    
    public var name: String {
        get {
            let difference = Calendar.current.dateComponents([.year, .month, .day], from: Date().day, to: date)

            let dayName: String
            if difference.day! == 0 {
                dayName = NSLocalizedString("Today", comment: "Today")
            } else if difference.day! == 1 {
                dayName = NSLocalizedString("Tomorrow", comment: "Tomorrow")
            } else {
                dayName = Calendar.current.weekdaySymbols[dayOfWeek - 1]
            }
            
            if Settings.numberOfWeeks != 1 {
                return dayName + " - " + NSLocalizedString("Week", comment: "Week") + " " + String(week)
            }
            
            return dayName
        }
    }
}
