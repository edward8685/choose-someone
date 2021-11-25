//
//  ChevronButton.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/9.
//

import UIKit

class PreviousPageButton: UIButton {
     
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .white
        
        let image = UIImage(systemName: "chevron.left",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        
        self.setImage(image, for: .normal)
        
        self.tintColor = .B1
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
