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
    
    public var date: DayDatePickerView.Date?
    public var minDate: DayDatePickerView.Date?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        if let minDate = minDate {
            datePickerView.setMinDate(minDate: minDate, animated: false)
        }
        
        let date = self.date ?? DayDatePickerView.Date(date: Date())
        datePickerView.setDate(date: date, animated: false)
    }

    @IBAction func handleSelected(_ sender: Any) {
        delegate?.dayDatePickerViewController(viewController: self, didSelectDate: datePickerView.date.date)
    }
}
