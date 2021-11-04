//
//  UserManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/3.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

class UserManager {
    
    let userId = Auth.auth().currentUser?.uid
    
    var userInfo = UserInfo()
    
    static let shared = UserManager()
    
    lazy var dataBase = Firestore.firestore()
    
    func signUpUserInfo(userInfo: UserInfo, completion: @escaping (Result<String, Error>) -> Void) {
        
        let userId = userInfo.uid
        
        let document = dataBase.collection("Users").document(userId)
        
        do {
            
            try document.setData(from: userInfo)
            
        } catch {
            
            completion(.failure(error))
            
        }
        
        completion(.success("Success"))
        
        
    }
    
    
    func fetchUserInfo(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        if let userId = Auth.auth().currentUser?.uid {
            
            let docRef = dataBase.collection("Users").document(userId)
            
            docRef.getDocument{ (document, error) in
                
                guard let document = document else { return }
                
                if let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    do {
                        if let userInfo = try document.data(as: UserInfo.self, decoder: Firestore.Decoder()) {
                            
                            self.userInfo = userInfo
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                    
                    completion(.success(self.userInfo))
                }
                
            }
            
        }
    }
}
