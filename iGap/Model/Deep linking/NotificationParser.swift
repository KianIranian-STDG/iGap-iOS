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
        
        if let data = userInfo["data"] as? [String: Any] {
            if let messageId = data["messageId"] as? String {
                return DeeplinkType.messages(.details(id: messageId))
            }
        }
        return nil
    }
}
