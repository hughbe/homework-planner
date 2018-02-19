//
//  CreateAttachmentViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public protocol CreateAttachmentViewControllerDelegate {
    func createAttachmentViewController(viewController: CreateAttachmentViewController, didCreateAttachment attachment: AttachmentViewModel)
    func didCancel(viewController: CreateAttachmentViewController)
}

public class CreateAttachmentViewController : UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var actionsView: ActionsView!
    
    public var delegate: CreateAttachmentViewControllerDelegate?

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeingPresented || isMovingToParentViewController {
            nameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        checkValid()
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        delegate?.didCancel(viewController: self)
    }
    
    internal func isValid() -> Bool {
        fatalError("Should not be called")
    }
    
    internal func checkValid() {
        let isValid = self.isValid()
        
        actionsView.createButton.isEnabled = isValid
    }
    
    internal func saveAttachment(attachment: AttachmentViewModel) {
        view.endEditing(true)
        delegate?.createAttachmentViewController(viewController: self, didCreateAttachment: attachment)
    }
}
