//
//  UIColor+Extension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/21.
//

import UIKit

private enum CSColor: String {

    // swiftlint:disable identifier_name
    case B1,B2,B3,B4
    case G1,G2,G3,G4,G5,G6
}

extension UIColor {

    static let B1 = CSColor(.B1)
    
    static let B2 = CSColor(.B2)
    
    static let B3 = CSColor(.B3)
    
    static let B4 = CSColor(.B4)
    
    static let G1 = CSColor(.G1)
    
    static let G2 = CSColor(.G2)
    
    static let G3 = CSColor(.G3)
    
    static let G4 = CSColor(.G4)
    
    static let G5 = CSColor(.G5)
    
    static let G6 = CSColor(.G6)
    
    // swiftlint:enable identifier_name
    
    private static func CSColor(_ color: CSColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
