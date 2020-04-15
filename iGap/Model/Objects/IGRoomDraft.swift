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

class IGRoomDraft: Object {
    @objc dynamic  var message: String = ""
    @objc dynamic  var roomId:  Int64  = -1
    @objc dynamic  var time:    Int64  = -1
    
    override static func primaryKey() -> String {
        return "roomId"
    }
    
    convenience init(igpDraft: IGPRoomDraft, roomId: Int64) {
        self.init()
        self.message = igpDraft.igpMessage
        self.roomId = roomId
    }
    
    convenience init(message: String?, roomId: Int64) {
        self.init()
        self.message = message != nil ? message! : ""
        self.roomId = roomId
        if message != nil && !(message?.isEmpty)! {
            self.time = IGGlobal.getCurrentMillis()
        } else {
            self.time = 0
        }
    }
    
    static func putOrUpdate(realm: Realm, igpDraft: IGPRoomDraft, roomId: Int64) -> IGRoomDraft {
        let predicate = NSPredicate(format: "roomId = %lld", roomId)
        var draft: IGRoomDraft! = realm.objects(IGRoomDraft.self).filter(predicate).first
        if draft == nil {
            draft = IGRoomDraft()
            draft.roomId = roomId
        }
        draft.message = igpDraft.igpMessage
        if !igpDraft.igpMessage.isEmpty {
            draft.time = Int64(Date(timeIntervalSince1970: TimeInterval(igpDraft.igpDraftTime)).timeIntervalSinceReferenceDate) //Int64(igpDraft.igpDraftTime) //Date(timeIntervalSince1970: TimeInterval(igpDraft.igpDraftTime))
        } else {
            draft.time = 0
        }
        return draft
    }
    
    static func putOrUpdate(message: String?, roomId: Int64) -> IGRoomDraft {
        let predicate = NSPredicate(format: "roomId = %lld", roomId)
        var draft: IGRoomDraft! = try! Realm().objects(IGRoomDraft.self).filter(predicate).first
        if draft == nil {
            draft = IGRoomDraft()
            draft.roomId = roomId
        }
        draft.message = message!
        if message != nil && !(message?.isEmpty)! {
            draft.time = IGGlobal.getCurrentMillis() //Date(timeIntervalSince1970: TimeInterval(IGGlobal.getCurrentMillis()))
        } else {
            draft.time = 0
        }
        return draft
    }
        
    func toIGP() -> IGPRoomDraft {
        var roomDraftMessage = IGPRoomDraft()
        roomDraftMessage.igpMessage = self.message
        return roomDraftMessage
    }
    
    func detach() -> IGRoomDraft {
        let detachedDraft = IGRoomDraft(value: self)
        return detachedDraft
    }
}
