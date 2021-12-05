//
//  UITableView+ColloectionVIewExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/22.
//

import UIKit

extension UITableView {
    
    func registerCellWithNib(identifier: String, bundle: Bundle?) {
        
        let nib = UINib(nibName: identifier, bundle: bundle)
        
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as! T
        // swiftlint:enable force_cast
    }
}

extension UITableViewCell {
    
    static var identifier: String {
        
        return String(describing: self)
    }
}

extension UICollectionView {
    
    func registerCellWithNib(reuseIdentifier: String, bundle: Bundle?) {
        
        let nib = UINib(nibName: reuseIdentifier, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
    return self.dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
        // swiftlint:enable force_cast
    }

}

extension UICollectionViewCell {
    
    static var reuseIdentifier: String {
        
        return String(describing: self)
    }
}
