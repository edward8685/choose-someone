//
//  ProfileCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/5.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemBackground: UIView!
    
    @IBOutlet weak var itemTitle: UILabel!
    
    func setUpCell(indexPath: IndexPath) {
        itemImage.image = ProfileFeat.allCases[indexPath.row].image
        itemImage.contentMode = .scaleToFill
        
        itemBackground.backgroundColor = ProfileFeat.allCases[indexPath.row].backgroundColor
        
        itemTitle.text = ProfileFeat.allCases[indexPath.row].title
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        itemBackground.layer.cornerRadius = itemBackground.frame.height / 2
    }
    
}
