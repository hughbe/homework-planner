//
//  Subject.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

extension Subject {
    public static var CommonSubjects = [
        "Biology",
        "Chemistry",
        "English",
        "Geography",
        "History",
        "Maths",
        "Physics",
    ]
    
    public var uiColor: UIColor? {
        get {
            guard let color = color else {
                return nil
            }
            
            return UIColor(string: color)
        }
        set {
            color = newValue?.getString()
        }
    }
}
