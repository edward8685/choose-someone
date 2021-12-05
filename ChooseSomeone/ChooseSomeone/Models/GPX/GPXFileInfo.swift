//
//  GPXFileInfo.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/29.
//

import Foundation

class GPXFileInfo: NSObject {

    var fileURL: URL = URL(fileURLWithPath: "")
    // swiftlint:disable force_try
    var modifiedDate: Date {
        
        return try! fileURL.resourceValues(
            forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
    }
    
    var fileName: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
}
