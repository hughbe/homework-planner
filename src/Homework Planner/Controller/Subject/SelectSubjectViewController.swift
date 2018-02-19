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
    func selectSubjectViewController(viewController: SelectSubjectViewController, didSelectSubject subject: SubjectViewModel)
}

public class SelectSubjectViewController: EditableViewController {
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    private var reloadAnimation = false

    private var subjects: [SubjectViewModel] = [] {
        didSet {
            UIView.transition(with: tableView, duration: reloadAnimation ? 0.35 : 0, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            })

            setHasData(subjects.count != 0, animated: reloadAnimation)

            // The first reload is the only one that is not animated.
            reloadAnimation = true
        }
    }
    public var delegate: SelectSubjectViewControllerDelegate?
    
    public var selectedSubject: SubjectViewModel?
    public var selectionEnabled = true
    public var showCurrentLesson = false

    private var currentLesson: LessonViewModel? = nil {
        didSet {
            if currentLesson != nil {
                tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
            } else {
                tableView.contentInset = UIEdgeInsets.zero
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = selectionEnabled

        if let selectedSubject = selectedSubject, let index = subjects.index(where: { $0.id == selectedSubject.id }) {
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
            subjects = try CoreDataStorage.shared.context.fetch(request).map(SubjectViewModel.init)
            if showCurrentLesson {
                let timetable = Timetable(date: Date(), modifyIfWeekend: false)
                currentLesson = try timetable.getCurrentLesson()
            } else {
                currentLesson = nil
            }
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
            if let subject = sender as? SubjectViewModel {
                createSubjectViewController.editingSubject = subject
            }
        }
    }
}

extension SelectSubjectViewController : CreateSubjectViewControllerDelegate {
    public func createSubjectViewController(viewController: CreateSubjectViewController, didCreateSubject: SubjectViewModel) {
        dismiss(animated: true)
        reloadData()
    }
    
    public func didCancel(viewController: CreateSubjectViewController) {
        dismiss(animated: true)
    }
}

extension SelectSubjectViewController : UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return currentLesson != nil ? 2 : 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentLesson != nil && section == 0 {
            return 1
        }

        return subjects.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell") as! SubjectTableViewCell

        let subject: SubjectViewModel
        if let currentLessonSubject = currentLesson?.subject, indexPath.section == 0 {
            subject = currentLessonSubject
        } else {
            subject = subjects[indexPath.row]
        }

        let selected: Bool
        if let selectedSubject = selectedSubject, selectedSubject.id == subject.id {
            selected = true
        } else {
            selected = false
        }

        cell.configure(subject: subject, selected: selected)

        return cell
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentLesson != nil {
            return UITableViewAutomaticDimension
        }

        return CGFloat.leastNonzeroMagnitude
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if currentLesson != nil {
            if section == 0 {
                return NSLocalizedString("Current Lesson", comment: "Current Lesson")
            }

            return NSLocalizedString("Subjects", comment: "Subjects")
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if currentLesson != nil && indexPath.section == 0 {
            return false
        }

        return true
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard selectionEnabled else {
            return
        }

        if let currentSubject = currentLesson?.subject, indexPath.section == 0 {
            select(subject: currentSubject)
        } else {
            if tableView.isEditing {
                performSegue(withIdentifier: "createEditSubject", sender: subjects[indexPath.row])
            } else {
                select(subject: subjects[indexPath.row])
            }
        }
    }

    private func select(subject: SubjectViewModel) {
        selectedSubject = subject
        tableView.reloadData()

        delegate?.selectSubjectViewController(viewController: self, didSelectSubject: subject)
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try subjects[indexPath.row].delete()

                subjects.remove(at: indexPath.row)
            } catch let error as NSError {
                CoreDataStorage.shared.context.rollback()
                showAlert(error: error)
            }
        }
    }
}
