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
    
    static let shared = GroupRoomManager()
    
    lazy var db = Firestore.firestore()
    
    func fetchMessages(completion: @escaping (Result<[Message], Error>) -> Void) {
        
        db.collection("Messages").order(by: "created_time", descending: false ).getDocuments() { (querySnapshot, error) in
            
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    var messages = [Message]()
                    
                    for document in querySnapshot!.documents {

                        do {
                            if let message = try document.data(as: Message.self, decoder: Firestore.Decoder()) {
                                messages.append(message)
                            }
                            completion(.success(messages))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    
                }
        }
    }
    
    func buildTeam(group: inout Group, completion: @escaping (Result<String, Error>) -> Void) {
        
        let document = db.collection("Groups").document()
        group.groupId = document.documentID
        document.setData(group.toDict) { error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                completion(.success("Success"))
            }
        }
    }
    func fetchGroups(completion: @escaping (Result<[Group], Error>) -> Void) {
        
        db.collection("Groups").order(by: "date", descending: false ).getDocuments() { (querySnapshot, error) in
            
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    var groups = [Group]()
                    
                    for document in querySnapshot!.documents {

                        do {
                            if let group = try document.data(as: Group.self, decoder: Firestore.Decoder()) {
                                groups.append(group)
                            }
                            completion(.success(groups))
                            
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    
                }
        }
    }
}


