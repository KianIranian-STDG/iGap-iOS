//
//  ShortcutManager.swift
//  iGap
//
//  Created by MacBook Pro on 6/25/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import RealmSwift

class ShortcutParser {
    static let shared = ShortcutParser()
    private init() { }
    
    func registerShortcuts() {
        let dashboardIcon = UIApplicationShortcutIcon(templateImageName: "Location_Marker")
        let dashboardShortcutItem = UIApplicationShortcutItem(type: ShortcutKey.discovery.rawValue, localizedTitle: "discovery", localizedSubtitle: nil, icon: dashboardIcon, userInfo: nil)
        let messageIcon = UIApplicationShortcutIcon(templateImageName: "Location_Marker")
        let messageShortcutItem = UIApplicationShortcutItem(type: ShortcutKey.messages.rawValue, localizedTitle: "Messages", localizedSubtitle: nil, icon: messageIcon, userInfo: nil)
        UIApplication.shared.shortcutItems = [dashboardShortcutItem, messageShortcutItem]
        
        let newListingIcon = UIApplicationShortcutIcon(templateImageName: "Location_Marker")
        let newListingShortcutItem = UIApplicationShortcutItem(type: ShortcutKey.chatroom.rawValue, localizedTitle: "Chat room", localizedSubtitle: nil, icon: newListingIcon, userInfo: [:])
        UIApplication.shared.shortcutItems?.append(newListingShortcutItem)
    }
    
    func handleShortcut(_ shortcut: UIApplicationShortcutItem) -> DeeplinkType? {
        switch shortcut.type {
        case ShortcutKey.discovery.rawValue:
            return .discovery(pathes: [])
        case ShortcutKey.messages.rawValue:
            return .messages(.root)
        case ShortcutKey.chatroom.rawValue:
            guard let roomId = shortcut.userInfo?["roomId"] else {  return nil }
            let predicate = NSPredicate(format: "channelRoom.publicExtra.username = %@", roomId as! CVarArg)
            if let room = try? Realm().objects(IGRoom.self).filter(predicate).first {
                return .chatRoom(room: room, messageId: nil)
            } else {
                return nil
            }
            
        default:
            return nil
        }
    }
}

enum ShortcutKey: String {
    case discovery = "msg.iGap.discovery"
    case messages = "msg.iGap.messages"
    case chatroom = "msg.iGap.chatroom"
}
