//
//  CreateHomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import DayDatePicker
import UIKit

public protocol CreateHomeworkViewControllerDelegate {
    func createHomeworkViewControllerDidCancel(viewController: CreateHomeworkViewController)
    func createHomeworkViewController(viewController: CreateHomeworkViewController, didCreateHomework homework: HomeworkViewModel)
}

public class CreateHomeworkViewController : UINavigationController {
    public var createDelegate: CreateHomeworkViewControllerDelegate?

    private var homework: HomeworkViewModel!
    private var subject: SubjectViewModel!

    public var editingHomework: HomeworkViewModel?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        homework = editingHomework ?? HomeworkViewModel(insert: false)

        let selectSubjectViewController = topViewController as! SelectSubjectViewController
        selectSubjectViewController.selectedSubject = homework.subject
        selectSubjectViewController.showCurrentLesson = true
        selectSubjectViewController.delegate = self
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeworkContentViewController = segue.destination as? HomeworkContentViewController {
            homeworkContentViewController.navigationItem.title = subject.name
            homeworkContentViewController.homework = homework
            homeworkContentViewController.delegate = self
        } else if let homeworkDueDateViewController = segue.destination as? DayDatePickerViewController {
            homeworkDueDateViewController.navigationItem.title = NSLocalizedString("Due Date", comment: "Due Date")
            homeworkDueDateViewController.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Create", comment: "Create")
            homeworkDueDateViewController.delegate = self

            homeworkDueDateViewController.minDate = DayDatePickerView.Date(date: Date())
            homeworkDueDateViewController.date = homework.date
        }
    }
}

extension CreateHomeworkViewController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        createDelegate?.createHomeworkViewControllerDidCancel(viewController: self)
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: SubjectViewModel) {
        self.subject = subject
        performSegue(withIdentifier: "setContent", sender: nil)
    }
}

extension CreateHomeworkViewController : HomeworkContentViewControllerDelegate {
    public func homeworkContentViewController(viewController: HomeworkContentViewController, didUpdateHomework homework: HomeworkViewModel) {
        performSegue(withIdentifier: "setDueDate", sender: nil)
    }
}

extension CreateHomeworkViewController : DayDatePickerViewControllerDelegate {
    public func dayDatePickerViewController(viewController: DayDatePickerViewController, didSelectDate date: Date) {
        homework.setDueDate(dueDate: date)

        do {
            try homework.create(subject: subject)
            createDelegate?.createHomeworkViewController(viewController: self, didCreateHomework: homework)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
}
