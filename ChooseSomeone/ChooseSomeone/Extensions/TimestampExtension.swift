//
//  TimestampExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/31.
//

import Foundation
import FirebaseFirestore

extension Timestamp {
    
    static func timeFormat(time: Timestamp) -> String {
        
        let timeInterval = time
        
        let date = timeInterval.dateValue()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy/MM/dd  HH:mm"
        
        let formatTime = dateFormatter.string(from: date as Date)
        
        return formatTime
    }
}
