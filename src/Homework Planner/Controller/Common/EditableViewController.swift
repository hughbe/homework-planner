//
//  EditableViewController.swift
//  Homework Planner
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

        editButton.setHidden(!hasData)
    }

    @IBAction func edit(_ sender: Any) {
        setEditing(!tableView.isEditing, animated: true)
    }

    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)

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
