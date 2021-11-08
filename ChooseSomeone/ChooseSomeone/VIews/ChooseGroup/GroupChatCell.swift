//
//  groupChatCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore

class GroupChatCell: UITableViewCell {
    
    @IBOutlet weak var createdTime: UILabel!
    
    @IBOutlet weak var memberName: UILabel!
    
    @IBOutlet weak var memberMessage: UILabel!
    
    @IBOutlet weak var memberImage: UIImageView!
    
    @IBOutlet weak var userMessage: UILabel!
    
    func setUpCell(messages: [Message], indexPath: IndexPath) {
        
        let userInfo = UserManager.shared.userInfo
        
        let time = messages[indexPath.row].createdTime
        createdTime.text = TimeFormater.preciseTime.timeFormat(time: time)
        
        if messages[indexPath.row].userId == userInfo.uid {
            userMessage.text = messages[indexPath.row].body
            isSentFromUser = true
        } else {
            isSentFromUser = false
//            memberName.text = messages[indexPath.row].userName
            memberMessage.text = messages[indexPath.row].body
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
        userMessage.layer.cornerRadius = 5
        userMessage.layer.masksToBounds = true
        memberMessage.layer.cornerRadius = 5
        memberMessage.layer.masksToBounds = true

 
        selectionStyle = .none
        self.backgroundColor = .clear
    }

    override func layoutSubviews() {
        
//        userMessage.applyGradient(colors: [.C4, .C3], locations: [0.0, 1.0], direction: .topToBottom)
//
//        memberMessage.applyGradient(colors: [.C2, .C1], locations: [0.0, 1.0], direction: .topToBottom)
    }
}
