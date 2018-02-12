//
//  HomeworkDisplayType.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 07/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public enum HomeworkDisplayType: Int {
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
    
    public static let allValues = [
        HomeworkDisplayType.sectionedByDate,
        HomeworkDisplayType.sectionedBySubject
    ]
}
