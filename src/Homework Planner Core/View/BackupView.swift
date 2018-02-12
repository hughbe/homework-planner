//
//  BackupView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 11/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

extension UIImage {
    func tinted(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return self
        }

        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        context.setBlendMode(.multiply)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }

        UIGraphicsEndImageContext()
        
        return newImage
    }
}

@IBDesignable
public class BackupView : UIView {
    @IBInspectable
    public var mainMessage: String! {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var image: UIImage? {
        get {
            return imageView.image
        } set {
            imageView.image = newValue?.tinted(color: UIColor(white: 0.4, alpha: 1))
            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var subtitleMessage: String! {
        get {
           return subtitleLabel.text
        } set {
            subtitleLabel.text = newValue
            layoutIfNeeded()
        }
    }

    private var titleLabel = UILabel()
    private var imageView = UIImageView()
    private var subtitleLabel = UILabel()
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        guard imageView.superview == nil else {
            return
        }
        
        backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        subtitleLabel.textColor = UIColor(white: 0.4, alpha: 1)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.minimumScaleFactor = 0.5
        
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(subtitleLabel)

        addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleLabel.font.pointSize * 1.5),
            
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: imageView, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 20),
            
            NSLayoutConstraint(item: subtitleLabel, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: subtitleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: subtitleLabel, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: subtitleLabel, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: subtitleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: subtitleLabel.font.pointSize * 1.5)
        ])
        
        layoutIfNeeded()
    }
}
