//
//  Message.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation
import FirebaseFirestore

struct Message: Codable {
    var groupId: String
    var userId: String
    var userName: String
    var body: String
    var createdTime: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case userId = "user_id"
        case userName = "user_name"
        case body
        case createdTime = "created_time"
    }
}
