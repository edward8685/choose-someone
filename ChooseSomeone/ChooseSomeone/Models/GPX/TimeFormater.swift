//
//  TimeFormater.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/31.
//

import Foundation
import FirebaseFirestore

enum TimeFormater: String {
    
    case dateStyle = "yyyy/MM/dd"
    
    case timeStyle = "HH:mm"
    
    case preciseTime = "yyyy/MM/dd  HH:mm"
    
    func timeFormat(time: Timestamp) -> String {
        
        let timeInterval = time
        
        let date = timeInterval.dateValue()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = self.rawValue
        
        let formatTime = dateFormatter.string(from: date as Date)
        
        return formatTime
    }
}
