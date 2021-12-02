//
//  MapViewDelegate.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/26.
//

import MapKit
import CoreGPX

class MapViewDelegate: NSObject, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            
            polyLineRenderer.alpha = 0.8
            
            polyLineRenderer.strokeColor = .B1
            
            polyLineRenderer.lineWidth = 2
            
            return polyLineRenderer
        }
        
        return MKOverlayRenderer()
    }
}
