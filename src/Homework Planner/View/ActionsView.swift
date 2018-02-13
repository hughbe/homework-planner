//
//  ActionsView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import UIView_Borders

@IBDesignable
public class ActionsView : UIView {
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var createButton: UIButton!
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        addTopBorder(withHeight: 1, andColor: UIColor.gray)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        addTopBorder(withHeight: 1, andColor: UIColor.gray)
    }
}
