//
//  Date+FormattedDayName.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public extension Date {
    public var formattedDayName: String {
        if Calendar.current.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Today")
        } else if Calendar.current.isDateInTomorrow(self) {
            return NSLocalizedString("Tomorrow", comment: "Tomorrow")
        }
        
        let prefixFormatter = DateFormatter()
        prefixFormatter.dateFormat = "EEEE d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = " MMM"
        
        return prefixFormatter.string(from: self) + ordinalIndicatorString + monthFormatter.string(from: self)
    }
}
