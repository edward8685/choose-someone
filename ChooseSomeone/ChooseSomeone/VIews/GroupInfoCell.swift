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
    
    @IBOutlet weak var travelRoute: UILabel!
    
    @IBOutlet weak var numOfPeople: UILabel!
    
    @IBOutlet weak var participationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
