//
//  ActionsView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

@IBDesignable
public class ActionsView : UIView {
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var createButton: UIButton!
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        cancelView.addViewBackedBorder(side: .right, thickness: 1, color: UIColor.gray)
        addViewBackedBorder(side: .top, thickness: 1, color: UIColor.gray)
    }
}
