//
//  UIViewExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/21.
//

import UIKit

extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        
        get {
            guard let borderColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        
        set {
            guard let uiColor = newValue else { return }
            layer.shadowColor = uiColor.cgColor
        }
        
    }
    
    @IBInspectable var shadowOpacity: Float {
        
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    
    enum Direction: Int {
        case topToBottom = 0
        case leftSkewed
    }
    
    func applyGradient(colors: [UIColor?], locations: [NSNumber]? = [0.0, 1.0], direction: Direction = .topToBottom) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map{ $0?.cgColor as Any }
        gradientLayer.locations = locations
        
        switch direction {
        case .topToBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
        case .leftSkewed:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            
        }
        
        self.layer.addSublayer(gradientLayer)
    }
    
    func roundCornersTop(cornerRadius: Double) {
        
        self.layer.cornerRadius = CGFloat(cornerRadius)
        
        self.clipsToBounds = true
        
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
    
    func stickSubView(_ objectView: UIView) {
        
        objectView.removeFromSuperview()
        
        addSubview(objectView)
        
        objectView.translatesAutoresizingMaskIntoConstraints = false
        
        objectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        objectView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        objectView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        objectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}
