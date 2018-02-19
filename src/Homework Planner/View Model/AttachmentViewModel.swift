//
//  AttachmentViewModel.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 19/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

public class AttachmentViewModel {
    internal let attachment: Attachment

    public init(attachment: Attachment) {
        self.attachment = attachment
    }

    public func delete() throws {
        try CoreDataStorage.shared.tryDelete(object: attachment)
    }

    public enum ContentType: Int32 {
        case url
        case image
    }

    public var type: AttachmentViewModel.ContentType {
        get {
            return AttachmentViewModel.ContentType(rawValue: attachment.type)!
        } set {
            attachment.type = newValue.rawValue
        }
    }

    public var title: String {
        get {
            return attachment.title ?? ""
        } set {
            attachment.title = newValue
        }
    }
}
