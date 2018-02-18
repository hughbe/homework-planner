//
//  HomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Homework_Planner_Core
import UIKit
import UserNotifications

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
    
    private var unsectionedHomework: [Homework] = [] {
        didSet {
            sectionData()

            UIView.transition(with: tableView, duration: reloadAnimation ? 0.35 : 0, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            })

            setHasData(unsectionedHomework.count != 0, animated: reloadAnimation)

            // The first reload is the only one that is not animated.
            reloadAnimation = true
        }
    }

    private var sectionedHomework: [[Homework]] = []

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBar
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        register(notification: Homework.DisplayType.Notifications.didChange) { _ in
            self.reloadData()
        }
        register(notification: Subject.Notifications.subjectsChanged) { _ in
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
    
    func showCreateHomework(homework: Homework?) {
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
            unsectionedHomework = try CoreDataStorage.shared.context.fetch(request)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
    
    private func sectionData() {
        let homeworkDisplay = Homework.DisplayType.currentDisplay
        
        if homeworkDisplay == .sectionedBySubject {
            let groupedHomework = Dictionary(grouping: unsectionedHomework) { homework in
                homework.subject?.name ?? ""
            }
            sectionedHomework = groupedHomework.values.sorted { homework1, homework2 in
                let name1 = homework1.first?.subject?.name ?? ""
                let name2 = homework2.first?.subject?.name ?? ""
                
                return name1.compare(name2) == .orderedAscending
            }
        } else if homeworkDisplay == .sectionedByDate {
            let groupedHomework = Dictionary(grouping: unsectionedHomework) { homework -> Date in
                homework.dueDate ?? Date().withoutTime
            }
            sectionedHomework = groupedHomework.values.sorted { homework1, homework2 in
                let date1 = homework1.first?.dueDate ?? Date().withoutTime
                let date2 = homework2.first?.dueDate ?? date1
                
                return date1.compare(date2) == .orderedAscending
            }
        } else {
            sectionedHomework = [unsectionedHomework]
        }

        sectionedHomework = sectionedHomework.map { homework in
            return homework.sorted { (homework1, homework2) in
                let order = homework1.order(other: homework2, comparisonType: homeworkDisplay.comparisonType)

                return order == .before
            }
        }
    }
    
    private func setEditing(editing: Bool) {
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
    
    private func createNotification(for homework: Homework) {
        guard let dueDate = homework.dueDate?.withoutTime, dueDate.compare(Date().withoutTime) == .orderedDescending else {
            return
        }
        
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: 1, to: dueDate) else {
            return
        }

        guard let name = homework.subject?.name else {
            return
        }

        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: notificationDate)
                components.hour = 12

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                let content = UNMutableNotificationContent()
                content.title = name + " " + NSLocalizedString("homework is due tomorrow", comment: "homework is due tomorrow")

                let notification = UNNotificationRequest(identifier: homework.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
                let center = UNUserNotificationCenter.current()
                center.add(notification) { error in
                    if let error = error {
                        self.showAlert(error: error as NSError)
                    }
                }
            }
        }
    }
    
    private func deleteNotification(for homework: Homework) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [homework.objectID.uriRepresentation().absoluteString])
    }
}

extension HomeworkViewController : CreateHomeworkViewControllerDelegate {
    public func createHomeworkViewControllerDidCancel(viewController: CreateHomeworkViewController) {
        viewController.dismiss(animated: true)
    }
    
    public func createHomeworkViewController(viewController: CreateHomeworkViewController, didCreateHomework homework: Homework) {
        viewController.dismiss(animated: true)

        createNotification(for: homework)
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
        guard let homework = sectionedHomework[section].first else {
            return nil
        }
        
        if Homework.DisplayType.currentDisplay == .sectionedBySubject {
            guard let subject = homework.subject, var title = subject.name else {
                return nil
            }
            
            if let teacher = subject.teacher, teacher.count > 0 {
                title.append("(\(teacher))")
            }
            
            return title
        } else if Homework.DisplayType.currentDisplay == .sectionedByDate {
            guard let dueDate = homework.dueDate else {
                return nil
            }
            
            return dueDate.formattedDayName
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeworkTableViewCell
        let homework = sectionedHomework[indexPath.section][indexPath.row]
        
        if Homework.DisplayType.currentDisplay == .sectionedBySubject {
            cell.titleLabel.text = homework.workSet
            formatDueDateLabel(cell: cell, homework: homework)
        } else if Homework.DisplayType.currentDisplay == .sectionedByDate {
            cell.titleLabel.text = homework.subject?.name
            cell.detailLabel.text = homework.workSet
            cell.detailLabel.textColor = UIColor(white: 0.4, alpha: 1)
        }
        
        cell.colorView.backgroundColor = homework.subject?.uiColor

        cell.priority = homework.priority
        cell.priorityHandler = { cell in
            homework.priority = !homework.priority
            self.moveAndSave(indexPath: indexPath)
        }

        cell.completed = homework.completed
        cell.completionHandler = { cell in
            homework.completed = !homework.completed
            
            if homework.completed {
                self.deleteNotification(for: homework)
            }
            
            if Homework.DisplayType.currentDisplay != .sectionedByDate {
                self.formatDueDateLabel(cell: cell, homework: homework)
            }
            
            self.moveAndSave(indexPath: indexPath)
        }
        
        return cell
    }
    
    private func moveAndSave(indexPath: IndexPath) {
        let oldHomework = self.sectionedHomework[indexPath.section].map{ $0.objectID }
        sectionData()
        
        let newHomework = self.sectionedHomework[indexPath.section]
        tableView.performBatchUpdates({
            for enumerator in newHomework.enumerated() {
                let oldIndex = oldHomework.index(of: enumerator.element.objectID)!
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
    
    private func formatDueDateLabel(cell: HomeworkTableViewCell, homework: Homework) {
        let dueDate = homework.dueDate ?? Date()
        let result = Calendar.current.compare(dueDate, to: Date(), toGranularity: .day)
        
        if homework.completed || result != .orderedAscending {
            cell.detailLabel.text = dueDate.formattedDayName
        } else if result == .orderedAscending {
            cell.detailLabel.text = NSLocalizedString("Overdue", comment: "Overdue") + " - " + dueDate.formattedDayName
        }

        if homework.completed || result == .orderedDescending {
            cell.detailLabel.textColor = UIColor(white: 0.4, alpha: 1)
        } else if result == .orderedSame {
            cell.detailLabel.textColor = UIColor.orange
        } else {
            cell.detailLabel.textColor = UIColor.red
        }
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let homework = sectionedHomework[indexPath.section][indexPath.row]
            deleteNotification(for: homework)

            CoreDataStorage.shared.context.delete(homework)
            
            do {
                try CoreDataStorage.shared.context.save()

                sectionedHomework[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)

                reloadData()
            } catch let error as NSError {
                CoreDataStorage.shared.context.rollback()
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
