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
            
        case .record: return UIImage(named: "edit")
            
        case .notice: return UIImage(named: "backpack")
            
        case .account: return UIImage(named: "gear")
            
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
            
        case .record: return UIColor.U1
            
        case .notice: return UIColor.U3
            
        case .account: return UIColor.B1
            
        case .share: return UIColor.B2
            
        }
        
    }
    
}
