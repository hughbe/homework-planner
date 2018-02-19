//
//  UrlAttachmentViewModel.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 19/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class UrlAttachmentViewModel : AttachmentViewModel {
    public convenience init() {
        self.init(attachment: UrlAttachment(context: CoreDataStorage.shared.context))
        type = .url
    }

    public init(attachment: UrlAttachment) {
        super.init(attachment: attachment)
    }

    public var url: URL? {
        get {
            return (attachment as! UrlAttachment).url
        }
        set {
            (attachment as! UrlAttachment).url = newValue
        }
    }
}
