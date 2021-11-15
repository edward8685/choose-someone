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

enum ProfileSegue: String, CaseIterable {
    
    case record = "toRecord"
    
    case notice = "toNotice"
    
    case account = "toAccount"
    
    }

struct ProfileGroup {
    
    let title: String
    
    let action: ProfileSegue?
    
    let items: [ProfileItem]
}

enum ProfileFeat: ProfileItem, CaseIterable {
    
    case record
    
    case notice
    
    case account
    
    case share
    
    var image: UIImage? {
        
        switch self {
            
        case .record: return UIImage.asset(.Icon_edit)
            
        case .notice: return UIImage.asset(.Icon_notice)
            
        case .account: return UIImage.asset(.Icon_gear)
            
        case .share: return UIImage(named: "hourglass")
        }
    }
    
    var title: String {
        
        switch self {
            
        case .record: return "我的紀錄"
            
        case .notice: return "登山須知"
            
        case .account: return "帳號設定"
            
        case .share: return "敬請期待"
            
        }
    }
    
    var backgroundColor: UIColor? {
        
        switch self {
            
        case .record: return UIColor.clear
            
        case .notice: return UIColor.clear
            
        case .account: return UIColor.clear
            
        case .share: return UIColor.clear
            
        }
        
    }
    
}
