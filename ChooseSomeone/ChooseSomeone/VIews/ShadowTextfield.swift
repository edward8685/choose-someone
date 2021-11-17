//
//  ShadowTextfield.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/8.
//

import UIKit

class ShadowTextField: UITextField {
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
      
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        borderStyle = .none
        self.clipsToBounds = true
        layer.cornerRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 0.15
        
        layer.backgroundColor = UIColor.white.cgColor
        
    }
}
