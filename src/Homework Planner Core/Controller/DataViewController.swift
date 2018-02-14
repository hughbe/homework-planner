//
//  DataViewController.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 14/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

open class DataViewController : UIViewController {
    @IBOutlet public weak var noDataView: UIView!
    @IBOutlet public weak var tableView: UITableView!

    private var notificationTokens: [NSObjectProtocol] = []

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Hide the views until data comes in.
        noDataView?.isHidden = true
        tableView.isHidden = true
        reloadData()
    }

    open func reloadData() {
        fatalError("Should be overriden.")
    }

    open func setHasData(_ hasData: Bool, animated: Bool) {
        tableView.setHidden(hidden: !hasData, animated: animated)
        noDataView?.setHidden(hidden: hasData, animated: animated)
    }

    public func register(notification: Notification.Name, handler: @escaping (Notification) -> Void) {
        notificationTokens.append(NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil, using: handler))
    }

    deinit {
        for token in notificationTokens {
            NotificationCenter.default.removeObserver(token)
        }
    }
}
