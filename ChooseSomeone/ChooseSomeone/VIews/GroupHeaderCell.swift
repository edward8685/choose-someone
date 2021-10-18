//
//  GroupHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit

class GroupHeaderCell: UITableViewCell {

    @IBOutlet weak var groupSegment: UISegmentedControl!
    
    @IBOutlet weak var groupSearchBar: UISearchBar!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
