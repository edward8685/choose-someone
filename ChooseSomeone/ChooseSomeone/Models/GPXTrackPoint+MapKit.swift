//
//  GPXPoint+MapKit.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/27.
//

import Foundation
import UIKit
import MapKit
import CoreGPX

extension GPXTrackPoint {

    convenience init(location: CLLocation) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.time = Date()
        self.elevation = location.altitude
    }
}
