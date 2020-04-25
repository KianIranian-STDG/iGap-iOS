/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import IGProtoBuff
import RealmSwift


/* Use this class for detect manage promoted user or room(group/channel) */
class IGHelperPromote {
    
    
    /**
     * check type of promoted room and make chat if promote type is user Otherwise get room info and join to room(group/channel)
     **/
    internal static func promoteManager(promoteList: [IGPClientGetPromoteResponse.IGPPromote], position: Int = 0) {
        if position == 0 {
            clearUnPromoteRooms(promoteList: promoteList)
        }
        
        if promoteList.count <= position { // after get all promote list disable premission for avoid from get promote list next time
            IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyAllowFetchPromote, state: false)
            return
        }
        
        let promote = promoteList[position]
        
        if promote.igpType == .user {
            IGHelperPromote.chatGetRoomAndPin(userId: promote.igpID, compeletion: {
                promoteManager(promoteList: promoteList, position: position + 1)
            })
        } else if promote.igpType == .publicRoom {
            IGHelperPromote.getRoomAndPin(roomId: promote.igpID, compeletion: {
                promoteManager(promoteList: promoteList, position: position + 1)
            })
        }
    }
    
    
    
    /**
     * clear unPromote rooms if before was promoted
     **/
    private static func clearUnPromoteRooms(promoteList: [IGPClientGetPromoteResponse.IGPPromote]){
        
        var array1: Array<Int64> = Array()
        var array2: Array<Int64> = Array()
        
        for promote in promoteList {
            array1.append(promote.igpID)
        }
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "isPromote == true")
        for room in realm.objects(IGRoom.self).filter(predicate) {
            if room.type == .chat {
                array2.append((room.chatRoom?.peer?.id)!)
            } else {
                array2.append(room.id)
            }
        }
        
        let differenceRoomId = array1.difference(from: array2)
        for roomId in differenceRoomId {
            IGFactory.shared.clearPromote(roomId: roomId)
        }
    }
    
    
 
    /**
     * make chat room with user and return "IGPChatGetRoomResponse" if "onChatGetRoom" closure is registered
     **/
    private static func chatGetRoomAndPin(userId: Int64, compeletion: @escaping () -> Void) {
        if let room = IGRoom.existRoomInLocal(userId: userId) {
            pinRoom(roomId: room.id)
            IGFactory.shared.promoteRoom(roomId: room.id)
            compeletion()
        } else {
            IGChatGetRoomRequest.Generator.generate(peerId: userId).success ({ (responseProto) in
                if let chatGetRoomResponse = responseProto as? IGPChatGetRoomResponse {
                    let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                    // need more time for insuring about save room info to realm
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        if let room = IGRoom.getRoomInfo(roomId: roomId) {
                            self.pinRoom(roomId: roomId)
                            IGFactory.shared.promoteRoom(roomId: roomId)
                            self.sendMessage(room: room)
                            compeletion()
                        }
                    }
                }
            }).error({ (errorCode, waitTime) in
                compeletion()
            }).send()
        }
    }
    
    
    
    /**
     * get room(group/channel) info with roomId and add info to Realm
     **/
    private static func getRoomAndPin(roomId: Int64, compeletion: @escaping () -> Void) {
        if let room = IGRoom.existRoomInLocal(roomId: roomId) {
            pinRoom(roomId: room.id)
            IGFactory.shared.promoteRoom(roomId: room.id)
            compeletion()
        } else {
            IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                    IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                    joinRoom(room: clientGetRoomResponse.igpRoom, compeletion: compeletion)
                }
            }).error ({ (errorCode, waitTime) in
                compeletion()
                switch errorCode {
                case .timeout:
                    getRoomAndPin(roomId: roomId, compeletion: compeletion)
                default:
                    break
                }
            }).send()
        }
    }
    

    
    private static func pinRoom(roomId: Int64) {
        IGClientPinRoomRequest.Generator.generate(roomId: roomId, pin: true).success({ (protoResponse) in
            if let pinRoomResponse = protoResponse as? IGPClientPinRoomResponse {
                IGClientPinRoomRequest.Handler.interpret(response: pinRoomResponse)
            }
        }).error({ (errorCode , waitTime) in }).send()
    }
    

    
    private static func joinRoom(room: IGPRoom, compeletion: @escaping () -> Void){
        var username: String!
        if room.hasIgpGroupRoomExtra {
            username = room.igpGroupRoomExtra.igpPublicExtra.igpUsername
        } else {
            username = room.igpChannelRoomExtra.igpPublicExtra.igpUsername
        }
        
        IGHelperJoin.getInstance().joinByUsername(username: username, roomId: room.igpID) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.pinRoom(roomId: room.igpID)
                IGFactory.shared.promoteRoom(roomId: room.igpID)
                compeletion()
            }
        }
    }
    
    
    /* after create new chat send message for really creation chat room in server side */
    private static func sendMessage(room: IGRoom){
        let message = IGRoomMessage(body: "/start")
        message.type = .text
        message.roomId = room.id
        let detachedMessage = message.detach()
        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
        IGMessageSender.defaultSender.send(message: message, to: room)
    }
    
    
    
    internal static func isPromotedRoom(room: IGRoom? = nil, roomId: Int64 = 0, userId: Int64 = 0) -> Bool {
        if room != nil {
            return room!.isPromote
        }
        
        var predicate = NSPredicate(format: "id == %lld", roomId)
        if userId != 0 {
            predicate = NSPredicate(format: "chatRoom.peer.id == %lld", userId)
        }
        
        if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
            return room.isPromote
        }
        
        return false
    }
}
