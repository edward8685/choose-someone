//
//  ProfileView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/5.
//

import UIKit

class ProfileView: UIView {
    
    var isEditting: Bool = false {
        
        didSet {
            
            editNameTextField.isEnabled = isEditting ? true : false
            
            editNameTextField.textColor = isEditting ? .black : .B1
            
            editNameTextField.isEnabled = isEditting ? true : false

        }
    }
    
    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var editImageButton: ImagePickerButton!
    
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var editNameTextField: UITextField!
    
    func setUpProfileView(userInfo: UserInfo) {
        
//        DispatchQueue.main.async { [self] in
            
            editNameTextField.text = userInfo.userName
//            print(userInfo)
            
            userImage.loadImage(userInfo.pictureRef)
            
            editNameTextField.textColor = .black
            
            editNameTextField.font = UIFont.regular(size: 14)
            
            editNameTextField.setLeftPaddingPoints(5)
        
//        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        userImage.layer.cornerRadius = userImage.frame.height / 2
        
    }
}
