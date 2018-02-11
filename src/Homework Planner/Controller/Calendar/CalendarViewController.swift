//
//  CalendarViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 08/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import JTCalendar
import UIKit

public class CalenadarViewController : UIViewController {
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsView: UIImageView!
    
    private var manager = JTCalendarManager()
    private var menuFont: UIFont!
    
    private var homework: [Homework] = []
    private var lessons: [Lesson] = []
    private var currentDate = Date()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Promote the menu view from the view to the navigation controller.
        if let view = navigationController?.navigationBar {
            view.addSubview(calendarMenuView)
            view.addConstraints([
                NSLayoutConstraint(item: calendarMenuView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: calendarMenuView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: calendarMenuView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: calendarMenuView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0)
            ])
        }
        
        manager.delegate = self
        manager.menuView = calendarMenuView
        manager.contentView = calendarContentView
        manager.setDate(currentDate)
        
        setWeekMode(weekMode: true, animated: false)
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadDate(date: currentDate, animated: true)
    }
    
    @IBOutlet var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var contentBottomConstraint: NSLayoutConstraint!
    
    public func loadDate(date: Date, animated: Bool) {
        let dateDay = date.day

        manager.setDate(dateDay)
        currentDate = dateDay
        (homework, lessons) = fetchData(date: currentDate)
        
        let hasEvents = homework.count > 0 || lessons.count > 0
        tableView.setHidden(hidden: !hasEvents, animated: animated)
        noEventsView.setHidden(hidden: hasEvents, animated: animated)
        
        UIView.transition(with: tableView, duration: animated ? 0.25 : 0, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })
    }
    
    private func fetchData(date: Date) -> ([Homework], [Lesson]) {
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
            let homework = try AppDelegate.shared.persistentContainer.viewContext.fetch(homeworkRequest)
            let lessons = try AppDelegate.shared.persistentContainer.viewContext.fetch(lessonsRequest)
            
            return (homework, lessons)
        } catch let error as NSError {
            showAlert(error: error)
            
            return ([], [])
        }
    }

    public func setWeekMode(weekMode: Bool, animated: Bool) {
        manager.settings.weekModeEnabled = weekMode
        manager.reload()
        
        tableView.isHidden = !weekMode && (homework.count > 0 || lessons.count > 0)
        noEventsView.isHidden = !weekMode || homework.count > 0 || lessons.count > 0
        contentBottomConstraint.isActive = !weekMode
        contentHeightConstraint.isActive = weekMode
        
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.navigationController?.view.layoutIfNeeded()
        }
    }

    @IBAction func goToPreviousDay(_ sender: Any) {
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            loadDate(date: date, animated: true)
            manager.reload()
        }
    }

    @IBAction func goToNextDay(_ sender: Any) {
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            loadDate(date: date, animated: true)
            manager.reload()
        }
    }
}

extension CalenadarViewController : JTCalendarDelegate {
    public func calendarBuildMenuItemView(_ calendar: JTCalendarManager!) -> UIView! {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }
    
    public func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: (UIView & JTCalendarDay)!) {
        let view = dayView as! JTCalendarDayView

        view.alpha = 1
        
        if view.isFromAnotherMonth {
            view.alpha = 0.5
        } else if manager.dateHelper.date(currentDate, isTheSameDayThan: view.date) {
            view.circleView.isHidden = false
            view.circleView.backgroundColor = UIColor.red
            view.dotView.backgroundColor = UIColor.white
            view.textLabel.textColor = UIColor.white
        } else if manager.dateHelper.date(Date(), isTheSameDayThan: view.date) {
            view.circleView.isHidden = false
            view.circleView.backgroundColor = UIColor.black
            view.dotView.backgroundColor = UIColor.white
            view.textLabel.textColor = UIColor.white
        } else {
            view.circleView.isHidden = true
            view.dotView.backgroundColor = UIColor.red
            view.textLabel.textColor = UIColor.black
        }

        let (homework, lessons) = fetchData(date: view.date)
        view.dotView.isHidden = homework.count == 0 && lessons.count == 0
    }
    
    public func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: (UIView & JTCalendarDay)!) {
        let view = dayView as! JTCalendarDayView
        loadDate(date: view.date, animated: true)

        if calendar.dateHelper.date(view.date, isTheSameDayThan: currentDate) {
            setWeekMode(weekMode: !calendar.settings.weekModeEnabled, animated: true)
        } else if homework.count == 0 && lessons.count == 0 {
            setWeekMode(weekMode: false, animated: true)
        } else if !calendar.settings.weekModeEnabled {
            setWeekMode(weekMode: true, animated: true)
        } else {
            manager.reload()
        }
    }
}

extension CalenadarViewController : UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return homework.count > 0 ? 1 : 0 + lessons.count > 0 ? 1 : 0
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if homework.count > 0 && indexPath.section == 0 {
            let homework = self.homework[indexPath.row]
            
            let homeworkViewController = HomeworkContentViewController.create(for: homework)
            tabBarController?.present(homeworkViewController, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 1 {
            return 85
        }
        
        let lesson = lessons[indexPath.row]
        if let teacher = lesson.subject?.teacher, teacher.count > 0 {
            return 85
        }
        
        return 75
    }
}

extension CalenadarViewController : UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard self.homework.count > 0 && indexPath.section == 0 else {
            return nil
        }
        
        let homework = self.homework[indexPath.row]
        return HomeworkContentViewController.create(for: homework)
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        tabBarController?.present(viewControllerToCommit, animated: true)
    }
}
