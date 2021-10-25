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
    
    func setUpLayout(trail: Trail) {
        
        trailName.text = trail.trailName
        
        trailInfo.text = trail.trailInfo
        
        trailLength.text = "\(trail.trailLength) 公里"
        
        trailLevel.text = "\(trail.trailLevel) 星"
        
        trafficInfo.text = trail.trailTraffic
        
        
        let fileReference = Storage.storage().reference().child("maps/\(trail.trailId)_MAP.jpg")
        print("maps/\(trail.trailId).jpg")
        fileReference.getData(maxSize: 10 * 1024 * 1024) { result in
            switch result {
            case .success(let data):
//                trailMap.loadImage(data, placeHolder: nil)
                let image = UIImage(data: data)
                self.trailMap.image = image
                self.trailMap.contentMode = .scaleAspectFill
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
