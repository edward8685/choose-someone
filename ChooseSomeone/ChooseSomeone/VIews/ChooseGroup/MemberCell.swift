//
//  JoinRequestCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import UIKit

class MemberCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var requestName: UILabel!
    
    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var viewOfBackground: UIView!
    
    func setUpCell(requests: [Request], indexPath: IndexPath) {
        
//        requestName.text = requests[indexPath.row].requestName
        requestLabel.text = "want to join your \(requests[indexPath.row].groupName)"
        
    }
    func setUpCell(group: Group, indexPath: IndexPath) {
        
        requestLabel.isHidden = true
        acceptButton.isHidden = true
        requestName.text = group.userIds[indexPath.row]
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        viewOfBackground.layer.cornerRadius = 10
        viewOfBackground.layer.masksToBounds = true
        selectionStyle = .none
    }
    
    override func layoutSubviews() {
        
        acceptButton.layer.cornerRadius = acceptButton.frame.height / 2
        acceptButton.layer.masksToBounds = true
        
        rejectButton.layer.cornerRadius = acceptButton.frame.height / 2
        rejectButton.layer.masksToBounds = true
        
        userImage.cornerRadius = acceptButton.frame.height / 2
        
    }
    
}
