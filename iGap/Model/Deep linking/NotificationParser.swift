//
//  NotificationParser.swift
//  iGap
//
//  Created by MacBook Pro on 6/25/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class NotificationParser {
    static let shared = NotificationParser()
    private init() { }
    
    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeeplinkType? {
        
        if let deepLink = userInfo["deepLink"] as? String {
            // handle notification deep link
            
            
        } else if let roomID = userInfo["roomId"] as? String {
            let roomStrAsNSString = roomID as NSString
            let roomIdInt64 = roomStrAsNSString.longLongValue
            if let messageID = userInfo["messageId"] as? String {
                let messageStrAsNSString = messageID as NSString
                let messageIdInt64 = messageStrAsNSString.longLongValue
                return DeeplinkType.chatRoom(.roomId(Id: roomIdInt64, messageId: messageIdInt64))
            } else {
                return DeeplinkType.chatRoom(.roomId(Id: roomIdInt64, messageId: nil))
            }
        }
        
//        if let data = userInfo["data"] as? [String: Any] {
//            if let messageId = data["messageId"] as? String {
//                return DeeplinkType.messages(.details(id: messageId))
//            }
//        }
        return nil
    }
}
