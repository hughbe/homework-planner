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
    
    private var minHour: Int?
    private var minMinute: Int?
    
    private var hour: Int?
    private var minute: Int?
    
    public func setTime(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    public func setMinTime(hour: Int, minute: Int) {
        self.minHour = hour
        self.minMinute = minute
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let minHour = minHour, let minMinute = minMinute {
            timePickerView.setMinTime(hour: minHour, minute: minMinute, animated: false)
        }

        if let hour = hour, let minute = minute {
            timePickerView.setTime(hour: hour, minute: minute, animated: false)
        } else {
            let components = Calendar.current.dateComponents([.hour, .minute], from: Date()) as NSDateComponents
            timePickerView.setTime(hour: components.hour, minute: components.minute, animated: false)
        }
    }
    
    public var delegate: TimePickerViewControllerDelegate?
    
    @IBAction func didSelect(_ sender: Any) {
        delegate?.timePickerViewController(viewController: self, didSelectTime: timePickerView.time)
    }
}
