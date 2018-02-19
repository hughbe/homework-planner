//
//  ImageAttachmentViewModel.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 19/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

#if !TODAY_EXTENSION
import INSPhotoGallery
#endif
import UIKit

public class ImageAttachmentViewModel : AttachmentViewModel {
    public convenience init() {
        self.init(attachment: ImageAttachment(context: CoreDataStorage.shared.context))
        type = .image
    }

    public init(attachment: ImageAttachment) {
        super.init(attachment: attachment)
    }

    public var image: UIImage? {
        get {
            guard let data = (attachment as! ImageAttachment).data else {
                return nil
            }

            return UIImage(data: data)
        } set {
            if let newValue = newValue {
                (attachment as! ImageAttachment).data = UIImageJPEGRepresentation(newValue, 1)
            } else {
                (attachment as! ImageAttachment).data = nil
            }
        }
    }

#if !TODAY_EXTENSION
    public var photo: INSPhotoViewable {
        let photo = INSPhoto(image: image, thumbnailImage: nil)
        if let title = (attachment as! ImageAttachment).title {
            photo.attributedTitle = NSAttributedString(string: title)
        }

        return photo
    }
#endif
}
