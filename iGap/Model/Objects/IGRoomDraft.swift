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
    @objc dynamic  var replyTo: Int64  = -1
    @objc dynamic  var roomId:  Int64  = -1
    @objc dynamic  var time:    Int64  = -1
    
    override static func primaryKey() -> String {
        return "roomId"
    }
    
    //init from network response
    convenience init(igpDraft: IGPRoomDraft, roomId: Int64) {
        self.init()
        self.message = igpDraft.igpMessage
        if igpDraft.igpReplyTo != 0 {
            self.replyTo = igpDraft.igpReplyTo
        }
        self.roomId = roomId
    }
    
    //init from within the device (i.e. segue back from messagesCVC)
    convenience init(message: String?, replyTo: Int64?, roomId: Int64) {
        self.init()
        self.message = message != nil ? message! : ""
        self.replyTo = replyTo != nil ? replyTo! : -1
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
        if igpDraft.igpReplyTo != 0 {
            draft.replyTo = igpDraft.igpReplyTo
        }
        if !igpDraft.igpMessage.isEmpty {
            draft.time = Int64(Date(timeIntervalSince1970: TimeInterval(igpDraft.igpDraftTime)).timeIntervalSinceReferenceDate) //Int64(igpDraft.igpDraftTime) //Date(timeIntervalSince1970: TimeInterval(igpDraft.igpDraftTime))
        } else {
            draft.time = 0
        }
        return draft
    }
    
    static func putOrUpdate(message: String?, replyTo: Int64?, roomId: Int64) -> IGRoomDraft {
        let predicate = NSPredicate(format: "roomId = %lld", roomId)
        var draft: IGRoomDraft! = try! Realm().objects(IGRoomDraft.self).filter(predicate).first
        if draft == nil {
            draft = IGRoomDraft()
            draft.roomId = roomId
        }
        draft.message = message!
        if replyTo != 0 {
            draft.replyTo = replyTo!
        }
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
        if self.replyTo != -1 {
            roomDraftMessage.igpReplyTo = self.replyTo
        }
        return roomDraftMessage
        //return try! roomDraftBuider.build()
    }
    
    //detach from current realm
    func detach() -> IGRoomDraft {
        let detachedDraft = IGRoomDraft(value: self)
        return detachedDraft
    }
}
