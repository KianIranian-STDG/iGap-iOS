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
    
    public func sendStatus(roomId: Int64, roomType: IGRoom.IGType? = nil, status: IGRoomMessageStatus, realmRoomMessages: [IGRoomMessage]) {
        var type = roomType
        if type == nil {
            type = IGRoom.getTypeWithId(roomId: roomId)
        }
        
        if type != nil {
            realmRoomMessages.forEach {
                self.sendStatusMessage(roomId: roomId, roomType: type!, status: status, message: $0)
            }
        }
    }
    
    //hint: don't send same status
    private func sendStatusMessage(roomId: Int64, roomType: IGRoom.IGType, status: IGRoomMessageStatus, message: IGRoomMessage) {
        
        if roomType == .channel { // channel messages doesn't have status
            return
        }

        if message.authorHash == IGAppManager.sharedManager.authorHash() { // shouldn't be send status for mine message
            return
        }
        
        if status == message.status { // don't send same status
            return
        }
        
        if status.hashValue <= message.status.hashValue { // don't send a status with lower level. e.g. when status is 'seen' don't send 'delivered'
            return
        }
        
        if status == .seen {
            IGFactory.shared.updateMessageStatus(primaryKeyId: message.primaryKeyId!, status: status)
            IGFactory.shared.addOfflineSeen(roomId: roomId, messageId: message.id)
        }
        
        switch roomType {
        case .chat:
            IGChatUpdateStatusRequest.Generator.generate(roomID: roomId, messageID: message.id, status: status).success({ (responseProto) in
                if let response = responseProto as? IGPChatUpdateStatusResponse {
                    IGChatUpdateStatusRequest.Handler.interpret(response: response)
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
            break
            
        case .group:
            IGGroupUpdateStatusRequest.Generator.generate(roomID: roomId, messageID: message.id, status: status).success({ (responseProto) in
                if let response = responseProto as? IGPGroupUpdateStatusResponse {
                    IGGroupUpdateStatusRequest.Handler.interpret(response: response)
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
            break
            
        case .channel:
            break
        }
    }
}
