//
//  Homework.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

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

extension Homework {
    public var overdue: Bool {
        get {
            guard let dueDate = dueDate else {
                return false
            }

            return dueDate.compare(Date()) == ComparisonResult.orderedAscending && !completed;
        }
    }
}
