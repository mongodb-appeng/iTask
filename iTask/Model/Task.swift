//
//  Task.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//  See https://github.com/mongodb-appeng/iTask/LICENSE for license details
//

import Foundation

class Task: Identifiable, Codable, Equatable {
  var _id: String
  let owner_id: String
  let createdAt: String
  var name: String
  var active = true
  var tags: [String] = []
  var dueBy = ""
  
  init(name: String, tags: [String], ownerID: String, dueBy: String) {
    self.name = name
    self.tags = tags
    self.owner_id = ownerID
    self.dueBy = dueBy
    self._id = UUID().uuidString
    self.createdAt = Date.getStringFromDate(Date())
  }
  
  static func == (lhs: Task, rhs: Task) -> Bool {
    lhs._id == rhs._id
  }
}
