//
//  DistanceLabel.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//

import Foundation
import UIKit
import MapKit

open class DistanceLabel: UILabel {
    
    /// Internal variable that keeps the actual distance
    private var _distance = 0.0

    
    /// Distance in meters
    open var distance: CLLocationDistance {
        get {
            return _distance
        }
        set {
            _distance = newValue
            text = newValue.toDistance()
        }
    }
}
