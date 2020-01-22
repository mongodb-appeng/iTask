//
//  GraphQL.swift
//  iTask
//
//  Created by Andrew Morgan on 21/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import Foundation
import StitchCore

class GraphQL {
  let url = URL(string: "\(Constants.STITCH_BASE_URL)/api/client/v2.0/app/\(Constants.STITCH_APP_ID)/graphql")!
  var accessToken: String? = nil
  var refreshToken: String? = nil
  var userID: String? = nil
  
  var currentUser: StitchCore.StitchUser? {
    return stitchClient.auth.isLoggedIn ? stitchClient.auth.currentUser : nil
  }

  var userToken: String? {
    return accessToken
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
          insertOneTask(data:$data){
              id,
              name,
              tags,
              active
          }
      }
      """
    let variables: Variables
    
    init(task: Task) {
      self.variables = Variables(task: task)
    }
  }
  
  func addTask(task: Task) {
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    guard let accessToken = accessToken else {
      print("Access token not set")
      return
    }
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    guard let body = try? JSONEncoder().encode(AddTaskObject(task: task)) else {
      print("Failed to encode the addTask body")
      return
    }
    print(String(data:body, encoding: .utf8)!)
    request.httpBody = body
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
  
  func fetchToken() {
    
    // TODO need to repeat this every 30 minutes, or when a GraphQL request fails
    // User https://www.hackingwithswift.com/example-code/system/how-to-make-an-action-repeat-using-timer +
    // https://www.hackingwithswift.com/books/ios-swiftui/how-to-be-notified-when-your-swiftui-app-moves-to-the-background
    
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
      } else {
        print("Invalid token response from server")
      }
    }.resume()
  }
  
  init() {
    self.fetchToken()
  }
}
