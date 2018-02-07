//
//  TimetableViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

public class TimetableViewController : UIViewController {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    @IBOutlet weak var previousDayButton: UIBarButtonItem!
    @IBOutlet weak var currentDayButton: UIBarButtonItem!
    @IBOutlet weak var nextDayButton: UIBarButtonItem!

    @IBOutlet weak var noLessonsTableView: UIImageView!
    @IBOutlet weak var lessonsTableView: UITableView!
    
    private var reloadAnimation = UITableViewRowAnimation.none

    private var lessons: [Lesson] = []
    private var day = Day(date: Date()) {
        didSet {
            currentDayButton.title = day.name
            loadData(animated: true)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Promote the toolbar from the view to the navigation controller.
        if let view = navigationController?.view {
            toolbar.clipsToBounds = true

            view.addSubview(toolbar)
            view.addConstraints([
                NSLayoutConstraint(item: toolbar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: toolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            ])
        }

        loadData(animated: false)
    }
    
    @IBAction func editLessons(_ sender: Any) {
        setEditingLessons(editing: !lessonsTableView.isEditing)
    }

    @IBAction func createLesson(_ sender: Any) {
        showCreateLesson(lesson: nil)
    }
    
    private func showCreateLesson(lesson: Lesson?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateLessonNavigationViewController") as! CreateLessonViewController
        viewController.createDelegate = self
        if let lesson = lesson {
            viewController.setLesson(lesson: lesson)
        }
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func goToPreviousDay(_ sender: Any) {
        reloadAnimation = .right
        day = day.previousDay
    }
    
    @IBAction func currentDayTapped(_ sender: Any) {
    }
    
    @IBAction func goToNextDay(_ sender: Any) {
        reloadAnimation = .left
        day = day.nextDay
    }
    
    fileprivate func loadData(animated: Bool) {
        let request = NSFetchRequest<Lesson>(entityName: "Lesson")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lesson.startHour, ascending: true),
            NSSortDescriptor(keyPath: \Lesson.startMinute, ascending: true)
        ]
        request.predicate = NSPredicate(format: "(dayOfWeek == %@) AND (week == %@)", argumentArray: [day.dayOfWeek, day.week])

        do {
            lessons = try AppDelegate.shared.persistentContainer.viewContext.fetch(request)
            
            if animated {
                lessonsTableView.beginUpdates()
                lessonsTableView.reloadSections(IndexSet(integer: 0), with: reloadAnimation)
                lessonsTableView.endUpdates()
            } else {
                lessonsTableView.reloadData()
            }
            
            let hasLessons = lessons.count != 0
            if hasLessons {
                if var items = toolbar.items, let first = items.first, first != editButton {
                    items.insert(editButton, at: 0)
                    toolbar.setItems(items, animated: animated)
                }
            } else {
                if var items = toolbar.items, let first = items.first, first == editButton {
                    items.removeFirst()
                    toolbar.setItems(items, animated: animated)
                }
            }
            
            if lessonsTableView.isEditing && !hasLessons {
                setEditingLessons(editing: false)
            }
            
            lessonsTableView.setHidden(hidden: !hasLessons, animated: animated)
            noLessonsTableView.setHidden(hidden: hasLessons, animated: animated)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
    
    private func setEditingLessons(editing: Bool) {
        lessonsTableView.setEditing(editing, animated: true)
        
        if editing {
            editButton.title = NSLocalizedString("Done", comment: "Done")
            editButton.style = .done
        } else {
            editButton.title = NSLocalizedString("Edit", comment: "Edit")
            editButton.style = .plain
        }
        
        createButton.isEnabled = !editing
    }
}

extension TimetableViewController : CreateLessonViewControllerDelegate {
    public func createLessonViewControllerDidCancel(viewController: CreateLessonViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    public func createLessonViewController(viewController: CreateLessonViewController, didCreateLesson lesson: Lesson) {
        do {
            lesson.dayOfWeek = Int32(day.dayOfWeek)
            lesson.week = Int32(day.week)

            try AppDelegate.shared.persistentContainer.viewContext.save()
            loadData(animated: true)
            viewController.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
}

extension TimetableViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LessonTableViewCell
        let lesson = lessons[indexPath.row]

        cell.colorView.backgroundColor = lesson.subject?.uiColor ?? UIColor.black
        cell.nameLabel.text = lesson.subject?.name ?? "No Subject"
        cell.teacherLabel.text = lesson.subject?.teacher
        
        if let startDate = lesson.startDate, let endDate = lesson.endDate {
            let startTime = DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .short)
            let endTime = DateFormatter.localizedString(from: endDate, dateStyle: .none, timeStyle: .short)
            
            cell.timeLabel.text = startTime + " - " + endTime
        } else {
            cell.timeLabel.text = "No Time"
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let lesson = lessons[indexPath.row]
        if let teacher = lesson.subject?.teacher, teacher.count > 0 {
            return 85
        }
        
        return 75
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let lesson = lessons[indexPath.row]
            AppDelegate.shared.persistentContainer.viewContext.delete(lesson)
            
            do {
                try AppDelegate.shared.persistentContainer.viewContext.save()
                
                lessons.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .top)
                
                loadData(animated: true)
            } catch let error as NSError {
                showAlert(error: error)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            return
        }

        let lesson = lessons[indexPath.row]
        showCreateLesson(lesson: lesson)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
