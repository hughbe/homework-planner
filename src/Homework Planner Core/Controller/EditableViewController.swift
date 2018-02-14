//
//  EditableViewController.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 14/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import UIKit

open class EditableViewController : DataViewController {
    @IBOutlet public var editButton: UIBarButtonItem!
    @IBOutlet public weak var createButton: UIBarButtonItem!

    open override func setHasData(_ hasData: Bool, animated: Bool) {
        super.setHasData(hasData, animated: animated)

        
    }

    @IBAction func edit(_ sender: Any) {
        setEditing(!tableView.isEditing)
    }

    public func setEditing(_ editing: Bool) {
        tableView.setEditing(editing, animated: true)

        if editing {
            editButton.title = NSLocalizedString("Done", comment: "Done")
            editButton.style = .done
        } else {
            editButton.title = NSLocalizedString("Edit", comment: "Edit")
            editButton.style = .plain
        }

        createButton.isEnabled = !editing
    }
}
