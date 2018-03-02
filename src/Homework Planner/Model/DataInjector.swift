//
//  DataInjector.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 14/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import DayDatePicker
import Foundation

#if DEBUG
public class DataInjector {
    private static var chemistry: SubjectViewModel!
    private static var economics: SubjectViewModel!
    private static var maths1: SubjectViewModel!
    private static var maths2: SubjectViewModel!
    private static var squash: SubjectViewModel!
    private static var russian: SubjectViewModel!
    private static var biology: SubjectViewModel!

    private static let injectedKey = "Injected"
    private static var injected: Bool {
        get {
            return UserDefaults.standard.value(forKey: injectedKey) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: injectedKey)
        }
    }

    public static func injectIfNeeded() throws {
        if injected {
            return
        }

        injectSubjects()
        injectHomework()
        injectLessons()

        InAppPurchase.unlockTimetable.purchase()

        do {
            try CoreDataStorage.shared.context.save()
            injected = true
        } catch let error as NSError {
            UIApplication.shared.keyWindow?.rootViewController?.showAlert(error: error)
        }
    }

    private static func injectSubjects() {
        chemistry = SubjectViewModel()
        chemistry.name = "Chemistry"
        chemistry.teacher = "Mr Orr"
        chemistry.color = SubjectViewModel.Colors.all[11]

        economics = SubjectViewModel()
        economics.name = "Economics"
        economics.teacher = "Miss Pick"
        economics.color = SubjectViewModel.Colors.all[4]

        maths1 = SubjectViewModel()
        maths1.name = "Maths"
        maths1.teacher = "Dr Cereceda"
        maths1.color = SubjectViewModel.Colors.all[0]

        maths2 = SubjectViewModel()
        maths2.name = "Maths"
        maths2.teacher = "Mr Charlton"
        maths2.color = SubjectViewModel.Colors.all[10]

        squash = SubjectViewModel()
        squash.name = "Squash"
        squash.color = SubjectViewModel.Colors.all[6]

        russian = SubjectViewModel()
        russian.name = "Russian"
        russian.teacher = "Mr Davies"
        russian.color = SubjectViewModel.Colors.all[7]

        biology = SubjectViewModel()
        biology.name = "Biology"
        biology.color = SubjectViewModel.Colors.all[1]
    }

    private static func injectHomework() {
        var chemistryHomework = HomeworkViewModel()
        chemistryHomework.subject = chemistry
        chemistryHomework.workSet = "Sheet on Buckminster Fullerene structures"
        chemistryHomework.setType(type: .exercise)
        chemistryHomework.setDueDate(dueDate: Date())

        var economicsHomework = HomeworkViewModel()
        economicsHomework.subject = economics
        economicsHomework.workSet = "To what extent is expansionary fiscal policy a good thing?"
        economicsHomework.setType(type: .essay)
        economicsHomework.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        economicsHomework.setPriorty(priority: true)

        var russianHomework = HomeworkViewModel()
        russianHomework.subject = russian
        russianHomework.workSet = "Quizlet Vocab (3.6)\nGrammar exercises from Navigator textbook (verbs of motion)"
        russianHomework.setType(type: .exercise)
        russianHomework.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        russianHomework.setCompleted(completed: true)

        let russianAttachment = UrlAttachmentViewModel()
        russianAttachment.title = "Quizlet"
        russianAttachment.url = URL(string: "http://quizlet.co.uk")!
        russianHomework.addAttachment(attachment: russianAttachment)

        var mathsHomework = HomeworkViewModel()
        mathsHomework.subject = maths1
        mathsHomework.workSet = "Integration by parts sheet"
        mathsHomework.setType(type: HomeworkViewModel.WorkType.exercise)
        mathsHomework.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!)

        var biologyHomework = HomeworkViewModel()
        biologyHomework.subject = biology
        biologyHomework.workSet = "Lab write up - dissection"
        biologyHomework.setType(type: HomeworkViewModel.WorkType.notes)
        biologyHomework.setDueDate(dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!)
    }

    private static func injectLessons() {
        let timetable = Timetable(date: Date(), modifyIfWeekend: true)

        var chemistryLesson = LessonViewModel()
        chemistryLesson.setDay(day: timetable.day)
        chemistryLesson.subject = chemistry
        chemistryLesson.startTime = TimePickerView.Time(hour: 9, minute: 00)
        chemistryLesson.endTime = TimePickerView.Time(hour: 10, minute: 15)

        var economicsLesson = LessonViewModel()
        economicsLesson.setDay(day: timetable.day)
        economicsLesson.subject = economics
        economicsLesson.startTime = TimePickerView.Time(hour: 10, minute: 40)
        economicsLesson.endTime = TimePickerView.Time(hour: 11, minute: 20)

        var maths1Lesson = LessonViewModel()
        maths1Lesson.setDay(day: timetable.day)
        maths1Lesson.subject = maths1
        maths1Lesson.startTime = TimePickerView.Time(hour: 11, minute: 20)
        maths1Lesson.endTime = TimePickerView.Time(hour: 11, minute: 55)

        var maths2Lesson = LessonViewModel()
        maths2Lesson.setDay(day: timetable.day)
        maths2Lesson.subject = maths2
        maths2Lesson.startTime = TimePickerView.Time(hour: 12, minute: 00)
        maths2Lesson.endTime = TimePickerView.Time(hour: 12, minute: 35)

        var squashLesson = LessonViewModel()
        squashLesson.setDay(day: timetable.day)
        squashLesson.subject = squash
        squashLesson.startTime = TimePickerView.Time(hour: 14, minute: 00)
        squashLesson.endTime = TimePickerView.Time(hour: 15, minute: 00)
    }
}
#endif
