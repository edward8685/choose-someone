//
//  NotificationExtension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/25.
//

import Foundation

extension Notification.Name {
    
    static let userInfoDidChanged = Notification.Name("userInfoDidChanged")
    
    static let requestNumDidChanged = Notification.Name("requestNumDidChanged")
    
    static let checkGroupDidTaped = Notification.Name("checkGroupDidTaped")
}

extension NSNotification {
    
    public static let userInfoDidChanged = Notification.Name.userInfoDidChanged
    
    public static let requestNumDidChanged = Notification.Name.requestNumDidChanged
    
    public static let checkGroupDidTaped = Notification.Name.checkGroupDidTaped
}
