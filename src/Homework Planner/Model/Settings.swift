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

            var nearestMonday = Date().day
            while true {
                let dayOfWeek = Calendar.current.component(.weekday, from: nearestMonday)
                if dayOfWeek == 2 {
                    return nearestMonday
                }
                
                nearestMonday = Calendar.current.date(byAdding: .day, value: -1, to: nearestMonday, wrappingComponents: true)!
            }
            
        }
        set {
            UserDefaults.standard.set(newValue, forKey: weekStartKey)
        }
    }
    
    public static var weekEnd: Date {
        get {
            let start = weekStart
            let daysInWeek = Calendar.current.range(of: .day, in: .weekOfMonth, for: start)!.count

            var components = DateComponents()
            components.day = daysInWeek * numberOfWeeks
            
            return Calendar.current.date(byAdding: components, to: start)!
        }
    }
}
