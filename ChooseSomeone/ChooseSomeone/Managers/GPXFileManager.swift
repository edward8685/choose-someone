//
//  GPXFileManager.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/29.
//

import CoreGPX

let kFileExt = ["gpx", "GPX"]

class GPXFileManager {
    
    class var GPXFilesFolderURL: URL {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsUrl
    }
    
    class func URLForFilename(_ filename: String) -> URL {
        
        var fullURL = self.GPXFilesFolderURL.appendingPathComponent(filename)
//        if  !(kFileExt.contains(fullURL.pathExtension)) {
            fullURL = fullURL.appendingPathExtension("gpx")
//        }
        return fullURL
    }
    
    class func saveToURL(fileURL: URL, gpxContents: String) {

        var writeError: NSError?
        
        let saved: Bool
        
        do {
            
            try gpxContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            saved = true
            
        } catch let error as NSError {
            
            writeError = error
            saved = false
            
        }
        if !saved {
            
            if let error = writeError {
                print("\(error.localizedDescription)")
                
            }
        }

    }
    
    class func save(filename: String, gpxContents: String) {
        
        let fileURL: URL = self.URLForFilename(filename)
        
        GPXFileManager.saveToURL(fileURL: fileURL, gpxContents: gpxContents)
        
        RecordManager.shared.uploadRecord(fileName: filename, fileURL: fileURL) { result in
            
            switch result {
                
            case .success:
                
                print("save to Firebase successfully")
                
            case .failure(let error):
                
                print("save to Firebase failure: \(error)")
            }
        }
    }
}
