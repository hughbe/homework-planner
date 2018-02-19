//
//  RootTabBarController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 07/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Date_Previous
import StoreKit
import UIKit

public class RootTabBarController : UITabBarController, UITabBarControllerDelegate {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.view.subviews.count > 0 {
            return true
        }
        
        // Settings
        let alertController = UIAlertController(title: NSLocalizedString("Settings", comment: "Settings"), message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Restore Purchases", comment: "Restore Purchases"), style: .default) { action in
            SKPaymentQueue.default().restoreCompletedTransactions()
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Change Subjects", comment: "Change Subjects"), style: .default) { action in
            let selectSubjectViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectSubjectViewController") as! SelectSubjectViewController
            selectSubjectViewController.selectionEnabled = false
            selectSubjectViewController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: selectSubjectViewController)
            self.present(navigationController, animated: true)
        })
        
        let toggleWeekends = Timetable.includeWeekends ? NSLocalizedString("Hide Weekends", comment: "Hide Weekends") : NSLocalizedString("Show Weekends", comment: "Show Weekends")
        alertController.addAction(UIAlertAction(title: toggleWeekends, style: .default) { action in
            Timetable.includeWeekends = !Timetable.includeWeekends
        })

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Set Homework Display Type", comment: "Set Homework Display Type"), style: .default) { action in
            
            let displayTypeAlertController = UIAlertController(title: NSLocalizedString("Homework Display Type", comment: "Homework Display Type"), message: nil, preferredStyle: .actionSheet)
            
            for type in HomeworkViewModel.DisplayType.allValues {
                displayTypeAlertController.addAction(UIAlertAction(title: type.name, style: .default) { action in
                    HomeworkViewModel.DisplayType.currentDisplay = type
                })
            }
            
            displayTypeAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

            displayTypeAlertController.popoverPresentationController?.sourceView = self.tabBar
            displayTypeAlertController.popoverPresentationController?.sourceRect = self.tabBar.bounds
            self.present(displayTypeAlertController, animated: true)
        })

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Set Number of Weeks", comment: "Set Number of Weeks"), style: .default) { action in
            
            let numberOfWeeksAlertController = UIAlertController(title: NSLocalizedString("Number of Weeks", comment: "Number of Weeks"), message: nil, preferredStyle: .actionSheet)
            
            numberOfWeeksAlertController.addAction(UIAlertAction(title: NSLocalizedString("1 Week", comment: "1 Week"), style: .default) { action in
                Timetable.numberOfWeeks = 1
            })
            
            numberOfWeeksAlertController.addAction(UIAlertAction(title: NSLocalizedString("2 Weeks", comment: "2 Weeks"), style: .default) { action in
                Timetable.numberOfWeeks = 2
            })

            numberOfWeeksAlertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

            numberOfWeeksAlertController.popoverPresentationController?.sourceView = self.tabBar
            numberOfWeeksAlertController.popoverPresentationController?.sourceRect = self.tabBar.bounds
            self.present(numberOfWeeksAlertController, animated: true)
        })

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

        alertController.popoverPresentationController?.sourceView = tabBar
        alertController.popoverPresentationController?.sourceRect = tabBar.bounds
        present(alertController, animated: true)
        
        return false
    }
}

extension RootTabBarController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        viewController.dismiss(animated: true)
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: SubjectViewModel) {
        viewController.dismiss(animated: true)
    }
}
