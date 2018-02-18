//
//  Date+OrdinalIndicatorString.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public extension Date {
    public var ordinalIndicatorString: String {
        let day = Calendar.current.component(.day, from: self)

        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22, 32:
            return "nd"
        case 3, 23, 33:
            return "rd"
        default:
            return "th"
        }
    }
}
