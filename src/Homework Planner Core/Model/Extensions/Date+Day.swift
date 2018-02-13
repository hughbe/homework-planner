//
//  Date+Day.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public extension Date {
    public var day: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components)!
    }
}
