//
//  HomeHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/23.
//

import UIKit

class HomeHeaderCell: UITableViewCell {

    @IBOutlet weak var totalKilos: UILabel!
    
    @IBOutlet weak var totalFriends: UILabel!
    
    @IBOutlet weak var totalGroups: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var genderImage: UIImageView!
    
    func updateUserInfo(user: UserInfo) {
        totalKilos.text = user.totalLength.description
        totalFriends.text = user.totalFriends.description
        totalGroups.text = user.totalGroups.description
        userName.text = user.userName
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        selectionStyle = .none
        
    }
}
