//
//  AppDelegate.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import StoreKit
import UIColor_Additions
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    public static let barTintColor = UIColor(red: 5 / 255.0, green: 6 / 255.0, blue: 9 / 255.0, alpha: 1.0)
    
    static var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let foregroundColor = UIColor.white
        
        UITabBar.appearance().tintColor = foregroundColor
        UITabBar.appearance().barTintColor = AppDelegate.barTintColor
        UIToolbar.appearance().barTintColor = AppDelegate.barTintColor

        UINavigationBar.appearance().barTintColor = AppDelegate.barTintColor
        UISearchBar.appearance().barTintColor = AppDelegate.barTintColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : foregroundColor]

        UIBarButtonItem.appearance().tintColor = foregroundColor
        application.statusBarStyle = .lightContent
        
        UITextField.appearance().tintColor = UIColor.black
        UITextView.appearance().tintColor = UIColor.black
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0, green: 153 / 255.0, blue: 102 / 255.0, alpha: 1)
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).highlightedTextColor = UIColor.white
        
        UNUserNotificationCenter.current().delegate = self
        SKPaymentQueue.default().add(self)
        
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Homework_Planner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( [.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            completionHandler()
            return
        }
        
        guard let url = URL(string: response.notification.request.identifier), let id = persistentContainer.viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url), let viewController = self.window?.rootViewController else {
            completionHandler()
            return
        }

        do {
            let homework = try persistentContainer.viewContext.existingObject(with: id) as! Homework
            
            viewController.present(HomeworkContentViewController.create(for: homework), animated: true)
        } catch let error as NSError {
            print(error)
        }

        completionHandler()
    }
    
    private func reloadTimetableViewController() {
        let tabBarController = window?.rootViewController as? UITabBarController
        if let navigationController = tabBarController?.viewControllers?[1] as? UINavigationController, let viewController = navigationController.viewControllers.first as? TimetableViewController {
            viewController.reloadAnimation = .fade
            
            if viewController.notPurchasedView != nil {
                viewController.loadData(animated: true)
            }
        }
    }
}

extension AppDelegate : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                let productId = transaction.payment.productIdentifier
                if productId == InAppPurchases.unlockTimetable.rawValue {
                    Settings.purchasedTimetable = true
                    reloadTimetableViewController()
                }
                break
            case .restored:
                let productId = transaction.original?.payment.productIdentifier
                if productId == InAppPurchases.unlockTimetable.rawValue {
                    Settings.purchasedTimetable = true
                    reloadTimetableViewController()
                }
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred, .purchasing:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        window?.rootViewController?.showAlert(title: NSLocalizedString("Restored Purchases", comment: "Restored Purchases"), message: nil)
        
        paymentQueue(queue, updatedTransactions: queue.transactions)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        window?.rootViewController?.showAlert(error: error as NSError)
    }
}
