//
//  CreateHomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import DayDatePicker
import UIKit

public protocol CreateHomeworkViewControllerDelegate {
    func createHomeworkViewControllerDidCancel(viewController: CreateHomeworkViewController)
    func createHomeworkViewController(viewController: CreateHomeworkViewController, didCreateHomework homework: Homework)
}

public class CreateHomeworkViewController : UINavigationController {
    public var createDelegate: CreateHomeworkViewControllerDelegate?

    private var homework = Homework(context: AppDelegate.shared.persistentContainer.viewContext)
    
    public func setHomework(homework: Homework) {
        AppDelegate.shared.persistentContainer.viewContext.delete(self.homework)
        self.homework = homework
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectSubjectViewController = topViewController as! SelectSubjectViewController
        selectSubjectViewController.selectedSubject = homework.subject
        selectSubjectViewController.delegate = self
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeworkContentViewController = segue.destination as? HomeworkContentViewController {
            homeworkContentViewController.homework = homework
            homeworkContentViewController.delegate = self
        } else if let homeworkDueDateViewController = segue.destination as? DayDatePickerViewController {
            homeworkDueDateViewController.navigationItem.title = NSLocalizedString("Due Date", comment: "Due Date")
            homeworkDueDateViewController.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Create", comment: "Create")
            homeworkDueDateViewController.delegate = self
            
            if let dueDate = homework.dueDate {
                homeworkDueDateViewController.minDate = DayDatePickerView.Date(date: Date())
                homeworkDueDateViewController.date = DayDatePickerView.Date(date: dueDate)
            }
        }
    }
}

extension CreateHomeworkViewController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        createDelegate?.createHomeworkViewControllerDidCancel(viewController: self)
        AppDelegate.shared.persistentContainer.viewContext.rollback()
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: Subject) {
        homework.subject = subject
        performSegue(withIdentifier: "setContent", sender: nil)
    }
}

extension CreateHomeworkViewController : HomeworkContentViewControllerDelegate {
    public func homeworkContentViewController(viewController: HomeworkContentViewController, didUpdateHomework homework: Homework) {
        performSegue(withIdentifier: "setDueDate", sender: nil)
    }
}

extension CreateHomeworkViewController : DayDatePickerViewControllerDelegate {
    public func dayDatePickerViewController(viewController: DayDatePickerViewController, didSelectDate date: Date) {
        homework.dueDate = date
        createDelegate?.createHomeworkViewController(viewController: self, didCreateHomework: homework)
    }
}
