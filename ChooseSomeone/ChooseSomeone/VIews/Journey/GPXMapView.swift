//
//  GPXMapView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreGPX

class GPXMapView: MKMapView {
    
    let session = GPXSession()

    var currentSegmentOverlay: MKPolyline
    
    var extent: GPXExtentCoordinates = GPXExtentCoordinates()
    
    var headingImageView: UIImageView?

    var heading: CLHeading?

    var headingOffset: CGFloat?
    
    var rotationGesture = UIRotationGestureRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        
        var tmpCoords: [CLLocationCoordinate2D] = []
        
        currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        
        super.init(coder: aDecoder)

        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureHandling(_:)))
        
        addGestureRecognizer(rotationGesture)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let compassView = subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!) }).first {

            compassView.frame.origin = CGPoint(x: UIScreen.width / 2 - 18, y: 30)
        }
    }
    
    @objc func rotationGestureHandling(_ gesture: UIRotationGestureRecognizer) {
        
        headingOffset = gesture.rotation

        if gesture.state == .ended {
            headingOffset = nil
        }
    }
    
    func updateHeading() {
        guard let heading = heading else { return }
        
        headingImageView?.isHidden = false
        let rotation = CGFloat((heading.trueHeading - camera.heading)/180 * Double.pi)
        
        var newRotation = rotation
        
        if let headingOffset = headingOffset {
            newRotation = rotation + headingOffset
        }
 
        UIView.animate(withDuration: 0.15) {
            self.headingImageView?.transform = CGAffineTransform(rotationAngle: newRotation)
        }
    }

    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        session.addPointToCurrentTrackSegmentAtLocation(location)

        removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = session.currentSegment.overlay
        addOverlay(currentSegmentOverlay)
        extent.extendAreaToIncludeLocation(location.coordinate)
    }

    func startNewTrackSegment() {
        if session.currentSegment.points.count > 0 {
            session.startNewTrackSegment()
            currentSegmentOverlay = MKPolyline()
        }
    }
    
    func finishCurrentSegment() {
        startNewTrackSegment()
    }
    
    func clearMap() {
        session.reset()
        removeOverlays(overlays)
        removeAnnotations(annotations)
        extent = GPXExtentCoordinates()
    }

    func exportToGPXString() -> String {
        return session.exportToGPXString()
    }
   
    func regionToGPXExtent() {
        setRegion(extent.region, animated: true)
    }
    
    func importFromGPXRoot(_ gpx: GPXRoot) {
        clearMap()
        addTrackSegments(for: gpx)
    }

    private func addTrackSegments(for gpx: GPXRoot) {
        session.tracks = gpx.tracks
        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length

            for segment in oneTrack.segments {
                let overlay = segment.overlay
                addOverlay(overlay)
                let segmentTrackpoints = segment.points
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
}
