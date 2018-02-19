//
//  HomeworkViewModel.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 18/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import DayDatePicker
import UIKit
import UserNotifications

public struct HomeworkViewModel {
    private static var checkedImage = #imageLiteral(resourceName: "checked")
    private static var uncheckedImage = #imageLiteral(resourceName: "unchecked")

    private static var starredImage = #imageLiteral(resourceName: "starred")
    private static var unstarredImage = #imageLiteral(resourceName: "unstarred")

    public let homework: Homework

    public init(insert: Bool = true) {
        if insert {
            self.init(homework: Homework(context: CoreDataStorage.shared.context))
        } else {
            let entityDescription = NSEntityDescription.entity(forEntityName: "Homework", in: CoreDataStorage.shared.context)!
            self.init(homework: Homework(entity: entityDescription, insertInto: nil))
        }
    }

    public init(homework: Homework) {
        self.homework = homework
    }

    public func delete() throws {
        try CoreDataStorage.shared.tryDelete(object: homework)
    }

    public func create(subject: SubjectViewModel) throws {
        CoreDataStorage.shared.context.insert(homework)
        homework.subject = subject.subject

        for attachment in homework.attachments ?? [] {
            (attachment as? Attachment)?.homework = homework
        }

        try CoreDataStorage.shared.context.save()
        createNotification()
    }

    public var id: NSManagedObjectID {
        return homework.objectID
    }

    public var subject: SubjectViewModel? {
        get {
            guard let subject = homework.subject else {
                return nil
            }

            return SubjectViewModel(subject: subject)
        } set {
            homework.subject = newValue?.subject
        }
    }

    public func title(displayType: DisplayType) -> String {
        switch displayType {
        case .sectionedByDate:
            return subject!.name
        case .sectionedBySubject:
            return workSet
        }
    }

    public func detail(displayType: DisplayType) -> String {
        switch displayType {
        case .sectionedByDate:
            return workSet
        case .sectionedBySubject:
            let dueDate = homework.dueDate ?? Date()
            let result = Calendar.current.compare(dueDate, to: Date(), toGranularity: .day)

            if homework.completed || result != .orderedAscending {
                return formattedDate
            } else {
                return NSLocalizedString("Overdue", comment: "Overdue") + " - " + formattedDate
            }
        }
    }

    public func detailColor(displayType: DisplayType) -> UIColor {
        switch displayType {
        case .sectionedByDate:
            return UIColor(white: 0.4, alpha: 1)
        case .sectionedBySubject:
            let dueDate = homework.dueDate ?? Date()
            let result = Calendar.current.compare(dueDate, to: Date(), toGranularity: .day)

            if homework.completed || result == .orderedDescending {
                return UIColor(white: 0.4, alpha: 1)
            } else if result == .orderedSame {
                return UIColor.orange
            } else {
                return UIColor.red
            }
        }
    }

    public var workSet: String {
        get {
            return homework.workSet ?? ""
        } set {
            homework.workSet = newValue
        }
    }

    public var sectionTitle: String? {
        if DisplayType.currentDisplay == .sectionedBySubject {
            var title = subject!.name
            if subject!.teacher.count > 0 {
                title.append("(\(subject!.teacher))")
            }

            return title
        } else if DisplayType.currentDisplay == .sectionedByDate {
            return formattedDate
        } else {
            fatalError("Invalid current display")
        }
    }

    public var date: DayDatePickerView.Date? {
        guard let date = homework.dueDate else {
            return nil
        }

        return DayDatePickerView.Date(date: date)
    }

    private var formattedDate: String {
        guard let dueDate = homework.dueDate else {
            return ""
        }

        if Calendar.current.isDateInToday(dueDate) {
            return NSLocalizedString("Today", comment: "Today")
        } else if Calendar.current.isDateInTomorrow(dueDate) {
            return NSLocalizedString("Tomorrow", comment: "Tomorrow")
        }

        let prefixFormatter = DateFormatter()
        prefixFormatter.dateFormat = "EEEE d"

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = " MMM"

        return prefixFormatter.string(from: dueDate) + dueDate.ordinalIndicatorString + monthFormatter.string(from: dueDate)
    }

    public var typeString: String {
        return WorkType(rawValue: homework.type)!.name
    }

    public func setType(type: HomeworkViewModel.WorkType) {
        homework.type = type.rawValue
    }

    public var priorityImage: UIImage {
        return homework.completed ? HomeworkViewModel.starredImage : HomeworkViewModel.unstarredImage
    }

    public var completedImage: UIImage {
        return homework.completed ? HomeworkViewModel.checkedImage : HomeworkViewModel.uncheckedImage
    }

    public func toggleCompleted() {
        setCompleted(completed: !homework.completed)
    }

    public func setCompleted(completed: Bool) {
        homework.completed = completed
    }

    public func togglePriority() {
        setPriorty(priority: !homework.priority)
    }

    public func setPriorty(priority: Bool) {
        homework.priority = priority
    }

    public func setDueDate(dueDate: Date) {
        homework.dueDate = dueDate.withoutTime
    }

    public var url: URL {
        let urlString = homework.objectID.uriRepresentation().absoluteString
        return URL(string: "homework-planner://\(urlString)")!
    }

    public var images: [ImageAttachmentViewModel] {
        guard let attachments = homework.attachments?.allObjects as? [Attachment] else {
            return []
        }

        return attachments.filter { $0.type == AttachmentViewModel.ContentType.image.rawValue }.map { $0 as! ImageAttachment }.map(ImageAttachmentViewModel.init)
    }

    public var numberOfAttachments: Int {
        return homework.attachments?.count ?? 0
    }

