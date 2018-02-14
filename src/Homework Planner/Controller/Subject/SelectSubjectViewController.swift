//
//  SelectSubjectViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Homework_Planner_Core
import UIKit

public protocol SelectSubjectViewControllerDelegate {
    func didCancel(viewController: SelectSubjectViewController)
    func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: Subject)
}

public class SelectSubjectViewController: UIViewController {
    public static let subjectsChangedNotification = NSNotification.Name(rawValue: "SubjectsChangedNotification")

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!

    @IBOutlet weak var subjectsTableView: UITableView!
    @IBOutlet weak var noSubjectsView: UIView!

    private var subjects: [Subject] = []
    public var delegate: SelectSubjectViewControllerDelegate?
    
    public var selectedSubject: Subject?
    public var selectionEnabled = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        subjectsTableView.allowsSelection = selectionEnabled
        
        loadData(animated: false)
        if let selectedSubject = selectedSubject, let index = subjects.index(where: { $0.objectID == selectedSubject.objectID }) {
            subjectsTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
        }
    }

    private func loadData(animated: Bool) {
        let request = NSFetchRequest<Subject>(entityName: "Subject")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Subject.name, ascending: true)
        ]

        do {
            subjects = try CoreDataStorage.shared.context.fetch(request)

            subjectsTableView.reloadData()
            
            let hasSubjects = subjects.count != 0
            if subjectsTableView.isEditing && !hasSubjects {
                setEditingSubjects(editing: false)
            }
            
            editButton.isEnabled = hasSubjects
            subjectsTableView.setHidden(hidden: !hasSubjects, animated: animated)
            noSubjectsView.setHidden(hidden: hasSubjects, animated: animated)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }

    @IBAction func createSubject(_ sender: Any) {
        performSegue(withIdentifier: "createEditSubject", sender: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.didCancel(viewController: self )
    }
    
    @IBAction func edit(_ sender: Any) {
        setEditingSubjects(editing: !subjectsTableView.isEditing)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createSubjectViewController = segue.destination as? CreateSubjectViewController {
            createSubjectViewController.delegate = self
            if let subject = sender as? Subject {
                createSubjectViewController.editingSubject = subject
            }
        }
    }
    
    private func setEditingSubjects(editing: Bool) {
        subjectsTableView.setEditing(editing, animated: true)

        if editing {
            editButton.title = NSLocalizedString("Done", comment: "Done")
            editButton.style = .done
        } else {
            editButton.title = NSLocalizedString("Edit", comment: "Edit")
            editButton.style = .plain
        }

        createButton.isEnabled = !editing
    }

    private func subjectsDidUpdate() {
        NotificationCenter.default.post(name: SelectSubjectViewController.subjectsChangedNotification, object: nil)
        loadData(animated: true)
    }
}

extension SelectSubjectViewController : CreateSubjectViewControllerDelegate {
    public func createSubjectViewController(viewController: CreateSubjectViewController, didCreateSubject: Subject) {
        dismiss(animated: true)

        do {
            try CoreDataStorage.shared.context.save()

            subjectsDidUpdate()
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
    
    public func didCancel(viewController: CreateSubjectViewController) {
        dismiss(animated: true)
    }
}

extension SelectSubjectViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell") as! SubjectTableViewCell
        let subject = subjects[indexPath.row]
        let selected: Bool
        if let selectedSubject = selectedSubject, selectedSubject.objectID == subject.objectID {
            selected = true
        } else {
            selected = false
        }

        cell.colorView.backgroundColor = subject.uiColor ?? UIColor.black
        cell.nameLabel.text = subject.name
        cell.teacherLabel.text = subject.teacher
        
        if selected {
            cell.nameLabel.textColor = UIColor.white
            cell.teacherLabel.textColor = UIColor.white
            cell.backgroundColor = UIColor(red: 0, green: 153 / 255.0, blue: 102 / 255.0, alpha: 1)
        }
        else {
            cell.nameLabel.textColor = UIColor.black
            cell.teacherLabel.textColor = UIColor(white: 0.4, alpha: 1)
            cell.backgroundColor = UIColor.clear
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectionEnabled else {
            return
        }
        
        let subject = subjects[indexPath.row]
        if subjectsTableView.isEditing {
            performSegue(withIdentifier: "createEditSubject", sender: subject)
        } else {
            selectedSubject = subject
            subjectsTableView.reloadData()
            
            delegate?.selectSubjectViewController(viewController: self, didSelectSubject: subject)
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let subject = subjects[indexPath.row]
            CoreDataStorage.shared.context.delete(subject)

            do {
                try CoreDataStorage.shared.context.save()
                
                subjects.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)

                subjectsDidUpdate()
            } catch let error as NSError {
                showAlert(error: error)
            }
        }
    }
}
