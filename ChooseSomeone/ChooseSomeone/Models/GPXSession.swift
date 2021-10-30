//
//  GPXSession.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/27.
//

import Foundation
import CoreGPX
import CoreLocation

let kGPXCreatorString = "Open GPX Tracker for iOS"

class GPXSession {
    
    var waypoints: [GPXWaypoint] = []
    
    var tracks: [GPXTrack] = []
    
    var trackSegments: [GPXTrackSegment] = []
    
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    
    var totalTrackedDistance = 0.00
    
    var currentTrackDistance = 0.00
    
    var currentSegmentDistance = 0.00
    
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.add(trackpoint: pt)
        
        if self.currentSegment.trackpoints.count >= 2 {
            let prevPt = self.currentSegment.trackpoints[self.currentSegment.trackpoints.count-2]
            
            guard let latitude = prevPt.latitude, let longitude = prevPt.longitude else { return }
            let prevPtLoc = CLLocation(latitude: latitude, longitude: longitude)
            
            let distance = prevPtLoc.distance(from: location)
            self.currentTrackDistance += distance
            self.totalTrackedDistance += distance
            self.currentSegmentDistance += distance
        }
    }
    
    func startNewTrackSegment() {
        if self.currentSegment.trackpoints.count > 0 {
            self.trackSegments.append(self.currentSegment)
            self.currentSegment = GPXTrackSegment()
            self.currentSegmentDistance = 0.00
        }
    }
    
    func reset() {
        self.trackSegments = []
        self.tracks = []
        self.currentSegment = GPXTrackSegment()
        
        self.totalTrackedDistance = 0.00
        self.currentTrackDistance = 0.00
        self.currentSegmentDistance = 0.00
        
    }
    
    func exportToGPXString() -> String {
        print("Exporting session data into GPX String")
        //Create the gpx structure
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.add(waypoints: self.waypoints)
        let track = GPXTrack()
        track.add(trackSegments: self.trackSegments)
        //add current segment if not empty
        if self.currentSegment.trackpoints.count > 0 {
            track.add(trackSegment: self.currentSegment)
        }
        //add existing tracks
        gpx.add(tracks: self.tracks)
        //add current track
        gpx.add(track: track)
        return gpx.gpx()
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
        
        let lastTrack = gpx.tracks.last ?? GPXTrack()
        totalTrackedDistance += lastTrack.length
        
        self.tracks = gpx.tracks
        self.trackSegments = lastTrack.tracksegments
        
        self.tracks.removeLast()
        
    }
    
}
