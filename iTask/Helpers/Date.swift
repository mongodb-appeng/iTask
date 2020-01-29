//
//  Date.swift
//  iTask
//
//  Created by Andrew Morgan on 24/01/2020.
//  Copyright © 2020 ClusterDB. All rights reserved.
//

import Foundation

// Date extension
extension Date {
  
  static func getStringFromDate(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
//                               .withDashSeparatorInDate,
//                               .withFullDate,
//                               .withFractionalSeconds,
//                               .withColonSeparatorInTimeZone]
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
//    formatter.locale = Locale(identifier: "en_US")
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
