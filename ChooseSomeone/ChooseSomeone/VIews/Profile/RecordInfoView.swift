//
//  RecordInfoView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/31.
//

import UIKit

class RecordInfoView: UIView {
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var altitudeDifferenceLabel: UILabel!
    
    @IBOutlet weak var totalClimbLabel: UILabel!
    
    @IBOutlet weak var totalDropLabel: UILabel!
    
    func updateTrackInfo(data: TrackInfo) {
        
        totalDistanceLabel.text = data.distance.toKilometers()
        
        timeLabel.text = data.spentTime.tohmsTimeFormat()
        
        let speed = data.distance / data.spentTime
        
        speedLabel.text = speed.toSpeed()
        
        altitudeDifferenceLabel.text = data.elevationDiff.toAltitude()
        
        totalClimbLabel.text = data.totalClimb.toAltitude()
        
        totalDropLabel.text = data.totalDrop.toAltitude()
        
    }
}
