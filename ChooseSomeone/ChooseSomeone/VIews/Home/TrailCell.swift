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
    
    @IBOutlet weak var trailDifficult: UIStackView!
    
    func setUpCell(model: Trail) {
        
        trailName.text = model.trailName
        
        trailArea.text = model.trailLocation
        
        trailLength.text = model.trailLength.description
        
        trailDifficult.arrangedSubviews[0].isHidden = true
        
        for _ in 0..<model.trailLevel {
            
            let image = UIImageView()
            
            image.translatesAutoresizingMaskIntoConstraints = false
            
            image.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            image.widthAnchor.constraint(equalToConstant: 40).isActive = true

            image.image = UIImage.asset(.mountain)
     
            trailDifficult.addArrangedSubview(image)
            }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
