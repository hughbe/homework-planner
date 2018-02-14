//
//  PersistentContainer.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

public class CoreDataStorage {
    private class PersistentContainer: NSPersistentContainer{
        override class func defaultDirectoryURL() -> URL{
            let x =  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.homework-planner")
            return x!
        }
    }

    public static var shared = CoreDataStorage()
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    public lazy var persistentContainer: NSPersistentContainer = {
        let container = PersistentContainer(name: "Homework_Planner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
#if UIApplication
                UIApplication.shared.keyWindow?.rootViewController?.showAlert(error: error as NSError)
#endif
            }
        })
        return container
    }()

#if DEBUG
    public func clear() {
        let homeworkFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Homework")
        let homeworkRequest = NSBatchDeleteRequest(fetchRequest: homeworkFetch)

        let lessonFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
        let lessonRequest = NSBatchDeleteRequest(fetchRequest: lessonFetch)

        let subjectFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
        let subjectRequest = NSBatchDeleteRequest(fetchRequest: subjectFetch)

        try! context.execute(homeworkRequest)
        try! context.execute(lessonRequest)
        try! context.execute(subjectRequest)
    }
#endif
}
