//
//  CreateUrlAttachmentViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Homework_Planner_Core
import UIKit

public class CreateUrlAttachmentViewController : CreateAttachmentViewController {
    @IBOutlet weak var urlTextField: UITextField!

    public var editingAttachment: UrlAttachment?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Can supply an existing attachment to prefill.
        if let attachment = editingAttachment {
            nameTextField.text = attachment.title
            urlTextField.text = attachment.url?.absoluteString
            checkValid()
        }
    }
    
    internal override func isValid() -> Bool {
        guard let name = nameTextField.text, let url = urlTextField.text else {
            return false
        }

        return name.count > 0 && url.count > 0 && (url != "http://" && url != "https://")
    }

    @IBAction func nameNext(_ sender: Any) {
        urlTextField.becomeFirstResponder()
    }
    
    @IBAction func urlChanged(_ sender: Any) {
        checkValid()
    }

    @IBAction func urlDone(_ sender: Any) {
        if isValid() {
            createAttachment(sender)
        }
    }
    
    @IBAction func createAttachment(_ sender: Any) {
        guard let urlText = urlTextField.text, let url = URL(string: urlText) else {
            showAlert(title: NSLocalizedString("Invalid url", comment: "Invalid url"), message: nil)
            return
        }
        
        guard let scheme = url.scheme, (scheme != "http" || scheme != "https") else {
            showAlert(title: NSLocalizedString("Invalid url scheme", comment: "Invalid url scheme"), message: nil)
            return
        }
        
        let createdAttachment = editingAttachment ?? UrlAttachment(context: CoreDataStorage.shared.context)
        
        createdAttachment.title = nameTextField.text
        createdAttachment.url = url
        createdAttachment.type = Attachment.ContentType.url.rawValue
        
        saveAttachment(attachment: createdAttachment)
    }
}
