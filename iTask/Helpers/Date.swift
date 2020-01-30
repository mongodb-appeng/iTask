//
//  Date.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//  See https://github.com/mongodb-appeng/iTask/LICENSE for license details
//
// Extends the `Date` class with helpers to map between Swift's Date class,
// the format required by MongoDB, and how we want them displayed in the app.

import Foundation

// Date extension
extension Date {
  
  static func getStringFromDate(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.string(from: date)
  }
  
  static func getDateFromString(dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    guard let date = formatter.date(from: dateString) else {
      return nil
    }
    return date
  }
  
  static func getPrintStringFromDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
  }
  
  static func getPrintStringFromISOString(_ string: String) -> String {
    guard let date = getDateFromString(dateString: string) else {
      print("Unable to get Date from String")
      return ""
    }
    return getPrintStringFromDate(date)
  }
}
