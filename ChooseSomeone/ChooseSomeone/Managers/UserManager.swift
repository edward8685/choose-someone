//
//  UserManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/3.
//

import UIKit
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

class UserManager {
    
    let userId = Auth.auth().currentUser?.uid
    
    var userInfo = UserInfo()
    
    static let shared = UserManager()
    
    let storage = Storage.storage()
    
    lazy var storageRef = storage.reference()
    
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
    
    func fetchUserInfo(uid: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        print(uid)
        let docRef = dataBase.collection("Users").document(uid)
        
        docRef.getDocument{ (document, error) in
            
            guard let document = document else { return }
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                do {
                    if let userInfo = try document.data(as: UserInfo.self, decoder: Firestore.Decoder()) {
                        
                        self.userInfo = userInfo
                        print(UserManager.shared.userInfo)
                        
                    }
                    
                } catch {
                    
                    completion(.failure(error))
                }
                
                completion(.success(self.userInfo))
            }
            
        }
        
    }
    
    func uploadUserPicture(imageData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        
        let userId = userInfo.uid
        
        let spaceRef = storageRef.child("pictures").child(userId)
        
        spaceRef.putData(imageData, metadata: nil) { result in
            
            switch result {
                
            case .success(_):
                
                spaceRef.downloadURL { result in
                    
                    switch result {
                        
                    case .success(let url):
                        
                        completion(.success(url))
                        
                        self.updateImageToDb(fileURL: url)
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
        
    }
    
    func updateImageToDb(fileURL: URL) {
        
        let userId = userInfo.uid
        
        let docRef = dataBase.collection("Users").document(userId)
        
        userInfo.pictureRef = fileURL.absoluteString
        
        do {
            
            try docRef.setData(from: userInfo)
            
        } catch {
            
            print("error")
            
        }
        
        print("sucessfully")
        
    }
    
    func updateUserName(name: String) {
        
        let userId = userInfo.uid

        let post = [UserInfo.CodingKeys.userName.rawValue: name ]
        
        let docRef = dataBase.collection("Users").document(userId)
        
        docRef.updateData(post) { error in
            
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("User name successfully updated")
            }
        }
    }
}
