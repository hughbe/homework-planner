//
//  TimetableViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 05/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import DayDatePicker
import Date_Previous
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

    private var lessons: [LessonViewModel] = [] {
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

    public var timetable = Timetable(date: Date(), modifyIfWeekend: true) {
        didSet {
            currentDayButton.title = timetable.dayName
            setEditing(false, animated: true)
            reloadData()
        }
    }

    public override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: LessonTableViewCell.self), bundle: nil), forCellReuseIdentifier: "LessonCell")

        super.viewDidLoad()

        if !InAppPurchase.unlockTimetable.isPurchased {
            let request = SKProductsRequest(productIdentifiers: [InAppPurchase.unlockTimetable.rawValue])
            request.delegate = self
            request.start()

            tableView.isHidden = true
            noDataView.isHidden = true
        } else {
            notPurchasedView.isHidden = true
        }

        // Promote the toolbar from the view to the navigation controller.
        navigationController?.replaceNavigationBar(with: toolbar)
        currentDayButton.title = timetable.dayName

        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)

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

        register(notification: SubjectViewModel.Notifications.subjectsChanged) { _ in
            self.reloadAnimation = .fade
            self.reloadData()
        }

        register(notification: Timetable.Notifications.numberOfWeeksChanged) { _ in
            self.reloadAnimation = .fade
            self.currentDayButton.title = self.timetable.dayName
            self.reloadData()
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override public func reloadData() {
        do {
            lessons = try timetable.getLessons()
        } catch let error as NSError {
            showAlert(error: error)
        }
    }

    @IBAction func createLesson(_ sender: Any) {
        showCreateLesson { createLessonViewController in
            createLessonViewController.day = timetable.day
            createLessonViewController.startTime = lessons.last?.endTime
        }
    }
    
    private func showCreateLesson(presentationHandler: (CreateLessonViewController) -> ()) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateLessonNavigationViewController") as! CreateLessonViewController
        viewController.createDelegate = self
        presentationHandler(viewController)

        tabBarController?.present(viewController, animated: true)
    }
    
    @IBAction func goToPreviousDay(_ sender: Any) {
        reloadAnimation = .right
        timetable.previousDay()
    }
    
    @IBAction func currentDayTapped(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Options", comment: "Options"), message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Go To Today", comment: "Go To Today"), style: .default) { action in
            self.reloadAnimation = .fade
            self.timetable = Timetable(date: Date(), modifyIfWeekend: true)
        })
        
        if Timetable.numberOfWeeks != 1 {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Set Current Week", comment: "Set Current Week"), style: .default) { action in
                let currentWeeekAlertController = UIAlertController(title: NSLocalizedString("Current Week", comment: "Current Week"), message: nil, preferredStyle: .actionSheet)
                
                currentWeeekAlertController.addAction(UIAlertAction(title: NSLocalizedString("Week 1", comment: "Week 1"), style: .default) { action in
                    self.reloadAnimation = .fade
                    self.timetable.setCurrentWeek(week: 1)
                })
                
                currentWeeekAlertController.addAction(UIAlertAction(title: NSLocalizedString("Week 2", comment: "Week 2"), style: .default) { action in
                    self.reloadAnimation = .fade
                    self.timetable.setCurrentWeek(week: 2)
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
        timetable.nextDay()
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
    
    public func createLessonViewController(viewController: CreateLessonViewController, didCreateLesson lesson: LessonViewModel) {
        viewController.dismiss(animated: true)
        reloadData()
    }
}

extension TimetableViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath) as! LessonTableViewCell
        cell.configure(lesson: lessons[indexPath.row])
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try lessons[indexPath.row].delete()

                reloadAnimation = .fade
                lessons.remove(at: indexPath.row)
            } catch let error as NSError {
                showAlert(error: error)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard tableView.isEditing else {
            return
        }

        showCreateLesson { $0.editingLesson = lessons[indexPath.row] }
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
