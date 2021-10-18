//
//  groupChatCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class GroupChatCell: UITableViewCell {

    @IBOutlet weak var createdTime: UILabel!
    
    @IBOutlet weak var otherName: UILabel!
    
    @IBOutlet weak var chatContent: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatContent.layer.cornerRadius = 5
        chatContent.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
