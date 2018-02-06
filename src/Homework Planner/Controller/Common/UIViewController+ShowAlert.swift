//
//  UIViewController+ShowAlert.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showAlert(error: NSError) {
        showAlert(title: NSLocalizedString("Error", comment: "Error"), message: error.localizedDescription)
    }

    public func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
}
