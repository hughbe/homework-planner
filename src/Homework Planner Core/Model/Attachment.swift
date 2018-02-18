//
//  Attachment.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import INSPhotoGallery
import UIKit

public extension Attachment {
    public enum ContentType: Int32 {
        case url
        case image
    }
}

public extension ImageAttachment {
    public var image: UIImage? {
        get {
            guard let data = data else {
                return nil
            }

            return UIImage(data: data)
        } set {
            if let newValue = newValue {
                data = UIImageJPEGRepresentation(newValue, 1)
            } else {
                data = nil
            }
        }
    }

    public var photo: INSPhotoViewable {
        let photo = INSPhoto(image: image, thumbnailImage: nil)
        if let title = title {
            photo.attributedTitle = NSAttributedString(string: title)
        }

        return photo
    }
}
