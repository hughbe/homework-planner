//
//  SubjectDependentViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 13/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

public class SubjectDependentViewController : UIViewController {
    private var notificationToken: NSObjectProtocol?

    public override func viewDidLoad() {
        super.viewDidLoad()

        notificationToken = NotificationCenter.default.addObserver(forName: SelectSubjectViewController.subjectsChangedNotification, object: nil, queue: nil) { notification in
            self.loadData(animated: true)
        }
    }

    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }

    public func loadData(animated: Bool) {
        fatalError("Should not be called")
    }
}
