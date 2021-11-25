//
//  TrailTheme.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/19.
//

import UIKit

protocol TrailItem {
    
    var image: UIImage? { get }
}

enum TrailThemes: String, TrailItem, CaseIterable {
    
    case easy = "愜意的走"
    
    case medium = "想流點汗"
    
    case hard = "百岳挑戰"
    
    var image: UIImage? {
        
        switch self {
            
        case .easy:
            
            return UIImage.asset(.scene_1)
            
        case .medium:
            
            return UIImage.asset(.scene_2)
            
        case .hard:
            
            return UIImage.asset(.scene_3)
        }
    }
}
