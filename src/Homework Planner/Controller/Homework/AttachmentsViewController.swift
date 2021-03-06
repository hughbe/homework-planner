//
//  AttachmentsViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import INSPhotoGallery
import SafariServices
import UIKit

public class AttachmentsViewController : EditableViewController {
    private var websites: [UrlAttachmentViewModel] = []
    private var images: [ImageAttachmentViewModel] = []
    
    public var homework: HomeworkViewModel!
    public var isEditingEnabled = true
    private var currentImage: UIImage!

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isEditingEnabled {
            editButton.setHidden(true)
            createButton.setHidden(true)
            (noDataView as! BackupView).subtitleButton.isEnabled = false
            (noDataView as! BackupView).actionableSubtitle = false
        }

        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func createAttachment(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Attachment Type", comment: "Attachment Type"), message: nil, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Website", comment: "Website"), style: .default) { action in
            self.performSegue(withIdentifier: "createUrlAttachment", sender: nil)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Image", comment: "Image"), style: .default) { action in
            self.performSegue(withIdentifier: "createImageAttachment", sender: nil)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))

        alertController.popoverPresentationController?.barButtonItem = createButton
        present(alertController, animated: true)
    }

    public override func reloadData() {
        reloadData(animated: false)
    }

    private func reloadData(animated: Bool) {
        websites = homework.websites
        images = homework.images
        
        UIView.transition(with: tableView, duration: animated ? 0.35 : 0, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })

        setHasData(homework.numberOfAttachments > 0, animated: animated)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createAttachmentViewController = segue.destination as? CreateAttachmentViewController {
            createAttachmentViewController.delegate = self
            
            if let editingAttachment = sender as? UrlAttachmentViewModel {
                let createUrlAttachmentViewController = createAttachmentViewController as! CreateUrlAttachmentViewController
                createUrlAttachmentViewController.editingAttachment = editingAttachment
            } else if let editingAttachment = sender as? ImageAttachmentViewModel {
                let createImageAttachmentViewController = createAttachmentViewController as! CreateImageAttachmentViewController
                createImageAttachmentViewController.editingAttachment = editingAttachment
            } else if sender != nil {
                fatalError("Unknown attachment")
            }
        }
    }
}

extension AttachmentsViewController : UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return (websites.count > 0 ? 1 : 0) + (images.count > 0 ? 1 : 0)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if websites.count > 0 && section == 0 {
            return NSLocalizedString("Websites", comment: "Websites")
        }
        
        return NSLocalizedString("Images", comment: "Images")
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if websites.count > 0 && section == 0 {
            return websites.count
        }
        
        return images.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if websites.count > 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UrlCell", for: indexPath) as! UrlAttachmentTableViewCell
            cell.configure(attachment: websites[indexPath.row])
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageAttachmentTableViewCell
            cell.configure(attachment: images[indexPath.row])
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if websites.count > 0 && indexPath.section == 0 {
            let websiteAttachment = websites[indexPath.row]
            if tableView.isEditing {
                performSegue(withIdentifier: "createUrlAttachment", sender: websiteAttachment)
            } else if let url = websiteAttachment.url {
                let safariViewController = SFSafariViewController(url: url)
                safariViewController.preferredBarTintColor = AppDelegate.barTintColor

                present(safariViewController, animated: true)
            }
        } else {
            let imageAttachment = images[indexPath.row]
            if tableView.isEditing {
                performSegue(withIdentifier: "createImageAttachment", sender: imageAttachment)
            } else {
                let photos = images.map { $0.photo }
                let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: photos[indexPath.row], referenceView: nil)
                
                present(galleryPreview, animated: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditingEnabled
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if websites.count > 0 && indexPath.section == 0 {
                homework.removeAttachment(attachment: websites[indexPath.row])
            } else {
                homework.removeAttachment(attachment: images[indexPath.row])
            }

            reloadData(animated: true)
        }
    }
}

extension AttachmentsViewController : CreateAttachmentViewControllerDelegate {
    public func createAttachmentViewController(viewController: CreateAttachmentViewController, didCreateAttachment attachment: AttachmentViewModel) {
        dismiss(animated: true)

        homework.addAttachment(attachment: attachment)
        reloadData(animated: true)
    }
    
    public func didCancel(viewController: CreateAttachmentViewController) {
        dismiss(animated: true)
    }
}
