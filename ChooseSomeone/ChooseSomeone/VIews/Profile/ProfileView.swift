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
            
            editNameTextField.backgroundColor = isEditting ? .systemGray6 : .clear
            
            editNameTextField.isEnabled = isEditting ? true : false

        }
    }
    
    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var editImageButton: ImagePickerButton!
    
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var editNameTextField: UITextField!
    
    func setUpProfileView(userInfo: UserInfo) {
        
            editNameTextField.text = userInfo.userName

            userImage.loadImage(userInfo.pictureRef)
            
            editNameTextField.textColor = .black
            
            editNameTextField.font = UIFont.regular(size: 24)
            
            editNameTextField.setLeftPaddingPoints(8)
        
            editNameTextField.setRightPaddingPoints(8)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        userImage.layer.cornerRadius = userImage.frame.height / 2
    }
}
