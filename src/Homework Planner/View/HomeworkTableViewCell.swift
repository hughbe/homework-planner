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
            
            displayDueDateLabel()
        }
    }
    
    public var dueDate = Date() {
        didSet {
            displayDueDateLabel()
        }
    }
    
    private func displayDueDateLabel() {
        let result = Calendar.current.compare(dueDate, to: Date(), toGranularity: .day)
        if result == .orderedAscending && !completed {
            dueLabel.textColor = UIColor.red
            dueLabel.text = NSLocalizedString("Overdue", comment: "Overdue") + " - " + getDueString(dueDate: dueDate)
        } else if result == .orderedSame && !completed {
            dueLabel.textColor = UIColor.orange
            dueLabel.text = NSLocalizedString("Today", comment: "Today")
        }
        else {
            dueLabel.textColor = UIColor(white: 0.6, alpha: 1)
            dueLabel.text = getDueString(dueDate: dueDate)
        }
    }

    @IBAction func toggleCompleted(_ sender: Any) {
        completed = !completed
        if let completionHandler = completionHandler {
            completionHandler(self)
        }
    }
    
    public var completionHandler: ((HomeworkTableViewCell) -> ())?
    
    private func getDueString(dueDate: Date) -> String {
        let prefixFormatter = DateFormatter()
        prefixFormatter.formatterBehavior = .behavior10_4
        prefixFormatter.dateFormat = "EEEE dd"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = " MMM"
        
        return prefixFormatter.string(from: dueDate) + dueDate.ordinalIndicatorString + monthFormatter.string(from: dueDate)
    }
}
