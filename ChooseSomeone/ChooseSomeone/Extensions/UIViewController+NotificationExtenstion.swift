//
//  ViewControllerExtenstion.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/11.
//

import UIKit
import IQKeyboardManagerSwift

class BaseViewController: UIViewController {
    
    static var identifier: String {
        
        return String(describing: self)
    }
    
    var isHideNavigationBar: Bool {
        
        return false
    }
    
    var isEnableResignOnTouchOutside: Bool {
        
        return true
    }
    
    var isEnableIQKeyboard: Bool {
        
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isEnableIQKeyboard {
            IQKeyboardManager.shared.enable = false
        } else {
            IQKeyboardManager.shared.enable = true
        }
        
        if !isEnableResignOnTouchOutside {
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        } else {
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    @objc func popToPreviousPage(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func showBlockAlertAction(uid: String) {
        
        let controller = UIAlertController(title: "封鎖該用戶", message: "將看不到該使用者的訊息及揪團" , preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let blockAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            
            UserManager.shared.blockUser(blockUserId: uid)
            
            UserManager.shared.userInfo.blockList?.append(uid)

        }
        
        controller.addAction(cancelAction)
        
        controller.addAction(blockAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
}

extension Notification.Name {
    
    static let userInfoDidChanged = Notification.Name("userInfoDidChanged")
    
    static let requestNumDidChanged = Notification.Name("requestNumDidChanged")
    
}

extension NSNotification {
    
    public static let userInfoDidChanged = Notification.Name.userInfoDidChanged
    
    public static let requestNumDidChanged = Notification.Name.requestNumDidChanged
}
