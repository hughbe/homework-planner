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

public class SelectColorView : PanelView, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet public var delegate: SelectColorViewDelegate!
    @IBOutlet weak var collectionView: UICollectionView!

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
}
