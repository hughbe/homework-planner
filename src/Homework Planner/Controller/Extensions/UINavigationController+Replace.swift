//
//  UINavigationController+Replace.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 14/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

internal extension UINavigationController {
    func replaceNavigationBar(with view: UIView) {
        view.clipsToBounds = true
        navigationBar.addSubview(view)
        navigationBar.addConstraints([
            NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: navigationBar, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: navigationBar, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: navigationBar, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: navigationBar, attribute: .bottomMargin, multiplier: 1, constant: 0)
        ])
    }
}
