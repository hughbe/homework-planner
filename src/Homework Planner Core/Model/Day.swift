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

    public func dayDifference(from other: Day) -> Int {
        let total = week * 7 + dayOfWeek
        let otherTotal = other.week * 7 + other.dayOfWeek

        return total - otherTotal
    }
}
