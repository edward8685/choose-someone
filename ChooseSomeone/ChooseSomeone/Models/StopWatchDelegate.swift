//
//  StopWatchDelegate.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//

import Foundation

protocol StopWatchDelegate: AnyObject {
    
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
