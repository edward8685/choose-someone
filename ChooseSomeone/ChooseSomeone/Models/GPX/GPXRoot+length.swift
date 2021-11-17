//
//  GPXRoot+length.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/27.
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
