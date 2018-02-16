//
//  Timetable.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 16/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Date_Previous
import Date_WithoutTime
import Foundation

public struct Timetable {
    public var day: Day
    private var date: Date {
        didSet {
            day = Timetable.getDay(date: date, modifyIfWeekend: true)
        }
    }

    public init(date: Date, modifyIfWeekend: Bool) {
        self.date = date.withoutTime
        self.day = Timetable.getDay(date: date, modifyIfWeekend: modifyIfWeekend)
    }

    public mutating func nextDay() {
        var nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        if !Timetable.includeWeekends {
            while Calendar.current.isDateInWeekend(nextDate) {
                nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate)!
            }
        }

        date = nextDate
    }

    public mutating func previousDay() {
        var previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        if !Timetable.includeWeekends {
            while Calendar.current.isDateInWeekend(previousDate) {
                previousDate = Calendar.current.date(byAdding: .day, value: -1, to: previousDate)!
            }
        }

        date = previousDate
    }

    public func getLessons() throws -> [Lesson] {
        let request = NSFetchRequest<Lesson>(entityName: "Lesson")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lesson.startHour, ascending: true),
            NSSortDescriptor(keyPath: \Lesson.startMinute, ascending: true)
        ]
        request.predicate = NSPredicate(format: "(dayOfWeek == %@) AND (week == %@)", argumentArray: [day.dayOfWeek, day.week])

        return try CoreDataStorage.shared.context.fetch(request)
    }

    public var dayName: String {
        let today = Timetable.getDay(date: Date(), modifyIfWeekend: false)
        let difference = day.dayDifference(from: today)

        let dayName: String
        if difference == 0 {
            dayName = NSLocalizedString("Today", comment: "Today")
        } else if difference == 1 {
            dayName = NSLocalizedString("Tomorrow", comment: "Tomorrow")
        } else {
            dayName = Calendar.current.weekdaySymbols[day.dayOfWeek - 1]
        }

        if Timetable.numberOfWeeks != 1 {
            return dayName + " - " + NSLocalizedString("Week", comment: "Week") + " " + String(day.week)
        }

        return dayName
    }

    public class Notifications {
        public static let numberOfWeeksChanged = Notification.Name("NumberOfWeeksChanged")
    }

    private static let numberOfWeeksKey = "NumberOfWeeks"
    private static let weekStartKey = "WeekStart"
    private static let includeWeekendsKey = "IncludeWeekends"
    private static let homeworkDisplayKey = "HomeworkDisplay"

    public static var numberOfWeeks: Int {
        get {
            let numberOfWeeks = UserDefaults.standard.integer(forKey: Timetable.numberOfWeeksKey)
            return max(1, numberOfWeeks)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Timetable.numberOfWeeksKey)
            weekStart = Date().previous(dayOfWeek: DayOfWeek.Monday)
            NotificationCenter.default.post(name: Notifications.numberOfWeeksChanged, object: newValue)
        }
    }

    public static var weekStart: Date {
        get {
            let storedDate = UserDefaults.standard.object(forKey: Timetable.weekStartKey) as? Date
            let date = storedDate ?? Date().previous(dayOfWeek: .Monday)
            return date.withoutTime
        }
        set {
            UserDefaults.standard.set(newValue.withoutTime, forKey: Timetable.weekStartKey)
        }
    }

    private static var weekEnd: Date {
        get {
            let days = 7 * numberOfWeeks - 1
            return Calendar.current.date(byAdding: .day, value: days, to: weekStart)!
        }
    }

    public static var includeWeekends: Bool {
        get {
            if let value = UserDefaults.standard.value(forKey: Timetable.includeWeekendsKey) as? Bool {
                return value
            }

            return false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Timetable.includeWeekendsKey)
        }
    }

    public mutating func setCurrentWeek(week: Int) {
        if week == 1 {
            Timetable.weekStart = date.previous(dayOfWeek: DayOfWeek.Monday)
            day = Day(dayOfWeek: day.dayOfWeek, week: 1)
        } else if week == 2 {
            let date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self.date)!
            Timetable.weekStart = date.previous(dayOfWeek: DayOfWeek.Monday)
            day = Day(dayOfWeek: day.dayOfWeek, week: 2)
        }
    }

    private static func getDay(date: Date, modifyIfWeekend: Bool) -> Day {
        var date = date.withoutTime
        if modifyIfWeekend && !Timetable.includeWeekends {
            while Calendar.current.isDateInWeekend(date) {
                date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            }
        }

        while date < weekStart {
            date = Calendar.current.date(byAdding: .weekOfYear, value: numberOfWeeks, to: date)!
        }

        let week = Calendar.current.dateComponents([.weekOfYear], from: weekStart, to: date).weekOfYear! % numberOfWeeks + 1
        let weekday = Calendar.current.component(.weekday, from: date)

        return Day(dayOfWeek: weekday, week: week)
    }
}
