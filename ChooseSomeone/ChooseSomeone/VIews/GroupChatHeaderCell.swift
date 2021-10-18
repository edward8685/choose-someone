//
//  ChatHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class GroupChatHeaderCell: UITableViewCell {
    
    @IBOutlet weak var travelDate: UILabel!
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var noted: UILabel!
    
    @IBOutlet weak var requestButtom: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
