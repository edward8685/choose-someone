//
//  DistanceLabel.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import Foundation
import UIKit
import MapKit

open class DistanceLabel: UILabel {
    
    private var _distance = 0.0

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
