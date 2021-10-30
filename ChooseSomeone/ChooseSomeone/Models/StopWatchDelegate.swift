//
//  StopWatchDelegate.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/27.
//

import Foundation

protocol StopWatchDelegate: AnyObject {
    
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
