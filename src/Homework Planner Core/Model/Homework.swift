//
//  Homework.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Foundation

public extension Homework {
    public enum WorkType: Int32 {
        case none
        case essay
        case exercise
        case revision
        case notes
        case other
        
        public var name: String {
            switch self {
            case .none:
                return NSLocalizedString("No Type", comment: "No Type")
            case .essay:
                return NSLocalizedString("Essay", comment: "Essay")
            case .exercise:
                return NSLocalizedString("Exercise", comment: "Exercise")
            case .revision:
                return NSLocalizedString("Revision", comment: "Revision")
            case .notes:
                return NSLocalizedString("Notes", comment: "Notes")
            case .other:
                return NSLocalizedString("Other", comment: "Other")
            }
        }
        
        public static let allValues: [Homework.WorkType] = [
            .none,
            .essay,
            .exercise,
            .revision,
            .notes,
            .other
        ]
    }
    
    public enum ComparisonType {
        case none
        case subject
        case date
    }
    
    public enum DisplayType: Int {
        case sectionedByDate
        case sectionedBySubject
        
        public var name: String {
            switch self {
            case .sectionedByDate:
                return NSLocalizedString("Order By Date", comment: "Order By Date")
            case .sectionedBySubject:
                return NSLocalizedString("Order By Subject", comment: "Order By Subject")
            }
        }
        
        public static let allValues: [DisplayType] = [
            .sectionedByDate,
            .sectionedBySubject
        ]
    }

    public func isGreaterThan(other: Homework, comparisonType: ComparisonType) -> Bool {
        if priority != other.priority {
            if priority {
                // Greater priority than the other.
                return other.completed == completed || !completed
            } else {
                // Lower priority than the other.
                return !completed && other.completed
            }
        }
        
        if completed != other.completed {
            if completed {
                return false
            } else if other.completed {
                return true
            }
        }
        
        if comparisonType == .subject {
            let name1 = subject?.name ?? ""
            let name2 = other.subject?.name ?? ""
            
            return name1.compare(name2) == .orderedDescending
        } else if comparisonType == .date {
            let date1 = dueDate ?? Date().day
            let date2 = other.dueDate ?? Date().day
            
            return date1.compare(date2) == .orderedDescending
        } else {
            return true
        }
    }
}