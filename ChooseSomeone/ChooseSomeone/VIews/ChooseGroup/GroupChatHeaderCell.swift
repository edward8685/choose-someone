//
//  ChatHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore

class GroupChatHeaderCell: UITableViewCell {
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var travelTime: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var hostName: UILabel!
    
    @IBOutlet weak var note: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var infoButton: UIButton!
    
    func setUpCell(group: Group) {
        
        let userId = UserManager.shared.userInfo.uid
        
        groupName.text = group.groupName
        
        travelDate.text = TimeFormater.dateStyle.timeFormat(time: group.date)
        
        travelTime.text = TimeFormater.timeStyle.timeFormat(time: group.date)
        
        trailName.text = group.trailName
        
        let upperLimit = group.upperLimit.description
        
        let counts = group.userIds.count
        
        numOfPeople.text = "\(counts) / \(upperLimit)"
        
        note.text = group.note
        
        if group.hostId == userId {
            
            requestButton.setTitle("編輯資訊", for: .normal)
            
        } else {
            
            for userInGroup in group.userIds {
                
                if userInGroup != userId {
                    
                    requestButton.setTitle("送出申請", for: .normal)
                    
                } else {
                    
                    requestButton.setTitle("退出隊伍", for: .normal)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
