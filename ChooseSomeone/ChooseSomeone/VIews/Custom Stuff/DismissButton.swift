//
//  DismissButton.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/26.
//

import UIKit

class DismissButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 2
        
        self.layer.masksToBounds = true
    }
    
    func configure() {
        
        self.backgroundColor = UIColor.hexStringToUIColor(hex: "64696F")
        
        let image = UIImage(systemName: "xmark",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular))
        
        self.setImage(image, for: .normal)
        
        self.tintColor = .white
    }
}
