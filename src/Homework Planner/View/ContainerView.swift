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

public class ContainerView: PanelView {
    @IBOutlet public var centerVerticalContstraint: NSLayoutConstraint!
    private var keyboardFrame: CGRect?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setVerticalConstraint() {
        guard let keyboardFrame = keyboardFrame,
              containsFirstResponder() else {
                return
        }
        
        let diff = frame.maxY - keyboardFrame.minY + 20
        if diff > 0 {
            centerVerticalContstraint.constant = -diff
        }

        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { notification in
            if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.keyboardFrame = keyboardFrame
                self.setVerticalConstraint()

            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { notification in
            self.keyboardFrame = nil
            UIView.animate(withDuration: 0.2) {
                self.centerVerticalContstraint.constant = 0
                self.superview?.layoutIfNeeded()
            }
        }
    }
}
