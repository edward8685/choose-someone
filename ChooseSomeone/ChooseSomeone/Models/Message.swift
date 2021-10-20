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
//public protocol MessageType {
//
//    var sender: Sender { get }
//
//    var messageId: String { get }
//
//    var sentDate: Date { get }
//
//    var kind: MessageKind { get }
//}
//public protocol SenderType {
//
//    var senderId: String { get }
//    
//    var displayName: String { get }
//}
