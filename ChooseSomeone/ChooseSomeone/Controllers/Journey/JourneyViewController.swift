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
import Firebase
import Lottie

class JourneyViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let userId = UserManager.shared.userInfo.uid
    
    var isDisplayingLocationServicesDenied: Bool = false
    
    var followUser: Bool = true {
        
        didSet {
            
            if followUser {
                
                let image = UIImage(systemName: "location.fill",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
                
                followUserButton.setImage(image, for: .normal)
                
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                
                let image = UIImage(systemName: "location",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
                
                followUserButton.setImage(image, for: .normal)
            }
        }
    }
    
    let locationManager: CLLocationManager = {
        
        let manager = CLLocationManager()
        
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.distanceFilter = 2 // meters
        
        manager.headingFilter = 3 // degrees
        
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
    
    lazy var waveLottieView: AnimationView = {
        let view = AnimationView(name: "wave")
        view.loopMode = .loop
        view.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
        view.center = buttonStackView.center
        view.contentMode = .scaleAspectFit
        view.play()
        self.view.addSubview(view)
        self.view.bringSubviewToFront(buttonStackView)
        return view
    }()

    var lastLocation: CLLocation?
    
    lazy var buttonStackView: UIStackView = {
        
        let view = UIStackView(arrangedSubviews: [followUserButton, trackerButton, saveButton, resetButton])
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .bottom
        return view
    }()
    
    let timeLabel = UILabel()
    
    let totalTrackedDistanceLabel = DistanceLabel()
    
    let currentSegmentDistanceLabel = DistanceLabel()
    
    let coordsLabel = UILabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        stopWatch.delegate = self
        
        RecordManager.shared.detectDeviceAndUpload()
        
        map.delegate = mapViewDelegate
        
        map.showsUserLocation = true
        
        locationManager.delegate = self
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        let center = locationManager.location?.coordinate ??
        CLLocationCoordinate2D(latitude: 25.042393, longitude: 121.56496)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)

        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        setUpButtons()
        
        setUpLabels()
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewWillLayoutSubviews() {

        let trakerRadius = trackerButton.frame.height / 2
        
        let otherRadius = saveButton.frame.height / 2

        followUserButton.roundCorners(cornerRadius: otherRadius)

        trackerButton.roundCorners(cornerRadius: trakerRadius)

        saveButton.roundCorners(cornerRadius: otherRadius)

        resetButton.roundCorners(cornerRadius: otherRadius)
        
        trackerButton.applyButtonGradient(
            colors: [UIColor.hexStringToUIColor(hex: "#C4E0F8"),
                     .B1],
            locations: [0.0, 1.0],
            direction: .leftSkewed)
        
        saveButton.applyButtonGradient(
            colors: [UIColor.hexStringToUIColor(hex: "#F3F9A7"),
                     UIColor.hexStringToUIColor(hex: "#45B649")],
            locations: [0.0, 1.0],
            direction: .leftSkewed)
        
        resetButton.applyButtonGradient(
            colors: [UIColor.hexStringToUIColor(hex: "#e1eec3"),
                     UIColor.hexStringToUIColor(hex: "#f05053")],
            locations: [0.0, 1.0],
            direction: .leftSkewed)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        updatePolylineColor()
    }
    
    func updatePolylineColor() {
        
        for overlay in map.overlays where overlay is MKPolyline {
            
            map.removeOverlay(overlay)
            
            map.addOverlay(overlay)
        }
    }
    
    func setUpButtons() {
        
        view.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStackView.widthAnchor.constraint(equalToConstant: UIScreen.width * 0.85),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            
            buttonStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        followUserButton.backgroundColor = .clear
        let image = UIImage(systemName: "location.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .medium))
        followUserButton.setImage(image, for: UIControl.State())
        
        trackerButton.translatesAutoresizingMaskIntoConstraints = false
        trackerButton.setTitle("Start", for: .normal)
        trackerButton.titleLabel?.font = UIFont.regular(size: 18)
        trackerButton.titleLabel?.textAlignment = .center
        
        saveButton.setTitle("Save", for: .normal)

        saveButton.titleLabel?.font = UIFont.regular(size: 16)
        saveButton.titleLabel?.textAlignment = .center
        saveButton.alpha = 0.5
       
        resetButton.setTitle("Reset", for: .normal)
        resetButton.titleLabel?.font = UIFont.regular(size: 16)
        resetButton.titleLabel?.textAlignment = .center
        resetButton.alpha = 0.5
        
        let button = UIButton()
       
        buttonStackView.addArrangedSubview(followUserButton)
        buttonStackView.addArrangedSubview(button)
        buttonStackView.addArrangedSubview(trackerButton)
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(resetButton)
        
        NSLayoutConstraint.activate([
            
            followUserButton.heightAnchor.constraint(equalToConstant: 50),
            
            followUserButton.widthAnchor.constraint(equalToConstant: 50),
            
            button.heightAnchor.constraint(equalToConstant: 50),
            
            button.widthAnchor.constraint(equalToConstant: 50),
            
            trackerButton.heightAnchor.constraint(equalToConstant: 80),
            
            trackerButton.widthAnchor.constraint(equalToConstant: 80),
            
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            
            resetButton.heightAnchor.constraint(equalToConstant: 50),
            
            resetButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        trackerButton.addTarget(self, action: #selector(trackerButtonTapped), for: .touchUpInside)
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        followUserButton.addTarget(self, action: #selector(followButtonTroggler), for: .touchUpInside)
    }
    
    func setUpLabels() {
        
        map.addSubview(coordsLabel)
        coordsLabel.numberOfLines = 0
        coordsLabel.frame = CGRect(x: 10, y: 30, width: 200, height: 100)
        coordsLabel.textAlignment = .left
        coordsLabel.font = UIFont.regular(size: 14)
        coordsLabel.textColor = UIColor.black
        
        map.addSubview(timeLabel)
        timeLabel.frame = CGRect(x: UIScreen.width - 100, y: 40, width: 80, height: 30)
        timeLabel.textAlignment = .right
        timeLabel.font = UIFont.regular(size: 26)
        timeLabel.textColor = UIColor.black
        timeLabel.text = "00:00"
        
        map.addSubview(totalTrackedDistanceLabel)
        totalTrackedDistanceLabel.frame = CGRect(x: UIScreen.width - 100, y: 70, width: 80, height: 30)
        totalTrackedDistanceLabel.textAlignment = .right
        totalTrackedDistanceLabel.font = UIFont.regular(size: 26)
        totalTrackedDistanceLabel.textColor = UIColor.black
        totalTrackedDistanceLabel.distance = 0.00
        
        map.addSubview(currentSegmentDistanceLabel)
        currentSegmentDistanceLabel.frame = CGRect(x: UIScreen.width - 100, y: 100, width: 80, height: 30)
        currentSegmentDistanceLabel.textAlignment = .right
        currentSegmentDistanceLabel.font = UIFont.regular(size: 18)
        currentSegmentDistanceLabel.textColor = UIColor.black
        currentSegmentDistanceLabel.distance = 0.00
        
    }
    
    enum GpxTrackingStatus {
        
        case notStarted
        
        case tracking
        
        case paused
    }
    
    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.notStarted {
        
        didSet {
            
            switch gpxTrackingStatus {
                
            case .notStarted:
                
                trackerButton.setTitle("Start",
                                       for: .normal)
             
                stopWatch.reset()
                waveLottieView.isHidden = true
                
                timeLabel.text = stopWatch.elapsedTimeString
                
                map.clearMap()
                
                totalTrackedDistanceLabel.distance = (map.session.totalTrackedDistance)
                
                currentSegmentDistanceLabel.distance = (map.session.currentSegmentDistance)
                
            case .tracking:
                
                trackerButton.setTitle("Pause", for: .normal)
                
                self.stopWatch.start()
                waveLottieView.isHidden = false
                waveLottieView.play()
                
            case .paused:
                self.trackerButton.setTitle("Resume", for: .normal)
                
                self.stopWatch.stop()
                waveLottieView.isHidden = true
                
                self.map.startNewTrackSegment()
            }
        }
    }
    
    @objc func trackerButtonTapped() {
        
        switch gpxTrackingStatus {
            
        case .notStarted:
            
            UIView.animate(withDuration: 0.3) {
                self.saveButton.alpha = 1.0
                self.resetButton.alpha = 1.0
            }

            gpxTrackingStatus = .tracking
            
        case .tracking:
            
            gpxTrackingStatus = .paused
            
        case .paused:
            
            gpxTrackingStatus = .tracking

        }
    }
    
    @objc func saveButtonTapped(withReset: Bool = false) {
        
        if gpxTrackingStatus == .notStarted {
            return
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let time = dateFormatter.string(from: date as Date)
        let defaultFileName = "\(time)"
        
        let alertController = UIAlertController(title: "儲存至裝置",
                                                message: "請輸入檔案名稱",
                                                preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.clearButtonMode = .always
            textField.text =  defaultFileName
        })
        
        let saveAction = UIAlertAction(title: "儲存",
                                       style: .default) { _ in
            
            let gpxString = self.map.exportToGPXString()
            
            let fileName = alertController.textFields?[0].text
            
            if let fileName = fileName {
                GPXFileManager.save(filename: fileName, gpxContents: gpxString)
            }
            
            if withReset {
                self.gpxTrackingStatus = .notStarted
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    @objc func resetButtonTapped() {
        
        let sheet = UIAlertController()
        
        let cancelOption = UIAlertAction(title: "取消", style: .cancel) { _ in
        }
        
        let deleteOption = UIAlertAction(title: "重置", style: .destructive) { _ in
            self.gpxTrackingStatus = .notStarted
            
            UIView.animate(withDuration: 0.3) {
                self.saveButton.alpha = 0.5
                self.resetButton.alpha = 0.5
            }
        }
        
        sheet.addAction(cancelOption)
        sheet.addAction(deleteOption)
        
        self.present(sheet, animated: true) {
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
            return
        }
        let alertController = UIAlertController(title: "Access to location denied",
                                                message: "Allow location",
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings",
                                           style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel",
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
        //        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(hAcc) vAcc: \(vAcc) floor: \(newLocation.floor?.description ?? "''")")
        //Update coordsLabel
        let latFormat = String(format: "%.5f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.5f", newLocation.coordinate.longitude)
        let altitude = newLocation.altitude.toAltitude()
        var text = "latitude: \(latFormat) \rlontitude: \(lonFormat) \raltitude: \(altitude)"
        
        coordsLabel.text = text
        
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {

            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            
            totalTrackedDistanceLabel.distance = map.session.totalTrackedDistance
            
            currentSegmentDistanceLabel.distance = map.session.currentSegmentDistance
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        map.heading = newHeading
        
        map.updateHeading()
    }
}
