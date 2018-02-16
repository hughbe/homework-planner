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

public class Timetable {
    public static var shared = Timetable()

    public func getLessons(on day: Day) throws -> [Lesson] {
        let request = NSFetchRequest<Lesson>(entityName: "Lesson")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Lesson.startHour, ascending: true),
            NSSortDescriptor(keyPath: \Lesson.startMinute, ascending: true)
        ]
        request.predicate = NSPredicate(format: "(dayOfWeek == %@) AND (week == %@)", argumentArray: [day.dayOfWeek, day.week])

        return try CoreDataStorage.shared.context.fetch(request)
    }

    private static let numberOfWeeksKey = "NumberOfWeeks"
    private static let weekStartKey = "WeekStart"
    private static let includeWeekendsKey = "IncludeWeekends"
    private static let homeworkDisplayKey = "HomeworkDisplay"

    public var numberOfWeeks: Int {
        get {
            let numberOfWeeks = UserDefaults.standard.integer(forKey: Timetable.numberOfWeeksKey)
            return max(1, numberOfWeeks)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Timetable.numberOfWeeksKey)
        }
    }

    public var weekStart: Date {
        get {
            if let date = UserDefaults.standard.object(forKey: Timetable.weekStartKey) as? Date {
                return date.withoutTime
            }

            return Date().previous(dayOfWeek: DayOfWeek.Monday).withoutTime
        }
        set {
            UserDefaults.standard.set(newValue.withoutTime, forKey: Timetable.weekStartKey)
        }
    }

    public var weekEnd: Date {
        get {
            let start = weekStart
            let daysInWeek = Calendar.current.range(of: .weekday, in: .weekOfMonth, for: start)!.count

            var components = DateComponents()
            components.day = daysInWeek * numberOfWeeks

            return Calendar.current.date(byAdding: components, to: start)!
        }
    }

    public var includeWeekends: Bool {
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

    public func getDay(date: Date, modifyIfWeekend: Bool) {
        
    }
}