    public var websites: [UrlAttachmentViewModel] {
        guard let attachments = homework.attachments?.allObjects as? [Attachment] else {
            return []
        }

        return attachments.filter { $0.type == AttachmentViewModel.ContentType.url.rawValue }.map { $0 as! UrlAttachment }.map(UrlAttachmentViewModel.init)
    }

    public func addAttachment(attachment: AttachmentViewModel) {
        homework.addToAttachments(attachment.attachment)
    }

    public func removeAttachment(attachment: AttachmentViewModel) {
        homework.removeFromAttachments(attachment.attachment)
    }

    public static func section(homework: [HomeworkViewModel]) -> [[HomeworkViewModel]] {
        let sectionedHomework: [[HomeworkViewModel]]

        switch DisplayType.currentDisplay {
        case .sectionedByDate:
            let groupedHomework = Dictionary(grouping: homework) { $0.homework.dueDate ?? Date() }
            sectionedHomework = groupedHomework.values.sorted { homework1, homework2 in
                let date1 = homework1.first?.homework.dueDate ?? Date().withoutTime
                let date2 = homework2.first?.homework.dueDate ?? date1

                return date1.compare(date2) == .orderedAscending
            }
        case .sectionedBySubject:
            let groupedHomework = Dictionary(grouping: homework) { $0.subject!.name }
            sectionedHomework = groupedHomework.values.sorted { homework1, homework2 in
                let name1 = homework1.first?.subject?.name ?? ""
                let name2 = homework2.first?.subject?.name ?? ""

                return name1.compare(name2) == .orderedAscending
            }
        }

        return sectionedHomework.map { homework in
            return homework.sorted { (homework1, homework2) in
                let order = homework1.order(other: homework2, comparisonType: DisplayType.currentDisplay.comparisonType)

                return order == .before
            }
        }
    }
}

extension HomeworkViewModel {
    private func createNotification() {
        guard let dueDate = homework.dueDate?.withoutTime, dueDate.compare(Date().withoutTime) == .orderedDescending else {
            return
        }

        guard let notificationDate = Calendar.current.date(byAdding: .day, value: 1, to: dueDate) else {
            return
        }

        guard let name = homework.subject?.name else {
            return
        }

        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { (granted, error) in
            guard granted else {
                return
            }

            var components = Calendar.current.dateComponents([.year, .month, .day], from: notificationDate)
            components.hour = 12

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let content = UNMutableNotificationContent()
            content.title = name + " " + NSLocalizedString("homework is due tomorrow", comment: "homework is due tomorrow")

            let notification = UNNotificationRequest(identifier: self.homework.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(notification) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }

    private func deleteNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [homework.objectID.uriRepresentation().absoluteString])
    }
}

extension HomeworkViewModel {
    public enum ComparisonType {
        case subject
        case date
    }

    public enum Order {
        case before
        case equal
        case after

        init(comparisonResult: ComparisonResult) {
            switch comparisonResult {
            case .orderedAscending:
                self = .before
            case .orderedSame:
                self = .equal
            case .orderedDescending:
                self = .after
            }
        }
    }

    public func order(other: HomeworkViewModel, comparisonType: ComparisonType) -> Order {
        if homework.priority != other.homework.priority && (!other.homework.completed || homework.completed == other.homework.completed) {
            if homework.priority {
                return .before
            }

            return .after
        }

        if homework.completed != other.homework.completed {
            if homework.completed {
                return .after
            }

            return .before
        }

        if comparisonType == .subject {
            return Order(comparisonResult: subject!.name.compare(other.subject!.name))
        } else if comparisonType == .date {
            let date1 = homework.dueDate ?? Date()
            let date2 = other.homework.dueDate ?? date1

            return Order(comparisonResult: date1.compare(date2))
        } else {
            return .equal
        }
    }
}

extension HomeworkViewModel {
    public enum DisplayType: Int {
        case sectionedByDate
        case sectionedBySubject

        public var name: String {
            switch self {
            case .sectionedByDate:
                return NSLocalizedString("Order By Date", comment: "Order By Date")
            case .sectionedBySubject:
                return NSLocalizedString("Order By Subject", comment: "Order By Subject")
            }
        }

        public static let allValues: [DisplayType] = [
            .sectionedByDate,
            .sectionedBySubject
        ]

        public var comparisonType: ComparisonType {
            switch self {
            case .sectionedByDate:
                return .subject
            case .sectionedBySubject:
                return .date
            }
        }

        public class Notifications {
            public static let didChange = NSNotification.Name("HomeworkDisplayTypeDidChange")
        }

        private static let homeworkDisplayKey = "HomeworkDisplay"

        public static var currentDisplay: DisplayType {
            get {
                if let value = UserDefaults.standard.value(forKey: homeworkDisplayKey) as? Int {
                    return DisplayType(rawValue: value)!
                }

                return .sectionedByDate
            } set {
                UserDefaults.standard.set(newValue.rawValue, forKey: homeworkDisplayKey)

                NotificationCenter.default.post(name: Notifications.didChange, object: newValue)
            }
        }
    }
}

extension HomeworkViewModel {
    public enum WorkType: Int32 {
        case none
        case essay
        case exercise
        case revision
        case notes
        case other

        public var name: String {
            switch self {
            case .none:
                return NSLocalizedString("No Type", comment: "No Type")
            case .essay:
                return NSLocalizedString("Essay", comment: "Essay")
            case .exercise:
                return NSLocalizedString("Exercise", comment: "Exercise")
            case .revision:
                return NSLocalizedString("Revision", comment: "Revision")
            case .notes:
                return NSLocalizedString("Notes", comment: "Notes")
            case .other:
                return NSLocalizedString("Other", comment: "Other")
            }
        }

        public static let allValues: [WorkType] = [
            .none,
            .essay,
            .exercise,
            .revision,
            .notes,
            .other
        ]
    }
}
