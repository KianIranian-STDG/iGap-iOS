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
            guard let queryItems = components.queryItems else { return nil }
            if let userName = self.getParameter(from: queryItems, param: "domain") {
                if let messageID = self.getParameter(from: queryItems, param: "messageId") {
                    let strAsNSString = messageID as NSString
                    let messageIdInt64 = strAsNSString.longLongValue
                    return DeeplinkType.chatRoom(username: userName, messageId: messageIdInt64)
                } else {
                    return DeeplinkType.chatRoom(username: userName, messageId: nil)
                }
            } else {
                return DeeplinkType.chatRoom(username: nil, messageId: nil)
            }
            
        case "discovery":
            return DeeplinkType.discovery(pathes: pathComponents)
            
        case "contact":
            return DeeplinkType.contact
            
        case "profile":
            return DeeplinkType.profile
            
        case "call":
            return DeeplinkType.call
            
        case "chat":
            if let userName = pathComponents.first {
                if let messageID = pathComponents.last {
                    let strAsNSString = messageID as NSString
                    let messageIdInt64 = strAsNSString.longLongValue
                    return DeeplinkType.chatRoom(username: userName, messageId: messageIdInt64)
                } else {
                    return DeeplinkType.chatRoom(username: userName, messageId: nil)
                }
            } else {
                return DeeplinkType.chatRoom(username: nil, messageId: nil)
            }
            
        case "favoritechannel":
            return DeeplinkType.favouriteChannel(token: pathComponents.first)
            
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
