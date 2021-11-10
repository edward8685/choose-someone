//
//  ProfileView.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/5.
//

import UIKit

class ProfileView: UIView {
    
    var isEditing: Bool = false {
        didSet{
        userName.isHidden = isEditing ? true : false
        editNameTextField.isHidden = isEditing ? false : true
        }
    }
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var editImageButton: ImagePickerButton!
    
    @IBOutlet weak var editNameButton: UIButton!
    
    @IBOutlet weak var editNameTextField: UITextField!
    
    func setUpProfileView(userInfo: UserInfo) {
        
        userName.text = userInfo.userName
        
        editNameTextField.text = userInfo.userName
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImage.layer.cornerRadius = userImage.frame.height / 2
    }
    
}
