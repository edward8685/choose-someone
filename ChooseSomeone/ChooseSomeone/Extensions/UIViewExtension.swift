//
//  UIViewExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/21.
//

import UIKit

extension UIView {
    
    //Border Color
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
    
    //Border width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    //Corner radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor?{
            set {
                guard let uiColor = newValue else { return }
                layer.shadowColor = uiColor.cgColor
            }
            get{
                guard let color = layer.shadowColor else { return nil }
                return UIColor(cgColor: color)
            }
        }

        @IBInspectable var shadowOpacity: Float{
            set {
                layer.shadowOpacity = newValue
            }
            get{
                return layer.shadowOpacity
            }
        }

        @IBInspectable var shadowOffset: CGSize{
            set {
                layer.shadowOffset = newValue
            }
            get{
                return layer.shadowOffset
            }
        }

        @IBInspectable var shadowRadius: CGFloat{
            set {
                layer.shadowRadius = newValue
            }
            get{
                return layer.shadowRadius
            }
        }
    
    
    func stickSubView(_ objectView: UIView) {
        
        objectView.removeFromSuperview()
        
        addSubview(objectView)
        
        objectView.translatesAutoresizingMaskIntoConstraints = false
        
        objectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        objectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        objectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        objectView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}
