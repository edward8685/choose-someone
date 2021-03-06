//
//  BuildTeamButton.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/25.
//

import UIKit

class BuildTeamButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        let image = UIImage.asset(.choose)
        
        self.setImage(image, for: .normal)
        
        self.tintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 2
        
        self.layer.masksToBounds = true
    }
}
