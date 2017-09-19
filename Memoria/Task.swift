//
//  Task.swift
//  Memoria
//
//  Created by Vishal Chaurasia on 9/19/17.
//  Copyright © 2017 Vishal. All rights reserved.
//

import Foundation
import RealmSwift
class Task: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var date : Double = 0
    @objc dynamic var priority = 0
}
