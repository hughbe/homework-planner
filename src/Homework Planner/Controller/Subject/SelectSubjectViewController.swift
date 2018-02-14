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

public class SelectSubjectViewController: EditableViewController {
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    private var subjects: [Subject] = [] {
        didSet {
            tableView.reloadData()
            setHasData(subjects.count != 0, animated: true)
        }
    }
    public var delegate: SelectSubjectViewControllerDelegate?
    
    public var selectedSubject: Subject?
    public var selectionEnabled = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = selectionEnabled

        if let selectedSubject = selectedSubject, let index = subjects.index(where: { $0.objectID == selectedSubject.objectID }) {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
            }
        }
    }

    public override func reloadData() {
        let request = NSFetchRequest<Subject>(entityName: "Subject")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Subject.name, ascending: true),
            NSSortDescriptor(keyPath: \Subject.teacher, ascending: true)
        ]

        do {
            subjects = try CoreDataStorage.shared.context.fetch(request)
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
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let createSubjectViewController = segue.destination as? CreateSubjectViewController {
            createSubjectViewController.delegate = self
            if let subject = sender as? Subject {
                createSubjectViewController.editingSubject = subject
            }
        }
    }
}

extension SelectSubjectViewController : CreateSubjectViewControllerDelegate {
    public func createSubjectViewController(viewController: CreateSubjectViewController, didCreateSubject: Subject) {

        do {
            try CoreDataStorage.shared.context.save()
            dismiss(animated: true)

            NotificationCenter.default.post(name: Subject.Notifications.subjectsChanged, object: nil)
            reloadData()
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
        tableView.deselectRow(at: indexPath, animated: true)

        guard selectionEnabled else {
            return
        }
        
        let subject = subjects[indexPath.row]
        if tableView.isEditing {
            performSegue(withIdentifier: "createEditSubject", sender: subject)
        } else {
            selectedSubject = subject
            tableView.reloadData()
            
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

                NotificationCenter.default.post(name: Subject.Notifications.subjectsChanged, object: nil)
                reloadData()
            } catch let error as NSError {
                CoreDataStorage.shared.context.rollback()
                showAlert(error: error)
            }
        }
    }
}
