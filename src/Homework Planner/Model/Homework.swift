//
//  Homework.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Foundation

public enum HomeworkType: Int32 {
    case None
    case Essay
    case Exercise
    case Revision
    case Notes
    case Other
    
    func getName() -> String {
        switch self {
        case .None:
            return NSLocalizedString("None", comment: "None")
        case .Essay:
            return NSLocalizedString("Essay", comment: "Essay")
        case .Exercise:
            return NSLocalizedString("Exercise", comment: "Exercise")
        case .Revision:
            return NSLocalizedString("Revision", comment: "Revision")
        case .Notes:
            return NSLocalizedString("Notes", comment: "Notes")
        case .Other:
            return NSLocalizedString("Other", comment: "Other")
        }
    }
    
    static let allValues = [
        HomeworkType.None,
        HomeworkType.Essay,
        HomeworkType.Exercise,
        HomeworkType.Revision,
        HomeworkType.Notes,
        HomeworkType.Other,
    ]
}

private extension Date {
    
}

extension Homework {
    public var dueString: String {
        get {
            guard let dueDate = dueDate else {
                return "No Date"
            }

            let prefixFormatter = DateFormatter()
            prefixFormatter.formatterBehavior = .behavior10_4
            prefixFormatter.dateFormat = "EEEE dd"
            
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = " MMM"
            
            return prefixFormatter.string(from: dueDate) + dueDate.ordinalIndicatorString + monthFormatter.string(from: dueDate)
        }
    }
}
