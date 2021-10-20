//
//  GroupRoom.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation
import FirebaseFirestore

struct Group: Codable {
    var groupId: String
    var groupName: String
    var hostId: String
    var date: Timestamp
    var upperLimit: Int
    var trailName: String
    var note: String
    var userIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case groupName = "group_name"
        case hostId =  "host_id"
        case date
        case upperLimit = "upper_limit"
        case trailName = "trail_name"
        case note
        case userIds = "user_ids"
    }
    var toDict: [String: Any] {
        return [
            "groupId": groupId as Any,
            "groupName": groupName as Any,
            "hostId": hostId as Any,
            "upperLimit": upperLimit as Any,
            "trailName": trailName as Any,
            "note": note as Any,
            "userIds": userIds as Any,
        ]
    }
}

