//
//  LessonViewModel.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 18/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import DayDatePicker
import UIKit

public struct LessonViewModel {
    private let lesson: Lesson

    public init(insert: Bool = true) {
        if insert {
            self.init(lesson: Lesson(context: CoreDataStorage.shared.context))
        } else {
            let entityDescription = NSEntityDescription.entity(forEntityName: "Lesson", in: CoreDataStorage.shared.context)!
            self.init(lesson: Lesson(entity: entityDescription, insertInto: nil))
        }
    }

    public init(lesson: Lesson) {
        self.lesson = lesson
    }

    public func delete() throws {
        try CoreDataStorage.shared.tryDelete(object: lesson)
    }

    public func create(subject: SubjectViewModel) throws {
        CoreDataStorage.shared.context.insert(lesson)
        lesson.subject = subject.subject

        try CoreDataStorage.shared.context.save()
    }

    public var subject: SubjectViewModel? {
        get {
            guard let subject = lesson.subject else {
                return nil
            }

            return SubjectViewModel(subject: subject)
        } set {
            lesson.subject = newValue?.subject
        }
    }

    public var font: UIFont {
        if isCurrent {
            return UIFont.boldSystemFont(ofSize: 18)
        } else {
            return UIFont.systemFont(ofSize: 18)
        }
    }

    public var formattedDuration: String {
        var startComponents = DateComponents()
        startComponents.hour = Int(lesson.startHour)
        startComponents.minute = Int(lesson.startMinute)

        var endComponents = DateComponents()
        endComponents.hour = Int(lesson.endHour)
        endComponents.minute = Int(lesson.endMinute)

        guard let startDate = Calendar.current.date(from: startComponents), let endDate = Calendar.current.date(from: endComponents) else {
            return ""
        }

        let startTime = DateFormatter.localizedString(from: startDate, dateStyle: .none, timeStyle: .short)
        let endTime = DateFormatter.localizedString(from: endDate, dateStyle: .none, timeStyle: .short)

        return startTime + " - " + endTime
    }

    public func setDay(day: Day) {
        lesson.dayOfWeek = Int32(day.dayOfWeek)
        lesson.week = Int32(day.week)
    }

    public var startTime: TimePickerView.Time? {
        get {
            guard lesson.startHour != -1 && lesson.startMinute != -1 else {
                return nil
            }

            return TimePickerView.Time(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
        } set {
            lesson.startHour = Int32(newValue?.hour ?? -1)
            lesson.startMinute = Int32(newValue?.minute ?? -1)
        }
    }

    public var endTime: TimePickerView.Time? {
        get {
            guard lesson.endHour != -1 && lesson.endMinute != -1 else {
                return startTime?.time(byAddingHour: 0, andMinutes: 30)
            }

            return TimePickerView.Time(hour: Int(lesson.startHour), minute: Int(lesson.startMinute))
        } set {
            lesson.endHour = Int32(newValue?.hour ?? -1)
            lesson.endMinute = Int32(newValue?.minute ?? -1)
        }
    }

    public var isCurrent: Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let hour = components.hour!
        let minute = components.minute!
        if hour < lesson.startHour || (hour == lesson.startHour && minute < lesson.startMinute) {
            return false
        }

        if hour > lesson.endHour || (hour == lesson.endHour && minute > lesson.endMinute) {
            return false
        }

        return true
    }
}
