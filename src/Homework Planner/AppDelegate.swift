//
//  AppDelegate.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Homework_Planner_Core
import StoreKit
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
        
        guard let url = URL(string: response.notification.request.identifier), let id = CoreDataStorage.shared.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url), let viewController = self.window?.rootViewController else {
            completionHandler()
            return
        }

        do {
            let homework = try CoreDataStorage.shared.context.existingObject(with: id) as! Homework
            
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
