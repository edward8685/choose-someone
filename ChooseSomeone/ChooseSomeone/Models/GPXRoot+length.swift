//
//  GPXRoot+length.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//

import Foundation
import MapKit
import CoreGPX

extension GPXRoot {
    
    public var tracksLength: CLLocationDistance {
        var tLength: CLLocationDistance = 0.0
        for track in self.tracks {
            tLength += track.length
        }
        return tLength
    }
}
