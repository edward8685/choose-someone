//
//  GroupHeaderCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import MASegmentedControl

class GroupHeaderCell: UITableViewCell {
    
    @IBOutlet weak var badgeView: UIView!
    
    @IBOutlet weak var textSegmentedControl: MASegmentedControl! {
        didSet {
            textSegmentedControl.itemsWithText = true
            textSegmentedControl.fillEqually = true
            textSegmentedControl.roundedControl = true
            
            textSegmentedControl.setSegmentedWith(items: ["揪團中", "我的揪團"])
            textSegmentedControl.padding = 2
            
            textSegmentedControl.textColor = .black
            
            textSegmentedControl.selectedTextColor = .black
            
            textSegmentedControl.thumbViewColor = .U2 ?? .systemGreen

            textSegmentedControl.titlesFont = UIFont(name: "NotoSansTC-Regular", size: 16)
        }
    }
    
    @IBOutlet weak var groupSearchBar: UISearchBar! {
        
        didSet {
        
        self.groupSearchBar.searchTextField.font = UIFont.regular(size: 14)
            
        }
    }
    
    @IBOutlet weak var requestListButton: UIButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        let image = UIImage()
        
        groupSearchBar.backgroundImage = image
        groupSearchBar.backgroundColor = .white
        groupSearchBar.searchTextField.backgroundColor = .white
        groupSearchBar.layer.cornerRadius = 15
        groupSearchBar.clipsToBounds = true
        
        selectionStyle = .none
        
        badgeView.isHidden = true
        
    }
    
}
