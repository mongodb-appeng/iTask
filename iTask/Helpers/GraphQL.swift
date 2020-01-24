//
//  GraphQL.swift
//  iTask
//
//  Created by Andrew Morgan on 21/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import Foundation
//import StitchCore

class GraphQL {
  let url = URL(string: "\(Constants.STITCH_BASE_URL)/api/client/v2.0/app/\(Constants.STITCH_APP_ID)/graphql")!
  var accessToken: String? = nil
  var refreshToken: String? = nil
  var userID: String? = nil
  
//  var currentUser: StitchCore.StitchUser? {
//    return stitchClient.auth.isLoggedIn ? stitchClient.auth.currentUser : nil
//  }

  var userToken: String? {
    return accessToken
  }
  
  func buildRequest(body: Data) -> URLRequest? {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    guard let accessToken = accessToken else {
      print("Access token not set")
      return nil
    }
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    print(String(data:body, encoding: .utf8)!)
    request.httpBody = body
    return request
  }
  
  class FetchTasksObject: Codable {
    let query = "{tasks(sortBy:DUEBY_ASC){id,name,tags,active,owner_id,createdAt,dueBy}}"
  }
  
  class FetchTaskResultData : Codable {
    let tasks: [Task]
  }
  
  class FetchTasksResult: Codable {
    let data: FetchTaskResultData
  }
  
  func fetchTasks(tasks: Tasks) {
    guard let body = try? JSONEncoder().encode(FetchTasksObject()) else {
      print("Failed to encode the body")
      tasks.taskList = []
      return
    }
    guard let request = buildRequest(body: body) else {
      print("Failed to build fetchTasks request")
      tasks.taskList = []
      return
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
        tasks.taskList = []
        return
      }
      print("Fetch task respone data:")
      print(String(data:data, encoding: .utf8)!)
      // TODO store the results in tasks.TaskList
      let decoder = JSONDecoder()
      do {
        let decoded = try decoder.decode(FetchTasksResult.self, from: data)
        print("Decoded \(decoded.data.tasks.count)")
        if (decoded.data.tasks.count > 0) {
          print("First id: \(decoded.data.tasks[0].id)")
        }
        DispatchQueue.main.async {
          tasks.taskList = decoded.data.tasks
        }
      } catch let error {
        print("Couldn't decode the tasks: \(error)")
      }
    }.resume()
  }
  
  class AddTaskObject: Codable {
    
    class Variables: Codable {
      let data: Task
      
      init(task: Task) {
        self.data = task
      }
    }
    
    let query =
      """
      mutation($data:TaskInsertInput!){
          insertOneTask(data:$data) {_id}
      }
      """
    let variables: Variables
    
    init(task: Task) {
      self.variables = Variables(task: task)
    }
  }
  
  func addTask(task: Task) {
    var body: Data
    do {
      body = try JSONEncoder().encode(AddTaskObject(task: task))
    } catch let error {
      print("Failed to encode the addTask body: \(error)")
      return
    }
    guard let request = buildRequest(body: body) else {
      print("Failed to build addTask request")
      return
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
          print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
          return
      }
      print("Respone data:")
      print(String(data:data, encoding: .utf8)!)
    }.resume()
  }
  
  class DeleteTaskObject: Codable {
    
    class Data: Codable {
      let id: String
      
      init(task: Task) {
        id = task.id
      }
    }
    
    class Variables: Codable {
      let data: Data
      
      init(task: Task) {
        self.data = Data(task: task)
      }
    }
    
    // TODO are any of the attributes in query actually needed?
    let query =
      """
      mutation($data:TaskQueryInput!){
        deleteOneTask(query:$data){
          _id
        }
      }
      """
    let variables: Variables
    
    init(task: Task) {
      self.variables = Variables(task: task)
    }
  }
  
  func deleteTask(task: Task) {
    guard let body = try? JSONEncoder().encode(DeleteTaskObject(task: task)) else {
      print("Failed to encode the body")
      return
    }
    guard let request = buildRequest(body: body) else {
      print("Failed to build addTask request")
      return
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
          print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
          return
      }
      print("Respone data:")
      print(String(data:data, encoding: .utf8)!)
    }.resume()
  }
  
  class UpdateTaskObject: Codable {
    
    class Query: Codable {
      let id: String
      
      init(task: Task) {
        print("Updated task with id: \(task.id)")
        id = task.id
      }
    }
    
    class Variables: Codable {
      let set: Task
      let query: Query
      
      init(task: Task) {
        self.set = task
        self.query = Query(task: task)
      }
    }
    
    let query =
      """
      mutation($query:TaskQueryInput!, $set:TaskUpdateInput!){
          updateOneTask(query:$query, set:$set){
              _id
          }
      }
      """
    let variables: Variables
    
    init(task: Task) {
      self.variables = Variables(task: task)
    }
  }
  
  func updateTask(task: Task) {
    guard let body = try? JSONEncoder().encode(UpdateTaskObject(task: task)) else {
      print("Failed to encode the updateTask body")
      return
    }
    guard let request = buildRequest(body: body) else {
      print("Failed to build addTask request")
      return
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
          print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
          return
      }
      print("Respone data:")
      print(String(data:data, encoding: .utf8)!)
    }.resume()
  }
  
  class TokenData: Codable {
    var access_token = ""
    var refresh_token = ""
    var user_id = ""
  }
  
  func connect(tasks: Tasks) {
//  func connect(tasks: Tasks, whenDone: () -> ()) {
    // TODO need to repeat this every 30 minutes, or when a GraphQL request fails
    // User https://www.hackingwithswift.com/example-code/system/how-to-make-an-action-repeat-using-timer +
    // https://www.hackingwithswift.com/books/ios-swiftui/how-to-be-notified-when-your-swiftui-app-moves-to-the-background
    
    
    // TODO only fetch token if not already set
    print("Fetching new auth token")
    let urlString = "\(Constants.STITCH_BASE_URL)/api/client/v2.0/app/\(Constants.STITCH_APP_ID)/auth/providers/anon-user/login"
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let refreshToken = refreshToken {
      request.setValue("Authorization", forHTTPHeaderField: "Bearer \(refreshToken)")
    }
    request.httpMethod = "POST"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      print("Sent token request")
      guard let data = data else {
          print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
          return
      }
      if let decodedToken = try? JSONDecoder().decode(TokenData.self, from: data) {
        self.accessToken = decodedToken.access_token
        self.refreshToken = decodedToken.refresh_token
        self.userID = decodedToken.user_id
        print("accessToken: \(self.accessToken ?? "")")
        print("refreshToken: \(self.refreshToken ?? "")")
        self.fetchTasks(tasks: tasks)
      } else {
        print("Invalid token response from server")
      }
    }.resume()
  }
}
