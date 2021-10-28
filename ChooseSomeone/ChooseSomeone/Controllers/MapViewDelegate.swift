//
//  Localized by nitricware on 19/08/19.
//

import MapKit
import CoreGPX

/// Handles all delegate functions of the GPX Mapview
///
class MapViewDelegate: NSObject, MKMapViewDelegate, UIAlertViewDelegate {

    /// The Waypoint is being edited (if there is any)
    var waypointBeingEdited: GPXWaypoint = GPXWaypoint()
    
    // Displays the line for each segment
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKPolyline {
            let pr = MKPolylineRenderer(overlay: overlay)

            pr.alpha = 0.8
            pr.strokeColor = UIColor.blue

            pr.lineWidth = 3
            return pr
        }
        return MKOverlayRenderer()
    }
}
