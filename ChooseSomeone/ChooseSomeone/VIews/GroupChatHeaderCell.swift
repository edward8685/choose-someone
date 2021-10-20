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
    
    func setUpCell(groups: Group){
        
        groupName.text = groups.groupName
        
        let timeInterval = groups.date
        let date = timeInterval.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date as Date)
        travelDate.text = time
        
        trailName.text = groups.trailName
        let upperLimit = groups.upperLimit.description
        let counts = groups.userIds.count
        numOfPeople.text = "\(counts) \\ \(upperLimit)"
        note.text = groups.note
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
