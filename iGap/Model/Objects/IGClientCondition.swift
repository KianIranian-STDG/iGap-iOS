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

class IGClientCondition {
    
    class IGCCRoom {
        struct IGOfflineEdited {
            var messageId: Int64 = -1
            var message: String?
        }
        struct IGOfflineDeleted {
            var offlineDelete: Int64 = -1
            var both: Bool = false
        }
        struct IGOfflineListen {
            var offlineListen: Int64 = -1
        }
        enum OfflineMute {
            case unchanged
            case muted
            case unmuted
        }
        
        var id: Int64 = -1
        var messageVersion: Int64 = 0 //The biggest message version available in the room
        var statusVersion: Int64 = 0  //The biggest message status available in the room
        var deleteVersion: Int64 = 0  //The biggest delete version available in the room
        var offlineEdited = [IGOfflineEdited]() // TODO - not managed yet
        var offlineDeleted = [IGOfflineDeleted]() // TODO - not managed yet
        var offlineSeen = [Int64]()
        var offlineListen = [IGOfflineListen]() // TODO - not managed yet
        var clearId: Int64 = 0
        var cacheStartId: Int64 = 0
        var cacheEndId: Int64 = 0
        var offlineMute: OfflineMute = .unchanged
    }
    
    
    internal static func computeClientCondition() -> [IGPClientCondition.IGPRoom] {
        var clientConditionRooms = [IGPClientCondition.IGPRoom]()
        let realm = try! Realm()
        let rooms = realm.objects(IGRoom.self).filter("isParticipant = 1")
        
        for room in rooms {
            let predicateCondition = NSPredicate(format: "roomId = %lld", room.id)
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND statusRaw != %d AND statusRaw != %d", room.id, IGRoomMessageStatus.failed.rawValue, IGRoomMessageStatus.sending.rawValue)
            let messages = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(byKeyPath: "creationTime")
            
            var clientConditionRequest = IGPClientCondition.IGPRoom()
            
            clientConditionRequest.igpRoomID = room.id
            //Hint: currently we don't set igpMessageVersion because we don't want get unread message after each login without open chat room
            /*
             if let maxMessageVersion: Int64 = messages.max(ofProperty: "messageVersion") {
             clientConditionRequest.igpMessageVersion = max(0,maxMessageVersion)
             }
             */
            clientConditionRequest.igpMessageVersion = 0
            
            if let maxStatusVersion: Int64 = messages.max(ofProperty: "statusVersion") {
                clientConditionRequest.igpStatusVersion = max(0,maxStatusVersion)
            }
            if let maxDeleteVersion: Int64 = messages.max(ofProperty: "deleteVersion") {
                clientConditionRequest.igpDeleteVersion = max(0,maxDeleteVersion)
            }
            if let firstMessage = messages.first {
                clientConditionRequest.igpCacheStartID = max(0,firstMessage.id)
            }
            if let lastMessage = messages.last {
                clientConditionRequest.igpCacheEndID = max(0,lastMessage.id)
            }
            clientConditionRequest.igpClearID = room.clearId
            
            for offlineSeen in try! Realm().objects(IGRealmOfflineSeen.self).filter(predicateCondition) {
                clientConditionRequest.igpOfflineSeen.append(offlineSeen.messageId)
            }
            
            clientConditionRooms.append(clientConditionRequest)
        }
        
        return clientConditionRooms
    }
}
