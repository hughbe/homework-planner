//
//  ContainerView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 29/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import UIView_Borders

private extension UIView {
    func containsFirstResponder() -> Bool {
        for view in subviews {
            if view.isFirstResponder || view.containsFirstResponder() {
                return true
            }
        }
        
        return false
    }
}

public class ContainerView : PanelView {
    @IBOutlet public var centerVerticalContstraint: NSLayoutConstraint!
    private var keyboardFrame: CGRect?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setVerticalConstraint(duration: Double, options: UIViewAnimationOptions) {
        guard let keyboardFrame = keyboardFrame else {
            return
        }

        guard let originInWindow = superview?.convert(frame.origin, to: nil) else {
            return
        }
        
        let maxY = originInWindow.y + frame.size.height
        let diff = maxY - keyboardFrame.minY + 20
        if diff > 0 && originInWindow.y - diff > 0 {
            centerVerticalContstraint.constant = -diff
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { notification in
            guard self.containsFirstResponder() else {
                return
            }
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            
            let options: UIViewAnimationOptions
            if let rawValue = curve?.uintValue {
                options = UIViewAnimationOptions(rawValue: rawValue)
            } else {
                options = []
            }

            if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardFrame = keyboardFrame
                self.setVerticalConstraint(duration: duration?.doubleValue ?? 0.35, options: options)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { notification in
            guard self.containsFirstResponder() else {
                return
            }

            self.keyboardFrame = nil
            
            let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            
            let options: UIViewAnimationOptions = curve == nil ? [] : [UIViewAnimationOptions(rawValue: curve!.uintValue)]
            UIView.animate(withDuration: duration?.doubleValue ?? 0.2, delay: 0, options: options, animations: {
                self.centerVerticalContstraint.constant = 0
                self.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
