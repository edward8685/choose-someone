//
//  ImagePickerButton.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/6.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    
    func presentImagePicker()
    
}

class ImagePickerButton: UIButton {
    
    weak var delegate: ImagePickerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTarget(self, action: #selector(pickImage), for: .touchUpInside)
    }
    
    @objc func pickImage(sender: UIButton) {
        
        delegate?.presentImagePicker()
    }
}
