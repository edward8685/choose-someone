//
//  GroupInfoCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore

class GroupInfoCell: UITableViewCell {
    
    @IBOutlet weak var viewOfCell: UIView!
    
    @IBOutlet weak var isOverLabel: UILabel!
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var travelTime: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var hostName: UILabel!
    
    @IBOutlet weak var flagImage: UIImageView!
    
    @IBOutlet weak var chevronView: UIImageView!
    
    func setUpCell(group: Group, hostname: String) {
        
        let userInfo = UserManager.shared.userInfo

        groupName.text = group.groupName
        
        trailName.text = group.trailName
        
        travelDate.text = TimeFormater.dateStyle.timestampToString(time: group.date)
        
        travelTime.text = TimeFormater.timeStyle.timestampToString(time: group.date)
        
        hostName.text = hostname
        
        let upperLimit = group.upperLimit.description
        
        let counts = group.userIds.count
        numOfPeople.text = "\(counts) / \(upperLimit)"
        
        if group.hostId == userInfo.uid {
            
            flagImage.isHidden = false
            
        } else {
            
            flagImage.isHidden = true
        }
        
        if group.userIds.contains(userInfo.uid) {
            
            chevronView.isHidden = false
            
            } else {
                
                chevronView.isHidden = true
            }
        
        if group.isExpired == true {
            
            isOverLabel.isHidden = false
            viewOfCell.backgroundColor = .systemGray4
            
        } else {
            
            isOverLabel.isHidden = true
            viewOfCell.backgroundColor = .white

        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        selectionStyle = .none
        self.backgroundColor = .clear
        
    }
}
