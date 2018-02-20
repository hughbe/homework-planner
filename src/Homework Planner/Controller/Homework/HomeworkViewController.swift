//
//  HomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

public enum HomeworkSearchType : Int {
    case all
    case subject
    case teacher
    case workSet
}

public class HomeworkViewController : EditableViewController {
    private lazy var searchBar: UISearchBar = {
        let filterType = UISegmentedControl(items: [NSLocalizedString("All", comment: "All"), NSLocalizedString("Subject", comment: "Subject"), NSLocalizedString("Teacher", comment: "Teacher"), NSLocalizedString("Work Set", comment: "Work Set")])
        filterType.selectedSegmentIndex = 0
        filterType.apportionsSegmentWidthsByContent = true
        filterType.addTarget(self, action: #selector(changeSearchType), for: .valueChanged)
        filterType.sizeToFit()

        let accessoryView = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        accessoryView.barTintColor = UIColor.white

        let showHideCompletedButton = UIBarButtonItem(title: NSLocalizedString("Hide Done", comment: "Hide Done"), style: .plain, target: self, action: #selector(showHideCompleted))
        showHideCompletedButton.tintColor = view.tintColor

        accessoryView.setItems([
            UIBarButtonItem(customView: filterType),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            showHideCompletedButton
            ], animated: false)

        let searchBar = UISearchBar()

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Homework", comment: "Homework")
        searchBar.inputAccessoryView = accessoryView
        searchBar.delegate = self

        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = UIColor.white
        textField?.tintColor = UIColor.white

        return searchBar
    }()

    private var searchType = HomeworkSearchType.all {
        didSet {
            reloadData()
        }
    }
    private var showCompleted = true {
        didSet {
            reloadData()
        }
    }

    private var reloadAnimation = false
    
    private var unsectionedHomework: [HomeworkViewModel] = [] {
        didSet {
            sectionedHomework = HomeworkViewModel.section(homework: unsectionedHomework)

            UIView.transition(with: tableView, duration: reloadAnimation ? 0.35 : 0, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            })

            setHasData(unsectionedHomework.count != 0, animated: reloadAnimation)

            // The first reload is the only one that is not animated.
            reloadAnimation = true
        }
    }

    private var sectionedHomework: [[HomeworkViewModel]] = []

    public override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: HomeworkTableViewCell.self), bundle: nil), forCellReuseIdentifier: "HomeworkCell")

        super.viewDidLoad()

        navigationItem.titleView = searchBar
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        register(notification: HomeworkViewModel.DisplayType.Notifications.didChange) { _ in
            self.reloadData()
        }
        register(notification: SubjectViewModel.Notifications.subjectsChanged) { _ in
            self.reloadData()
        }
    }

    @IBAction func createHomework(_ sender: Any) {
        showCreateHomework(homework: nil)
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        searchBar.resignFirstResponder()
    }
    
    @objc func showHideCompleted(_ sender: UIBarButtonItem) {
        showCompleted = !showCompleted
        
        if showCompleted {
            sender.title = NSLocalizedString("Hide Done", comment: "Hide Done")
        } else {
            sender.title = NSLocalizedString("Show Done", comment: "Show Done")
        }
    }
    
    @objc func changeSearchType(_ sender: UISegmentedControl) {
        searchType = HomeworkSearchType(rawValue: sender.selectedSegmentIndex)!
    }
    
    func showCreateHomework(homework: HomeworkViewModel?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateHomeworkNavigationViewController") as! CreateHomeworkViewController
        viewController.createDelegate = self
        viewController.editingHomework = homework
        
        tabBarController?.present(viewController, animated: true)
    }

    public override func reloadData() {
        let request = NSFetchRequest<Homework>(entityName: "Homework")

        let notCompletedPredicate: NSPredicate?
        if !showCompleted {
            notCompletedPredicate = NSPredicate(format: "completed != TRUE")
        } else {
            notCompletedPredicate = nil
        }

        let filterPredicate: NSPredicate?
        if let text = searchBar.text, text.count > 0 {
            let subjectPredicate = NSPredicate(format: "subject.name CONTAINS[c] %@", text as NSString)
            let teacherPredicate = NSPredicate(format: "subject.teacher CONTAINS[c] %@", text as NSString)
            let workSetPredicate = NSPredicate(format: "workSet CONTAINS[c] %@", text as NSString)

            switch searchType {
            case .all:
                filterPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [subjectPredicate, teacherPredicate, workSetPredicate])
            case .subject:
                filterPredicate = subjectPredicate
            case .teacher:
                filterPredicate = teacherPredicate
            case .workSet:
                filterPredicate = workSetPredicate
            }
        } else {
            filterPredicate = nil
        }

        let predicates = [notCompletedPredicate, filterPredicate].flatMap { $0 }
        if predicates.count > 0 {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        do {
            unsectionedHomework = try CoreDataStorage.shared.context.fetch(request).map(HomeworkViewModel.init)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }

    public lazy var cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkCell") as! HomeworkTableViewCell
}

