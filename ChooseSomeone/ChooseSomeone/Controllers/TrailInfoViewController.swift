//
//  TrailInfo.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailInfoViewController: UIViewController {
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var trailInfo: UILabel!
    
    @IBOutlet weak var trialLength: UILabel!
    
    @IBOutlet weak var trailLevel: UILabel!
    
    @IBOutlet weak var trafficInfo: UILabel!
    
    @IBOutlet weak var trailMap: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.isNavigationBarHidden = true
        
    }
    
}
