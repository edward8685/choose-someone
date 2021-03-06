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

class UserRecordViewController: BaseViewController, ChartViewDelegate {
    
    // MARK: - Class Properties -
    
    @IBOutlet weak var map: GPXMapView!
    
    @IBOutlet weak var recordInfoView: RecordInfoView!
    
    @IBOutlet weak var chartView: LineChartView! {
        
        didSet {
            chartView.delegate = self
        }
    }
    
    private let mapViewDelegate = MapViewDelegate()
    
    lazy var record = Record()
    
    lazy var trackInfo = TrackInfo()
    
    lazy var trackChartData = TrackChartData()
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = mapViewDelegate
        
        self.view.addSubview(map)
        
        navigationController?.isNavigationBarHidden = true
        
        self.tabBarController?.tabBar.isHidden = true
        
        setUpButton()
        
        parseGPXFile()
        
        recordInfoView.updateTrackInfo(data: trackInfo)
        
        setChart(xValues: trackChartData.distance, yValues: trackChartData.elevation)
    }
    
    // MARK: - Methods -
    
    func setChart(xValues: [Double], yValues: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        chartView.noDataText = "Can not get track record!"
        
        for index in 0..<trackChartData.elevation.count {
            
            let xvalue = xValues[index] / 1000 // m -> km
            
            let yvalue = yValues[index]
            
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
        
        chartView.xAxis.setLabelCount(yValues.count, force: true)
        
        chartView.legend.enabled = false
        
        setUpChartLayout()
    }
    
    // MARK: - Parse GPX File and Process Track Data -
    
    func parseGPXFile() {
        
        let inputURL = URL(string: record.recordRef)
        
        if let inputURL = inputURL {
            
            guard let gpx = GPXParser(withURL: inputURL)?.parsedData() else { return }
            
            didLoadGPXFile(gpxRoot: gpx)
            
            processTrackData(gpxRoot: gpx)
        }
        
        func processTrackData(gpxRoot: GPXRoot) {
            
            var temArray: [Double] = []
            
            for track in gpxRoot.tracks {
                
                var lastLength: Double = 0.0
                
                for segment in track.segments {
                    
                    for trackPoints in segment.points {
                        
                        if let ele = trackPoints.elevation,
                           
                            let time = trackPoints.time?.timeIntervalSinceReferenceDate {
                            trackChartData.elevation.append(ele)
                            trackChartData.time.append(Double(time))
                        }
                    }
                    // add the last segment endpoint to coordinate of the next segment
                    let segmentLength = segment.distanceFromOrigin().map { $0 + lastLength }
                    
                    lastLength = segmentLength.last ?? 0
                    
                    temArray += segmentLength
                }
            }
            
            trackChartData.distance = temArray
            
            trackChartData.time = trackChartData.time.map { $0 - self.trackChartData.time[0]}
            
            trackInfo.distance = trackChartData.distance.last ?? 0
            
            trackInfo.spentTime = trackChartData.time.last ?? 0
            
            processDiffOfElevation(elevation: trackChartData.elevation)
        }
    }
    
    func didLoadGPXFile(gpxRoot: GPXRoot) {
        
        map.importFromGPXRoot(gpxRoot)
        
        map.regionToGPXExtent()
    }
    
    func processDiffOfElevation(elevation: [Double]) {
        
        var totalClimp: Double = 0.0
        
        var totalDrop: Double = 0.0

        if elevation.count != 0 {
            
            for index in 0..<elevation.count - 1 {
                
                let diff = elevation[index + 1] - elevation[index]
                
                if diff < 0 && abs(diff) < 1.35 {
                    
                    totalDrop += diff

                } else if diff > 0 && abs(diff) < 1.35 {
                    
                    totalClimp += diff
                }
            }
        }
        
        totalDrop = abs(totalDrop)
        
        trackInfo.totalClimb = totalClimp
        
        trackInfo.totalDrop = totalDrop
        
        if let maxValue = trackChartData.elevation.max(),
           let minValue = trackChartData.elevation.min() {
            
            trackInfo.elevationDiff = maxValue - minValue
        }
    }
    
    // MARK: - UI Settings -
    
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
        
        let radius = UIScreen.width * 13 / 107
        
        let button = PreviousPageButton(frame: CGRect(x: 40, y: 50, width: radius, height: radius))
        
        button.addTarget(self, action: #selector(popToPreviousPage), for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    // MARK: - Polyline -
    
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
