//
//  GraphQL.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//  See https://github.com/mongodb-appeng/iTask/LICENSE for license details
//

import Foundation

class GraphQL {
  let url = URL(string: "\(Constants.STITCH_BASE_URL)/api/client/v2.0/app/\(Constants.STITCH_APP_ID)/graphql")!
  var accessToken: String? = nil
  var refreshToken: String? = nil
  var userID: String? = nil

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
    let query = "{tasks(sortBy:DUEBY_ASC){_id,name,tags,active,owner_id,createdAt,dueBy}}"
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
      let decoder = JSONDecoder()
      do {
        let decoded = try decoder.decode(FetchTasksResult.self, from: data)
        print("Decoded \(decoded.data.tasks.count)")
        if (decoded.data.tasks.count > 0) {
          print("First _id: \(decoded.data.tasks[0]._id)")
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
      let _id: String
      
      init(task: Task) {
        _id = task._id
      }
    }
    
    class Variables: Codable {
      let data: Data
      
      init(task: Task) {
        self.data = Data(task: task)
      }
    }
    
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
      print("Failed to build deleteTask request")
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
      let _id: String
      
      init(task: Task) {
        print("Updated task with _id: \(task._id)")
        _id = task._id
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
      print("Failed to build updateTask request")
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
  
  class RefreshedTokenData: Codable {
    var access_token = ""
  }
  
  func connect(tasks: Tasks) {   
    // If this isn't the first time that this app has run on this device then it should be
    // possible to retrieve the refresh token so that we auethenticate as the same anonymous user
    if let tokens = UserDefaults.standard.data(forKey: "iTaskToken") {
      let decoder = JSONDecoder()
      if let decoded = try? decoder.decode(TokenData.self, from: tokens) {
        self.refreshToken = decoded.refresh_token
        self.userID = decoded.user_id
        print("Found refresh token: \(self.refreshToken ?? "")")
      }
    }
    
    print("Fetching new auth token")
    var urlString: String
    if let _ = refreshToken {
      urlString = "\(Constants.STITCH_BASE_URL)/api/client/v2.0/auth/session"
      print("Using refresh URL: \(urlString)")
    } else {
      urlString = "\(Constants.STITCH_BASE_URL)/api/client/v2.0/app/\(Constants.STITCH_APP_ID)/auth/providers/anon-user/login"
    }
    let url = URL(string: urlString)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let refreshToken = refreshToken {
      request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
    }
    request.httpMethod = "POST"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      print("Sent token request")
      guard let data = data else {
          print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
          return
      }
      print ("Token response: \(String(data:data, encoding: .utf8) ?? "")")

      if let _ = self.refreshToken {
        if let decodedToken = try? JSONDecoder().decode(RefreshedTokenData.self, from: data) {
          self.accessToken = decodedToken.access_token
          print("accessToken: \(self.accessToken ?? "")")
        } else {
          print("Invalid token response from server")
          return
        }
      } else {
        UserDefaults.standard.set(data, forKey: "iTaskToken")
        if let decodedToken = try? JSONDecoder().decode(TokenData.self, from: data) {
          self.accessToken = decodedToken.access_token
          self.refreshToken = decodedToken.refresh_token
          self.userID = decodedToken.user_id
          print("accessToken: \(self.accessToken ?? "")")
          print("refreshToken: \(self.refreshToken ?? "")")
        } else {
          print("Invalid token response from server")
          return
        }
      }
      self.fetchTasks(tasks: tasks)
    }.resume()
  }
}
