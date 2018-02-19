//
//  ImageAttachmentTableViewCell.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class ImageAttachmentTableViewCell : UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!

    public func configure(attachment: ImageAttachmentViewModel) {
        nameLabel.text = attachment.title
        previewImageView.image = attachment.image
    }
}
