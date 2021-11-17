//
//  TrailThemeCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/23.
//

import UIKit

class TrailThemeCell: UITableViewCell {

    @IBOutlet weak var themeImage: UIImageView!
    
    @IBOutlet weak var themeLabel: UILabel!
    
    func setUpCell(theme: String, image: UIImage?) {
        
        themeLabel.text = theme
        
        themeImage.image = image
        
        themeImage.contentMode = .scaleToFill
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentView.backgroundColor = .clear
        
        self.backgroundColor = .clear
        
        selectionStyle = .none
    }
}
