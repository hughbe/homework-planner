//
//  UIView+FindViewWithClassNamed.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 07/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

internal extension UIView {
    func findView(name: String) -> UIView? {
        for view in subviews {
            let className = NSStringFromClass(type(of: view))
            if className.caseInsensitiveCompare(name) == .orderedSame {
                return view
            }
            
            if let foundView = view.findView(name: name) {
                return foundView
            }
        }
        
        return nil
    }
}
