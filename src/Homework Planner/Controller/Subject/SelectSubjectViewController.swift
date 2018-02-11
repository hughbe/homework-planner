//
//  SelectSubjectViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

public protocol SelectSubjectViewControllerDelegate {
    func didCancel(viewController: SelectSubjectViewController)
    func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: Subject)
}

public class SelectSubjectViewController: UIViewController {
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
    }
    
    private func loadData(animated: Bool) {
        let request = NSFetchRequest<Subject>(entityName: "Subject")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Subject.name, ascending: true)
        ]

        do {
            subjects = try AppDelegate.shared.persistentContainer.viewContext.fetch(request)

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

    @IBAction func cancel(_ sender: Any) {
        delegate?.didCancel(viewController: self )
    }
    
    @IBAction func edit(_ sender: Any) {
        setEditingSubjects(editing: !subjectsTableView.isEditing)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createSubjectViewController = segue.destination as? CreateSubjectViewController {
            createSubjectViewController.delegate = self
            if segue.identifier == "editSubject" {
                createSubjectViewController.editingSubject = sender as? Subject
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
}

extension SelectSubjectViewController : CreateSubjectViewControllerDelegate {
    public func createSubjectViewController(viewController: CreateSubjectViewController, didCreateSubject: Subject) {
        dismiss(animated: true)
        loadData(animated: true)
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
            cell.teacherLabel.textColor = UIColor.black
            cell.backgroundColor = UIColor.clear
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectionEnabled else {
            return
        }
        
        let subject = subjects[indexPath.row]
        if subjectsTableView.isEditing {
            performSegue(withIdentifier: "editSubject", sender: subject)
        } else {
            selectedSubject = subject
            subjectsTableView.reloadData()
            
            delegate?.selectSubjectViewController(viewController: self, didSelectSubject: subject)
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let subject = subjects[indexPath.row]
            AppDelegate.shared.persistentContainer.viewContext.delete(subject)

            do {
                try AppDelegate.shared.persistentContainer.viewContext.save()
                
                subjects.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)

                loadData(animated: true)
            } catch let error as NSError {
                showAlert(error: error)
            }
        }
    }
}
