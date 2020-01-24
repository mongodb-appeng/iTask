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
  
  static func getStringFromDate(date: Date) -> String {
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
}
