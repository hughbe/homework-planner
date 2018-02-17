//
//  CalendarViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 08/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Homework_Planner_Core
import JTCalendar
import UIKit

public class CalenadarViewController : DayViewController {
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    
    private lazy var manager: JTCalendarManager = {
        let manager = JTCalendarManager()
        manager.delegate = self
        manager.menuView = calendarMenuView
        manager.contentView = calendarContentView
        manager.setDate(currentDate)

        return manager
    }()

    private var menuFont: UIFont!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Promote the menu view from the view to the navigation controller.
        navigationController?.replaceNavigationBar(with: calendarMenuView)

        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        
        setWeekMode(weekMode: true, animated: false)
    }
    
    @IBOutlet var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var contentBottomConstraint: NSLayoutConstraint!

    public func setWeekMode(weekMode: Bool, animated: Bool) {
        manager.settings.weekModeEnabled = weekMode
        manager.reload()

        if weekMode {
            setHasData(homework.count > 0 || lessons.count > 0, animated: false)
        } else {
            tableView.isHidden = true
            noDataView?.isHidden = true
        }

        contentBottomConstraint.isActive = !weekMode
        contentHeightConstraint.isActive = weekMode
        
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.navigationController?.view.layoutIfNeeded()
        }
    }

    @IBAction func goToPreviousDay(_ sender: Any) {
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            manager.setDate(date)
            currentDate = date
            manager.reload()
        }
    }

    @IBAction func goToNextDay(_ sender: Any) {
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            manager.setDate(date)
            currentDate = date
            manager.reload()
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
        
        if Calendar.current.isDate(currentDate, inSameDayAs: view.date) {
            view.circleView.isHidden = false
            view.circleView.backgroundColor = UIColor.red
            view.dotView.backgroundColor = UIColor.white
            view.textLabel.textColor = UIColor.white
        } else if Calendar.current.isDate(Date(), inSameDayAs: view.date) {
            view.circleView.isHidden = false
            view.circleView.backgroundColor = UIColor.black
            view.dotView.backgroundColor = UIColor.white
            view.textLabel.textColor = UIColor.white
        } else {
            if view.isFromAnotherMonth {
                view.alpha = 0.5
            }

            view.circleView.isHidden = true
            view.dotView.backgroundColor = UIColor.red
            view.textLabel.textColor = UIColor.black
        }

        let (homework, lessons) = fetchData(date: view.date)
        view.dotView.isHidden = homework.count == 0 && lessons.count == 0
    }
    
    public func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: (UIView & JTCalendarDay)!) {
        let view = dayView as! JTCalendarDayView
        let date = view.date.withoutTime
        let oldCurrentDate = currentDate

        manager.setDate(date)
        currentDate = date

        if Calendar.current.isDate(oldCurrentDate, inSameDayAs: date) {
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
