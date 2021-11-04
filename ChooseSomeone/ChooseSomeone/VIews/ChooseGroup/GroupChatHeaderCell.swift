//
//  ChatHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class GroupChatHeaderCell: UITableViewCell {
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var note: UILabel!
    
    @IBOutlet weak var requestButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var infoButton: UIButton!
    
    func setUpCell(groups: Group) {
        
        let userId = UserManager.shared.userInfo.uid
        
        groupName.text = groups.groupName
        
        let timeInterval = groups.date
        let date = timeInterval.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd  HH:mm"
        let time = dateFormatter.string(from: date as Date)
        travelDate.text = time
        
        trailName.text = groups.trailName
        let upperLimit = groups.upperLimit.description
        let counts = groups.userIds.count
        numOfPeople.text = "\(counts) / \(upperLimit)"
        note.text = groups.note
        
        for userInGroup in groups.userIds {
            if userInGroup != userId {
                requestButton.setTitle("送出申請", for: .normal)
            } else {
                requestButton.setTitle("退出隊伍", for: .normal)
            }
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
