//
//  DayViewController.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

open class DayViewController : DataViewController {
    public var homework: [Homework] = []
    public var lessons: [Lesson] = []
    public var currentDate = Date() {
        didSet {
            reloadData(animated: true)
        }
    }

    private var token: NSObjectProtocol!

    open override func viewDidLoad() {
        super.viewDidLoad()

        register(notification: Subject.Notifications.subjectsChanged) { _ in
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

    public func fetchData(date: Date) -> ([Homework], [Lesson]) {
        let day = Day(date: date, modifyIfWeekend: false)
        
        let homeworkRequest = NSFetchRequest<Homework>(entityName: "Homework")
        homeworkRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Homework.subject?.name, ascending: true)
        ]
        homeworkRequest.predicate = NSPredicate(format: "dueDate == %@", argumentArray: [date])
        
        let lessonsRequest = NSFetchRequest<Lesson>(entityName: "Lesson")
        lessonsRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lesson.startHour, ascending: true),
            NSSortDescriptor(keyPath: \Lesson.startMinute, ascending: true)
        ]
        lessonsRequest.predicate = NSPredicate(format: "(dayOfWeek == %@) AND (week == %@)", argumentArray: [day.dayOfWeek, day.week])
        
        do {
            let homework = try CoreDataStorage.shared.context.fetch(homeworkRequest)
            let lessons = try CoreDataStorage.shared.context.fetch(lessonsRequest)
            
            return (homework, lessons)
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
            let homework = self.homework[indexPath.row]
            
            cell.titleLabel.text = homework.subject?.name
            cell.detailLabel.text = homework.workSet
            cell.colorView.backgroundColor = homework.subject?.uiColor
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath) as! LessonTableViewCell
            let lesson = self.lessons[indexPath.row]
            
            cell.nameLabel.text = lesson.subject?.name ?? "No Subject"
            cell.teacherLabel.text = lesson.subject?.teacher
            cell.colorView.backgroundColor = lesson.subject?.uiColor
            cell.timeLabel.text = lesson.formattedDuration
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 1 {
            return 85
        }
        
        let lesson = lessons[indexPath.row]
        if let teacher = lesson.subject?.teacher, teacher.count > 0 {
            return 90
        }
        
        return 75
    }
}
