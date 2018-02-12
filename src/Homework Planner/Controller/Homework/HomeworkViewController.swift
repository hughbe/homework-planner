//
//  HomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit
import UserNotifications

public enum HomeworkSearchType : Int {
    case all
    case subject
    case teacher
    case workSet
}

public class HomeworkViewController : UIViewController {
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!

    @IBOutlet weak var noHomeworkView: UIView!
    @IBOutlet weak var homeworkTableView: UITableView!
    
    private var searchBar: UISearchBar!
    private var searchType = HomeworkSearchType.all {
        didSet {
            loadData(animated: true)
        }
    }
    private var showCompleted = true {
        didSet {
            loadData(animated: true)
        }
    }
    
    private var unsectionedHomework: [Homework] = []
    private var sectionedHomework: [[Homework]] = []

    public override func viewDidLoad() {
        super.viewDidLoad()

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
        
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = NSLocalizedString("Homework", comment: "Homework")
        searchBar.inputAccessoryView = accessoryView
        searchBar.delegate = self

        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = UIColor.white
        textField?.tintColor = UIColor.white

        navigationItem.titleView = searchBar

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: homeworkTableView)
        }
        
        loadData(animated: false)
    }
    
    @IBAction func editHomework(_ sender: Any) {
        setEditingHomework(editing: !homeworkTableView.isEditing)
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
    
    public func loadData(animated: Bool) {
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
            unsectionedHomework = try AppDelegate.shared.persistentContainer.viewContext.fetch(request)
            sectionData()
            
            UIView.transition(with: homeworkTableView, duration: animated ? 0.35 : 0, options: .transitionCrossDissolve, animations: {
                self.homeworkTableView.reloadData()
            })
            
            let hasHomework = unsectionedHomework.count != 0
            if hasHomework {
                navigationItem.leftBarButtonItem = editButton
            } else {
                navigationItem.leftBarButtonItem = nil
            }

            if homeworkTableView.isEditing && !hasHomework {
                setEditingHomework(editing: false)
            }
            
            homeworkTableView.setHidden(hidden: !hasHomework, animated: animated)
            noHomeworkView.setHidden(hidden: hasHomework, animated: animated)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }
    
    private func sectionData() {
        let homeworkDisplay = Settings.homeworkDisplay
        
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
                homework.dueDate ?? Date().day
            }
            sectionedHomework = groupedHomework.values.sorted { homework1, homework2 in
                let date1 = homework1.first?.dueDate ?? Date().day
                let date2 = homework2.first?.dueDate ?? Date().day
                
                return date1.compare(date2) == .orderedAscending
            }
        } else {
            sectionedHomework = [unsectionedHomework]
        }
        
        for enumerator in sectionedHomework.enumerated() {
            sectionedHomework[enumerator.offset] = enumerator.element.sorted { (homework1, homwork2) in
                if homeworkDisplay == .sectionedBySubject {
                    return homework1.isGreaterThan(other: homwork2, comparisonType: .date)
                } else if homeworkDisplay == .sectionedByDate {
                    return homework1.isGreaterThan(other: homwork2, comparisonType: .subject)
                } else {
                    return homework1.isGreaterThan(other: homwork2, comparisonType: .none)
                }
            }
        }
    }
    
    private func setEditingHomework(editing: Bool) {
        homeworkTableView.setEditing(editing, animated: true)
        
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
        guard let dueDate = homework.dueDate?.day, dueDate.compare(Date().day) == .orderedDescending else {
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
        do {
            try AppDelegate.shared.persistentContainer.viewContext.save()

            createNotification(for: homework)
            
            loadData(animated: true)
            viewController.dismiss(animated: true)
        } catch let error as NSError {
            showAlert(error: error)
        }
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
        
        if Settings.homeworkDisplay == .sectionedBySubject {
            guard let subject = homework.subject, var title = subject.name else {
                return nil
            }
            
            if let teacher = subject.teacher, teacher.count > 0 {
                title.append("(\(teacher))")
            }
            
            return title
        } else if Settings.homeworkDisplay == .sectionedByDate {
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
        
        if Settings.homeworkDisplay == .sectionedBySubject {
            cell.titleLabel.text = homework.workSet
            formatDueDateLabel(cell: cell, homework: homework)
        } else if Settings.homeworkDisplay == .sectionedByDate {
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
            
            if Settings.homeworkDisplay != .sectionedByDate {
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
        homeworkTableView.performBatchUpdates({
            for enumerator in newHomework.enumerated() {
                let oldIndex = oldHomework.index(of: enumerator.element.objectID)!
                let oldIndexPath = IndexPath(row: oldIndex, section: indexPath.section)
                let newIndexPath = IndexPath(row: enumerator.offset, section: indexPath.section)

                homeworkTableView.moveRow(at: oldIndexPath, to: newIndexPath)
            }
        })
        
        do {
            try AppDelegate.shared.persistentContainer.viewContext.save()
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

            AppDelegate.shared.persistentContainer.viewContext.delete(homework)
            
            do {
                try AppDelegate.shared.persistentContainer.viewContext.save()

                sectionedHomework[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)

                loadData(animated: true)
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
        loadData(animated: true)
    }
}

extension HomeworkViewController : UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = homeworkTableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let homework = sectionedHomework[indexPath.section][indexPath.row]
        return HomeworkContentViewController.create(for: homework)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        tabBarController?.present(viewControllerToCommit, animated: true)
    }
}
