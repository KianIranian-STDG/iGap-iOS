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
    @objc dynamic var postMessageRights: IGRealmPostMessageRights!
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
    
    public static func getRoomAccess(roomId: Int64, userId: Int64 = 0) -> IGRealmRoomAccess? {
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
        realmRoomAccess?.editMessage = roomAccess.igpEditMessage
        realmRoomAccess?.deleteMessage = roomAccess.igpDeleteMessage
        realmRoomAccess?.pinMessage = roomAccess.igpPinMessage
        realmRoomAccess?.addMember = roomAccess.igpAddMember
        realmRoomAccess?.banMember = roomAccess.igpBanMember
        realmRoomAccess?.getMember = roomAccess.igpGetMember
        realmRoomAccess?.addAdmin = roomAccess.igpAddAdmin
        realmRoomAccess?.postMessageRights = IGRealmPostMessageRights(roomAccess.igpPostMessage)
        
        IGDatabaseManager.shared.realm.add(realmRoomAccess!, update: .modified)
    }
    
    public static func putOrUpdateNoTransaction(roomId: Int64, userId: Int64, adminRights: IGPChannelAddAdmin.IGPAdminRights) {
        let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
        var realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first
        if realmRoomAccess == nil {
            realmRoomAccess = IGRealmRoomAccess()
            realmRoomAccess?.id = makeId(roomId, userId)
        }
        realmRoomAccess?.modifyRoom = adminRights.igpModifyRoom
        realmRoomAccess?.editMessage = adminRights.igpEditMessage
        realmRoomAccess?.deleteMessage = adminRights.igpDeleteMessage
        realmRoomAccess?.pinMessage = adminRights.igpPinMessage
        realmRoomAccess?.addMember = adminRights.igpAddMember
        realmRoomAccess?.banMember = adminRights.igpBanMember
        realmRoomAccess?.getMember = adminRights.igpGetMember
        realmRoomAccess?.addAdmin = adminRights.igpAddAdmin
        realmRoomAccess?.postMessageRights = IGRealmPostMessageRights(adminRights.igpPostMessage)
        
        IGDatabaseManager.shared.realm.add(realmRoomAccess!, update: .modified)
    }
    
    public static func putOrUpdateNoTransaction(roomId: Int64, userId: Int64, adminRights: IGPGroupAddAdmin.IGPAdminRights) {
        let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
        var realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first
        if realmRoomAccess == nil {
            realmRoomAccess = IGRealmRoomAccess()
            realmRoomAccess?.id = makeId(roomId, userId)
        }
        realmRoomAccess?.modifyRoom = adminRights.igpModifyRoom
        realmRoomAccess?.editMessage = true
        realmRoomAccess?.deleteMessage = adminRights.igpDeleteMessage
        realmRoomAccess?.pinMessage = adminRights.igpPinMessage
        realmRoomAccess?.addMember = adminRights.igpAddMember
        realmRoomAccess?.banMember = adminRights.igpBanMember
        realmRoomAccess?.getMember = adminRights.igpGetMember
        realmRoomAccess?.addAdmin = adminRights.igpAddAdmin
        realmRoomAccess?.postMessageRights = IGRealmPostMessageRights(true)
        
        IGDatabaseManager.shared.realm.add(realmRoomAccess!, update: .modified)
    }
    
    public static func putOrUpdateNoTransaction(roomId: Int64, userId: Int64, memberRights: IGPGroupChangeMemberRights.IGPMemberRights) {
        let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
        var realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first
        if realmRoomAccess == nil {
            realmRoomAccess = IGRealmRoomAccess()
            realmRoomAccess?.id = makeId(roomId, userId)
        }
        
        realmRoomAccess?.modifyRoom = false
        realmRoomAccess?.editMessage = false
        realmRoomAccess?.deleteMessage = false
        realmRoomAccess?.pinMessage = memberRights.igpPinMessage
        realmRoomAccess?.addMember = memberRights.igpAddMember
        realmRoomAccess?.banMember = false
        realmRoomAccess?.getMember = memberRights.igpGetMember
        realmRoomAccess?.addAdmin = false
        realmRoomAccess?.postMessageRights = IGRealmPostMessageRights(sendText: memberRights.igpSendText,
                                                                      sendMedia: memberRights.igpSendMedia,
                                                                      sendGif: memberRights.igpSendGif,
                                                                      sendSticker: memberRights.igpSendSticker,
                                                                      sendLink: memberRights.igpSendLink)
        
        IGDatabaseManager.shared.realm.add(realmRoomAccess!, update: .modified)
    }
    
    public static func putOrUpdate(roomId: Int64, userId: Int64, roomAccess: IGPRoomAccess) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                putOrUpdateNoTransaction(roomId: roomId, userId: userId, roomAccess: roomAccess)
            }
        }
    }
    
    public static func putOrUpdate(roomId: Int64, userId: Int64, adminRights: IGPChannelAddAdmin.IGPAdminRights){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                putOrUpdateNoTransaction(roomId: roomId, userId: userId, adminRights: adminRights)
            }
        }
    }
    
    public static func putOrUpdate(roomId: Int64, userId: Int64, adminRights: IGPGroupAddAdmin.IGPAdminRights){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                putOrUpdateNoTransaction(roomId: roomId, userId: userId, adminRights: adminRights)
            }
        }
    }
    
    public static func putOrUpdate(roomId: Int64, userId: Int64, memberRights: IGPGroupChangeMemberRights.IGPMemberRights){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                putOrUpdateNoTransaction(roomId: roomId, userId: userId, memberRights: memberRights)
            }
        }
    }
    
    public static func makeClearRoomAccess(roomId: Int64, userId: Int64){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let predicate = NSPredicate(format: "id = %@", makeId(roomId, userId))
                var realmRoomAccess = IGDatabaseManager.shared.realm.objects(IGRealmRoomAccess.self).filter(predicate).first
                if realmRoomAccess == nil {
                    realmRoomAccess = IGRealmRoomAccess()
                    realmRoomAccess?.id = makeId(roomId, userId)
                }
                realmRoomAccess?.modifyRoom = false
                realmRoomAccess?.editMessage = false
                realmRoomAccess?.deleteMessage = false
                realmRoomAccess?.pinMessage = false
                realmRoomAccess?.addMember = false
                realmRoomAccess?.banMember = false
                realmRoomAccess?.getMember = false
                realmRoomAccess?.addAdmin = false
                realmRoomAccess?.postMessageRights = IGRealmPostMessageRights(false)
                IGDatabaseManager.shared.realm.add(realmRoomAccess!, update: .modified)
            }
        }
    }
    
    
    public static func deleteRoomAccess(roomId: Int64, userId: Int64){
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
            roomAccess.igpEditMessage = realmRoomAccess.editMessage
            roomAccess.igpDeleteMessage = realmRoomAccess.deleteMessage
            roomAccess.igpPinMessage = realmRoomAccess.pinMessage
            roomAccess.igpAddMember = realmRoomAccess.addMember
            roomAccess.igpBanMember = realmRoomAccess.banMember
            roomAccess.igpGetMember = realmRoomAccess.getMember
            roomAccess.igpAddAdmin = realmRoomAccess.addAdmin
            var postMessageRights = IGPPostMessageRights()
            postMessageRights.igpSendText = realmRoomAccess.postMessageRights.sendText
            postMessageRights.igpSendMedia = realmRoomAccess.postMessageRights.sendMedia
            postMessageRights.igpSendSticker = realmRoomAccess.postMessageRights.sendSticker
            postMessageRights.igpSendGif = realmRoomAccess.postMessageRights.sendGif
            postMessageRights.igpSendLink = realmRoomAccess.postMessageRights.sendLink
            roomAccess.igpPostMessage = postMessageRights
            return roomAccess
        }
        
        return nil
    }
}

class IGRealmPostMessageRights: Object {

    @objc dynamic var sendText: Bool = false
    @objc dynamic var sendMedia: Bool = false
    @objc dynamic var sendGif: Bool = false
    @objc dynamic var sendSticker: Bool = false
    @objc dynamic var sendLink: Bool = false
    
    convenience init(_ postMessageRights: IGPPostMessageRights) {
        self.init()
        
        self.sendText = postMessageRights.igpSendText
        self.sendMedia = postMessageRights.igpSendMedia
        self.sendGif = postMessageRights.igpSendGif
        self.sendSticker = postMessageRights.igpSendSticker
        self.sendLink = postMessageRights.igpSendLink
    }
    
    convenience init(sendText: Bool, sendMedia: Bool, sendGif: Bool, sendSticker: Bool, sendLink: Bool) {
        self.init()
        
        self.sendText = sendText
        self.sendMedia = sendMedia
        self.sendGif = sendGif
        self.sendSticker = sendSticker
        self.sendLink = sendLink
    }
    
    convenience init(_ allState: Bool) {
        self.init()
        
        self.sendText = allState
        self.sendMedia = allState
        self.sendGif = allState
        self.sendSticker = allState
        self.sendLink = allState
    }
}
