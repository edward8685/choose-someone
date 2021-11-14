//
//  groupChatCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore
import Kingfisher

class GroupChatCell: UITableViewCell {
    
    @IBOutlet weak var createdTime: UILabel!
    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var memberMessage: UILabel!
    
    @IBOutlet weak var memberImage: UIImageView!
    
    @IBOutlet weak var userMessage: UILabel!
    
    func setUpCell(message: Message, memberInfo: UserInfo) {
       
        let userInfo = UserManager.shared.userInfo
        
        let time = message.createdTime
        createdTime.text = TimeFormater.preciseTime.timeFormat(time: time)
        
        let userId = message.userId
        
        if userId == userInfo.uid {
            
            userMessage.text = message.body
            isSentFromUser = true
            
        } else {
            
            isSentFromUser = false
        
            memberName.text = memberInfo.userName
            
            memberMessage.text = message.body
            
            guard let ref = memberInfo.pictureRef else { return }
            
            memberImage.loadImage(ref)

        }
        
    }
    
    var isSentFromUser: Bool = true {
        didSet {
            userMessage.isHidden = isSentFromUser ? false : true
            memberName.isHidden = isSentFromUser ? true : false
            memberMessage.isHidden = isSentFromUser ? true : false
            memberImage.isHidden = isSentFromUser ? true : false
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
 
        selectionStyle = .none
        self.backgroundColor = .clear
        userMessage.layer.cornerRadius = 5
        userMessage.layer.masksToBounds = true
        memberMessage.layer.cornerRadius = 5
        memberMessage.layer.masksToBounds = true
        
        DispatchQueue.main.async {
            
            self.userMessage.applyGradient(colors: [.C3, .C4], locations: [0.0, 1.0], direction: .topToBottom)

            self.memberMessage.applyGradient(colors: [.C1, .C2], locations: [0.0, 1.0], direction: .topToBottom)
        }
    }
    
    override func layoutSubviews() {
        memberImage.layer.cornerRadius = memberImage.frame.height / 2
        memberImage.clipsToBounds = true
    }
}
