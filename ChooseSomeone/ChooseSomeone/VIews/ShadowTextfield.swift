//
//  ShadowTextfield.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/8.
//

import UIKit

class ShadowTextField: UITextField {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderStyle = .none
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.masksToBounds = false
        layer.shadowOpacity = 0.15
        layer.backgroundColor = UIColor.white.cgColor
    }
}
