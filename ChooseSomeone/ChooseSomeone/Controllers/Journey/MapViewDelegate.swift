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
            
            let pr = MKPolylineRenderer(overlay: overlay)

            pr.alpha = 0.8
            
            pr.strokeColor = .B1
            
            pr.lineWidth = 2
            
            return pr
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard let map = mapView as? GPXMapView else { return }
    }
}
