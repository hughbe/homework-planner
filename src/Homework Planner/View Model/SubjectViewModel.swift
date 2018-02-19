//
//  SubjectViewModel.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 18/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

public struct SubjectViewModel {
    internal let subject: Subject

    public init() {
        self.init(subject: Subject(context: CoreDataStorage.shared.context))
    }

    public init(subject: Subject) {
        self.subject = subject
    }

    public func delete() throws {
        try CoreDataStorage.shared.tryDelete(object: subject)
        NotificationCenter.default.post(name: Notifications.subjectsChanged, object: nil)
    }

    public var id: NSManagedObjectID {
        return subject.objectID
    }

    public var name: String {
        get {
            return subject.name ?? NSLocalizedString("No Subject", comment: "No Subject")
        }
        set {
            subject.name = newValue
        }
    }

    public var teacher: String {
        get {
            return subject.teacher ?? ""
        }
        set {
            subject.teacher = newValue
        }
    }

    private static let defaultColor = UIColor.black

    public var color: UIColor {
        get {
            guard let string = subject.color else {
                return SubjectViewModel.defaultColor
            }

            let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            let components = componentsString.components(separatedBy: ", ")

            if components.count != 4 {
                return SubjectViewModel.defaultColor
            }

            return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                           green: CGFloat((components[1] as NSString).floatValue),
                           blue: CGFloat((components[2] as NSString).floatValue),
                           alpha: CGFloat((components[3] as NSString).floatValue))
        } set {
            if let components = newValue.cgColor.components {
                subject.color = "[\(components[0]), \(components[1]), \(components[2]), \(components[3])]"
            }
        }
    }

    public static func findSubject(name: String, teacher: String) throws -> SubjectViewModel? {
        let request = NSFetchRequest<Subject>(entityName: "Subject")

        do {
            let subjects = try CoreDataStorage.shared.context.fetch(request)
            if let subject = subjects.first(where: { subject in
                return subject.name == name && subject.teacher == teacher
            }) {
                return SubjectViewModel(subject: subject)
            }
        } catch let error as NSError {
#if !TODAY_EXTENSION
                UIApplication.shared.keyWindow?.rootViewController?.showAlert(error: error)
#else
                print(error)
#endif
        }

        return nil
    }

    public class Colors {
        public static let all: [UIColor] = [
            UIColor(red: 255 / 255, green: 204 / 255, blue: 102 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 255 / 255, blue: 204 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 204 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 204 / 255, green: 102 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 111 / 255, blue: 207 / 255, alpha: 1),
            UIColor(red: 76 / 255, green: 76 / 255, blue: 76 / 255, alpha: 1),
            UIColor(red: 64 / 255, green: 128 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 128 / 255, green: 64 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 102 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 102 / 255, green: 255 / 255, blue: 102 / 255, alpha: 1),
            UIColor(red: 128 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1),
            UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 47 / 255, blue: 146 / 255, alpha: 1),
            ]

        public static func randomColor() -> UIColor {
            return all[Int(arc4random_uniform(UInt32(all.count)))]
        }
    }

    public class Notifications {
        public static let subjectsChanged = NSNotification.Name(rawValue: "SubjectsChangedNotification")
    }

    public static var CommonSubjects = [
        "Biology",
        "Chemistry",
        "Drama",
        "Economics",
        "English",
        "French",
        "Geography",
        "History",
        "Latin",
        "Maths",
        "PE",
        "Philosophy",
        "Politics",
        "Physics",
        "Russian",
        "Spanish"
    ]
}
