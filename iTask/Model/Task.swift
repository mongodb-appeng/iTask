//
//  Task.swift
//  iTask
//
//  Created by Andrew Morgan on 20/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import Foundation

class Task: Identifiable, Codable, Equatable {
//  let id = UUID().uuidString
  let id: String
  let owner_id: String
  var name: String
  var active = true
  var tags: [String] = []
  
  init(name: String, tags: [String], ownerID: String) {
    self.name = name
    self.tags = tags
    self.owner_id = ownerID
    self.id = UUID().uuidString
  }
  
  static func == (lhs: Task, rhs: Task) -> Bool {
    lhs.id == rhs.id
  }
}
