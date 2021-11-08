//
//  GroupInfoCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseFirestore

class GroupInfoCell: UITableViewCell {
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var travelTime: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var hostName: UILabel!
    
    @IBOutlet weak var flagImage: UIImageView!
    
    @IBOutlet weak var chevronView: UIImageView!
    
    func setUpCell(group: Group, indexPath: IndexPath) {
        
        let userInfo = UserManager.shared.userInfo

        groupName.text = group.groupName
        
        trailName.text = group.trailName
        
        travelDate.text = TimeFormater.dateStyle.timeFormat(time: group.date)
        
        travelTime.text = TimeFormater.timeStyle.timeFormat(time: group.date)
        
        let upperLimit = group.upperLimit.description
        
        let counts = group.userIds.count
        numOfPeople.text = "\(counts) / \(upperLimit)"
        
        if group.hostId == userInfo.uid {
            flagImage.isHidden = false
        } else {
            flagImage.isHidden = true
        }
        
        for userInGroup in group.userIds {
            if userInGroup != userInfo.uid {
                chevronView.isHidden = true
            } else {
                chevronView.isHidden = false
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        selectionStyle = .none
        self.backgroundColor = .clear
        
    }
    
    override func layoutSubviews() {
//        chevronView.layer.cornerRadius = chevronView.frame.height / 2
    }
    
}
