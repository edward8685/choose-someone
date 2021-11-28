//
//  Constant.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/28.
//

import Foundation

enum SegueIdentifier: String {

    case trailList = "toTrailList"

    case trailInfo = "toTrailInfo"

    case requestList = "toRequestList"
    
    case groupChat = "toGroupChat"
    
    case buildTeam = "toBuildTeam"
    
    case userRecord = "toUserRecord"
}

enum ProfileSegue: String, CaseIterable {
    
    case record = "toRecord"
    
    case account = "toAccount"
    
    case privacy = "toPrivacy"
}

enum Collection: String {
    
    case groups = "Groups"
    
    case messages = "Messages"
    
    case records = "Records"
    
    case requests = "Requests"
    
    case users = "Users"
    
    case trails = "Trails"
}
