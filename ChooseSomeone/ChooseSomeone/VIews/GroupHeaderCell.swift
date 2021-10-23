//
//  GroupHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import MASegmentedControl

class GroupHeaderCell: UITableViewCell {
    
    @IBOutlet weak var textSegmentedControl: MASegmentedControl! {
        didSet {
            //Set this booleans to adapt control
            textSegmentedControl.itemsWithText = true
            textSegmentedControl.fillEqually = true
            textSegmentedControl.roundedControl = true
            
            textSegmentedControl.setSegmentedWith(items: ["揪團中", "我的揪團"])
            textSegmentedControl.padding = 2
            textSegmentedControl.textColor = .white
            
            textSegmentedControl.selectedSegmentIndex
            
            textSegmentedControl.selectedTextColor = UIColor.white
            textSegmentedControl.thumbViewColor = UIColor.hexStringToUIColor(hex: "72E717")
            textSegmentedControl.segmentedBackGroundColor = UIColor.systemGray
            
            textSegmentedControl.titlesFont = UIFont(name: "OpenSans-Semibold", size: 15)
        }
    }
    
    @IBOutlet weak var groupSearchBar: UISearchBar!
    
    @IBOutlet weak var requestListButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
