//
//  HomeworkTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class HomeworkTableViewCell : ColorTableViewCell {
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var detailLabel: UILabel!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var priorityButton: UIButton!
    
    private static var checkedImage = #imageLiteral(resourceName: "checked")
    private static var uncheckedImage = #imageLiteral(resourceName: "unchecked")
    
    private static var starredImage = #imageLiteral(resourceName: "starred")
    private static var unstarredImage = #imageLiteral(resourceName: "unstarred")
    
    public var completed = false {
        didSet {
            if completed {
                completedButton.setImage(HomeworkTableViewCell.checkedImage, for: .normal)
            } else {
                completedButton.setImage(HomeworkTableViewCell.uncheckedImage, for: .normal)
            }
        }
    }
    
    public var completionHandler: ((HomeworkTableViewCell) -> ())?

    public var priority = false {
        didSet {
            if priority {
                priorityButton.setImage(HomeworkTableViewCell.starredImage, for: .normal)
            } else {
                priorityButton.setImage(HomeworkTableViewCell.unstarredImage, for: .normal)
            }
        }
    }
    
    public var priorityHandler: ((HomeworkTableViewCell) -> ())?

    @IBAction func toggleCompleted(_ sender: Any) {
        completed = !completed
        if let completionHandler = completionHandler {
            completionHandler(self)
        }
    }

    @IBAction func togglePriority(_ sender: Any) {
        priority = !priority
        if let priorityHandler = priorityHandler {
            priorityHandler(self)
        }
    }
}
