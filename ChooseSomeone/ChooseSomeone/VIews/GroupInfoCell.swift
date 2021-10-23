//
//  GroupInfoCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class GroupInfoCell: UITableViewCell {
    
    private let userId = "1357988"
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var participationLabel: UILabel!
    
    @IBOutlet weak var flagImage: UIImageView!
    
    func setUpCell(group: Group, indexPath: IndexPath){
        
        groupName.text = group.groupName
        
        let timeInterval = group.date
        let date = timeInterval.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd  HH:mm"
        let time = dateFormatter.string(from: date as Date)
        travelDate.text = time
        
        trailName.text = group.trailName
        
        let upperLimit = group.upperLimit.description
        let counts = group.userIds.count
        numOfPeople.text = "\(counts) / \(upperLimit)"
        
        if group.hostId == userId {
            flagImage.isHidden = false
        } else {
            flagImage.isHidden = true
        }
        
        for userInGroup in group.userIds {
            if userInGroup != userId {
                participationLabel.isHidden = true
            } else {
                participationLabel.isHidden = false
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
