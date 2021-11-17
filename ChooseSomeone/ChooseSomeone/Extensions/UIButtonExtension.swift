//
//  UIButtonExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/21.
//

import UIKit

@IBDesignable extension UIButton {
    
    @IBInspectable var CSBorderWidth: CGFloat {
        
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var CSCornerRadius: CGFloat {
        
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var CSBorderColor: UIColor? {
        
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
    }
    
    @IBInspectable override var shadowOpacity: Float {
        
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable override var shadowOffset: CGSize {
        
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    override var shadowColor: UIColor? {
        
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

@IBDesignable

public class GradientButton: UIButton {
    public override class var layerClass: AnyClass {
        
        CAGradientLayer.self
    }
    private var gradientLayer: CAGradientLayer {
        
        // swiftlint:disable force_cast
        layer as! CAGradientLayer
        // swiftlint:enable force_cast
    }

    @IBInspectable public var startColor: UIColor = .white {
        
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable public var endColor: UIColor = .red {
        
        didSet {
            updateColors()
        }
    }

    @IBInspectable public var startPoint: CGPoint {
        get { gradientLayer.startPoint }
        set { gradientLayer.startPoint = newValue }
    }

    @IBInspectable public var endPoint: CGPoint {
        get { gradientLayer.endPoint }
        set { gradientLayer.endPoint = newValue }
    }

    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        updateColors()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateColors()
    }
}

private extension GradientButton {
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
}
