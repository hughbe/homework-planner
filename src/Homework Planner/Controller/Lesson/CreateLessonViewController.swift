//
//  CreateLessonViewController
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import DayDatePicker

public protocol CreateLessonViewControllerDelegate {
    func createLessonViewControllerDidCancel(viewController: CreateLessonViewController)
    func createLessonViewController(viewController: CreateLessonViewController, didCreateLesson lesson: Lesson)
}

public class CreateLessonViewController : UINavigationController {
    public var createDelegate: CreateLessonViewControllerDelegate?
    private var startTimeController: TimePickerViewController?
    private var endTimeController: TimePickerViewController?
    
    private var lesson = Lesson(context: AppDelegate.shared.persistentContainer.viewContext)
    
    public func setLesson(lesson: Lesson) {
        AppDelegate.shared.persistentContainer.viewContext.delete(self.lesson)
        self.lesson = lesson
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                if lesson.hasStartTime {
                    timePickerViewController.setTime(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
                }
            } else if segue.identifier == "setEndTime" {
                endTimeController = timePickerViewController
                timePickerViewController.navigationItem.title = NSLocalizedString("End Time", comment: "End Time")
                timePickerViewController.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Create", comment: "Create")
                
                if lesson.hasStartTime {
                    timePickerViewController.setMinTime(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
                }
                
                if lesson.hasEndTime {
                    timePickerViewController.setTime(hour: Int(lesson.endHour), minute: Int(lesson.endMinute))
                }
            }
            
            timePickerViewController.delegate = self
        }
    }
}

extension CreateLessonViewController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        createDelegate?.createLessonViewControllerDidCancel(viewController: self)
        AppDelegate.shared.persistentContainer.viewContext.rollback()
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: Subject) {
        lesson.subject = subject
        performSegue(withIdentifier: "setStartTime", sender: nil)
    }
}

extension CreateLessonViewController : TimePickerViewControllerDelegate {
    public func timePickerViewController(viewController: TimePickerViewController, didSelectTime time: TimePickerView.Time) {
        if viewController == startTimeController {
            lesson.startHour = Int32(time.hour)
            lesson.startMinute = Int32(time.minute)
            
            performSegue(withIdentifier: "setEndTime", sender: nil)
        } else if viewController == endTimeController {
            lesson.endHour = Int32(time.hour)
            lesson.endMinute = Int32(time.minute)
            
            createDelegate?.createLessonViewController(viewController: self, didCreateLesson: lesson)
        }
    }
}
