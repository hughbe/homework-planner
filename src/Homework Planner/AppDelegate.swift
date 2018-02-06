//
//  AppDelegate.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import CoreData
import UIColor_Additions
import DayDatePicker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let barTintColor = UIColor(red: 103.0 / 255.0, green: 130.0 / 255.0, blue: 180.0 / 255.0, alpha: 1.0).add_darkerColor(withValue: 0.75)
        let foregroundColor = UIColor.white
        
        UITabBar.appearance().tintColor = foregroundColor
        UITabBar.appearance().barTintColor = barTintColor
        UITabBar.appearance().backgroundColor = UIColor(red: 15 / 255.0, green: 85 / 255.0, blue: 160 / 255.0, alpha: 1.0)

        UINavigationBar.appearance().barTintColor = barTintColor
        UIToolbar.appearance().barTintColor = barTintColor
        UISearchBar.appearance().barTintColor = barTintColor
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : foregroundColor]

        UIBarButtonItem.appearance().tintColor = foregroundColor
        application.statusBarStyle = .lightContent
        
        UITextField.appearance().tintColor = UIColor.black
        UITextView.appearance().tintColor = UIColor.black
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
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
