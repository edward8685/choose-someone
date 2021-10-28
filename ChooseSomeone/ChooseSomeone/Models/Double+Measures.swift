//
//  Double+Meatures.swift
//  OpenGpxTracker
//
//  Created by merlos on 03/05/2019.
//
// Shared file: this file is also included in the OpenGpxTracker-Watch Extension target.

import Foundation

/// Number of meters in 1 kilometer (km)
let kMetersPerKilometer = 1000.0

/// Number of kilometers per hour in 1 meter per second
/// To convert m/s -> km/h
let kKilometersPerHourInOneMeterPerSecond = 3.6

/// Number of miles per hour in 1 meter per second
///
/// Extension to convert meters to other units
///
/// It was created to support conversion of units also in iOS9
///
/// (UnitConverterLinear)[https://developer.apple.com/documentation/foundation/unitlength#overview]
/// is available only in iOS 10 or above.
///
/// It always asumes the value in meters (lengths) or meters per second (speeds)
extension Double {
    
    /// Assuming current value is in meters, it returns the equivalent in kilometers
    func toKilometers() -> Double {
        return self/kMetersPerKilometer
    }
    
    /// Assuming current value is in meters, it returns a string wiht the equivalent in
    /// kilometers with two decimals and km
    ///
    /// Example: Current value is 1210.0, it returns "1.21km"
    func toKilometers() -> String {
        return String(format: "%.2fkm", toKilometers() as Double)
    }
    
    /// Returns current value as a string without decimals and with m.
    ///
    /// Example: Current value is 1210.13, it returns "1210m"
    func toMeters() -> String {
        return String(format: "%.0fm", self)
    }
    
    /// Assuming current value (d) is in meters it returns the distance as string
    /// * if d < 1000 => in meters ("567m")
    /// * if d > 1000 => in kilometers ("1.24km")
    /// * if useImperial == true => converted in miles ("1.24mi")
    func toDistance() -> String {
            return self > kMetersPerKilometer ? toKilometers() as String : toMeters() as String
    }
  
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in kilometers per hour (km/h)
    func toKilometersPerHour() -> Double {
        return self * kKilometersPerHourInOneMeterPerSecond
    }
    
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in kilometers per hour with two decimals as
    /// string  ("120.34km/h")
    func toKilometersPerHour() -> String {
        return String(format: "%.2fkm/h", toKilometersPerHour() as Double)
    }
    
    func toSpeed() -> String {
        return toKilometersPerHour() as String
    }
    
    func toAltitude() -> String {
        toMeters() as String
    }
    
    /// Asuming current value is an altitud in meters,
    func toAccuracy(useImperial: Bool = false) -> String {
        return "±\(toMeters() as String)"
    }

}
