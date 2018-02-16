//
//  LegacyImporter.swift
//  Homework Planner Core
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import Date_Previous
import Foundation
import UIKit

@objc(SubjectLegacy) private class SubjectLegacy : NSObject, NSCoding {
    private static let idKey = "subject_id"
    private static let nameKey = "subject_subject"
    private static let teacherKey = "subject_teacher"
    private static let colorKey = "subject_color"
    
    public var id: String
    public var name: String
    public var teacher: String
    public var color: UIColor

    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: SubjectLegacy.idKey) as? String ?? "No Subject Id"
        name = aDecoder.decodeObject(forKey: SubjectLegacy.nameKey) as? String ?? "No Subject Name"
        teacher = aDecoder.decodeObject(forKey: SubjectLegacy.teacherKey) as? String ?? "No Teacher"
        color = aDecoder.decodeObject(forKey: SubjectLegacy.colorKey) as? UIColor ?? UIColor.black
    }

    func encode(with aCoder: NSCoder) {
        fatalError("Unused.")
    }
}

@objc(AttachmentLegacy) private class AttachmentLegacy : NSObject, NSCoding {
    private static let typeKey = "attachment_type"
    private static let titleKey = "attachment_title"
    private static let infoKey = "attachment_attachmentInfo"
    
    public var type: Int
    public var title: String
    public var info: Any?
    
    required init?(coder aDecoder: NSCoder) {
        type = aDecoder.decodeInteger(forKey: AttachmentLegacy.typeKey)
        title = aDecoder.decodeObject(forKey: AttachmentLegacy.titleKey) as? String ?? "No Title"
        info = aDecoder.decodeObject(forKey: AttachmentLegacy.infoKey)
    }
    
    func encode(with aCoder: NSCoder) {
        fatalError("Unused.")
    }
}

@objc(HomeworkLegacy) private class HomeworkLegacy : NSObject, NSCoding {
    private static let subjectKey = "homework_subject"
    private static let workSetKey = "homework_summary"
    private static let dueDateKey = "homework_due_date"
    private static let completedKey = "homework_done"
    private static let typeKey = "homework_type"
    private static let attachmentsKey = "homework_attachments"
    
    public var subject: SubjectLegacy?
    public var workSet: String
    public var dueDate: Date
    public var type: Int
    public var attachments: [AttachmentLegacy]
    public var completed: Bool
    
    required init?(coder aDecoder: NSCoder) {
        subject = aDecoder.decodeObject(forKey: HomeworkLegacy.subjectKey) as? SubjectLegacy
        workSet = aDecoder.decodeObject(forKey: HomeworkLegacy.workSetKey) as? String ?? "No Work Set"
        dueDate = aDecoder.decodeObject(forKey: HomeworkLegacy.dueDateKey) as? Date ?? Date()
        type = aDecoder.decodeInteger(forKey: HomeworkLegacy.typeKey)
        attachments = aDecoder.decodeObject(forKey: HomeworkLegacy.attachmentsKey) as? [AttachmentLegacy] ?? []
        completed = aDecoder.decodeBool(forKey: HomeworkLegacy.completedKey)
    }
    
    func encode(with aCoder: NSCoder) {
        fatalError("Unused.")
    }
}

@objc(DayLegacy) private class DayLegacy : NSObject, NSCoding {
    private static let dayKey = "day_day"
    private static let weekKey = "day_week"
    
    public var day: Int
    public var week: Int
    
    required init?(coder aDecoder: NSCoder) {
        day = aDecoder.decodeInteger(forKey: DayLegacy.dayKey)
        week = aDecoder.decodeInteger(forKey: DayLegacy.weekKey)
    }
    
    func encode(with aCoder: NSCoder) {
        fatalError("Unused.")
    }
}

@objc(LessonLegacy) private class LessonLegacy : NSObject, NSCoding {
    private static let subjectKey = "lesson_subject"
    private static let dayKey = "lesson_day"
    private static let startTimeKey = "lesson_start_time"
    private static let endTimeKey = "lesson_end_time"
    
    public var subject: SubjectLegacy?
    public var day: DayLegacy?
    public var startTime: Date
    public var endTime: Date
    
    required init?(coder aDecoder: NSCoder) {
        subject = aDecoder.decodeObject(forKey: LessonLegacy.subjectKey) as? SubjectLegacy
        day = aDecoder.decodeObject(forKey: LessonLegacy.dayKey) as? DayLegacy
        startTime = aDecoder.decodeObject(forKey: LessonLegacy.startTimeKey) as? Date ?? Date()
        endTime = aDecoder.decodeObject(forKey: LessonLegacy.endTimeKey) as? Date ?? Date()
    }
    
    func encode(with aCoder: NSCoder) {
        fatalError("Unused.")
    }
}

public class LegacyImporter {
    private static var allSubjects: [SubjectLegacy] = []

