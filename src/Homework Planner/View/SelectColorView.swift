//
//  SelectColorView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 31/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import Homework_Planner_Core

@objc public protocol SelectColorViewDelegate {
    func selectColorView(selectColorView: SelectColorView, didSelectColor color: UIColor)
}

public class SelectColorView : PanelView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet public var delegate: SelectColorViewDelegate!
    @IBOutlet public weak var collectionView: UICollectionView! {
        didSet {
            collectionView?.delegate = self
        }
    }

    public var selectedColor: UIColor? {
        didSet {
            collectionView.reloadData()
        }
    }

    public var colors: [UIColor] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let color = colors[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        cell.backgroundColor = color
        cell.layer.cornerRadius = 5
        
        if let selectedColor = selectedColor, selectedColor.isEqual(color) {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
        } else {
            cell.layer.borderWidth = 0
        }

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.row]
        delegate.selectColorView(selectColorView: self, didSelectColor: color)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets: CGFloat = 8

        let heightSmall = (frame.size.height - sectionInsets * 2) / 2 - 2

        let totalWidthSmall = CGFloat(colors.count / 2) * heightSmall
        if totalWidthSmall < frame.size.width * 0.75 {
            let heightLarge = frame.size.height - sectionInsets * 2
            return CGSize(width: heightLarge, height: heightLarge)
        }

        return CGSize(width: heightSmall, height: heightSmall)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        collectionView.collectionViewLayout.invalidateLayout()
    }
}
