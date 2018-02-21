//
//  HomeworkTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public protocol HomeworkTableViewCellDelegate {
    func homeworkTableViewCellDidToggleCompleted(_ cell: HomeworkTableViewCell)
    func homeworkTableViewCellDidTogglePriority(_ cell: HomeworkTableViewCell)
}

public class HomeworkTableViewCell : ColorTableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var completedButton: UIButton!
    @IBOutlet private weak var priorityButton: UIButton!

    @IBOutlet private weak var titleTrailingToButtons: NSLayoutConstraint!
    @IBOutlet private weak var titleTrailingToSuperview: NSLayoutConstraint!

    public var delegate: HomeworkTableViewCellDelegate?

    public func configure(homework: HomeworkViewModel, display: HomeworkViewModel.DisplayType) {
        completedButton.setImage(homework.completedImage, for: .normal)
        priorityButton.setImage(homework.priorityImage, for: .normal)
        titleLabel.text = homework.title(displayType: display)
        detailLabel.text = homework.detail(displayType: display)
        detailLabel.textColor = homework.detailColor(displayType: display)
        configure(color: homework.subject!.color)

        completedButton.isHidden = delegate == nil
        priorityButton.isHidden = delegate == nil

        titleTrailingToButtons.isActive = delegate != nil
        titleTrailingToSuperview.isActive = delegate == nil
        contentView.layoutIfNeeded()
    }

    @IBAction func toggleCompleted(_ sender: Any) {
        delegate?.homeworkTableViewCellDidToggleCompleted(self)
    }

    @IBAction func togglePriority(_ sender: Any) {
        delegate?.homeworkTableViewCellDidTogglePriority(self)
    }
}
