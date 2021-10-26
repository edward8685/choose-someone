//
//  JourneyViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/26.
//

import UIKit
import MapKit

class JourneyViewController: UIViewController {
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.headingFilter = 3 //degrees (1 is default)
        manager.pausesLocationUpdatesAutomatically = false
        return manager
    }()
    
    @IBOutlet weak var mapView: MKMapView!{
        didSet {
            mapView.delegate = self
        }
    }
    var currentPlacemark: CLPlacemark?
    
    var currentRoute: MKRoute?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Show the current user's location
        mapView.showsUserLocation = true
        
        // Hide the segmented control by default and register the event
        
        // Request for a user's authorization for location services
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
}
}
// MARK: - MKMapViewDelegate methods
extension JourneyViewController: MKMapViewDelegate {
    
}
