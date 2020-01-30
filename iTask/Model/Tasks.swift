//
//  Tasks.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//  See https://github.com/mongodb-appeng/iTask/LICENSE for license details
//

import Foundation

class Tasks: ObservableObject {
  @Published var taskList = [Task]()
  
  func addTask(_ newTask: Task) {
    if let _ = taskList.firstIndex(of: newTask) {
      print("Attempt to add duplicate task")
    } else {
      taskList.append(newTask)
      graphQL.addTask(task: newTask)
    }
  }
  
  func deleteTask(_ oldTask: Task) {
    if let index = taskList.firstIndex(of: oldTask) {
      taskList.remove(at: index)
      graphQL.deleteTask(task: oldTask)
    } else {
      print("Attempt to delete a non-existent task")
    }
  }
  
  func updateTask(_ existingTask: Task) {
    if let index = taskList.firstIndex(of: existingTask) {
      taskList[index] = existingTask
      graphQL.updateTask(task: existingTask)
    } else {
      print("Attempt to update a non-existent task")
    }
  }
  
  func fetchTasks() {
    graphQL.fetchTasks(tasks: self)
  }
  
  init() {
    graphQL.connect(tasks: self)
  }
}
