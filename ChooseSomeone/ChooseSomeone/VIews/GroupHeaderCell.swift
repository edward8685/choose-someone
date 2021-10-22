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
    
    @IBOutlet weak var requestListButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
