//
//  DataInjector.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 14/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation

#if DEBUG
public class DataInjector {
    private static var chemistry: Subject!
    private static var economics: Subject!
    private static var maths1: Subject!
    private static var maths2: Subject!
    private static var squash: Subject!
    private static var russian: Subject!
    private static var biology: Subject!

    private static let injectedKey = "Injected"
    private static var injected: Bool {
        get {
            return UserDefaults.standard.value(forKey: injectedKey) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: injectedKey)
        }
    }

    public static func injectIfNeeded() {
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
#if UIApplication
            UIApplication.shared.keyWindow?.rootViewController?.showAlert(error: error)
#else
            print(error)
#endif
        }
    }

    private static func injectSubjects() {
        let context = CoreDataStorage.shared.context

        chemistry = Subject(context: context)
        chemistry.name = "Chemistry"
        chemistry.teacher = "Mr Orr"
        chemistry.uiColor = Subject.Colors.all[11]

        economics = Subject(context: context)
        economics.name = "Economics"
        economics.teacher = "Miss Pick"
        economics.uiColor = Subject.Colors.all[4]

        maths1 = Subject(context: context)
        maths1.name = "Maths"
        maths1.teacher = "Dr Cereceda"
        maths1.uiColor = Subject.Colors.all[0]

        maths2 = Subject(context: context)
        maths2.name = "Maths"
        maths2.teacher = "Mr Charlton"
        maths2.uiColor = Subject.Colors.all[10]

        squash = Subject(context: context)
        squash.name = "Squash"
        squash.uiColor = Subject.Colors.all[6]

        russian = Subject(context: context)
        russian.name = "Russian"
        russian.teacher = "Mr Davies"
        russian.uiColor = Subject.Colors.all[7]

        biology = Subject(context: context)
        biology.name = "Biology"
        biology.uiColor = Subject.Colors.all[1]
    }

    private static func injectHomework() {
        let context = CoreDataStorage.shared.context

        let chemistryHomework = Homework(context: context)
        chemistryHomework.subject = chemistry
        chemistryHomework.workSet = "Sheet on Buckminster Fullerene structures"
        chemistryHomework.type = Homework.WorkType.exercise.rawValue
        chemistryHomework.dueDate = Date().day

        let economicsHomework = Homework(context: context)
        economicsHomework.subject = economics
        economicsHomework.workSet = "To what extent is expansionary fiscal policy a good thing?"
        economicsHomework.type = Homework.WorkType.essay.rawValue
        economicsHomework.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date().day)!
        economicsHomework.priority = true

        let russianHomework = Homework(context: context)
        russianHomework.subject = russian
        russianHomework.workSet = "Quizlet Vocab (3.6)\nGrammar exercises from Navigator textbook (verbs of motion)"
        russianHomework.type = Homework.WorkType.exercise.rawValue
        russianHomework.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date().day)!
        russianHomework.completed = true

        let russianAttachment = UrlAttachment(context: context)
        russianAttachment.type = Attachment.ContentType.url.rawValue
        russianAttachment.title = "Quizlet"
        russianAttachment.url = URL(string: "http://quizlet.co.uk")!
        russianHomework.addToAttachments(russianAttachment)

        let mathsHomework = Homework(context: context)
        mathsHomework.subject = maths1
        mathsHomework.workSet = "Integration by parts sheet"
        mathsHomework.type = Homework.WorkType.exercise.rawValue
        mathsHomework.dueDate = Calendar.current.date(byAdding: .day, value: 2, to: Date().day)!

        let biologyHomework = Homework(context: context)
        biologyHomework.subject = biology
        biologyHomework.workSet = "Lab write up - dissection"
        biologyHomework.type = Homework.WorkType.notes.rawValue
        biologyHomework.dueDate = Calendar.current.date(byAdding: .day, value: 3, to: Date().day)!
    }

    private static func injectLessons() {
        let context = CoreDataStorage.shared.context

        let day = Day(date: Date().day, modifyIfWeekend: true)

        let chemistryLesson = Lesson(context: context)
        chemistryLesson.dayOfWeek = Int32(day.dayOfWeek)
        chemistryLesson.week = Int32(day.week)
        chemistryLesson.subject = chemistry
        chemistryLesson.startHour = 9
        chemistryLesson.startMinute = 00
        chemistryLesson.endHour = 10
        chemistryLesson.endMinute = 15

        let economicsLesson = Lesson(context: context)
        economicsLesson.dayOfWeek = Int32(day.dayOfWeek)
        economicsLesson.week = Int32(day.week)
        economicsLesson.subject = economics
        economicsLesson.startHour = 10
        economicsLesson.startMinute = 40
        economicsLesson.endHour = 11
        economicsLesson.endMinute = 20

        let maths1Lesson = Lesson(context: context)
        maths1Lesson.dayOfWeek = Int32(day.dayOfWeek)
        maths1Lesson.week = Int32(day.week)
        maths1Lesson.subject = maths1
        maths1Lesson.startHour = 11
        maths1Lesson.startMinute = 20
        maths1Lesson.endHour = 11
        maths1Lesson.endMinute = 55

        let maths2Lesson = Lesson(context: context)
        maths2Lesson.dayOfWeek = Int32(day.dayOfWeek)
        maths2Lesson.week = Int32(day.week)
        maths2Lesson.subject = maths2
        maths2Lesson.startHour = 12
        maths2Lesson.startMinute = 00
        maths2Lesson.endHour = 12
        maths2Lesson.endMinute = 35

        let squashLesson = Lesson(context: context)
        squashLesson.dayOfWeek = Int32(day.dayOfWeek)
        squashLesson.week = Int32(day.week)
        squashLesson.subject = squash
        squashLesson.startHour = 14
        squashLesson.startMinute = 00
        squashLesson.endHour = 15
        squashLesson.endMinute = 00
    }
}
#endif
