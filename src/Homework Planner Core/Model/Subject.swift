//
//  Subject.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

extension Subject {
    public class Colors {
        public static let all: [UIColor] = [
            UIColor(red: 255 / 255, green: 204 / 255, blue: 102 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 255 / 255, blue: 204 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 204 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 204 / 255, green: 102 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 111 / 255, blue: 207 / 255, alpha: 1),
            UIColor(red: 76 / 255, green: 76 / 255, blue: 76 / 255, alpha: 1),
            UIColor(red: 64 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 128 / 255, green: 64 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 102 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 255 / 255, blue: 102 / 255, alpha: 1),
            UIColor(red: 128 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 47 / 255, blue: 146 / 255, alpha: 1),
        ]

        public static func randomColor() -> UIColor {
            return all[Int(arc4random_uniform(UInt32(all.count)))]
        }
    }

    public static var CommonSubjects = [
        "Biology",
        "Chemistry",
        "Drama",
        "Economics",
        "English",
        "French",
        "Geography",
        "History",
        "Latin",
        "Maths",
        "PE",
        "Philosophy",
        "Politics",
        "Physics",
        "Russian",
        "Spanish"
    ]
    
    public var uiColor: UIColor? {
        get {
            guard let color = color else {
                return nil
            }
            
            return UIColor(string: color)
        }
        set {
            color = newValue?.stringRepresentation
        }
    }
}
