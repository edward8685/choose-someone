//
//  GPXMapView.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreGPX
import CoreData

class GPXMapView: MKMapView {
    
    /// Current session of GPX location logging. Handles all background tasks and recording.
    let session = GPXSession()

    /// The line being displayed on the map that corresponds to the current segment.
    var currentSegmentOverlay: MKPolyline
    
    ///
    var extent: GPXExtentCoordinates = GPXExtentCoordinates() //extent of the GPX points and tracks

    var compassRect: CGRect
    
    /// Selected tile server.
    /// - SeeAlso: GPXTileServer
    
    /// Overlay that holds map tiles
    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    
    ///
//    let coreDataHelper = CoreDataHelper()
    
    /// Heading of device
    var heading: CLHeading?
    
    /// Offset to heading due to user's map rotation
    var headingOffset: CGFloat?
    
    /// Gesture for heading arrow to be updated in realtime during user's map interactions
    var rotationGesture = UIRotationGestureRecognizer()
    
    ///
    /// Initializes the map with an empty currentSegmentOverlay.
    ///
    required init?(coder aDecoder: NSCoder) {
        var tmpCoords: [CLLocationCoordinate2D] = [] //init with empty
        currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        compassRect = CGRect.init(x: 0, y: 0, width: 36, height: 36)
        super.init(coder: aDecoder)
        
        // Rotation Gesture handling (for the map rotation's influence towards heading pointing arrow)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureHandling(_:)))
        
        addGestureRecognizer(rotationGesture)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
    }
    
    ///
    /// Override default implementation to set the compass that appears in the map in a better position.
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        // set compass position by setting its frame
        if let compassView = subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!) }).first {
            if compassRect.origin.x != 0 {
                compassView.frame = compassRect
            }
        }
        
//        updateMapInformation(tileServer)
    }
    
    /// Handles rotation detected from user, for heading arrow to update.
    @objc func rotationGestureHandling(_ gesture: UIRotationGestureRecognizer) {
        headingOffset = gesture.rotation

        
        if gesture.state == .ended {
            headingOffset = nil
        }
    }
    
    
    /// Adds a new point to current segment.
    /// - Parameters:
    ///    - location: Typically a location provided by CLLocation
    ///
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
    let pt = GPXTrackPoint(location: location)
//        coreDataHelper.add(toCoreData: pt, withTrackSegmentID: session.trackSegments.count)
        session.addPointToCurrentTrackSegmentAtLocation(location)
        //redrawCurrent track segment overlay
        //First remove last overlay, then re-add the overlay updated with the new point
        removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = session.currentSegment.overlay
        addOverlay(currentSegmentOverlay)
        extent.extendAreaToIncludeLocation(location.coordinate)
    }
    
    ///
    /// If current segmet has points, it appends currentSegment to trackSegments and
    /// initializes currentSegment to a new one.
    ///
    func startNewTrackSegment() {
        if session.currentSegment.trackpoints.count > 0 {
            session.startNewTrackSegment()
            currentSegmentOverlay = MKPolyline()
        }
    }
    
    ///
    /// Finishes current segment.
    ///
    func finishCurrentSegment() {
        startNewTrackSegment() //basically, we need to append the segment to the list of segments
    }
    ///
    ///
    /// Converts current map into a GPX String
    ///
    ///
    func exportToGPXString() -> String {
        return session.exportToGPXString()
    }
   
    ///
    /// Sets the map region to display all the GPX data in the map (segments and waypoints).
    ///
    func regionToGPXExtent() {
        setRegion(extent.region, animated: true)
    }
    
    /// Imports GPX contents into the map.
    ///
    /// - Parameters:
    ///     - gpx: The result of loading a gpx file with iOS-GPX-Framework.
    ///
    func importFromGPXRoot(_ gpx: GPXRoot) {
//        clearMap()
//        addWaypoints(for: gpx)
        addTrackSegments(for: gpx)
    }


    private func addTrackSegments(for gpx: GPXRoot) {
        session.tracks = gpx.tracks
        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                addOverlay(overlay)
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
//        clearMap()
//        addWaypoints(for: gpx, fromImport: false)
        
        session.continueFromGPXRoot(gpx)
        
        // for last session's previous tracks, through resuming
        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                addOverlay(overlay)
                
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
        
        // for last session track segment
        for trackSegment in session.trackSegments {
            
            let overlay = trackSegment.overlay
            addOverlay(overlay)
            
            let segmentTrackpoints = trackSegment.trackpoints
            //add point to map extent
            for waypoint in segmentTrackpoints {
                extent.extendAreaToIncludeLocation(waypoint.coordinate)
            }
        }
        
    }
}
