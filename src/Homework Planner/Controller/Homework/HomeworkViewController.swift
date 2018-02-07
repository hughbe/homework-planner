//
//  HomeworkViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

public class HomeworkViewController : UIViewController {
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var createButton: UIBarButtonItem!

    @IBOutlet weak var noHomeworkView: UIImageView!
    @IBOutlet weak var homeworkTableView: UITableView!
    
    private var unsectionedHomework: [Homework] = []
    private var sectionedHomework: [[Homework]] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        loadData(animated: false)
    }
    
    @IBAction func editHomework(_ sender: Any) {
        setEditingHomework(editing: !homeworkTableView.isEditing)
    }

    @IBAction func createHomework(_ sender: Any) {
        showCreateHomework(homework: nil)
    }
    
    func showCreateHomework(homework: Homework?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateHomeworkNavigationViewController") as! CreateHomeworkViewController
        viewController.createDelegate = self
        
        if let homework = homework {
            viewController.setHomework(homework: homework)
        }
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
    
    fileprivate func loadData(animated: Bool) {
        let request = NSFetchRequest<Homework>(entityName: "Homework")
        
        do {
            unsectionedHomework = try AppDelegate.shared.persistentContainer.viewContext.fetch(request)
            let groupedHomework = Dictionary(grouping: unsectionedHomework) { homework -> String in
                homework.subject?.name ?? ""
            }
            sectionedHomework = groupedHomework.values.sorted { homework1, homework2 in
                let name1 = homework1.first?.subject?.name ?? ""
                let name2 = homework2.first?.subject?.name ?? ""
                
                return name1.compare(name2) == .orderedAscending
            }
            
            homeworkTableView.reloadData()
            
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
}

extension HomeworkViewController : CreateHomeworkViewControllerDelegate {
    public func createHomeworkViewControllerDidCancel(viewController: CreateHomeworkViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    public func createHomeworkViewController(viewController: CreateHomeworkViewController, didCreateHomework homework: Homework) {
        do {
            try AppDelegate.shared.persistentContainer.viewContext.save()
            loadData(animated: true)
            viewController.dismiss(animated: true, completion: nil)
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
        guard let homework = sectionedHomework[section].first, let subject = homework.subject, var title = subject.name else {
            return nil
        }

        if let teacher = subject.teacher, teacher.count > 0 {
            title.append("(\(teacher))")
        }
        
        return title
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeworkTableViewCell
        let homework = sectionedHomework[indexPath.section][indexPath.row]
        cell.workSetLabel.text = homework.workSet
        cell.completed = homework.completed
        
        guard let dueDate = homework.dueDate else {
            return cell
        }
        
        cell.dueDate = dueDate

        cell.completionHandler = { cell in
            homework.completed = !homework.completed
            cell.completed = homework.completed
            
            do {
                try AppDelegate.shared.persistentContainer.viewContext.save()
            } catch let error as NSError {
                self.showAlert(error: error)
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let subject = sectionedHomework[indexPath.section][indexPath.row]
            AppDelegate.shared.persistentContainer.viewContext.delete(subject)
            
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
        let homework = sectionedHomework[indexPath.section][indexPath.row]

        if tableView.isEditing {
            showCreateHomework(homework: homework)
        } else {
            showAlert(title: homework.subject?.name ?? "", message: "Homework")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
