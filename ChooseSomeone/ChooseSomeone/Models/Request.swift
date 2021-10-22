//
//  Requests.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation
import FirebaseFirestore

struct Request: Codable {
    var groupId: String
    var groupName: String
    var hostId: String
    var requestId: String
    var requestName: String
    var createdTime: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case requestId = "request_id"
        case requestName = "request_name"
        case groupId = "group_id"
        case groupName = "group_name"
        case hostId = "host_id"
        case createdTime = "created_time"
    }
}

