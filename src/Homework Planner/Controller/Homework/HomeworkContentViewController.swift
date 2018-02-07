//
//  HomeworkContentViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 30/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public protocol HomeworkContentViewControllerDelegate {
    func homeworkContentViewController(viewController: HomeworkContentViewController, didUpdateHomework homework: Homework)
}

public class HomeworkContentViewController: UIViewController {
    @IBOutlet weak var additionalActionsView: UIView!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var attachmentsView: UIView!

    @IBOutlet weak var workSetTextView: UITextView!
    @IBOutlet weak var typeButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    
    public var homework: Homework!
    public var delegate: HomeworkContentViewControllerDelegate!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        additionalActionsView.addTopBorder(withHeight: 1, andColor: UIColor.black)
        typeView.addRightBorder(withWidth: 1, andColor: UIColor.black)
        
        navigationItem.title = homework.subject?.name
        workSetTextView.text = homework.workSet
        
        if let type = HomeworkType(rawValue: homework.type) {
            displayHomeworkType(type: type)
        }

        checkValid()
    }
    
    public override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        
        if isBeingPresented || isMovingToParentViewController {
            workSetTextView.becomeFirstResponder()
        }
    }

    @IBAction func next(_ sender: Any) {
        homework.workSet = workSetTextView.text
        
        delegate.homeworkContentViewController(viewController: self, didUpdateHomework: homework)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func changeType(_ sender: Any) {
        let actionSheet = UIAlertController(title: NSLocalizedString("Homework Type", comment: "Homework Type"), message: nil, preferredStyle: .actionSheet)
        
        for type in HomeworkType.allValues {
            let name = type.getName()
            actionSheet.addAction(UIAlertAction(title: name, style: .default) { action in
                self.homework.type = type.rawValue
                self.displayHomeworkType(type: type)
            })
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func displayHomeworkType(type: HomeworkType) {
        typeButton.setTitle(type.getName(), for: .normal)
    }
    
    private func checkValid() {
        let isValid: Bool
        if let workSet = workSetTextView.text {
            isValid = workSet.count != 0
        } else {
            isValid = false
        }
        
        // Work around a bug in UIKit?
        // Commenting out the line below means this doesn't work...
        navigationItem.rightBarButtonItem?.isEnabled = !isValid
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
}

extension HomeworkContentViewController : UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        checkValid()
    }
}

extension HomeworkContentViewController {
    @IBAction func addCameraAttachment(_ sender: Any) {
        print("addCameraAttachment: Not Implemented")
    }
    
    @IBAction func addWebsiteAttachment(_ sender: Any) {
        print("addWebsiteAttachment: Not Implemented")
    }
}
