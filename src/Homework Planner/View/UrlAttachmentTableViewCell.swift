//
//  UrlAttachmentTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class UrlAttachmentTableViewCell : UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var urlLabel: UILabel!

    public func configure(attachment: UrlAttachmentViewModel) {
        nameLabel.text = attachment.title
        urlLabel.text = attachment.url?.absoluteString
    }
}
