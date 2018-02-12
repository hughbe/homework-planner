//
//  CreateLessonViewController
//  Homework Planner
//
//  Created by Hugh Bellamy on 06/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import DayDatePicker
import Homework_Planner_Core
import UIKit

public protocol CreateLessonViewControllerDelegate {
    func createLessonViewControllerDidCancel(viewController: CreateLessonViewController)
    func createLessonViewController(viewController: CreateLessonViewController, didCreateLesson lesson: Lesson)
}

public class CreateLessonViewController : UINavigationController {
    public var createDelegate: CreateLessonViewControllerDelegate?
    private var startTimeController: TimePickerViewController?
    private var endTimeController: TimePickerViewController?
    
    private var lesson: Lesson!
    private var subject: Subject!

    public var startHour: Int32?
    public var startMinute: Int32?
    public var editingLesson: Lesson?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let editingLesson = editingLesson {
            lesson = editingLesson
        } else {
            let entityDescription = NSEntityDescription.entity(forEntityName: "Lesson", in: CoreDataStorage.shared.context)!
            lesson = Lesson(entity: entityDescription, insertInto: nil)
        }
        
        if let startHour = startHour, let startMinute = startMinute {
            lesson.startHour = startHour
            lesson.startMinute = startMinute
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
                
                if lesson.hasStartTime {
                    let time = TimePickerView.Time(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
                    timePickerViewController.time = time
                }
            } else if segue.identifier == "setEndTime" {
                endTimeController = timePickerViewController
                timePickerViewController.navigationItem.title = NSLocalizedString("End Time", comment: "End Time")
                timePickerViewController.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Create", comment: "Create")
                
                if lesson.hasStartTime {
                    let time = TimePickerView.Time(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
                    timePickerViewController.minTime = time.time(byAddingHour: 0, andMinutes: 5)
                }

                if lesson.hasEndTime {
                    let time = TimePickerView.Time(hour: Int(lesson.endHour), minute: Int(lesson.endMinute))
                    timePickerViewController.time = time
                } else {
                    let time = TimePickerView.Time(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
                    timePickerViewController.time = time.time(byAddingHour: 0, andMinutes: 30)
                }
            }
            
            timePickerViewController.delegate = self
        }
    }
}

extension CreateLessonViewController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        createDelegate?.createLessonViewControllerDidCancel(viewController: self)
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: Subject) {
        self.subject = subject
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
            CoreDataStorage.shared.context.insert(lesson)

            lesson.subject = subject
            lesson.endHour = Int32(time.hour)
            lesson.endMinute = Int32(time.minute)

            createDelegate?.createLessonViewController(viewController: self, didCreateLesson: lesson)
        }
    }
}
