//
//  FirebaseManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/19.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupRoomManager {
    
    private var hostId = "1357988"
    
    static let shared = GroupRoomManager()
    
    lazy var dataBase = Firestore.firestore()
    
    func fetchMessages(groupId: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        dataBase.collection("Messages").whereField("group_id", isEqualTo: groupId).addSnapshotListener { (snapshot, error) in
            
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
                messages.sort{ $0.createdTime.seconds < $1.createdTime.seconds }
                
                completion(.success(messages))
            }
        }
    }
    
    func fetchGroups(completion: @escaping (Result<[Group], Error>) -> Void) {
        let collection = dataBase.collection("Groups")
        collection.order(by: "date", descending: false).getDocuments() {(querySnapshot,error) in
            
            guard let querySnapshot = querySnapshot else { return }
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var groups = [Group]()
                
                for document in querySnapshot.documents {
                    
                    do {
                        
                        if let group = try document.data(as: Group.self, decoder: Firestore.Decoder()) {
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
    
    func fetchRequest(completion: @escaping (Result<[Request], Error>) -> Void) {
        
        dataBase.collection("Requests").whereField("host_id", isEqualTo: hostId).addSnapshotListener { (querySnapshot, error) in
            
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
                
                requests.sort{ $0.createdTime.seconds > $1.createdTime.seconds }
                
                completion(.success(requests))
                
            }
        }
    }
    
    func buildTeam(group: inout Group, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection("Groups").document()
        
        group.groupId = document.documentID
        
        do {
            
            try document.setData(from: group)
            
        } catch {
            
            completion(.failure(error))
            
        }
        
        completion(.success("Success"))
    }
    
    func sendMessage(groupId: String, message: Message, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection("Messages").document()
        
        do {
            
            try document.setData(from: message)
            
        } catch {
            
            completion(.failure(error))
        }
        
        completion(.success("Success"))
        
    }
    
    func sendRequest(request: Request, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = dataBase.collection("Requests").document()
        
        do {
            
            try document.setData(from: request)
            
        } catch {
            
            completion(.failure(error))
            
        }
        
        completion(.success("Success"))
        
    }
    
    func addUserToGroup(groupId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        dataBase.collection("Groups")
            .whereField("group_id", isEqualTo: groupId)
            .getDocuments { (querySnapshot, error) in
                
                guard let querySnapshot = querySnapshot else { return }
                
                if let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    for document in querySnapshot.documents {
                        
                        document.reference.updateData([
                            "user_ids": FieldValue.arrayUnion([userId])
                        ])
                        completion(.success("Success"))
                    }
                }
            }
    }
    
    func removeRequest(groupId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        dataBase.collection("Requests")
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
}
