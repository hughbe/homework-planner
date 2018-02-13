//
//  UIBarButtonItem+Hide.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

internal extension UIBarButtonItem {
    func hide() {
        tintColor = UIColor.clear
        isEnabled = false
    }
}
