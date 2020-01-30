//
//  Constants.swift
//  iTask
//
//  Created by Andrew Morgan on 08/01/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//  See https://github.com/mongodb-appeng/iTask/LICENSE for license details
//

import Foundation

struct Constants {
  static let STITCH_APP_ID = "itask-xoind" // Get this from your Stitch app
  
  static let STITCH_BASE_URL = "https://stitch.mongodb.com" // Don't change
  static let STITCH_GRAPHQL_TOKEN_TIMEOUT = 30.0  // Auth token refresh interval in minutes
                                                // - shouldn't need to change
}
