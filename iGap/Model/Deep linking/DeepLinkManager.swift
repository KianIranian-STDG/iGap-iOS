//
//  DeepLinkManager.swift
//  iGap
//
//  Created by MacBook Pro on 6/25/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

enum DeeplinkType {
    enum Messages {
        case root
        case details(id: String)
    }
    case messages(Messages)
    case payment(message: String, status: PaymentStatus, orderId: String)
    case discovery(pathes: [String])
//    case dashboard
    case chatRoom(room: IGRoom, messageId: Int64?)
//    case request(id: String)
}

class DeepLinkManager {
    
    static let shared = DeepLinkManager()
    
    fileprivate init() {}
    
    private var deeplinkType: DeeplinkType?
    
    // check existing deepling and perform action
    func checkDeepLink() {
        guard let deeplinkType = deeplinkType else {
            return
        }
        
        DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
        // reset deeplink after handling
        self.deeplinkType = nil // (1)
    }
    
    @discardableResult
    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        deeplinkType = ShortcutParser.shared.handleShortcut(item)
        return deeplinkType != nil
    }
    
    @discardableResult
    func handleDeeplink(url: URL) -> Bool {
        deeplinkType = DeepLinkParser.shared.parseDeepLink(url)
        return deeplinkType != nil
    }
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deeplinkType = NotificationParser.shared.handleNotification(notification)
    }
}
