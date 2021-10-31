//
//  ProfileCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/30.
//

import UIKit
import FirebaseFirestore

class ProfileCell: UITableViewCell {

    @IBOutlet weak var recordName: UILabel!
    
    @IBOutlet weak var uploadTime: UILabel!
    
    func setUpCell(model: Record) {
        
        recordName.text = model.recordName
        
        uploadTime.text = Timestamp.timeFormat(time: model.createdTime)
    
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
