//
//  TrialInfoScrollView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/25.
//

import UIKit

class TrialInfoView: UIView {
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var trailInfo: UILabel!
    
    @IBOutlet weak var trailLength: UILabel!
    
    @IBOutlet weak var trailLevel: UILabel!
    
    @IBOutlet weak var trafficInfo: UILabel!
    
    @IBOutlet weak var trailMap: UIImageView!
    
    func setUpLayout(trail: Trail) {
        
        trailName.text = trail.trailName
        
        trailInfo.text = trail.trailInfo
        
        trailLength.text = "\(trail.trailLength) 公里"
        
        trailLevel.text = "\(trail.trailLevel) 星"
        
        trafficInfo.text = trail.trailTraffic
        
    }
    
}
