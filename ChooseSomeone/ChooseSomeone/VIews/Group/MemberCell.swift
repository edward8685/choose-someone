//
//  JoinRequestCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import UIKit

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var requestNameLabel: UILabel!
    
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var viewOfBackground: UIView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    //Join Request
    
    func setUpCell(request: Request, userInfo: UserInfo) {
        
        requestNameLabel.text = userInfo.userName
        
        requestLabel.text = "want to join your group"
        
        groupNameLabel.text = "\(request.groupName)"
        
        guard let ref = userInfo.pictureRef else { return }
        
        userImage.loadImage(ref)
        
    }
    
    // Check Teammate
    
    func setUpCell(group: Group, userInfo: UserInfo) {
        
        requestLabel.isHidden = true
        acceptButton.isHidden = true
        groupNameLabel.isHidden = true
        
//        let image = UIImage.asset(.block)
        let image = UIImage(systemName: "person.fill.xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        
        rejectButton.setImage(image, for: .normal)
        
        rejectButton.tintColor = .white
        
        if userInfo.uid == UserManager.shared.userId {
            rejectButton.isHidden = true
        }
        
        requestNameLabel.text = userInfo.userName
        
        userImage.loadImage(userInfo.pictureRef)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        viewOfBackground.layer.cornerRadius = 10
        viewOfBackground.layer.masksToBounds = true
        selectionStyle = .none
        
        rejectButton.imageView?.contentMode = .scaleAspectFit
        rejectButton.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2
        acceptButton.layer.masksToBounds = true
        
        rejectButton.layer.cornerRadius = rejectButton.frame.height / 2
        rejectButton.layer.masksToBounds = true
        
        userImage.cornerRadius = userImage.frame.height / 2
        
    }
    
}
