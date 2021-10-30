//
//  Record.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import Foundation

struct Record: Codable {
    
    var uid: String
    var recordId: String
    var recordName: String
    var recordRef: URL?

    enum CodingKeys: String, CodingKey {
        case uid
        case recordId = "record_id"
        case recordName = "record_name"
        case recordRef = "record_ref"
    }
    
    init() {
            self.uid = ""
            self.recordId = ""
            self.recordName = ""
            self.recordRef = URL(string: "")
        }
}
