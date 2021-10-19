//
//  JoinRequestCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import UIKit

class JoinRequestCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var acceptedButton: UIButton!
    
    @IBOutlet weak var deniedButton: UIButton!
    
    @IBOutlet weak var viewOfBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        viewOfBackground.layer.cornerRadius = 10
        viewOfBackground.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
