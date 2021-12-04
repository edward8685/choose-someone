//
//  Record.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import Foundation
import FirebaseFirestore

struct Record: Codable, Hashable {
    
    var uid: String
    var createdTime: Timestamp
    var recordId: String
    var recordName: String
    var recordRef: String
    
    enum CodingKeys: String, CodingKey {
        case uid
        case createdTime = "created_time"
        case recordId = "record_id"
        case recordName = "record_name"
        case recordRef = "record_ref"
    }
    
    init() {
        self.uid = ""
        self.createdTime = Timestamp()
        self.recordId = ""
        self.recordName = ""
        self.recordRef = ""
    }
}
