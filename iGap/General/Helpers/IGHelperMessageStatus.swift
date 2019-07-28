/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift

class IGHelperMessageStatus {
    
    static let shared = IGHelperMessageStatus()
    
    public func sendSeen(roomId: Int64, realmRoomMessages: [IGRoomMessage]) {
        if let roomType = IGRoom.getTypeWithId(roomId: roomId) {
            IGFactory.shared.markAllMessagesAsRead(roomId: roomId)
            realmRoomMessages.forEach{
                if let authorHash = $0.authorHash {
                    if authorHash != IGAppManager.sharedManager.authorHash() {
                        self.sendSeenForMessage(roomId: roomId, roomType: roomType, $0)
                    }
                }
            }
        }
    }
    
    private func sendSeenForMessage(roomId: Int64, roomType: IGRoom.IGType ,_ message: IGRoomMessage) {
        if message.status == .seen || message.status == .listened {
            return
        }
        switch roomType {
        case .chat:
            if IGRecentsTableViewController.visibleChat[roomId]! {
                IGChatUpdateStatusRequest.Generator.generate(roomID: roomId, messageID: message.id, status: .seen).success({ (responseProto) in
                    switch responseProto {
                    case let response as IGPChatUpdateStatusResponse:
                        IGChatUpdateStatusRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
        case .group:
            if IGRecentsTableViewController.visibleChat[roomId]! {
                IGGroupUpdateStatusRequest.Generator.generate(roomID: roomId, messageID: message.id, status: .seen).success({ (responseProto) in
                    switch responseProto {
                    case let response as IGPGroupUpdateStatusResponse:
                        IGGroupUpdateStatusRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
            break
        case .channel:
            /*
             if IGRecentsTableViewController.visibleChat[(room?.id)!]! {
             if let message = self.messages?.last {
             IGChannelGetMessagesStatsRequest.Generator.generate(messages: [message], room: self.room!).success({ (responseProto) in
             
             }).error({ (errorCode, waitTime) in
             
             }).send()
             }
             }
             */
            break
        }
    }
}
