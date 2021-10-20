//
//  GroupInfoCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class GroupInfoCell: UITableViewCell {
    
    @IBOutlet weak var groupName: UILabel!
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var participationLabel: UILabel!
    
    func setUpCell(groups: [Group], indexPath: IndexPath){
        
        groupName.text = groups[indexPath.row].groupName
        
        let timeInterval = groups[indexPath.row].date
        let date = timeInterval.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date as Date)
        travelDate.text = time
        
        trailName.text = groups[indexPath.row].trailName
        let upperLimit = groups[indexPath.row].upperLimit.description
        let counts = groups[indexPath.row].userIds.count
        numOfPeople.text = "\(counts) \\ \(upperLimit)"
        
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
