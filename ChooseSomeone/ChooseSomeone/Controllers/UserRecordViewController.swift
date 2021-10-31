//
//  UserRecordViewController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/31.
//

import UIKit
import MapKit
import CoreGPX
import CoreLocation
import Firebase

class UserRecordViewController: UIViewController {
    
    @IBOutlet weak var map: GPXMapView!
    
    let mapViewDelegate = MapViewDelegate()
    
    var record = Record()
    
    let timeLabel = UILabel()
    
    let totalTrackedDistanceLabel = DistanceLabel()
    
    let coordsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = mapViewDelegate

//        let center = locationManager.location?.coordinate ??
//        CLLocationCoordinate2D(latitude: 25.042393, longitude: 121.56496)
//        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//        let region = MKCoordinateRegion(center: center, span: span)
//        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        setUpLabels()
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
    }
    
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot) {
 
        self.map.importFromGPXRoot(gpxRoot)
        
        self.map.regionToGPXExtent()
        
        self.totalTrackedDistanceLabel.distance = self.map.session.totalTrackedDistance
    }
    
    func actionLoadFileAtIndex(_ rowIndex: Int) {
            
//            guard let gpxFileInfo: GPXFileInfo = (self.fileList.object(at: rowIndex) as? GPXFileInfo) else {
//
//                return
//            }
//
//            print("Load gpx File: \(gpxFileInfo.fileName)")
//            guard let gpx = GPXParser(withURL: gpxFileInfo.fileURL)?.parsedData() else {
//                print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to parse GPX file")
//                self.displayLoadingFileAlert(false)
//                return
//            }
//
//            DispatchQueue.main.sync {
//                    self.delegate?.didLoadGPXFileWithName(gpxFileInfo.fileName, gpxRoot: gpx)
//            }
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
}
