//
//  RecordManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class RecordManager {
    
    private var userId = "1357988"
    
    var record = Record()
    
    let storage = Storage.storage()
    
    static let shared = RecordManager()
    
    lazy var storageRef = storage.reference()
    
    lazy var dataBase = Firestore.firestore()
    
    func uploadRecord(fileName: String, fileURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        
        do {
            let data: Data = try Data(contentsOf: fileURL)
            
            let recordRef = storageRef.child("records")
            
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
                            
                            self.uploadToDb(fileName: fileName, fileURL: url)
                            
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
    
    func uploadToDb(fileName: String, fileURL: URL) {
        
        let document = dataBase.collection("Records").document()
        
        record.uid = userId
        
        record.recordId = document.documentID
        
        record.recordName = fileName
        
        record.recordRef = fileURL
        
        do {
            
            try document.setData(from: record)
            
        } catch {
            
            print("error")
    
        }
        
        print("sucessfully")
        
    }
}
