//
//  HomeworkTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class HomeworkTableViewCell : UITableViewCell {
    @IBOutlet weak var workSetLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var completedButton: UIButton!
    
    private static var checkedImage = #imageLiteral(resourceName: "checked")
    private static var uncheckedImage = #imageLiteral(resourceName: "unchecked")
    
    public var completed = false {
        didSet {
            if completed {
                completedButton.setImage(HomeworkTableViewCell.checkedImage, for: .normal)
            } else {
                completedButton.setImage(HomeworkTableViewCell.uncheckedImage, for: .normal)
            }
        }
    }

    @IBAction func toggleCompleted(_ sender: Any) {
        completed = !completed
        if let completionHandler = completionHandler {
            completionHandler(self)
        }
    }
    
    public var completionHandler: ((HomeworkTableViewCell) -> ())?
}
