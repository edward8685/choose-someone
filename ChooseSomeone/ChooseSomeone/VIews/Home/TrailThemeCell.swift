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
    
    func setUpCell(theme: [String], image: [String], indexPath: IndexPath) {
        themeLabel.text = theme[indexPath.row]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear
        selectionStyle = .none
        
    }
}
