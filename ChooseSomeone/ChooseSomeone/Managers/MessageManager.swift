////
////  MessageManager.swift
////  ChooseSomeone
////
////  Created by Ed Chang on 2021/10/21.
////
//
//import Foundation
//import Firebase
//import FirebaseFirestoreSwift
//
//class MessageManager {
//    
//    static let shared = MessageManager()
//    
//    lazy var db = Firestore.firestore()
//
//    func fetchMessages(groupId: String,completion: @escaping (Result<[Message], Error>) -> Void) {
//        
////        db.collection("Messages").order(by: "created_time", descending: false ).getDocuments() { (querySnapshot, error) in
//        db.collection("Messages").whereField("group_id", isEqualTo: groupId).getDocuments() { (querySnapshot, error) in
//
//            if let error = error {
//                
//                completion(.failure(error))
//            } else {
//                
//                var messages = [Message]()
//                
//                for document in querySnapshot!.documents {
//                    
//                    do {
//                        if let message = try document.data(as: Message.self, decoder: Firestore.Decoder()) {
////                            if message.groupId == groupId {
//                            messages.append(message)
////                            }
//                        }
//                        
//                        
//                    } catch {
//                        
//                        completion(.failure(error))
//                    }
//                }
//                messages.sort{$0.createdTime.seconds < $1.createdTime.seconds}
//                completion(.success(messages))
//            }
//        }
//    }
//    
//    func sendRequest(groupId: String,hostId: String, request: Request, completion: @escaping (Result<String, Error>) -> Void) {
//        
//        let document = db.collection("Requests").document()
//        document.setData(request.toDict) { error in
//            
//            if let error = error {
//                
//                completion(.failure(error))
//            } else {
//
//                completion(.success("Success"))
//            }
//        }
//    }
//}
//
