//
//  UIColor+String.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 28/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import Foundation

public extension UIColor {
    public var stringRepresentation: String? {
        guard let components = cgColor.components else {
            return nil
        }
        
        return "[\(components[0]), \(components[1]), \(components[2]), \(components[3])]"
    }
    
    public convenience init?(string: String) {
        let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let components = componentsString.components(separatedBy: ", ")
        if components.count != 4 {
            return nil
        }

        self.init(red: CGFloat((components[0] as NSString).floatValue),
                       green: CGFloat((components[1] as NSString).floatValue),
                       blue: CGFloat((components[2] as NSString).floatValue),
                       alpha: CGFloat((components[3] as NSString).floatValue))
    }
}
