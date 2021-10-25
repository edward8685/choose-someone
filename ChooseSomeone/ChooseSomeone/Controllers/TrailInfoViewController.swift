//
//  TrailInfo.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailInfoViewController: UIViewController {
    
    @IBOutlet weak var trailInfo: TrialInfoView!
    
    var trail: Trail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButton()
    
        navigationController?.isNavigationBarHidden = true
        
        if let trail = trail {
        trailInfo.setUpLayout(trail: trail)
        }
    }
    
    func setUpButton() {
        
        let dismissButton = UIButton()
        
        dismissButton.frame = CGRect(x: UIScreen.width - 50, y: 50, width: 30, height: 30)
        dismissButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        dismissButton.backgroundColor = UIColor.hexStringToUIColor(hex: "64696F")
        let image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .light))
        dismissButton.setImage(image, for: .normal)
        dismissButton.tintColor = .white
        dismissButton.layer.cornerRadius = 15
        dismissButton.layer.masksToBounds = true
        
        dismissButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(dismissButton)
    }
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
}
