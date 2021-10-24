//
//  TrailCell.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

class TrailCell: UICollectionViewCell {
    
    @IBOutlet weak var trailName: UILabel!
    
    @IBOutlet weak var trailArea: UILabel!
    
    @IBOutlet weak var trailLength: UILabel!
    
    @IBOutlet weak var checkGroupButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
