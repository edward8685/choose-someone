//
//  TrackInfo.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/2.
//

import Foundation

import Foundation

struct TrackInfo: Codable {
    
    var distance: Double
    var spentTime: TimeInterval
    var avgSpeed: Double
    var elevationDiff: Double
    var totalClimb: Double
    var totalDrop: Double
    
    init() {
        self.distance = 0.0
        self.spentTime = 0.0
        self.avgSpeed = 0.0
        self.elevationDiff = 0.0
        self.totalClimb = 0.0
        self.totalDrop = 0.0
    }
}
