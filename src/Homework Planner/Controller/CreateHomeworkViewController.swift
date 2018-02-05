//
//  CreateHomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class CreateHomeworkViewController : UINavigationController {
    private var subject: Subject?

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectSubjectViewController = topViewController as! SelectSubjectViewController
        selectSubjectViewController.delegate = self
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeworkContentViewController = segue.destination as? HomeworkContentViewController {
            homeworkContentViewController.navigationItem.title = subject!.name
        }
    }
}

extension CreateHomeworkViewController : SelectSubjectViewControllerDelegate {
    public func didCancel(viewController: SelectSubjectViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: Subject) {
        self.subject = subject
        performSegue(withIdentifier: "setContent", sender: nil)
    }
}
