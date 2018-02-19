//
//  HomeworkTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class HomeworkTableViewCell : ColorTableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var completedButton: UIButton!
    @IBOutlet private weak var priorityButton: UIButton!

    public func configure(homework: HomeworkViewModel, display: HomeworkViewModel.DisplayType) {
        completedButton.setImage(homework.completedImage, for: .normal)
        priorityButton.setImage(homework.priorityImage, for: .normal)
        titleLabel.text = homework.title(displayType: display)
        detailLabel.text = homework.detail(displayType: display)
        detailLabel.textColor = homework.detailColor(displayType: display)
        configure(color: homework.subject!.color)

        completedButton.isHidden = completionHandler == nil
        priorityButton.isHidden = priorityHandler == nil
    }
    
    public var completionHandler: ((HomeworkTableViewCell) -> ())?
    
    public var priorityHandler: ((HomeworkTableViewCell) -> ())?

    @IBAction func toggleCompleted(_ sender: Any) {
        if let completionHandler = completionHandler {
            completionHandler(self)
        }
    }

    @IBAction func togglePriority(_ sender: Any) {
        if let priorityHandler = priorityHandler {
            priorityHandler(self)
        }
    }

    public var calculatedHeight: CGFloat {
        return detailLabel.frame.maxY + 17
    }
}
