//
//  ProfileItem.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/5.
//

import UIKit

protocol ProfileItem {
    
    var backgroundColor: UIColor? { get }
    
    var image: UIImage? { get }
    
    var title: String { get }
}

enum ProfileFeat: ProfileItem, CaseIterable {
    
    case record
    
    case account
    
    case privacy
    
    var image: UIImage? {
        
        switch self {
            
        case .record: return UIImage.asset(.Icon_edit)
            
        case .account: return UIImage.asset(.Icon_gear)
            
        case .privacy: return UIImage.asset(.Icon_notice)
            
        }
    }
    
    var title: String {
        
        switch self {
            
        case .record: return "我的紀錄"
            
        case .account: return "帳號設定"
            
        case .privacy: return "隱私權聲明"
        }
    }
    
    var backgroundColor: UIColor? {
        
        switch self {
            
        case .record: return UIColor.clear
            
        case .account: return UIColor.clear
            
        case .privacy: return UIColor.clear
        }
    }
}
