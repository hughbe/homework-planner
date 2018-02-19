//
//  ColorTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 08/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class ColorTableViewCell : UITableViewCell {
    @IBOutlet private weak var colorView: UIView!
    @IBOutlet private weak var colorLeadingConstraint: NSLayoutConstraint!

    public func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = colorView.backgroundColor
        
        super.setHighlighted(highlighted, animated: animated)
        colorView.backgroundColor = color
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        let color = colorView.backgroundColor

        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = color
    }

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
