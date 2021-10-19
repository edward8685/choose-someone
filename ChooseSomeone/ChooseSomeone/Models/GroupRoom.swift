//
//  GroupRoom.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation

struct GroupRoom: Codable {
    
    var groupId: String
    var groupName: String
    var hostId: String
    var date: Int64
    var upperLimit: Int
    var trailName: String
    var note: String
    var userIds: [String]
    var messages: [Message]?
    
    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case groupName = "group_name"
        case hostId =  "host_id"
        case date
        case upperLimit = "upper_limit"
        case trailName = "trail_name"
        case note
        case userIds = "user_ids"
        case messages
    }
}

struct Message: Codable {
    var sender: String
    var body: String
    var createdTime: Int64
    enum CodingKeys: String, CodingKey {
        case sender
        case body
        case createdTime = "created_time"
    }
}
