//
//  UIImageExtenstion.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/14.
//

import UIKit

enum ImageAsset: String {

    // Profile tab - Tab
    
    // swiftlint:disable identifier_name
    case scene_1
    case scene_2
    case scene_3
    case trail_bg1
    case trail_bg2
    case group_bg
    case home_bg
    
    case Icon_edit
    case Icon_gear
    case Icon_notice
    
    case badge
    case choose
    case block
    case mountain
    case placeholder
    case loading
    case man
    case women
    
    case Logo_flap
    case Logo_regular
    case Logo_stack
    
    case hiking
    case hiking_fill
    case route
    case route_fill
    case group
    case group_fill
    case search
    case search_fill
    case track
    case track_fill
    case profile
    case profile_fill
}

// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
