//
//  DatabaseService.swift
//  Memoria
//
//  Created by Vishal Chaurasia on 9/19/17.
//  Copyright © 2017 Vishal. All rights reserved.
//

import Foundation
import RealmSwift
class DatabaseService {
    static let uiRealm = try! Realm()
    
    class func addNew(task: Task) throws {
        do {
            try uiRealm.write {
                uiRealm.add(task)
            }
        }
    }
    
    class func fetchTasks() -> [Task] {
        return Array(uiRealm.objects(Task.self))
    }
    
    class func updateTask(newTask: Task, oldTask: Task) throws {
        do {
            try uiRealm.write {
                oldTask.title = newTask.title
                oldTask.date = newTask.date
                oldTask.priority = newTask.priority
            }
        }
    }
}
