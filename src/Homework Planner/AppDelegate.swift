//
//  AppDelegate.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import StoreKit
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    public static let barTintColor = UIColor(red: 5 / 255.0, green: 6 / 255.0, blue: 9 / 255.0, alpha: 1.0)
    public static let barForegroundColor = UIColor.white
    
    static var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().barTintColor = AppDelegate.barTintColor
        UIToolbar.appearance().barTintColor = AppDelegate.barTintColor

        UINavigationBar.appearance().barTintColor = AppDelegate.barTintColor
        UISearchBar.appearance().barTintColor = AppDelegate.barTintColor

        UITabBar.appearance().tintColor = AppDelegate.barForegroundColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : AppDelegate.barForegroundColor]
        UIBarButtonItem.appearance().tintColor = AppDelegate.barForegroundColor
        application.statusBarStyle = .lightContent
        
        UITextField.appearance().tintColor = UIColor.black
        UITextView.appearance().tintColor = UIColor.black

        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0, green: 153 / 255.0, blue: 102 / 255.0, alpha: 1)
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).highlightedTextColor = UIColor.white
        
        UNUserNotificationCenter.current().delegate = self
        SKPaymentQueue.default().add(InAppPurchase.transactionObserver)

        do {
            try LegacyImporter.importIfNeeded()
        } catch let error as NSError {
            window?.rootViewController?.showAlert(error: error)
        }
#if DEBUG
        try! DataInjector.injectIfNeeded()
#endif
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(InAppPurchase.transactionObserver)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let resourceSpecifier = (url as NSURL).resourceSpecifier, resourceSpecifier.count > 2 else {
            return false
        }

        guard let scheme = url.scheme else {
            return false
        }

        let index: String.Index = resourceSpecifier.index(resourceSpecifier.startIndex, offsetBy: 2)
        let objectData = String(resourceSpecifier[index...])

        if scheme == "homework-planner" {
            return showHomework(objectId: objectData)
        } else if scheme == "homework-planner-timetable" {
            guard let tabBarController = window?.rootViewController as? UITabBarController else {
                return false
            }

            tabBarController.selectedIndex = 1
            guard let navigationController = tabBarController.selectedViewController as? UINavigationController, let timetableViewController = navigationController.viewControllers[0] as? TimetableViewController else {
                return false
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard let date = dateFormatter.date(from: objectData) else {
                return false
            }

            timetableViewController.reloadAnimation = .fade
            timetableViewController.timetable = Timetable(date: date, modifyIfWeekend: false)

            return true
        }

        return false
    }
    
    @discardableResult
    private func showHomework(objectId: String) -> Bool {
        guard let url = URL(string: objectId), let id = CoreDataStorage.shared.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url), let viewController = window?.rootViewController else {
            return false
        }
        
        do {
            let homework = try CoreDataStorage.shared.context.existingObject(with: id) as! Homework
            
            viewController.present(HomeworkContentViewController.create(for: HomeworkViewModel(homework: homework)), animated: true)
            
            return true
        } catch let error as NSError {
            window?.rootViewController?.showAlert(error: error)
            return false
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
        
        showHomework(objectId: response.notification.request.identifier)
        completionHandler()
    }
}
