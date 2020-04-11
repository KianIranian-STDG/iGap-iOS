/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

/**
 * for manage members in channel & group
 */
class IGRealmRoomAccess: Object {

    @objc dynamic var id: String? // roomId_userId
    @objc dynamic var modifyRoom: Bool = false
    @objc dynamic var postMessage: Bool = false
    @objc dynamic var editMessage: Bool = false
    @objc dynamic var deleteMessage: Bool = false
    @objc dynamic var pinMessage: Bool = false
    @objc dynamic var addMember: Bool = false
    @objc dynamic var banMember: Bool = false
    @objc dynamic var getMember: Bool = false
    @objc dynamic var addAdmin: Bool = false

    override static func primaryKey() -> String {
        return "id"
    }
    
    private static func makeId(_ roomId: Int64, _ userId: Int64) -> String {
        return String(describing: roomId) + "_" + String(describing: userId)
    }
    
    public static func getRoomAccess(roomId: Int64, userId: Int64) -> IGRealmRoomAccess? {
        let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
        return IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first
    }
    
    public static func putOrUpdateNoTransaction(roomId: Int64, userId: Int64, roomAccess: IGPRoomAccess) {
        let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
        var realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first
        if realmRoomAccess == nil {
            realmRoomAccess = IGRealmRoomAccess()
            realmRoomAccess?.id = makeId(roomId, userId)
        }
        realmRoomAccess?.modifyRoom = roomAccess.igpModifyRoom
        realmRoomAccess?.postMessage = roomAccess.igpPostMessage
        realmRoomAccess?.editMessage = roomAccess.igpEditMessage
        realmRoomAccess?.deleteMessage = roomAccess.igpDeleteMessage
        realmRoomAccess?.pinMessage = roomAccess.igpPinMessage
        realmRoomAccess?.addMember = roomAccess.igpAddMember
        realmRoomAccess?.banMember = roomAccess.igpBanMember
        realmRoomAccess?.getMember = roomAccess.igpGetMember
        realmRoomAccess?.addAdmin = roomAccess.igpAddAdmin
        
        IGDatabaseManager.shared.realm.add(realmRoomAccess!)
    }
    
    public static func putOrUpdate(roomId: Int64, userId: Int64, roomAccess: IGPRoomAccess) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                putOrUpdateNoTransaction(roomId: roomId, userId: userId, roomAccess: roomAccess)
            }
        }
    }
    
    
    public static func clearRoomAccess(roomId: Int64, userId: Int64){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
                if let realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first {
                    IGDatabaseManager.shared.realm.delete(realmRoomAccess)
                }
            }
        }
    }
    
    
    func convertRealmToProto() -> IGPRoomAccess? {
        
        let predicate = NSPredicate(format: "id = %@", id!)
        if let realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first {
            var roomAccess = IGPRoomAccess()
            roomAccess.igpModifyRoom = realmRoomAccess.modifyRoom
            roomAccess.igpPostMessage = realmRoomAccess.postMessage
            roomAccess.igpEditMessage = realmRoomAccess.editMessage
            roomAccess.igpDeleteMessage = realmRoomAccess.deleteMessage
            roomAccess.igpPinMessage = realmRoomAccess.pinMessage
            roomAccess.igpAddMember = realmRoomAccess.addMember
            roomAccess.igpBanMember = realmRoomAccess.banMember
            roomAccess.igpGetMember = realmRoomAccess.getMember
            roomAccess.igpAddAdmin = realmRoomAccess.addAdmin
            return roomAccess
        }
        
        return nil
    }
}

