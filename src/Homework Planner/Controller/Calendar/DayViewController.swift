//
//  DayViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Date_WithoutTime
import UIKit

open class DayViewController : DataViewController {
    public var homework: [HomeworkViewModel] = []
    public var lessons: [LessonViewModel] = []
    public var currentDate = Date() {
        didSet {
            reloadData(animated: true)
        }
    }

    private var token: NSObjectProtocol!

    open override func viewDidLoad() {
        tableView.register(UINib(nibName: String(describing: HomeworkTableViewCell.self), bundle: nil), forCellReuseIdentifier: "HomeworkCell")
        tableView.register(UINib(nibName: String(describing: LessonTableViewCell.self), bundle: nil), forCellReuseIdentifier: "LessonCell")

        super.viewDidLoad()

        register(notification: SubjectViewModel.Notifications.subjectsChanged) { _ in
            self.reloadData(animated: true)
        }
    }

    open override func reloadData() {
        reloadData(animated: false)
    }

    open func reloadData(animated: Bool) {
        let dateDay = currentDate.withoutTime
        (homework, lessons) = fetchData(date: dateDay)

        let hasEvents = homework.count > 0 || lessons.count > 0
        tableView.setHidden(hidden: !hasEvents, animated: animated)
        noDataView?.setHidden(hidden: hasEvents, animated: animated)

        UIView.transition(with: tableView, duration: animated ? 0.25 : 0, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData(animated: true)
    }

    public func fetchData(date: Date) -> ([HomeworkViewModel], [LessonViewModel]) {
        let timetable = Timetable(date: date, modifyIfWeekend: false)

        let homeworkRequest = NSFetchRequest<Homework>(entityName: "Homework")
        homeworkRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Homework.subject?.name, ascending: true)
        ]
        homeworkRequest.predicate = NSPredicate(format: "dueDate == %@", argumentArray: [date])

        do {
            let homework = try CoreDataStorage.shared.context.fetch(homeworkRequest)
            let lessons = try timetable.getLessons()
            return (homework.map(HomeworkViewModel.init), lessons)
        } catch let error as NSError {
            showAlert(error: error)
            
            return ([], [])
        }
    }
}

extension DayViewController : UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return (homework.count > 0 ? 1 : 0) + (lessons.count > 0 ? 1 : 0)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if homework.count > 0 && section == 0 {
            return homework.count
        }
        
        return lessons.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if homework.count > 0 && section == 0 {
            return NSLocalizedString("Homework", comment: "Homework")
        }
        
        return NSLocalizedString("Lessons", comment: "Lessons")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if homework.count > 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeworkCell", for: indexPath) as! HomeworkTableViewCell
            cell.configure(homework: homework[indexPath.row], display: .sectionedBySubject)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath) as! LessonTableViewCell
            cell.configure(lesson: lessons[indexPath.row])
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 1 {
            return 85
        }

        if lessons[indexPath.row].subject!.teacher.count > 0 {
            return 90
        }
        
        return 75
    }
}
