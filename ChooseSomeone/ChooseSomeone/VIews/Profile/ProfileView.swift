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
            
            if isEditting {
                editNameButton.setImage(UIImage(systemName: "arrow.down.square"), for: .normal)
                
            } else {
                editNameButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            }
                
            UIView.animate(withDuration: 0.1) {
                
                self.editNameTextField.backgroundColor = self.isEditting ? .systemGray6 : .clear
                
                self.editNameTextField.textColor = self.isEditting ? .black : .B1
                
            } completion: { [self] _ in
                
                editNameTextField.isEnabled = isEditting ? true : false
                
                editNameTextField.isEnabled = isEditting ? true : false
                
            }
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
        
        editNameTextField.roundCorners(cornerRadius: 8)
    }
}
