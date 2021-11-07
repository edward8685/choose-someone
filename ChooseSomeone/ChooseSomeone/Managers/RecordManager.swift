//
//  RecordManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/29.
//

import Foundation
import FirebaseStorage
import FirebaseFirestoreSwift
import FirebaseFirestore

class RecordManager {
    
    let userId = UserManager.shared.userInfo.uid
    
    var record = Record()
    
    let storage = Storage.storage()
    
    static let shared = RecordManager()
    
    lazy var storageRef = storage.reference()
    
    lazy var dataBase = Firestore.firestore()
    
    func uploadRecord(fileName: String, fileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        
        do {
            let data: Data = try Data(contentsOf: fileURL)
 
                let recordRef = storageRef.child("records").child("\(userId)")
                
                //            let filename = fileURL.lastPathComponent
                
                //            let spaceRef = recordRef.child(UUID().uuidString + ".gpx")
                
                let spaceRef = recordRef.child(fileName)
                
                spaceRef.putData(data, metadata: nil) { result in
                    
                    switch result {
                        
                    case .success(_):
                        
                        spaceRef.downloadURL { result in
                            
                            switch result {
                                
                            case .success(let url):
                                
                                completion(.success(url))
                                
                                self.uploadRecordToDb(fileName: fileName, fileURL: url)
                                
                            case .failure(let error):
                                
                                completion(.failure(error))
                            }
                        }
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                    }
                }
            
        } catch {
            
            print("Unable to load data")
            
        }
        
    }
    
    func uploadRecordToDb(fileName: String, fileURL: URL) {
        
        let document = dataBase.collection("Records").document()
        
            record.uid = userId
        
        record.recordId = document.documentID
        
        record.recordName = fileName
        
        record.recordRef = fileURL.absoluteString
        
        do {
            
            try document.setData(from: record)
            
        } catch {
            
            print("error")
            
        }
        
        print("sucessfully")
        
    }
    
    func fetchRecords(completion: @escaping (Result<[Record], Error>) -> Void) {
        let collection = dataBase.collection("Records").whereField("uid", isEqualTo: userId)
        collection.getDocuments() {(querySnapshot, error) in
            
            guard let querySnapshot = querySnapshot else { return }
            
            if let error = error {
                
                completion(.failure(error))
                
            } else {
                
                var records = [Record]()
                
                for document in querySnapshot.documents {
                    
                    do {
                        
                        if let record = try document.data(as: Record.self, decoder: Firestore.Decoder()) {
                            
                            records.append(record)
                            
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                records.sort{ $0.createdTime.seconds < $1.createdTime.seconds }
                
                completion(.success(records))
            }
        }
    }
}
