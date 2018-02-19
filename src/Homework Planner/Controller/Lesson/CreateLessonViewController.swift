//
//  CreateLessonViewController
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import DayDatePicker
import UIKit

public protocol CreateLessonViewControllerDelegate {
    func createLessonViewControllerDidCancel(viewController: CreateLessonViewController)
    func createLessonViewController(viewController: CreateLessonViewController, didCreateLesson lesson: LessonViewModel)
}

public class CreateLessonViewController : UINavigationController {
    public var createDelegate: CreateLessonViewControllerDelegate?
    private var startTimeController: TimePickerViewController?
    private var endTimeController: TimePickerViewController?
    
    private var lesson: LessonViewModel!
    private var subject: SubjectViewModel!

    public var day: Day?
    public var startTime: TimePickerView.Time?
    public var editingLesson: LessonViewModel?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        lesson = editingLesson ?? LessonViewModel(insert: false)
        lesson.startTime = startTime
        if let day = day {
            lesson.setDay(day: day)
        }
        
        let selectSubjectViewController = topViewController as! SelectSubjectViewController
        selectSubjectViewController.selectedSubject = lesson.subject
        selectSubjectViewController.delegate = self
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let timePickerViewController = segue.destination as? TimePickerViewController {
            if segue.identifier == "setStartTime" {
                startTimeController = timePickerViewController
                timePickerViewController.navigationItem.title = NSLocalizedString("Start Time", comment: "Start Time")
                timePickerViewController.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Next", comment: "Next")

                timePickerViewController.time = lesson.startTime
            } else if segue.identifier == "setEndTime" {
                endTimeController = timePickerViewController
                timePickerViewController.navigationItem.title = NSLocalizedString("End Time", comment: "End Time")
                timePickerViewController.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Create", comment: "Create")

                timePickerViewController.minTime = lesson.startTime?.time(byAddingHour: 0, andMinutes: 5)
                timePickerViewController.time = lesson.endTime
            }
            
            timePickerViewController.delegate = self
        }
    }
}

extension CreateLessonViewController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        createDelegate?.createLessonViewControllerDidCancel(viewController: self)
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: SubjectViewModel) {
        self.subject = subject
        performSegue(withIdentifier: "setStartTime", sender: nil)
    }
}

extension CreateLessonViewController : TimePickerViewControllerDelegate {
    public func timePickerViewController(viewController: TimePickerViewController, didSelectTime time: TimePickerView.Time) {
        if viewController == startTimeController {
            lesson.startTime = time
            performSegue(withIdentifier: "setEndTime", sender: nil)
        } else if viewController == endTimeController {
            lesson.endTime = time

            do {
                try lesson.create(subject: subject)
                createDelegate?.createLessonViewController(viewController: self, didCreateLesson: lesson)
            } catch let error as NSError {
                showAlert(error: error)
            }
        }
    }
}
