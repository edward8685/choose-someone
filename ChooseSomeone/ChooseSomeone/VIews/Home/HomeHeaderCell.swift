//
//  HomeHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/23.
//

import UIKit

class HomeHeaderCell: UITableViewCell {
    
    var lengthStartValue: Double = 0.0
    
    var friendsStartValue: Int = 0
    
    var groupsStartValue: Int = 0
    
    var lengthEndValue: Double = 0.0
    
    var friendsEndValue: Int = 0
    
    var groupsEndValue: Int = 0
    
    var lengthDiff: Double = 0.0
    
    var friendsDiff: Int = 0
    
    var groupsDiff: Int = 0
    
    //    let animationDuration = 3.0
    
    @IBOutlet weak var totalKilos: UILabel!
    
    @IBOutlet weak var totalFriends: UILabel!
    
    @IBOutlet weak var totalGroups: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    
    func updateUserInfo(user: UserInfo) {
        
        let displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
        
        displayLink.add(to: .main, forMode: .default)
        
        lengthEndValue = user.totalLength / 1000
        
        friendsEndValue = user.totalFriends
        
        groupsEndValue = user.totalGroups
        
        lengthDiff = lengthEndValue - lengthStartValue
        
        friendsDiff = friendsEndValue - friendsStartValue
        
        groupsDiff = groupsEndValue - groupsStartValue
        
        userName.text = user.userName
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        selectionStyle = .none
        
    }
    
    @objc func handleUpdate() {
        
        let length = String(format: "%.1f", lengthStartValue)
        
        totalKilos.text = "\(length)"
        
        totalFriends.text = "\(friendsStartValue)"
        
        totalGroups.text = "\(groupsStartValue)"
        
        //        lengthStartValue += lengthDiff / animationDuration
        //        friendsStartValue += friendsDiff / Int(animationDuration)
        //        groupsStartValue += groupsDiff / Int(animationDuration)
        
        lengthStartValue += 0.2
        friendsStartValue += 1
        groupsStartValue += 1
        
        if lengthStartValue > lengthEndValue {
            lengthStartValue = lengthEndValue
        }
        if friendsStartValue > friendsEndValue {
            friendsStartValue = friendsEndValue
        }
        if groupsStartValue > groupsEndValue {
            groupsStartValue = groupsEndValue
        }
    }
}
