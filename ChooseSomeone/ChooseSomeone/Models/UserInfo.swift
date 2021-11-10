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
    var pictureRef: String?
    var totalLength: Double
    var totalFriends: Int
    var totalGroups: Int
    var blockList: [String]?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case userName = "user_name"
        case pictureRef = "picture_ref"
        case totalLength = "total_length"
        case totalFriends = "total_friends"
        case totalGroups = "total_groups"
        case blockList = "block_list"
    }
    
    init() {
        self.uid = ""
        self.userName = ""
        self.pictureRef = ""
        self.totalLength = 0.0
        self.totalFriends = 0
        self.totalGroups = 0
        self.blockList = []
    }
}
