//
//  ContainerView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 29/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

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
        guard let keyboardFrame = keyboardFrame, let superview = superview else {
            return
        }
        guard let superCenter = superview.superview?.convert(superview.center, to: nil) else {
            return
        }

        let maxY = superCenter.y + frame.size.height / 2
        let keyboardY = keyboardFrame.minY - 20
        if maxY < keyboardY {
            return
        }

        let diff = keyboardY - maxY
        let minY = superCenter.y - frame.size.height / 2

        if minY + diff > 0 {
            centerVerticalContstraint.constant = diff
        } else {
            centerVerticalContstraint.constant = -superCenter.y / 2 + 40
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

    public override func layoutSubviews() {
        super.layoutSubviews()


        guard self.containsFirstResponder() else {
            return
        }

        setVerticalConstraint(duration: 0.35, options: [])
    }
}
