//
//  Task.swift
//  iTask
//
//  Created by Andrew Morgan on 20/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import Foundation

class Task: Identifiable, Codable, Equatable {
  let id = UUID()
  var name: String
//  var type: String // TODO remove
//  var amount: Int // TODO remove
  var complete = false
  var tags: [String] = []
  
  init(name: String, tags: [String]) {
    self.name = name
    self.tags = tags
//    self.type = type
//    self.amount = amount
  }
  
  static func == (lhs: Task, rhs: Task) -> Bool {
    lhs.id == rhs.id
  }
}