    private static let importedKey = "Imported"
    private static var imported: Bool {
        get {
            return UserDefaults.standard.value(forKey: importedKey) as? Bool ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: importedKey)
        }
    }

    public static func importIfNeeded() {
        if imported {
            return
        }

        NSKeyedUnarchiver.setClass(SubjectLegacy.self, forClassName: "Subject")
        NSKeyedUnarchiver.setClass(HomeworkLegacy.self, forClassName: "Homework")
        NSKeyedUnarchiver.setClass(AttachmentLegacy.self, forClassName: "Attachment")
        NSKeyedUnarchiver.setClass(LessonLegacy.self, forClassName: "Lesson")
        NSKeyedUnarchiver.setClass(DayLegacy.self, forClassName: "Day")

        importSubjects()
        importHomework()
        importLessons()

        try? CoreDataStorage.shared.context.save()
        imported = true
    }
    
    private static func importSubjects() {
        guard let data = UserDefaults.standard.object(forKey: "subjects") as? Data else {
            return
        }
        
        allSubjects = NSKeyedUnarchiver.unarchiveObject(with: data) as? [SubjectLegacy] ?? []

        for subject in allSubjects {
            if findSubject(name: subject.name, teacher: subject.teacher) != nil {
                // Already imported.
                continue
            }
            
            createSubject(subject: subject)
        }
    }
    
    @discardableResult
    private static func createSubject(subject: SubjectLegacy) -> Subject {
        let newSubject = Subject(context: CoreDataStorage.shared.context)
        newSubject.name = subject.name
        newSubject.teacher = subject.teacher
        newSubject.uiColor = subject.color
        
        return newSubject
    }
    
    private static func importHomework() {
        guard let data = UserDefaults.standard.object(forKey: "homeworks") as? Data else {
            return
        }

        let allHomework = NSKeyedUnarchiver.unarchiveObject(with: data) as? [HomeworkLegacy] ?? []

        for homework in allHomework {
            guard let actualSubject = homework.subject else {
                continue
            }
            
            let updatedSubject = allSubjects.first(where: { $0.id == actualSubject.id }) ?? actualSubject
            
            let newSubject: Subject
            if let subject = findSubject(name: updatedSubject.name, teacher: updatedSubject.teacher) {
                newSubject = subject
            } else {
                newSubject = createSubject(subject: updatedSubject)
            }
            
            let newHomework = Homework(context: CoreDataStorage.shared.context)
            newHomework.subject = newSubject
            newHomework.workSet = homework.workSet
            newHomework.dueDate = homework.dueDate
            switch homework.type {
            case 0:
                newHomework.type = Homework.WorkType.none.rawValue
            case 1:
                newHomework.type = Homework.WorkType.essay.rawValue
            case 2:
                newHomework.type = Homework.WorkType.exercise.rawValue
            case 3:
                newHomework.type = Homework.WorkType.revision.rawValue
            case 4:
                newHomework.type = Homework.WorkType.notes.rawValue
            default:
                newHomework.type = Homework.WorkType.other.rawValue
            }
            
            for attachment in homework.attachments {
                if attachment.type == 0 {
                    if let data = attachment.info as? Data {
                        let newAttachment = ImageAttachment(context: CoreDataStorage.shared.context)
                        newAttachment.type = Attachment.ContentType.image.rawValue
                        newAttachment.title = attachment.title
                        newAttachment.data = data
                        
                        newHomework.addToAttachments(newAttachment)
                    }
                } else {
                    if let string = attachment.info as? String, let url = URL(string: string) {
                        let newAttachment = UrlAttachment(context: CoreDataStorage.shared.context)
                        newAttachment.type = Attachment.ContentType.url.rawValue
                        newAttachment.title = attachment.title
                        newAttachment.url = url
                    
                        newHomework.addToAttachments(newAttachment)
                    }
                }
            }
            
            newHomework.completed = homework.completed
        }
    }
    
    private static func importLessons() {
        Timetable.numberOfWeeks = isTwoWeekTimetable ? 2 : 1
        Timetable.weekStart = weekStartDate

        guard let data = UserDefaults.standard.object(forKey: "lessons") as? Data else {
            return
        }
        
        let allLessons = NSKeyedUnarchiver.unarchiveObject(with: data) as? [LessonLegacy] ?? []
        for lesson in allLessons {
            guard let actualSubject = lesson.subject, let day = lesson.day else {
                continue
            }
            
            let updatedSubject = allSubjects.first(where: { $0.id == actualSubject.id }) ?? actualSubject
            
            let newSubject: Subject
            if let subject = findSubject(name: updatedSubject.name, teacher: updatedSubject.teacher) {
                newSubject = subject
            } else {
                newSubject = createSubject(subject: updatedSubject)
            }
            
            let startComponents = Calendar.current.dateComponents([.hour, .minute], from: lesson.startTime)
            let endComponents = Calendar.current.dateComponents([.hour, .minute], from: lesson.endTime)
            
            let newLesson = Lesson(context: CoreDataStorage.shared.context)
            newLesson.subject = newSubject
            newLesson.startHour = Int32(startComponents.hour ?? 1)
            newLesson.startMinute = Int32(startComponents.minute ?? 1)
            newLesson.endHour = Int32(endComponents.hour ?? 2)
            newLesson.endMinute = Int32(endComponents.minute ?? 2)
            newLesson.week = Int32(day.week)
            newLesson.dayOfWeek = Int32(day.day + 1)
        }
    }
    
    private static var weekStartDate: Date {
        if let date = UserDefaults.standard.object(forKey: "days_start_week") as? Date {
            return date.withoutTime.previous(dayOfWeek: DayOfWeek.Monday)
        }
        
        return Date().withoutTime.previous(dayOfWeek: DayOfWeek.Monday)
    }
    
    private static var isTwoWeekTimetable: Bool {
        guard let data = UserDefaults.standard.object(forKey: "days") as? Data else {
            return false
        }
        
        guard let days = NSKeyedUnarchiver.unarchiveObject(with: data) as? [DayLegacy] else {
            return false
        }
        
        let filtered = days.filter { $0.week == 2 }
        return filtered.count != 0
    }
    
    private static func findSubject(name: String, teacher: String) -> Subject? {
        let request = NSFetchRequest<Subject>(entityName: "Subject")
        
        do {
            let subjects = try CoreDataStorage.shared.context.fetch(request)
            return subjects.first { subject in
                return subject.name == name && subject.teacher == teacher
            }
        } catch let error as NSError {
#if UIApplication
            UIApplication.shared.keyWindow?.rootViewController?.showAlert(error: error)
#else
            print(error)
#endif

            return nil
        }
    }
}
