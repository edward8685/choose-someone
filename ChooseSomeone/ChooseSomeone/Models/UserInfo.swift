//
//  User.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation

struct UserInfo: Codable {
    
    var uid: String
    var userName: String?
    var userPicture: String?
    var totalLength: Double
    var totalFriends: Int
    var totalGroups: Int
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userName = "user_name"
        case userPicture = "user_picture"
        case totalLength = "total_length"
        case totalFriends = "total_friends"
        case totalGroups = "total_groups"
    }
    
    init() {
        self.uid = ""
        self.userName = ""
        self.userPicture = ""
        self.totalLength = 0.0
        self.totalFriends = 0
        self.totalGroups = 0
    }
}
