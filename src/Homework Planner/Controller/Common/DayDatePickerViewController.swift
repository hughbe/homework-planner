//
//  HomeworkDueDateViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import DayDatePicker

public protocol DayDatePickerViewControllerDelegate {
    func dayDatePickerViewController(viewController: DayDatePickerViewController, didSelectDate date: Date)
}

public class DayDatePickerViewController: UIViewController {
    @IBOutlet public weak var datePickerView: DayDatePickerView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    public var delegate: DayDatePickerViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let components = Calendar.current.dateComponents([.day, .month, .year], from: Date()) as NSDateComponents
        datePickerView.setMinDate(year: components.year, month: components.month, day: components.day, animated: false)
        datePickerView.setDate(year: components.year, month: components.month, day: components.day, animated: false)
    }

    @IBAction func handleSelected(_ sender: Any) {
        delegate?.dayDatePickerViewController(viewController: self, didSelectDate: datePickerView.date.date)
    }
}
