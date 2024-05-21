//
//  SpeedTestResultsModel.swift
//  SpeedTest
//
//  Created by admin on 5/18/24.
//

import Foundation
import SpeedcheckerSDK

struct SpeedTestResultsModel {
    var latitude: Double
    var longitude: Double
    var downloadSpeedMbps: Double
    var uploadSpeedMbps: Double
}
