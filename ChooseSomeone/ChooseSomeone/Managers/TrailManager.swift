//
//  TrailManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class TrailManager {
    
    static let shared = TrailManager()
    
    lazy var dataBase = Firestore.firestore()
    
    private let trailsCollection = Collection.trails.rawValue
    
    func fetchTrails(completion: @escaping (Result<[Trail], Error>) -> Void) {
        
        let collection = dataBase.collection(trailsCollection)
        collection.getDocuments { (querySnapshot, error) in
            
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
    
    func fetchTrailMap(tralId: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        let fileReference = Storage.storage().reference().child("maps/\(tralId)_MAP.jpg")
        
        fileReference.getData(maxSize: 10 * 1024 * 1024) { result in
            
            switch result {
                
            case .success(let data):
                
                if let image = UIImage(data: data) {
                
                completion(.success(image))
                
                }
                
            case .failure(let error):
                
                print(error)
                completion(.failure(error))
            }
        }
    }
}
