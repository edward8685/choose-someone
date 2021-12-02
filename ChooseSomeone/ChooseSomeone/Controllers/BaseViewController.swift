//
//  ViewControllerExtenstion.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/11.
//

import UIKit
import IQKeyboardManagerSwift

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    static var identifier: String {
        
        return String(describing: self)
    }
    
    var isHideNavigationBar: Bool {
        
        return false
    }
    
    var isEnableIQKeyboard: Bool {
        
        return true
    }
    
    override func viewDidLoad() {
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        if !isEnableIQKeyboard {
            
            IQKeyboardManager.shared.enable = false
            
        } else {
            
            IQKeyboardManager.shared.enable = true
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isHideNavigationBar {
            
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        if !isEnableIQKeyboard {
            
            IQKeyboardManager.shared.enable = false
            
        } else {
            
            IQKeyboardManager.shared.enable = true
        }
    }
    
    @objc func popToPreviousPage(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissVC() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func showBlockAlertAction(uid: String) {
        
        let controller = UIAlertController(title: "封鎖用戶", message: "您將無法看見該用戶的訊息及揪團", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let blockAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
            
            UserManager.shared.blockUser(blockUserId: uid)
            
            UserManager.shared.userInfo.blockList?.append(uid)
        }
        
        controller.addAction(cancelAction)
        
        controller.addAction(blockAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func showAlertAction(title: String, message: String? = "") {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func setNavigationBar(title: String) {
        
        self.title = "\(title)"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let leftButton = PreviousPageButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        let image = UIImage(systemName: "chevron.left")
        
        leftButton.setImage(image, for: .normal)
        
        leftButton.addTarget(self, action: #selector(popToPreviousPage), for: .touchUpInside)
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: leftButton), animated: true)
    }
}
