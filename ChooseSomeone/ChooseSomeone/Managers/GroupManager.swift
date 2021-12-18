//
//  FirebaseManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

class GroupManager {

    var userId: String { UserManager.shared.userInfo.uid }
    
    static let shared = GroupManager()
    
    private init() { }
    
    lazy var dataBase = Firestore.firestore()
    
    private let groupsCollection = Collection.groups.rawValue
    
    private let requestsCollection = Collection.requests.rawValue
    
    private let messagesCollection = Collection.messages.rawValue
    
    func addSnapshotListener(groupId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        dataBase.collection(messagesCollection)
            .whereField("group_id", isEqualTo: groupId)
            .addSnapshotListener { (snapshot, error) in
                
                if let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    var messages = [Message]()
                    
                    for document in snapshot!.documents {
                        
                        do {
                            if let message = try document.data(as: Message.self, decoder: Firestore.Decoder()) {
                                
                                messages.append(message)
                            }
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    messages.sort { $0.createdTime.seconds < $1.createdTime.seconds }
                    
                    completion(.success(messages))
                }
            }
    }
    
    func fetchMessages(groupId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        let collection = dataBase.collection(messagesCollection)
        
        collection.getDocuments { (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else { return }
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var messages = [Message]()
                
                for document in querySnapshot.documents {
                    
                    do {
                        
                        if let message = try document.data(as: Message.self, decoder: Firestore.Decoder()) {
                            messages.append(message)
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(messages))
            }
        }
    }
    
    func fetchGroups(completion: @escaping (Result<[Group], Error>) -> Void) {
        
        let collection = dataBase.collection(groupsCollection)
        
        collection.order(by: "date", descending: false).getDocuments { (querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else { return }
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var groups = [Group]()
                
                for document in querySnapshot.documents {
                    
                    do {
                        
                        if var group = try document.data(as: Group.self, decoder: Firestore.Decoder()) {
                            
                            if group.date.checkIsExpired() { //
                                
                                group.isExpired = true
                                
                            } else {
                                
                                group.isExpired = false
                            }
                            
                            groups.append(group)
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(groups))
            }
        }
    }
    
    func addRequestListener(completion: @escaping (Result<[Request], Error>) -> Void) {
        
        dataBase.collection(requestsCollection)
            .whereField("host_id", isEqualTo: userId)
            .addSnapshotListener { (querySnapshot, error) in
                
                guard let querySnapshot = querySnapshot else { return }
                
                if let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    var requests = [Request]()
                    
                    for document in querySnapshot.documents {
                        
                        do {
                            
                            if let request = try document.data(as: Request.self, decoder: Firestore.Decoder()) {
                                
                                requests.append(request)
                            }
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    
                    requests.sort { $0.createdTime.seconds > $1.createdTime.seconds }
                    
                    completion(.success(requests))
                }
            }
    }
    
    func buildTeam(group: inout Group, completion: (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(groupsCollection).document()
        
        group.groupId = document.documentID
        
        do {
            
            try document.setData(from: group)
            
        } catch {
            
            completion(.failure(error))
            
        }
        
        completion(.success("Success"))
    }
    
    func updateTeam(group: Group, completion: (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(groupsCollection).document(group.groupId)
        
        do {
            
            try document.setData(from: group)
            
        } catch {
            
            completion(.failure(error))
            
        }
        
        completion(.success("Success"))
    }
    
    func sendMessage(groupId: String, message: Message, completion: (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(messagesCollection).document()
        
        do {
            
            try document.setData(from: message)
            
        } catch {
            
            completion(.failure(error))
        }
        
        completion(.success("Success"))
        
    }
    
    func sendRequest(request: Request, completion: (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection(requestsCollection).document()
        
        do {
            
            try document.setData(from: request)
            
        } catch {
            
            completion(.failure(error))
        }
        
        completion(.success("Success"))
    }
    
    func addUserToGroup(groupId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let docRef = dataBase.collection(groupsCollection).document(groupId)
        
        docRef.updateData([
            "user_ids": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                
                print("Error updating document: \(error)")
                
                completion(.failure(error))
                
            } else {
                
                print("User leave group successfully")
                
                completion(.success("Success"))
            }
        }
    }
    
    func removeRequest(groupId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        dataBase.collection(requestsCollection)
            .whereField("group_id", isEqualTo: groupId)
            .whereField("request_id", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                
                guard let querySnapshot = querySnapshot else { return }
                
                if let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    for document in querySnapshot.documents {
                        
                        document.reference.delete()
                        
                        completion(.success("Success"))
                    }
                }
            }
    }
    
    func leaveGroup(groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let docRef = dataBase.collection(groupsCollection).document(groupId)
        
        docRef.updateData([
            "user_ids": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                
                print("Error updating document: \(error)")
                
            } else {
                
                print("User leave group successfully")
            }
        }
    }
}