extension HomeworkViewController : CreateHomeworkViewControllerDelegate {
    public func createHomeworkViewControllerDidCancel(viewController: CreateHomeworkViewController) {
        viewController.dismiss(animated: true)
    }
    
    public func createHomeworkViewController(viewController: CreateHomeworkViewController, didCreateHomework homework: HomeworkViewModel) {
        viewController.dismiss(animated: true)
        reloadData()
    }
}

extension HomeworkViewController : UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionedHomework.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedHomework[section].count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionedHomework[section].first?.sectionTitle
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkCell", for: indexPath) as! HomeworkTableViewCell
        let homework = sectionedHomework[indexPath.section][indexPath.row]

        cell.priorityHandler = { cell in
            homework.togglePriority()
            cell.configure(homework: homework, display: HomeworkViewModel.DisplayType.currentDisplay)
            self.moveAndSave(indexPath: indexPath)
        }

        cell.completionHandler = { cell in
            homework.toggleCompleted()
            cell.configure(homework: homework, display: HomeworkViewModel.DisplayType.currentDisplay)

            self.moveAndSave(indexPath: indexPath)
        }

        cell.configure(homework: homework, display: HomeworkViewModel.DisplayType.currentDisplay)
        
        return cell
    }
    
    private func moveAndSave(indexPath: IndexPath) {
        let oldHomework = self.sectionedHomework[indexPath.section].map{ $0.id }
        sectionedHomework = HomeworkViewModel.section(homework: unsectionedHomework)
        
        let newHomework = self.sectionedHomework[indexPath.section]
        tableView.performBatchUpdates({
            for enumerator in newHomework.enumerated() {
                let oldIndex = oldHomework.index(of: enumerator.element.id)!
                let oldIndexPath = IndexPath(row: oldIndex, section: indexPath.section)
                let newIndexPath = IndexPath(row: enumerator.offset, section: indexPath.section)

                tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            }
        })
        
        do {
            try CoreDataStorage.shared.context.save()
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try sectionedHomework[indexPath.section][indexPath.row].delete()

                sectionedHomework[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)

                reloadData()
            } catch let error as NSError {
                showAlert(error: error)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let homework = sectionedHomework[indexPath.section][indexPath.row]
        if tableView.isEditing {
            showCreateHomework(homework: homework)
        } else {
            let homeworkViewController = HomeworkContentViewController.create(for: homework)
            tabBarController?.present(homeworkViewController, animated: true)
        }
    }
}

extension HomeworkViewController : UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData()
    }
}

extension HomeworkViewController : UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let homework = sectionedHomework[indexPath.section][indexPath.row]
        return HomeworkContentViewController.create(for: homework)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        tabBarController?.present(viewControllerToCommit, animated: true)
    }
}
