//
//  GPXTrack+length.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/27.
//

import Foundation
import MapKit
import CoreGPX

extension GPXTrack {
    
    public var length: CLLocationDistance {
        
        var trackLength: CLLocationDistance = 0.0
        
        for segment in tracksegments {
            
            trackLength += segment.length()
            
        }
        
        return trackLength
    }    
}
