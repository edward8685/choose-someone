//
//  TrialInfoScrollView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/25.
//

import UIKit
import FirebaseStorage
import FirebaseStorageSwift


class TrialInfoView: UIView {
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var trailInfo: UILabel!
    
    @IBOutlet weak var trailLength: UILabel!
    
    @IBOutlet weak var trailLevel: UILabel!
    
    @IBOutlet weak var trafficInfo: UILabel!
    
    @IBOutlet weak var trailMap: UIImageView!
    
    @IBOutlet weak var dimmingView: UIView!
    
    
    func setUpLayout(trail: Trail) {
        
        trailName.text = trail.trailName
    
        trailInfo.text? = trail.trailInfo.replacingOccurrences(of: "\\r\\n", with: "\n")
        
        trailLength.text = "\(trail.trailLength) 公里"
        
        trailLevel.text = "\(trail.trailLevel) 星"
        
        trafficInfo.text = trail.trailTraffic.replacingOccurrences(of: "\\r\\n", with: "\n")
        
        TrailManager.shared.fetchTrailMap(tralId: trail.trailId) {result in
            
            switch result {
                
            case .success(let image):
                
                self.trailMap.image = image
                
                self.trailMap.contentMode = .scaleAspectFill
                
            case .failure(let error):
                
                print("fetch map failure \(error)")
                
            }
        }
    }
}
