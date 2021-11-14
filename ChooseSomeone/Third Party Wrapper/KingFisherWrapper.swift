//
//  KingFisherWrapper.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/25.
//

import UIKit
import Kingfisher

extension UIImageView {

    func loadImage(_ urlString: String?) {

        guard urlString != nil else { return }
        
        let url = URL(string: urlString!)
        
        let image = UIImage(named: "placeholder")

        self.kf.setImage(with: url, placeholder: image)
    }
}
