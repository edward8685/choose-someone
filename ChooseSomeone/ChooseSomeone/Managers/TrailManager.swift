//
//  TrailManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TrailManager {
    
    static let shared = TrailManager()
    
    lazy var dataBase = Firestore.firestore()
    
    func fetchTrails(completion: @escaping (Result<[Trail], Error>) -> Void) {
        let collection = dataBase.collection("Trails")
        collection.getDocuments() {(querySnapshot,error) in
            
            guard let querySnapshot = querySnapshot else { return }
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var trails = [Trail]()
                
                for document in querySnapshot.documents {
                    
                    do {
                        
                        if let trail = try document.data(as: Trail.self, decoder: Firestore.Decoder()) {
                            trails.append(trail)
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(trails))
            }
        }
    }
}
