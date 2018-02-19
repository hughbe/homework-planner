//
//  CreateImageAttachmentViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class CreateImageAttachmentViewController : CreateAttachmentViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    public var editingAttachment: ImageAttachmentViewModel?
    
    private var image: UIImage?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Can supply an existing attachment to prefill.
        if let attachment = editingAttachment {
            nameTextField.text = attachment.title
            imageView.image = attachment.image
            image = attachment.image
            checkValid()
        }
    }
    
    internal override func isValid() -> Bool {
        guard let name = nameTextField.text else {
            return false
        }
        
        return name.count > 0 && image != nil
    }
    
    @IBAction func nameNext(_ sender: Any) {
        nameTextField.resignFirstResponder()
    }
    
    @IBAction func changeImage(_ sender: Any) {
        view.endEditing(true)

        let alertController = UIAlertController(title: NSLocalizedString("Add Photo", comment: "Add Image"), message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { action in
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = self
                
                self.present(imagePickerController, animated: true)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Photo Library", comment: "Photo Library"), style: .default) { action in
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.delegate = self
                
                self.present(imagePickerController, animated: true)
            })
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default))

        alertController.popoverPresentationController?.sourceView = imageView
        alertController.popoverPresentationController?.sourceRect = imageView.bounds
        present(alertController, animated: true)
    }

    @IBAction func createAttachment(_ sender: Any) {
        guard let name = nameTextField.text else {
            return
        }

        let createdAttachment = editingAttachment ?? ImageAttachmentViewModel()
        
        createdAttachment.title = name
        createdAttachment.image = image

        saveAttachment(attachment: createdAttachment)
    }
}

extension CreateImageAttachmentViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)

        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.image = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = originalImage
        } else {
            showAlert(title: NSLocalizedString("Could not fetch image", comment: "Could not fetch image"), message: nil)
            return
        }
        
        imageView.image = image
        checkValid()
    }
}
