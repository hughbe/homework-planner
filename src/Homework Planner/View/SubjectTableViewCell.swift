//
//  SubjectTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class SubjectTableViewCell : ColorTableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var teacherLabel: UILabel!

    public func configure(subject: SubjectViewModel, selected: Bool) {
        nameLabel.text = subject.name
        teacherLabel.text = subject.teacher

        if selected {
            nameLabel.textColor = UIColor.white
            teacherLabel.textColor = UIColor.white
            backgroundColor = UIColor(red: 0, green: 153 / 255.0, blue: 102 / 255.0, alpha: 1)
        }
        else {
            nameLabel.textColor = UIColor.black
            teacherLabel.textColor = UIColor(white: 0.4, alpha: 1)
            backgroundColor = UIColor.clear
        }
    }
}
