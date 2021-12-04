//
//  TrailInfo.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailInfoViewController: BaseViewController {
    
    // MARK: - Class Properties -
    
    @IBOutlet weak var trailInfoView: TrialInfoView!
    
    var trail: Trail?
    
    // MARK: - View Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDismissButton()
        
        navigationController?.isNavigationBarHidden = true
        
        if let trail = trail {
            trailInfoView.setUpLayout(trail: trail)
        }
    }
    
    // MARK: - Methods -
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UI Settings -
    
    func setUpDismissButton() {
        
        let button = DismissButton(frame: CGRect(x: UIScreen.width - 50, y: 30, width: 30, height: 30))
        
        button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    func setUpdimmingView() {
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        
        trailInfoView.dimmingView.addGestureRecognizer(recognizer)
    }
}
