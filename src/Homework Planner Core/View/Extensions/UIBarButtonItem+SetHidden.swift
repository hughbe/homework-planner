//
//  UIBarButtonItem+SetHidden.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public extension UIBarButtonItem {
    public func setHidden(_ hidden: Bool) {
        if hidden {
            tintColor = UIColor.clear
            isEnabled = false
        } else {
            tintColor = nil
            isEnabled = true
        }
    }
}
