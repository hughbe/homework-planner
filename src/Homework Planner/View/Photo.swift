//
//  Photo.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import NYTPhotoViewer
import UIKit

public class Photo : NSObject, NYTPhoto {
    public let title: String
    public let imageToDisplay: UIImage
    
    public init(title: String, image: UIImage) {
        self.title = title
        self.imageToDisplay = image
    }
    
    public var image: UIImage? {
        return imageToDisplay
    }
    
    public var imageData: Data? {
        return UIImageJPEGRepresentation(imageToDisplay, 1)
    }
    
    public var placeholderImage: UIImage? {
        return imageToDisplay
    }
    
    public var attributedCaptionTitle: NSAttributedString? {
        return NSAttributedString(string: title)
    }
    
    public var attributedCaptionSummary: NSAttributedString? {
        return nil
    }
    
    public var attributedCaptionCredit: NSAttributedString? {
        return nil
    }
}
