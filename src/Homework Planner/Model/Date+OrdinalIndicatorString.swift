//
//  Date+OrdinalIndicatorString.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

internal extension Date {
    var ordinalIndicatorString: String {
        get {
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
    }
    
    var day: Date {
        get {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
            return Calendar.current.date(from: components)!
        }
    }
}
