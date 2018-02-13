//
//  AttachmentsViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 09/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Homework_Planner_Core
import NYTPhotoViewer
import SafariServices
import UIKit

public class AttachmentsViewController : UIViewController {
    @IBOutlet weak var attachmentsTableView: UITableView!
    @IBOutlet weak var noAttachmentsView: BackupView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!

    private var websites: [UrlAttachment] = []
    private var images: [ImageAttachment] = []
    
    public var homework: Homework!
    public var isEditingEnabled = true
    private var currentImage: UIImage!

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isEditingEnabled {
            editButton.hide()
            createButton.hide()
            noAttachmentsView.subtitleButton.isEnabled = false
            noAttachmentsView.actionableSubtitle = false
        }
        
        reloadData(animated: false)
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
        
        present(alertController, animated: true)
    }
    
    @IBAction func edit(_ sender: Any) {
        setEditingAttachments(editing: !attachmentsTableView.isEditing)
    }

    private func reloadData(animated: Bool) {
        let attachments = homework.attachments?.allObjects as? [Attachment] ?? []
        
        websites = attachments.filter { $0.type == Attachment.ContentType.url.rawValue }.map { $0 as! UrlAttachment }
        images = attachments.filter { $0.type == Attachment.ContentType.image.rawValue }.map { $0 as! ImageAttachment }
        
        UIView.transition(with: attachmentsTableView, duration: animated ? 0.35 : 0, options: .transitionCrossDissolve, animations: {
            self.attachmentsTableView.reloadData()
        })

        let hasAttachments = attachments.count > 0
        if attachmentsTableView.isEditing && !hasAttachments {
            setEditingAttachments(editing: false)
        }
        
        editButton.isEnabled = hasAttachments
        attachmentsTableView.setHidden(hidden: !hasAttachments, animated: animated)
        noAttachmentsView.setHidden(hidden: hasAttachments, animated: animated)
    }
    
    private func setEditingAttachments(editing: Bool) {
        attachmentsTableView.setEditing(editing, animated: true)
        
        if editing {
            editButton.title = NSLocalizedString("Done", comment: "Done")
            editButton.style = .done
        } else {
            editButton.title = NSLocalizedString("Edit", comment: "Edit")
            editButton.style = .plain
        }
        
        createButton.isEnabled = !editing
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createAttachmentViewController = segue.destination as? CreateAttachmentViewController {
            createAttachmentViewController.delegate = self
            
            if let editingAttachment = sender as? UrlAttachment {
                let createUrlAttachmentViewController = createAttachmentViewController as! CreateUrlAttachmentViewController
                createUrlAttachmentViewController.editingAttachment = editingAttachment
            } else if let editingAttachment = sender as? ImageAttachment {
                let createImageAttachmentViewController = createAttachmentViewController as! CreateImageAttachmentViewController
                createImageAttachmentViewController.editingAttachment = editingAttachment
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
            let website = websites[indexPath.row]
            
            cell.nameLabel.text = website.title
            cell.urlLabel.text = website.url?.absoluteString
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageAttachmentTableViewCell
            let image = images[indexPath.row]
            
            cell.nameLabel.text = image.title
            cell.previewImageView.image = image.image
            
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
                let photos = images.map { attachment -> NYTPhoto? in
                    guard let image = imageAttachment.image else {
                        return nil
                    }
        
                    return Photo(title: attachment.title ?? NSLocalizedString("Image", comment: "Image"), image: image)
                }.flatMap { $0 }
                
                let dataSource = NYTPhotoViewerArrayDataSource(photos: photos)
                let photosViewController = NYTPhotosViewController(dataSource: dataSource, initialPhotoIndex: indexPath.row, delegate: nil)
                
                present(photosViewController, animated: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isEditingEnabled
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let attachment: Attachment
            if websites.count > 0 && indexPath.section == 0 {
                attachment = websites[indexPath.row]
            } else {
                attachment = images[indexPath.row]
            }
            
            homework.removeFromAttachments(attachment)
            reloadData(animated: true)
        }
    }
}

extension AttachmentsViewController : CreateAttachmentViewControllerDelegate {
    public func createAttachmentViewController(viewController: CreateAttachmentViewController, didCreateAttachment attachment: Attachment) {
        dismiss(animated: true)
        
        homework.addToAttachments(attachment)
        reloadData(animated: true)
    }
    
    public func didCancel(viewController: CreateAttachmentViewController) {
        dismiss(animated: true)
    }
}
