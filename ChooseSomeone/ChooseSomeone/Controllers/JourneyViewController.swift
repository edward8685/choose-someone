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
    
    private var userId = "1357988"
    
    var lastGpxFilename: String = ""
    
    var isDisplayingLocationServicesDenied: Bool = false
    
    var followUser: Bool = true {
        didSet {
            if followUser {
                let image = UIImage(systemName: "location.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
                followUserButton.setImage(image, for: UIControl.State())
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                let image = UIImage(systemName: "location",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
                followUserButton.setImage(image, for: UIControl.State())
            }
        }
    }
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        
//        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.headingFilter = 3 //degrees
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    let mapViewDelegate = MapViewDelegate()
    
    @IBOutlet weak var map: GPXMapView!
    
    var stopWatch = StopWatch()
    
    var trackerButton = UIButton()
    
    var resetButton = UIButton()
    
    var saveButton = UIButton()
    
    var followUserButton = UIButton()
    
    var lastLocation: CLLocation?
    
    lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [followUserButton, trackerButton, saveButton, resetButton])
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 10
        view.distribution = .fillEqually
        
        return view
    }()
    
    let timeLabel = UILabel()
    
    let totalTrackedDistanceLabel = DistanceLabel()
    
    let currentSegmentDistanceLabel = DistanceLabel()
    
    let coordsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatch.delegate = self
        
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        
        locationManager.delegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 25.042393, longitude: 121.56496)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        setUpButtons()
        setUpLabels()
        
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
    
    func setUpButtons() {
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIScreen.height * 0.13),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: UIScreen.height * 0.06)
            
        ])
        
        followUserButton.layer.cornerRadius = 24
        followUserButton.backgroundColor = .clear
        let image = UIImage(systemName: "location.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
        followUserButton.setImage(image, for: UIControl.State())
        
        trackerButton.layer.cornerRadius = 20
        trackerButton.setTitle("Tracking", for: UIControl.State())
        trackerButton.backgroundColor = UIColor.hexStringToUIColor(hex: "7CCA5F")
        trackerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .center
        
        saveButton.layer.cornerRadius = 20
        saveButton.setTitle("Save", for: UIControl.State())
        saveButton.backgroundColor = UIColor.hexStringToUIColor(hex: "007AFF")
        saveButton.titleLabel?.textAlignment = .center
        
        resetButton.layer.cornerRadius = 20
        resetButton.setTitle("Reset", for: UIControl.State())
        resetButton.backgroundColor = UIColor.hexStringToUIColor(hex: "E31C00")
        resetButton.titleLabel?.textAlignment = .center
        
        buttonStackView.addArrangedSubview(followUserButton)
        buttonStackView.addArrangedSubview(trackerButton)
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(resetButton)
        
        trackerButton.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        followUserButton.addTarget(self, action: #selector(followButtonTroggler), for: .touchUpInside)
    }
    
    func setUpLabels() {
        
        map.addSubview(coordsLabel)
        coordsLabel.numberOfLines = 0
        coordsLabel.frame = CGRect(x: 15, y: 30, width: 200, height: 100)
        coordsLabel.textAlignment = .left
        coordsLabel.font = .systemFont(ofSize: 14)
        coordsLabel.textColor = UIColor.black
        
        map.addSubview(timeLabel)
        timeLabel.frame = CGRect(x: UIScreen.width - 100, y: 40, width: 80, height: 30)
        timeLabel.textAlignment = .right
        timeLabel.font = .systemFont(ofSize: 26)
        timeLabel.textColor = UIColor.black
        timeLabel.text = "00:00"
        
        map.addSubview(totalTrackedDistanceLabel)
        totalTrackedDistanceLabel.frame = CGRect(x: UIScreen.width - 100, y: 70, width: 80, height: 30)
        totalTrackedDistanceLabel.textAlignment = .right
        totalTrackedDistanceLabel.font = .systemFont(ofSize: 26)
        totalTrackedDistanceLabel.textColor = UIColor.black
        totalTrackedDistanceLabel.distance = 0.00
        
        map.addSubview(currentSegmentDistanceLabel)
        currentSegmentDistanceLabel.frame = CGRect(x: UIScreen.width - 100, y: 100, width: 80, height: 30)
        currentSegmentDistanceLabel.textAlignment = .right
        currentSegmentDistanceLabel.font = .systemFont(ofSize: 18)
        currentSegmentDistanceLabel.textColor = UIColor.black
        currentSegmentDistanceLabel.distance = 0.00
        
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
                trackerButton.setTitle("Tracking",
                                       for: UIControl.State())
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
                map.clearMap()
                totalTrackedDistanceLabel.distance = (map.session.totalTrackedDistance)
                currentSegmentDistanceLabel.distance = (map.session.currentSegmentDistance)
                
            case .tracking:
                print("switched to tracking mode")
                // set tracerkButton to allow Pause
                trackerButton.setTitle("Pause", for: UIControl.State())
                // start clock
                self.stopWatch.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle("Resume", for: UIControl.State())
                
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }
    
    
    @objc func trackerButtonTapped() {
        
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

        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) {
            return
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let time = dateFormatter.string(from: date as Date)
        let defaultFileName = "\(time)"
        
        let alertController = UIAlertController(title: "Save Data",
                                                message: "Enter Record Name",
                                                preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.clearButtonMode = .always
            textField.text =  defaultFileName
        })

        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
            
            let gpxString = self.map.exportToGPXString()
            print(gpxString)
            
            let fileName = alertController.textFields?[0].text
            
            if let fileName = fileName {
            GPXFileManager.save(filename: fileName, gpxContents: gpxString)
            }
            
            if withReset {
                self.gpxTrackingStatus = .notStarted
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc func resetButtonTapped() {
        
        let sheet = UIAlertController()
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        
        let deleteOption = UIAlertAction(title: "Reset", style: .destructive) { _ in
            self.gpxTrackingStatus = .notStarted
        }
        
        sheet.addAction(cancelOption)
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
    
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning")
        super.didReceiveMemoryWarning()
    }
    
    func checkLocationServicesStatus() {
        if !CLLocationManager.locationServicesEnabled() {
            displayLocationServicesDisabledAlert()
            return
        }
        
        if !([.authorizedAlways, .authorizedWhenInUse]
                .contains(CLLocationManager.authorizationStatus())) {
            displayLocationServicesDeniedAlert()
            return
        }
    }
    
    func displayLocationServicesDisabledAlert() {
        
        let alertController = UIAlertController(title: "Disabled", message: "Enable", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    
    func displayLocationServicesDeniedAlert() {
        if isDisplayingLocationServicesDenied {
            return // display it only once.
        }
        let alertController = UIAlertController(title: "ACCESS_TO_LOCATION_DENIED",
                                                message: "ALLOW_LOCATION",
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "SETTINGS",
                                           style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "CANCEL",
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
        let hAcc = newLocation.horizontalAccuracy
        let vAcc = newLocation.verticalAccuracy
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(hAcc) vAcc: \(vAcc) floor: \(newLocation.floor?.description ?? "''")")
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        let altitude = newLocation.altitude.toAltitude()
        var text = "latitude:\(latFormat) \rlongtitude: \(lonFormat) \raltitude:\(altitude)"
        coordsLabel.text = text
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.distance = map.session.totalTrackedDistance
            currentSegmentDistanceLabel.distance = map.session.currentSegmentDistance
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("ViewController::didUpdateHeading true: \(newHeading.trueHeading) magnetic: \(newHeading.magneticHeading)")
        print("mkMapcamera heading=\(map.camera.heading)")
        map.heading = newHeading // updates heading variable
        map.updateHeading()
    }
}

extension Notification.Name {
    static let loadRecoveredFile = Notification.Name("loadRecoveredFile")
    static let updateAppearance = Notification.Name("updateAppearance")
}

