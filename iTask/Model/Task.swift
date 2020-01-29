//
//  Task.swift
//  iTask
//
//  Created by Andrew Morgan on 20/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import Foundation

class Task: Identifiable, Codable, Equatable {
  var id: String
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
    self.id = UUID().uuidString
    self.createdAt = Date.getStringFromDate(Date())
  }
  
  static func == (lhs: Task, rhs: Task) -> Bool {
    lhs.id == rhs.id
  }
}
