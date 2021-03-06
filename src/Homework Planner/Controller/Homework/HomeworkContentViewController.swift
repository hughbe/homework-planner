//
//  HomeworkContentViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 30/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public protocol HomeworkContentViewControllerDelegate {
    func homeworkContentViewController(viewController: HomeworkContentViewController, didUpdateHomework homework: HomeworkViewModel)
}

public class HomeworkContentViewController: UIViewController {
    @IBOutlet weak var additionalActionsToolbar: UIToolbar!
    @IBOutlet weak var additionalActionsContainer: UIView!

    @IBOutlet weak var workSetTextView: UITextView!
    @IBOutlet weak var typeButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var websiteButton: UIBarButtonItem!
    @IBOutlet weak var attachmentsButton: UIBarButtonItem!

    public var homework: HomeworkViewModel!
    public var delegate: HomeworkContentViewControllerDelegate?
    public var isEditingEnabled = true

    public override func viewDidLoad() {
        super.viewDidLoad()

        if let subject = homework.subject {
            navigationItem.title = subject.name
        }

        workSetTextView.text = homework.workSet
        typeButton.title = homework.typeString
        
        if !isEditingEnabled {
            typeButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .disabled)
            typeButton.isEnabled = false

            workSetTextView.isEditable = false
            cameraButton.setHidden(true)
            websiteButton.setHidden(true)

            let attachmentsCount = homework.numberOfAttachments
            if let title = attachmentsButton.title, attachmentsCount > 0 {
                attachmentsButton.title = title + " (\(attachmentsCount))"
            } else {
                attachmentsButton.isEnabled = false
            }
            
            attachmentsButton.isEnabled = attachmentsCount > 0
            navigationItem.rightBarButtonItem = nil
        }

        checkValid()
    }
    
    public override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        
        if isBeingPresented || isMovingToParentViewController {
            additionalActionsContainer.setNeedsLayout()
            additionalActionsContainer.layoutIfNeeded()
            workSetTextView.becomeFirstResponder()
        }
    }

    @IBAction func next(_ sender: Any) {
        view.endEditing(true)
        homework.workSet = workSetTextView.text
        
        delegate?.homeworkContentViewController(viewController: self, didUpdateHomework: homework)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
        
        if !isEditingEnabled {
            navigationController?.dismiss(animated: true)
        }
    }

    @IBAction func changeType(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("Homework Type", comment: "Homework Type"), message: nil, preferredStyle: .actionSheet)
        
        for type in HomeworkViewModel.WorkType.allValues {
            alertController.addAction(UIAlertAction(title: type.name, style: .default) { action in
                self.homework.setType(type: type)
                self.typeButton.title = self.homework.typeString
            })
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel))

        alertController.popoverPresentationController?.barButtonItem = typeButton
        present(alertController, animated: true)
    }
    
    private func isValid() -> Bool {
        guard let workSet = workSetTextView.text else {
            return false
        }

        return workSet.count != 0
    }
    
    private func checkValid() {
        let isValid = self.isValid()
        
        // Work around a bug in UIKit?
        // Commenting out the line below means this doesn't work...
        navigationItem.rightBarButtonItem?.isEnabled = !isValid
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        view.endEditing(true)

        if let createAttachmentViewController = segue.destination as? CreateAttachmentViewController {
            createAttachmentViewController.delegate = self
        } else if let attachmentsViewController = segue.destination as? AttachmentsViewController {
            attachmentsViewController.homework = homework
            attachmentsViewController.isEditingEnabled = isEditingEnabled
        }
    }
    
    public static func create(for homework: HomeworkViewModel) -> UIViewController {
        let homeworkViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeworkContentViewController") as! HomeworkContentViewController
        homeworkViewController.homework = homework
        homeworkViewController.isEditingEnabled = false
        
        let navigationController = UINavigationController(rootViewController: homeworkViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.modalTransitionStyle = .crossDissolve
        
        return navigationController
    }
}

extension HomeworkContentViewController : UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        checkValid()
    }
}

extension HomeworkContentViewController : CreateAttachmentViewControllerDelegate {
    public func createAttachmentViewController(viewController: CreateAttachmentViewController, didCreateAttachment attachment: AttachmentViewModel) {
        dismiss(animated: true)
        
        homework.addAttachment(attachment: attachment)
    }
    
    public func didCancel(viewController: CreateAttachmentViewController) {
        dismiss(animated: true)
    }
}
