//
//  TimetableViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Homework_Planner_Core
import StoreKit
import UIKit

public class TimetableViewController : UIViewController {
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    @IBOutlet weak var previousDayButton: UIBarButtonItem!
    @IBOutlet weak var currentDayButton: UIBarButtonItem!
    @IBOutlet weak var nextDayButton: UIBarButtonItem!

    @IBOutlet weak var notPurchasedView: UIView!
    @IBOutlet weak var noLessonsView: UIView!
    @IBOutlet weak var lessonsTableView: UITableView!
    
    public var reloadAnimation = UITableViewRowAnimation.none
    
    private var timetableProduct: SKProduct?

    private var lessons: [Lesson] = []
    public var day = Day(date: Date().day, modifyIfWeekend: true) {
        didSet {
            currentDayButton.title = day.name
            setEditingLessons(editing: false)
            loadData(animated: true)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if !InAppPurchase.unlockTimetable.isPurchased {
            let request = SKProductsRequest(productIdentifiers: [InAppPurchase.unlockTimetable.rawValue])
            request.delegate = self
            request.start()
        }
        
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

        currentDayButton.title = day.name
        loadData(animated: false)
    }
    
    @IBAction func editLessons(_ sender: Any) {
        setEditingLessons(editing: !lessonsTableView.isEditing)
    }

    @IBAction func createLesson(_ sender: Any) {
        let endHour = lessons.last?.endHour
        let endMinute = lessons.last?.endMinute

        showCreateLesson(lesson: nil, startHour: endHour, startMinute: endMinute)
    }
    
    private func showCreateLesson(lesson: Lesson?, startHour: Int32?, startMinute: Int32?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateLessonNavigationViewController") as! CreateLessonViewController
        viewController.createDelegate = self

        viewController.startHour = startHour
        viewController.startMinute = startMinute

        tabBarController?.present(viewController, animated: true)
    }
    
    @IBAction func goToPreviousDay(_ sender: Any) {
        reloadAnimation = .right
        day = day.previousDay
    }
    
    @IBAction func currentDayTapped(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Options", comment: "Options"), message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Go To Today", comment: "Go To Today"), style: .default) { action in
            self.reloadAnimation = .fade
            self.day = Day(date: Date(), modifyIfWeekend: true)
        })
        
        if Settings.numberOfWeeks != 1 {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Set Current Week", comment: "Set Current Week"), style: .default) { action in
                let currentWeeekAlertController = UIAlertController(title: NSLocalizedString("Current Week", comment: "Current Week"), message: nil, preferredStyle: .actionSheet)
                
                currentWeeekAlertController.addAction(UIAlertAction(title: NSLocalizedString("Week 1", comment: "Week 1"), style: .default) { action in
                    Settings.weekStart = self.day.date.previous(dayOfWeek: DayOfWeek.Monday)
                    self.day = Day(dayOfWeek: self.day.dayOfWeek, week: 1)
                })
                
                currentWeeekAlertController.addAction(UIAlertAction(title: NSLocalizedString("Week 2", comment: "Week 2"), style: .default) { action in
                    let date = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: self.day.date)!
                    Settings.weekStart = date.previous(dayOfWeek: DayOfWeek.Monday)
                    self.day = Day(dayOfWeek: self.day.dayOfWeek, week: 2)
                })
                
                currentWeeekAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
                
                self.present(currentWeeekAlertController, animated: true)
            })
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @IBAction func goToNextDay(_ sender: Any) {
        reloadAnimation = .left
        day = day.nextDay
    }
    
    public func loadData(animated: Bool) {
        guard InAppPurchase.unlockTimetable.isPurchased else {
            lessonsTableView.setHidden(hidden: true, animated: animated)
            noLessonsView.setHidden(hidden: true, animated: animated)
            
            notPurchasedView.setHidden(hidden: false, animated: animated)
            
            return
        }
    
        notPurchasedView.setHidden(hidden: true, animated: animated)
        
        let request = NSFetchRequest<Lesson>(entityName: "Lesson")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lesson.startHour, ascending: true),
            NSSortDescriptor(keyPath: \Lesson.startMinute, ascending: true)
        ]
        request.predicate = NSPredicate(format: "(dayOfWeek == %@) AND (week == %@)", argumentArray: [day.dayOfWeek, day.week])

        do {
            lessons = try CoreDataStorage.shared.context.fetch(request)
            
            if animated {
                lessonsTableView.beginUpdates()
                lessonsTableView.reloadSections(IndexSet(integer: 0), with: reloadAnimation)
                lessonsTableView.endUpdates()
            } else {
                lessonsTableView.reloadData()
            }
            
            let hasLessons = lessons.count != 0
            if hasLessons {
                editButton.tintColor = nil
                editButton.isEnabled = true
            } else {
                editButton.tintColor = UIColor.clear
                editButton.isEnabled = false
            }
            
            if lessonsTableView.isEditing && !hasLessons {
                setEditingLessons(editing: false)
            }
            
            lessonsTableView.setHidden(hidden: !hasLessons, animated: animated)
            noLessonsView.setHidden(hidden: hasLessons, animated: animated)
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

    @IBAction func restorePurchases(_ sender: Any) {
        guard let product = timetableProduct else {
            showAlert(title: NSLocalizedString("Invalid Product", comment: "Invalid Product"), message: nil)
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension TimetableViewController : CreateLessonViewControllerDelegate {
    public func createLessonViewControllerDidCancel(viewController: CreateLessonViewController) {
        viewController.dismiss(animated: true)
    }
    
    public func createLessonViewController(viewController: CreateLessonViewController, didCreateLesson lesson: Lesson) {
        do {
            lesson.dayOfWeek = Int32(day.dayOfWeek)
            lesson.week = Int32(day.week)
            
            try CoreDataStorage.shared.context.save()
            loadData(animated: true)
            viewController.dismiss(animated: true)
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
        cell.timeLabel.text = lesson.formattedDuration
        
        return cell
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
            CoreDataStorage.shared.context.delete(lesson)
            
            do {
                try CoreDataStorage.shared.context.save()
                
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
        showCreateLesson(lesson: lesson, startHour: nil, startMinute: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TimetableViewController : SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        timetableProduct = response.products.first { $0.productIdentifier == InAppPurchase.unlockTimetable.rawValue }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        showAlert(error: error as NSError)
    }
}
