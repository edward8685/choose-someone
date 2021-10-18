//
//  UIViewExtensions.swift
//  Publisher
//
//  Created by Ed Chang on 2021/10/6.
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

extension UICollectionViewCell{
    
    static var reuseIdentifier: String {
        
        return String(describing: self)
    }
}

extension UIView {
    
    func stickSubView(_ objectView: UIView) {
        
        objectView.removeFromSuperview()
        
        addSubview(objectView)
        
        objectView.translatesAutoresizingMaskIntoConstraints = false
        
        objectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        objectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        objectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        objectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
