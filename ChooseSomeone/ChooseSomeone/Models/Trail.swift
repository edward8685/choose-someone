//
//  Trail.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation

struct Trail: Codable, Hashable {
    let trailId: String
    let trailName: String
    let trailLocation: String
    let trailLevel: Int
    let trailLength: Double
    let trailInfo: String
    let trailTraffic: String
//    let trailMap: String?
//    let trailLikedList: [String]?
    
    enum CodingKeys: String, CodingKey {
        case trailId = "trail_id"
        case trailName = "trail_name"
        case trailLocation = "trail_location"
        case trailLevel = "trail_level"
        case trailLength = "trail_length"
        case trailInfo = "trail_info"
        case trailTraffic = "trail_traffic"
//        case trailMap = "trail_map"
//        case trailLikedList = "trail_liked_list"
    }
}
