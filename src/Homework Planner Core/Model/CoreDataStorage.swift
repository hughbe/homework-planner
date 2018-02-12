//
//  PersistentContainer.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import CoreData
import UIKit

private class PersistentContainer: NSPersistentContainer{
    override class func defaultDirectoryURL() -> URL{
        let x =  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.homework-planner")
        return x!
    }
}

public class CoreDataStorage {
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
}
