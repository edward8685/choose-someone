//
//  User.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation

struct User: Codable {
    
    var uid: String
    var userName: String
    var userEmail: String
    var joinedRoomIds: [String]?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userName = "user_name"
        case userEmail = "user_email"
        case joinedRoomIds = "joined_room_ids"
    }
}


