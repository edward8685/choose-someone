//
//  JourneyViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/26.
//

import UIKit
import MapKit
import CoreGPX
import CoreLocation

class JourneyViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var trackerButton: UIButton!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var followUserButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var totalTrackedDistanceLabel: DistanceLabel!
    
    @IBOutlet weak var coordsLabel: UILabel!
    /// Name of the last file that was saved (without extension)
    var lastGpxFilename: String = ""
    
    var useImperial = false
    
    var isDisplayingLocationServicesDenied: Bool = false
    
    var followUser: Bool = true {
        didSet {
            if followUser {
                print("followUser=true")
                followUserButton.setTitle("Following", for: UIControl.State())
//                followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControl.State())
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                followUserButton.setTitle("Follow", for: UIControl.State())
                print("followUser=false")
                //               followUserButton.setImage(UIImage(named: "follow_user"), for: UIControl.State())
            }
        }
    }
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.headingFilter = 3 //degrees (1 is default)
        manager.pausesLocationUpdatesAutomatically = false
//        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    let mapViewDelegate = MapViewDelegate()
    
    @IBOutlet weak var map: GPXMapView!{
        didSet {
            map.delegate = mapViewDelegate
        }
    }
    
    var stopWatch = StopWatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatch.delegate = self
        
        // Map autorotate configuration
        map.autoresizesSubviews = true
        map.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.autoresizesSubviews = true
        self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // Show the current user's location
        map.showsUserLocation = true
        
        locationManager.delegate = self
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        // Request for a user's authorization for location services
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            map.showsUserLocation = true
        }
        
        
        setUpTrackerButton()
    }
    /// Will update polyline color when invoked
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updatePolylineColor()
    }
    
    /// Updates polyline color
    func updatePolylineColor() {
        for overlay in map.overlays where overlay is MKPolyline {
                map.removeOverlay(overlay)
                map.addOverlay(overlay)
        }
    }
    
    func setUpTrackerButton() {
        
        trackerButton.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        followUserButton.addTarget(self, action: #selector(followButtonTroggler), for: .touchUpInside)
    }
    
    /// Defines the different statuses regarding tracking current user location.
    enum GpxTrackingStatus {
        
        /// Tracking has not started or map was reset
        case notStarted
        
        /// Tracking is ongoing
        case tracking
        
        /// Tracking is paused (the map has some contents)
        case paused
    }
    
    /// Tells what is the current status of the Map Instance.
    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.notStarted {
        didSet {
            print("gpxTrackingStatus changed to \(gpxTrackingStatus)")
            switch gpxTrackingStatus {
            case .notStarted:
                print("switched to non started")
                // set Tracker button to allow Start
                trackerButton.setTitle(NSLocalizedString("START_TRACKING", comment: "no comment"), for: UIControl.State())
                trackerButton.alpha = 1.0
                //save & reset button to transparent.
                saveButton.alpha = 1.0
                resetButton.alpha = 1.0
                //reset clock
                stopWatch.reset()
                                timeLabel.text = stopWatch.elapsedTimeString
                
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                //                map.coreDataHelper.clearAll()
                //                map.coreDataHelper.coreDataDeleteAll(of: CDRoot.self)//deleteCDRootFromCoreData()
                
                                totalTrackedDistanceLabel.distance = (map.session.totalTrackedDistance)
                //                currentSegmentDistanceLabel.distance = (map.session.currentSegmentDistance)
                
            case .tracking:
                print("switched to tracking mode")
                // set tracerkButton to allow Pause
                trackerButton.setTitle(NSLocalizedString("PAUSE", comment: "no comment"), for: UIControl.State())
                trackerButton.alpha = 0.5
                //activate save & reset buttons
                saveButton.alpha = 0.5
                resetButton.alpha = 0.5
                // start clock
                self.stopWatch.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle(NSLocalizedString("RESUME", comment: "no comment"), for: UIControl.State())
                self.trackerButton.alpha = 0.5
                // activate save & reset (just in case switched from .NotStarted)
                saveButton.alpha = 0.5
                resetButton.alpha = 0.5
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                //                self.map.startNewTrackSegment()
            }
        }
    }
    var lastLocation: CLLocation?
    
    @objc func trackerButtonTapped() {
        print("startGpxTracking::")
        switch gpxTrackingStatus {
        case .notStarted:
            gpxTrackingStatus = .tracking
        case .tracking:
            gpxTrackingStatus = .paused
        case .paused:
            gpxTrackingStatus = .tracking
        }
    }
    
    @objc func saveButtonTapped(withReset: Bool = false) {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) {
            return
        }

        //
        //        alertController.addTextField(configurationHandler: { (textField) in
        //            textField.clearButtonMode = .always
        
        //    })
        
        let saveAction = UIAlertAction(title: NSLocalizedString("SAVE", comment: "no comment"), style: .default) { _ in
            //export to a file
            let gpxString = self.map.exportToGPXString()
            //            self.lastGpxFilename = filename!
            //            self.map.coreDataHelper.coreDataDeleteAll(of: CDRoot.self)//deleteCDRootFromCoreData()
            //            self.map.coreDataHelper.clearAllExceptWaypoints()
            //            self.map.coreDataHelper.add(toCoreData: filename!, willContinueAfterSave: true)
            if withReset {
                self.gpxTrackingStatus = .notStarted
            }
        }
//        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"), style: .cancel) { _ in }
//
//        alertController.addAction(saveAction)
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true)
        
    }
    
    @objc func resetButtonTapped() {
        
        let sheet = UIAlertController(title: nil, message: NSLocalizedString("SELECT_OPTION", comment: "no comment"), preferredStyle: .actionSheet)
        
        let cancelOption = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"), style: .cancel) { _ in
        }
        
        let saveAndStartOption = UIAlertAction(title: NSLocalizedString("SAVE_START_NEW", comment: "no comment"), style: .default) { _ in
            //Save
            self.saveButtonTapped(withReset: true)
        }
        
        let deleteOption = UIAlertAction(title: NSLocalizedString("RESET", comment: "no comment"), style: .destructive) { _ in
            self.gpxTrackingStatus = .notStarted
        }
        
        sheet.addAction(cancelOption)
        sheet.addAction(saveAndStartOption)
        sheet.addAction(deleteOption)
        
        self.present(sheet, animated: true) {
            print("Loaded actionSheet")
        }
    }
    
    @objc func followButtonTroggler() {
        self.followUser = !self.followUser
    }
    
    @objc func stopFollowingUser(_ gesture: UIPanGestureRecognizer) {
        if self.followUser {
            self.followUser = false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func checkLocationServicesStatus() {
        if !CLLocationManager.locationServicesEnabled() {
//            displayLocationServicesDisabledAlert()
            return
        }

        if !([.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())) {
            displayLocationServicesDeniedAlert()
            return
        }
    }
    
    
    func displayLocationServicesDeniedAlert() {
        if isDisplayingLocationServicesDenied {
            return // display it only once.
        }
        let alertController = UIAlertController(title: NSLocalizedString("ACCESS_TO_LOCATION_DENIED", comment: "no comment"),
                                                message: NSLocalizedString("ALLOW_LOCATION", comment: "no comment"),
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "no comment"),
                                           style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL",
                                                                  comment: "no comment"),
                                         style: .cancel) { _ in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        isDisplayingLocationServicesDenied = false
    }

}
// MARK: - MKMapViewDelegate methods
extension JourneyViewController: MKMapViewDelegate {
    
}
extension JourneyViewController: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel.text = elapsedTimeString
    }
}

// MARK: CLLocationManagerDelegate

extension JourneyViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        let locationError = error as? CLError
        switch locationError?.code {
        case CLError.locationUnknown:
            print("Location Unknown")
        case CLError.denied:
            print("Access to location services denied. Display message")
            checkLocationServicesStatus()
        case CLError.headingFailure:
            print("Heading failure")
        default:
            print("Default error")
        }
  
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.first!
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        let altitude = newLocation.altitude.toAltitude(useImperial: useImperial)
        coordsLabel.text = String(format: NSLocalizedString("COORDS_LABEL", comment: "no comment"), latFormat, lonFormat, altitude)
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.distance = map.session.totalTrackedDistance
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("ViewController::didUpdateHeading true: \(newHeading.trueHeading) magnetic: \(newHeading.magneticHeading)")
        print("mkMapcamera heading=\(map.camera.heading)")
        map.heading = newHeading // updates heading variable
        map.updateHeading() // updates heading view's rotation
    }
}

extension Notification.Name {
    static let loadRecoveredFile = Notification.Name("loadRecoveredFile")
    static let updateAppearance = Notification.Name("updateAppearance")
    // swiftlint:disable file_length
}

// swiftlint:enable line_length
