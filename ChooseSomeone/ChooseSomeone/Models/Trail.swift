//
//  Trail.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation

struct Trail: Codable {
    let trailId: Int
    let trailCategory: String?
    let trailLocation: String
    let trailLevel: Int
    let traiLength: Int
    let trailInfo: String
    let trailTraffic: String?     
    let trailMap: String?
//    let trailImages: [String]
    let trailLikedList: [String]?
    
    enum CodingKeys: String, CodingKey {
        case trailId = "trail_id"
        case trailCategory = "trail_category"
        case trailLocation = "trail_location"
        case trailLevel = "trail_level"
        case traiLength = "trail_length"
        case trailInfo = "trail_info"
        case trailTraffic = "trail_traffic"
        case trailMap = "trail_map"
//        case trailImages = "trail_images"
        case trailLikedList
    }
}
