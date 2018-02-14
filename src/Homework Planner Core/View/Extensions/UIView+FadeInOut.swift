//
//  UIView+FadeInOut.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public extension UIView {
    public func setHidden(hidden: Bool, animated: Bool) {
        guard isHidden != hidden else {
            return
        }
        
        guard animated else {
            isHidden = hidden
            alpha = 1
            return
        }
        
        if hidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }, completion: { completed in
                self.alpha = 1
                self.isHidden = true
            })
        } else {
            self.alpha = 0
            self.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
}
