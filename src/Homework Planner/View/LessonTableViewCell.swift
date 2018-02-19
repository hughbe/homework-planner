//
//  LessonTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class LessonTableViewCell : SubjectTableViewCell {
    @IBOutlet private weak var timeLabel: UILabel!

    public func configure(lesson: LessonViewModel) {
        configure(subject: lesson.subject!, selected: false)

        timeLabel.text = lesson.formattedDuration
        timeLabel.font = lesson.font
    }
}
