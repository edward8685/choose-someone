//
//  Double+Meatures.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/27.
//

import Foundation

let metersPerKilometer = 1000.0

let kilometersPerHourInOneMeterPerSecond = 3.6

extension Double {
    
    func toKilometers() -> Double {
        return self/metersPerKilometer
    }
    
    func toKilometers() -> String {
        return String(format: "%.2fkm", toKilometers() as Double)
    }
    
    func toMeters() -> String {
        return String(format: "%.0fm", self)
    }
    
    func toDistance() -> String {
        return self > metersPerKilometer ? toKilometers() as String : toMeters() as String
    }
    
    func toKilometersPerHour() -> Double {
        return self * kilometersPerHourInOneMeterPerSecond
    }
    
    func toKilometersPerHour() -> String {
        return String(format: "%.2fkm/h", toKilometersPerHour() as Double)
    }
    
    func toSpeed() -> String {
        return toKilometersPerHour() as String
    }
    
    func toAltitude() -> String {
        toMeters() as String
    }
    
    func toAccuracy(useImperial: Bool = false) -> String {
        return "±\(toMeters() as String)"
    }
    
    func tohmsTimeFormat () -> String {
        
        let seconds = Int(self)
        
        let hour = (seconds % 3600) % 60
        
        let minute = (seconds % 3600) / 60
        
        let second = seconds / 3600
        
        var timeString = ""
        
        timeString += second.description
        
        timeString += ":"
        
        timeString += minute.description
        
        timeString += ":"
        
        timeString += hour.description
        
        return timeString
    }
}
