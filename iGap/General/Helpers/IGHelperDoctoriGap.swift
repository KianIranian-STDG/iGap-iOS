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

class IGHelperDoctoriGap {

    internal static let DOCTOR_IGAP_ID : Int64 = 2297310
    private static let doctoriGapRoom = "DOCTOR_IGAP"
    
    /* check that is need create doctor iGap room or no. if is needed then create room and set pin true */
    internal static func doctoriGapCreator(){
        
        if !isExistDoctoriGap() {
            if !IGHelperPreferences.readBoolean(key: doctoriGapRoom) {
                IGChatGetRoomRequest.Generator.generate(peerId: Int64(DOCTOR_IGAP_ID)).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                            let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                            let room = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                            pinRoom(room: room)
                            let message = IGRoomMessage(body: "/start")
                            message.type = .text
                            message.roomId = roomId
                            let detachedMessage = message.detach()
                            IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                            IGMessageSender.defaultSender.send(message: message, to: room)
                        }
                    }
                    
                }).error({ (errorCode, waitTime) in
                    switch errorCode {
                    case .timeout:
                        IGHelperDoctoriGap.doctoriGapCreator()
                    default:
                        break
                    }
                }).send()
            }
        }
    }
    
    internal static func isDoctoriGapRoom(room: IGRoom) -> Bool {
        if let chatRoom = room.chatRoom {
            if let user = chatRoom.peer {
                if user.id == DOCTOR_IGAP_ID {
                    return true
                }
            }
        }
        return false
    }
    
    internal static func isDoctoriGapUser(userId: Int64) -> Bool {
        return userId == DOCTOR_IGAP_ID
    }
    
    private static func isExistDoctoriGap() -> Bool{
        if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "chatRoom.peer.id = %lld AND isParticipant == true" ,DOCTOR_IGAP_ID)).first {
            pinRoom(room: room)
            return true
        }
        return false
    }
    
    private static func pinRoom(room: IGRoom) {
        IGClientPinRoomRequest.Generator.generate(roomId: room.id, pin: true).success({ (protoResponse) in
            if let pinRoomResponse = protoResponse as? IGPClientPinRoomResponse {
                IGClientPinRoomRequest.Handler.interpret(response: pinRoomResponse)
            }
        }).error({ (errorCode , waitTime) in
            switch errorCode {
            case .timeout:
                IGHelperDoctoriGap.pinRoom(room: room)
            default:
                break
            }
        }).send()
    }
    
}
