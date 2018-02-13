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
public class BackupView : UIControl {
    private var untintedImage: UIImage?
    
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
            untintedImage = newValue
            tintImageIfNeeded()
        }
    }
    
    @IBInspectable
    public var subtitleMessage: String! {
        get {
           return subtitleButton.title(for: .normal)
        } set {
            subtitleButton.isHidden = newValue == nil || newValue.count == 0
            subtitleButton.setTitle(newValue, for: .normal)

            layoutIfNeeded()
        }
    }
    
    @IBInspectable
    public var tintImage: Bool = true {
        didSet {
            tintImageIfNeeded()
        }
    }
    
    @IBInspectable public var actionableSubtitle: Bool = true {
        didSet {
            displaySubtitleButton()
        }
    }

    private var titleLabel = UILabel()
    private var imageView = UIImageView()
    public var subtitleButton = UIButton(type: .system)
    
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

        displaySubtitleButton()
        subtitleButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        subtitleButton.isHidden = subtitleMessage == nil || subtitleMessage.count == 0
        
        subtitleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        subtitleButton.titleLabel?.minimumScaleFactor = 0.5
        subtitleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 5)

        subtitleButton.translatesAutoresizingMaskIntoConstraints = false
        subtitleButton.addTarget(self, action: #selector(subtitleTapped), for: .touchUpInside)
        
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(subtitleButton)

        addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleLabel.font.pointSize * 1.5),
            
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 20),
            
            NSLayoutConstraint(item: subtitleButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: subtitleButton, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: subtitleButton, attribute: .bottom, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: subtitleButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: subtitleButton.titleLabel!.font.pointSize * 1.5)
        ])
        
        layoutIfNeeded()
    }
    
    @objc private func subtitleTapped(_ sender: UIButton) {
        sendActions(for: .touchUpInside)
    }
    
    private func displaySubtitleButton() {
        if actionableSubtitle {
            subtitleButton.layer.borderWidth = 1
            subtitleButton.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
            subtitleButton.layer.cornerRadius = 4
            subtitleButton.backgroundColor = UIColor(hue: 208 / 360, saturation: 0.72, brightness: 0.69, alpha: 1)
            subtitleButton.tintColor = UIColor.white
        } else {
            subtitleButton.layer.borderWidth = 0
            subtitleButton.backgroundColor = nil
            subtitleButton.tintColor = UIColor(white: 0.4, alpha: 1)
        }
    }
    
    private func tintImageIfNeeded() {
        if tintImage {
            imageView.image = untintedImage?.tinted(color: UIColor(white: 0.4, alpha: 1))
        } else {
            imageView.image = untintedImage
        }
    }
}
