//
//  Date+OrdinalIndicatorString.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public enum DayOfWeek : Int {
    case Monday = 2
    case Tuesday = 3
    case Wednesday = 4
    case Thursday = 5
    case Friday = 6
    case Saturday = 7
    case Sunday = 1
}

public extension Date {
    public var ordinalIndicatorString: String {
        let day = Calendar.current.component(.day, from: self)

        switch day {
        case 1, 21, 32:
            return "st"
        case 2, 22, 32:
            return "nd"
        case 3, 23, 33:
            return "nd"
        default:
            return "th"
        }
    }
    
    public var day: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
    
    public var formattedDayName: String {
        let difference = Calendar.current.dateComponents([.day], from: Date().day, to: day).day!
        if difference == 0 {
            return NSLocalizedString("Today", comment: "Today")
        } else if difference == 1 {
            return NSLocalizedString("Tomorrow", comment: "Tomorrow")
        }
        
        let prefixFormatter = DateFormatter()
        prefixFormatter.dateFormat = "EEEE d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = " MMM"
        
        return prefixFormatter.string(from: self) + ordinalIndicatorString + monthFormatter.string(from: self)
    }
    
    public func previous(dayOfWeek: DayOfWeek) -> Date {
        var previousMonday = day
        while true {
            let weekday = Calendar.current.component(.weekday, from: previousMonday)
            if weekday == dayOfWeek.rawValue {
                return previousMonday
            }
            
            previousMonday = Calendar.current.date(byAdding: .day, value: -1, to: previousMonday, wrappingComponents: true)!
        }
    }
}
