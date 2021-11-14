//
//  SceneDelegate.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/18.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if Auth.auth().currentUser != nil {
            
            if let uid = Auth.auth().currentUser?.uid {
                
                print("----------Current User ID: \(uid)----------")
                
                UserManager.shared.fetchUserInfo(uid: uid) { result in
                    
                    switch result {
                        
                    case .success(let userInfo):
                        
                        UserManager.shared.userInfo = userInfo
                        
                        guard let tabbarVC = UIStoryboard.main.instantiateViewController(identifier: "TabbarController") as? UITabBarController else { return }
                        
                        self.window?.rootViewController = tabbarVC
                        
                        print("Fetch user info successfully")
                        
                    case .failure(let error):
                        
                        print("Fetch user info failure: \(error)")
                    }
                }
                
            }
            
        } else {
            
            guard let loginVC = UIStoryboard.login.instantiateViewController(identifier:LoginViewController.identifier) as? LoginViewController else { return }
            
            self.window?.rootViewController = loginVC
            
        }
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {

    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {

    }
    
    func sceneWillResignActive(_ scene: UIScene) {

    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
