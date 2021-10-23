//
//  UITableView+ColloectionVIewExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/22.
//

import UIKit

extension UITableView {
    
    func lk_registerCellWithNib(identifier: String, bundle: Bundle?) {
        
        let nib = UINib(nibName: identifier, bundle: bundle)
        
        register(nib, forCellReuseIdentifier: identifier)
    }
    
}

extension UITableViewCell {
    
    static var identifier: String {
        
        return String(describing: self)
    }
}

extension UICollectionView {
    
    func lk_registerCellWithNib(reuseIdentifier: String, bundle: Bundle?) {
        
        let nib = UINib(nibName: reuseIdentifier, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
}

extension UICollectionViewCell {
    
    static var reuseIdentifier: String {
        
        return String(describing: self)
    }
}
