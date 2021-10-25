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
    
    func setUpCell(model: Trail, indexPath: IndexPath) {
        
        trailName.text = model.trailName
        trailArea.text = model.trailLocation
        trailLength.text = model.trailLength.description
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
