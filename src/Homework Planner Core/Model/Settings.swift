//
//  Settings.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public class Settings {
    private static let numberOfWeeksKey = "NumberOfWeeks"
    private static let weekStartKey = "WeekStart"
    private static let includeWeekendsKey = "IncludeWeekends"
    private static let homeworkDisplayKey = "HomeworkDisplay"
    private static let purchasedTimetableKey = "PurchasedTimetable"
    
    public static var numberOfWeeks: Int {
        get {
            let numberOfWeeks = UserDefaults.standard.integer(forKey: numberOfWeeksKey)
            return max(1, numberOfWeeks)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: numberOfWeeksKey)
        }
    }
    
    public static var weekStart: Date {
        get {
            if let date = UserDefaults.standard.object(forKey: weekStartKey) as? Date {
                return date
            }

            return Date().previous(dayOfWeek: DayOfWeek.Monday)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: weekStartKey)
        }
    }
    
    public static var weekEnd: Date {
        get {
            let start = weekStart
            let daysInWeek = Calendar.current.range(of: .weekday, in: .weekOfMonth, for: start)!.count

            var components = DateComponents()
            components.day = daysInWeek * numberOfWeeks
            
            return Calendar.current.date(byAdding: components, to: start)!
        }
    }
    
    public static var includeWeekends: Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: includeWeekendsKey) as? Bool {
                return value
            }
            
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: includeWeekendsKey)
        }
    }
    
    public static var homeworkDisplay: HomeworkDisplayType {
        get {
            if let value = UserDefaults.standard.value(forKey: homeworkDisplayKey) as? Int {
                return HomeworkDisplayType(rawValue: value)!
            }
            
            return .sectionedByDate
        } set {
            UserDefaults.standard.set(newValue.rawValue, forKey: homeworkDisplayKey)
        }
    }
    
    public static var purchasedTimetable: Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: purchasedTimetableKey) as? Bool {
                return value
            }
            
            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: purchasedTimetableKey)
        }
    }
}
