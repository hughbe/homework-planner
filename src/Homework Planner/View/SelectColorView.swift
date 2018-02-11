//
//  SelectColorView.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 31/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

@objc public protocol SelectColorViewDelegate {
    func selectColorView(selectColorView: SelectColorView, didSelectColor color: UIColor)
}

public class SelectColorView : PanelView, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet public var delegate: SelectColorViewDelegate!
    public var selectedColor: UIColor?
    
    public static func getRandomColor() -> UIColor {
        return colors[Int(arc4random_uniform(UInt32(colors.count)))]
    }
    
    private static var colors: [UIColor] = [
        UIColor(red: 255 / 255, green: 204 / 255, blue: 102 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
        UIColor(red: 102 / 255, green: 255 / 255, blue: 204 / 255, alpha: 1),
        UIColor(red: 102 / 255, green: 204 / 255, blue: 255 / 255, alpha: 1),
        UIColor(red: 204 / 255, green: 102 / 255, blue: 255 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 111 / 255, blue: 207 / 255, alpha: 1),
        UIColor(red: 76 / 255, green: 76 / 255, blue: 76 / 255, alpha: 1),
        UIColor(red: 64 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1),
        UIColor(red: 128 / 255, green: 64 / 255, blue: 0 / 255, alpha: 1),
        UIColor(red: 102 / 255, green: 102 / 255, blue: 255 / 255, alpha: 1),
        UIColor(red: 102 / 255, green: 255 / 255, blue: 102 / 255, alpha: 1),
        UIColor(red: 128 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1),
        UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
        UIColor(red: 255 / 255, green: 47 / 255, blue: 146 / 255, alpha: 1),
    ]
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SelectColorView.colors.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let color = SelectColorView.colors[indexPath.row]
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
        let color = SelectColorView.colors[indexPath.row]
        delegate.selectColorView(selectColorView: self, didSelectColor: color)
    }
}
