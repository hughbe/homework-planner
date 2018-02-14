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

public class TimetableViewController : EditableViewController {
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var previousDayButton: UIBarButtonItem!
    @IBOutlet weak var currentDayButton: UIBarButtonItem!
    @IBOutlet weak var nextDayButton: UIBarButtonItem!

    @IBOutlet weak var notPurchasedView: UIView!
    
    public var reloadAnimation = UITableViewRowAnimation.none
    
    private var timetableProduct: SKProduct?

    private var lessons: [Lesson] = [] {
        didSet {
            if reloadAnimation != .none {
                tableView.beginUpdates()
                tableView.reloadSections(IndexSet(integer: 0), with: reloadAnimation)
                tableView.endUpdates()
            } else {
                tableView.reloadData()
            }

            setHasData(lessons.count != 0, animated: reloadAnimation != .none)
        }
    }

    public var day = Day(date: Date().day, modifyIfWeekend: true) {
        didSet {
            currentDayButton.title = day.name
            setEditing(false)
            reloadData()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if !InAppPurchase.unlockTimetable.isPurchased {
            let request = SKProductsRequest(productIdentifiers: [InAppPurchase.unlockTimetable.rawValue])
            request.delegate = self
            request.start()
        } else {
            notPurchasedView.isHidden = true
        }

        // Promote the toolbar from the view to the navigation controller.
        navigationController?.replaceNavigationBar(with: toolbar)
        currentDayButton.title = day.name

        register(notification: InAppPurchase.Notifications.purchaseError) { notification in
            if let transaction = notification.object as? SKPaymentTransaction, let error = transaction.error {
                self.showAlert(error: error as NSError)
            }
        }

        register(notification: InAppPurchase.Notifications.purchaseSuccess) { notification in
            if let transaction = notification.object as? SKPaymentTransaction, let error = transaction.error {
                self.showAlert(error: error as NSError)
            }
        }

        register(notification: Subject.Notifications.subjectsChanged) { _ in
            self.reloadData()
        }
    }

    override public func reloadData() {
        let request = NSFetchRequest<Lesson>(entityName: "Lesson")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lesson.startHour, ascending: true),
            NSSortDescriptor(keyPath: \Lesson.startMinute, ascending: true)
        ]
        request.predicate = NSPredicate(format: "(dayOfWeek == %@) AND (week == %@)", argumentArray: [day.dayOfWeek, day.week])

        do {
            lessons = try CoreDataStorage.shared.context.fetch(request)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }

    @IBAction func createLesson(_ sender: Any) {
        let endHour = lessons.last?.endHour
        let endMinute = lessons.last?.endMinute

        showCreateLesson(lesson: nil, startHour: endHour, startMinute: endMinute)
    }
    
    private func showCreateLesson(lesson: Lesson?, startHour: Int32?, startMinute: Int32?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateLessonNavigationViewController") as! CreateLessonViewController
        viewController.createDelegate = self

        viewController.editingLesson = lesson
        viewController.startHour = startHour
        viewController.startMinute = startMinute

        tabBarController?.present(viewController, animated: true)
    }
    
    @IBAction func goToPreviousDay(_ sender: Any) {
        reloadAnimation = .right
        day = day.previousDay
    }
    
    @IBAction func currentDayTapped(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Options", comment: "Options"), message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Go To Today", comment: "Go To Today"), style: .default) { action in
            self.reloadAnimation = .fade
            self.day = Day(date: Date(), modifyIfWeekend: true)
        })
        
        if Settings.numberOfWeeks != 1 {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Set Current Week", comment: "Set Current Week"), style: .default) { action in
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

                currentWeeekAlertController.popoverPresentationController?.barButtonItem = self.currentDayButton
                self.present(currentWeeekAlertController, animated: true)
            })
        }

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

        alertController.popoverPresentationController?.barButtonItem = currentDayButton
        present(alertController, animated: true)
    }
    
    @IBAction func goToNextDay(_ sender: Any) {
        reloadAnimation = .left
        day = day.nextDay
    }

    @IBAction func restorePurchases(_ sender: Any) {
        guard let product = timetableProduct else {
            showAlert(title: NSLocalizedString("Invalid Product", comment: "Invalid Product"), message: nil)
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            showAlert(title: NSLocalizedString("Purchases are disabled in your device", comment: "Purchases are disabled in your device"), message: nil)
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
        lesson.dayOfWeek = Int32(day.dayOfWeek)
        lesson.week = Int32(day.week)

        do {
            try CoreDataStorage.shared.context.save()
            viewController.dismiss(animated: true)

            reloadData()
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
        return 90
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let lesson = lessons[indexPath.row]
            CoreDataStorage.shared.context.delete(lesson)
            
            do {
                try CoreDataStorage.shared.context.save()
                
                lessons.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .top)
            } catch let error as NSError {
                CoreDataStorage.shared.context.rollback()
                showAlert(error: error)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard tableView.isEditing else {
            return
        }

        let lesson = lessons[indexPath.row]
        showCreateLesson(lesson: lesson, startHour: nil, startMinute: nil)
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
