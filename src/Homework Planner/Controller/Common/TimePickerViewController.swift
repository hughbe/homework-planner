//
//  TimePickerViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import DayDatePicker

public protocol TimePickerViewControllerDelegate {
    func timePickerViewController(viewController: TimePickerViewController, didSelectTime time: TimePickerView.Time)
}

public class TimePickerViewController : UIViewController {
    @IBOutlet public weak var timePickerView: TimePickerView!
    @IBOutlet weak var selectBarButtonItem: UIBarButtonItem!
    
    public var minTime: TimePickerView.Time?
    public var time: TimePickerView.Time?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let minTime = minTime {
            timePickerView.setMinTime(minTime: minTime, animated: false)
        }

        let time = self.time ?? TimePickerView.Time(date: Date())
        timePickerView.setTime(time: time, animated: false)
    }
    
    public var delegate: TimePickerViewControllerDelegate?
    
    @IBAction func didSelect(_ sender: Any) {
        delegate?.timePickerViewController(viewController: self, didSelectTime: timePickerView.time)
    }
}
