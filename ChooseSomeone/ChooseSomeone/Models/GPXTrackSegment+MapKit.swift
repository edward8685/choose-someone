//
//  GPXTrackSegment+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//

import Foundation
import UIKit
import MapKit
import CoreGPX

extension GPXTrackSegment {
    
    public var overlay: MKPolyline {
        var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
        let polyLine = MKPolyline(coordinates: &coords, count: coords.count)
        return polyLine
    }
}

extension GPXTrackSegment {
  
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for point in self.points {
            coords.append(point.coordinate)
        }
        return coords
    }
    
    func length() -> CLLocationDistance {
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance
        if self.points.count < 2 {
            return length
        }
        var prev: CLLocation?
        for point in self.points {
            let point: CLLocation = CLLocation(latitude: Double(point.latitude!), longitude: Double(point.longitude!) )
            if prev == nil { //if first point => set it as previous and go for next
                prev = point
                continue
            }
            distanceTwoPoints = point.distance(from: prev!)
            length += distanceTwoPoints
            prev = point
        }
        return length
    }    
}
