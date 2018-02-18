//
//  UIViewController+ShowAlert.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit
import CoreData

public extension UIViewController {
    public func showAlert(error: NSError) {
        let message: String
        if error.code == NSValidationRelationshipDeniedDeleteError {
            message = NSLocalizedString("Cannot delete used", comment: "Cannot delete this subject as there are pieces of homework or lessons that use it.")
        } else {
            message = error.localizedDescription
        }
        
        showAlert(title: NSLocalizedString("Error", comment: "Error"), message: message)
    }

    public func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .default))
        
        present(alert, animated: true) {
            if let view = alert.view.superview {
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            }
        }
    }
    
    @objc private func alertControllerBackgroundTapped() {
        dismiss(animated: true, completion: nil)
    }
}
