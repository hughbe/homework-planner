//
//  SubjectTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class SubjectTableViewCell : UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var colorLeadingConstraint: NSLayoutConstraint!
    
    public override func willTransition(to state: UITableViewCellStateMask) {
        super.willTransition(to: state)
        
        let editingView = findView(name: "UITableViewCellEditControl")
        let width = editingView?.frame.size.width ?? 47
        
        if state.contains(.showingEditControlMask) {
            separatorInset = UIEdgeInsets(top: 0, left: width + colorView.frame.size.width + 3, bottom: 0, right: 0)
            colorLeadingConstraint.constant = 12
        } else {
            separatorInset = UIEdgeInsets(top: 0, left: colorView.frame.size.width, bottom: 0, right: 0)
            colorLeadingConstraint.constant = 0
        }
    }
}
