//
//  UIFontExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/2.
//

import UIKit

enum FontName: String {
    
    case regular = "NotoSansTC-Regular"
    
    case bold = "NotoSansTC-Bold"
    
    case thin = "NotoSansTC-Thin"

    case light = "NotoSansTC-Light"

    case medium = "NotoSansTC-Medium"
    
    case black = "NotoSansTC-Black"

}

extension UIFont {
    
    static func regular(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.regular.rawValue, size: size)
    }
    
    static func bold(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.bold.rawValue, size: size)
    }
    
    static func thin(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.thin.rawValue, size: size)
    }

    static func light(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.light.rawValue, size: size)
    }
    
    static func medium(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.medium.rawValue, size: size)
    }

    static func black(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.black.rawValue, size: size)
    }

    private static func font(_ font: FontName, size: CGFloat) -> UIFont? {

        return UIFont(name: font.rawValue, size: size)
    }
}