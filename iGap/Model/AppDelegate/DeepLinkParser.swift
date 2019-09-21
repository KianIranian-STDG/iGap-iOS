//
//  DeepLinkParser.swift
//  iGap
//
//  Created by MacBook Pro on 6/25/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import RealmSwift

class DeepLinkParser {
    static let shared = DeepLinkParser()
    private init() {}
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        
        switch host {
        case "resolve":
            if let roomId = pathComponents.first {
                let RoomID = roomId
                let messageID = pathComponents[1]
                let strAsNSString = messageID as NSString
                let messageIdInt64 = strAsNSString.longLongValue
                let predicate = NSPredicate(format: "channelRoom.publicExtra.username = %@", RoomID)
                if let room = try! Realm().objects(IGRoom.self).filter(predicate).first {
                    return DeeplinkType.chatRoom(room: room, messageId: messageIdInt64)
                }
            }
        case "dashboard":
            if let requestId = pathComponents.first {
                return DeeplinkType.request(id: requestId)
            }
        case "messages":
            if let messageId = pathComponents.first {
                return DeeplinkType.messages(.details(id: messageId))
            }
        case "payment-result":
            guard let queryItems = components.queryItems else { return nil }
            let message = self.getParameter(from: queryItems, param: "message") ?? ""
            let status = PaymentStatus(rawValue: self.getParameter(from: queryItems, param: "status") ?? PaymentStatus.failure.rawValue) ?? PaymentStatus.failure
            let orderId = self.getParameter(from: queryItems, param: "order_id") ?? ""
            return DeeplinkType.payment(message: message, status: status, orderId: orderId)
        default:
            break
        }
        return nil
    }
    
    func getParameter(from queryItems: [URLQueryItem], param: String) -> String? {
        return queryItems.first(where: { $0.name == param })?.value
    }
}
