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
import Charts

class UserRecordViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var map: GPXMapView!
    
    @IBOutlet weak var recordInfoView: RecordInfoView!
    
    @IBOutlet weak var chartView: LineChartView! {
        didSet {
            chartView.delegate = self
        }
    }
    
    private let mapViewDelegate = MapViewDelegate()
    
    var record = Record()
    
    var trackInfo = TrackInfo()
    
    lazy var elevation: [Double] = []
    
    lazy var trackTime: [Double] = []
    
    lazy var distanceFromOrigin: [Double] = []
    
    private let timeLabel = UILabel()
    
    private let totalTrackedDistanceLabel = DistanceLabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        map.delegate = mapViewDelegate
        
        self.view.addSubview(map)
        
        navigationController?.isNavigationBarHidden = true
        
        setUpButton()
        
        parseGPXFile()
        
        setChart(distance: distanceFromOrigin, values: elevation)
        
        recordInfoView.updateTrackInfo(data: trackInfo)
        
    }
    
    func setChart(distance: [Double], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        chartView.noDataText = "Can not get track record!"
        
        for index in 0..<elevation.count {
            
            let xvalue = distance[index] / 1000
            
            let yvalue = values[index]
            
            let dataEntry = ChartDataEntry(x: xvalue, y: yvalue)
            
            dataEntries.append(dataEntry)
        }
        
        let dataSet = LineChartDataSet(entries: dataEntries, label: "")
        
        dataSet.colors = [.U1 ?? .systemGray]
        
        dataSet.drawFilledEnabled = true
        
        dataSet.drawCirclesEnabled = false
        
        dataSet.drawValuesEnabled = false
        
        dataSet.lineWidth = 2
        
        dataSet.fillAlpha = 0.8
        
        dataSet.fillColor = .U2 ?? .lightGray
        
        chartView.data = LineChartData(dataSets: [dataSet])
        
        chartView.xAxis.setLabelCount(values.count, force: true)
        
        chartView.legend.enabled = false
        
        setUpChartLayout()

    }
    
    func setUpChartLayout() {
 
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.setLabelCount(10, force: false)
        xAxis.drawGridLinesEnabled = true
        xAxis.granularityEnabled = true
        
        let yAxis = chartView.leftAxis
        yAxis.axisMinimum = 0
        yAxis.setLabelCount(10, force: false)
        yAxis.labelPosition = .outsideChart
        yAxis.drawGridLinesEnabled = true
        yAxis.granularityEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.animate(xAxisDuration: 2.0)
    }
    
    func setUpButton() {
        
        let returnButton = UIButton()
        
        let radius = UIScreen.width * 13 / 107
        
        returnButton.frame = CGRect(x: 20, y: 40, width: radius, height: radius)
        
        returnButton.backgroundColor = .white
        
        let image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        
        returnButton.setImage(image, for: .normal)
        
        returnButton.tintColor = .B1
        
        returnButton.layer.cornerRadius = radius / 2
        
        returnButton.layer.masksToBounds = true
        
        returnButton.addTarget(self, action: #selector(returnToPreviousPage), for: .touchUpInside)
        
        view.addSubview(returnButton)
    }
    
    @objc func returnToPreviousPage() {
        navigationController?.popViewController(animated: true)
    }
    
    func parseGPXFile() {
        let inputURL = URL(string: record.recordRef)
        
        if let inputURL = inputURL {
            
            guard let gpx = GPXParser(withURL: inputURL)?.parsedData() else { return }
            
            didLoadGPXFile(gpxRoot: gpx)
            
            for track in gpx.tracks {
                
                for segment in track.segments {
                   
                    for trackPoints in segment.points {
                        
                        if let ele = trackPoints.elevation,
                           
                            let time = trackPoints.time?.timeIntervalSinceReferenceDate {
                            elevation.append(ele)
                            trackTime.append(Double(time))
                        }
                    }
                    
                    distanceFromOrigin = segment.distanceFromOrigin()
                }
            }
            trackTime = trackTime.map { $0 - self.trackTime[0]}
            
            trackInfo.distance = distanceFromOrigin.last ?? 0
            
            trackInfo.spentTime = trackTime.last ?? 0
            
            if let maxValue = elevation.max(),
               let minValue = elevation.min() {
                
                trackInfo.elevationDiff = maxValue - minValue
            }
            
            calculateElevation(elevation: elevation)
        }
    }
    
    func didLoadGPXFile(gpxRoot: GPXRoot) {
        
        map.importFromGPXRoot(gpxRoot)
        
        map.regionToGPXExtent()
    }
    
    func calculateElevation(elevation: [Double]) {
        
        var totalClimp: Double = 0.0
        
        var totalDrop: Double = 0.0
        
        for index in 0..<elevation.count - 1 {
            
            let diff = elevation[index + 1] - elevation[index]
            
            if diff < 0 {
                
                totalDrop += diff
                
            } else {
                
                totalClimp += diff
            }
        }
        
        totalDrop = abs(totalDrop)
        
        trackInfo.totalClimb = totalClimp
        
        trackInfo.totalDrop = totalDrop
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
