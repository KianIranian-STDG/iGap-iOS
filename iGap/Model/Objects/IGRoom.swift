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
import UIKit
import IGProtoBuff

class IGRoom: Object {
    enum IGType: Int {
        case chat     = 0
        case group
        case channel
        
        static func convert(igpType: IGPRoom.IGPType) -> IGType {
            switch igpType {
            case IGPRoom.IGPType.chat:
                return .chat
            case IGPRoom.IGPType.group:
                return .group
            case IGPRoom.IGPType.channel:
                return .channel
            default:
                return .chat
            }
        }
    }
    
    enum IGRoomMute: Int {
        case unmute = 100
        case mute = 101
        
        static func convert(igpType: IGPRoomMute) -> IGRoomMute {
            switch igpType {
            case IGPRoomMute.mute:
                return .mute
            case IGPRoomMute.unmute:
                return .unmute
            default:
                return .unmute
            }
        }
    }
    
    //properties
    @objc dynamic var id:                 Int64                   = -1
    @objc dynamic var typeRaw:            IGType.RawValue         = IGType.chat.rawValue
    @objc dynamic var title:              String?
    @objc dynamic var initilas:           String?
    @objc dynamic var colorString:        String                  = "FFFFFF"
    @objc dynamic var unreadCount:        Int32                   = 0
    @objc dynamic var badgeUnreadCount:   Int32                   = 0 // use this value just for show unread count on app icon, always overrid 'unreadCount' value to currect variable
    @objc dynamic var isReadOnly:     	  Bool                    = false
    @objc dynamic var isParticipant:  	  Bool                    = false
    @objc dynamic var draft:              IGRoomDraft?
    @objc dynamic var chatRoom:           IGChatRoom?
    @objc dynamic var groupRoom:          IGGroupRoom?
    @objc dynamic var channelRoom:        IGChannelRoom?
    @objc dynamic var lastMessage:        IGRoomMessage?
    @objc dynamic var firstUnreadMessage: IGRoomMessage?
    @objc dynamic var savedScrollMessageId:Int64 = 0
    @objc dynamic var sortimgTimestamp:   Double                  = 0.0
    @objc dynamic var clearIdString:      String?
    @objc dynamic var muteRoom:           IGRoomMute.RawValue     = IGRoomMute.unmute.rawValue
    @objc dynamic var pinId:              Int64                   = 0
    @objc dynamic var pinMessage:         IGRoomMessage?
    @objc dynamic var deletedPinMessageId:Int64                   = 0
    @objc dynamic var priority:           Int32                   = 0
    @objc dynamic var isPromote:          Bool                    = false
    @objc dynamic var isDeleted:          Bool                    = false // if this value is true should be delete current room
    
    //ignored properties
    var currenctActionsByUsers = Dictionary<String, (IGRegisteredUser, IGClientAction)>() //actorId, action
    
    var type: IGType {
        get {
            if let s = IGType(rawValue: typeRaw) {
                return s
            }
            return .chat
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    
    var mute: IGRoomMute {
        get {
            if let muteState = IGRoomMute(rawValue: muteRoom) {
                return muteState
            }
            return .unmute
        }
        set {
            muteRoom = newValue.rawValue
        }
    }
    
    var color: UIColor {
        get {
            return  UIColor.hexStringToUIColor(hex: colorString)
        }
    }
    var clearId: Int64 {
        get {
            if let clearIdS = clearIdString {
                if let intVal = Int64(clearIdS) {
                    return intVal
                }
                return 0
            }
            return 0
        }
        set {
            clearIdString = "\(newValue)"
        }
    }
    
    //override
    override static func ignoredProperties() -> [String] {
        return ["currenctActionsByUsers", "color", "type", "clearId"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    //initilizer
    convenience init(igpRoom: IGPRoom) {
        self.init()
        self.id = igpRoom.igpID
        switch igpRoom.igpType {
        case .chat:
            self.type = .chat
        case .group:
            self.type = .group
        case .channel:
            self.type = .channel
        default:
            break
        }
        
        switch igpRoom.igpRoomMute {
        case .mute:
            self.mute = .mute
        case .unmute:
            self.mute = .unmute
        default:
            break
        }
        
        self.title = igpRoom.igpTitle
        self.initilas = igpRoom.igpInitials
        self.colorString = igpRoom.igpColor
        self.unreadCount = igpRoom.igpUnreadCount
        self.badgeUnreadCount = igpRoom.igpUnreadCount
        self.priority = igpRoom.igpPriority
        if igpRoom.hasIgpLastMessage {
            var shouldFetchBefore = false
            
            /*if this message not exist set gap otherwise don't change in gap state */
            var setGap = false
            if !IGRoomMessage.existMessage(messageId: igpRoom.igpLastMessage.igpMessageID) {
                shouldFetchBefore = true
            }
            
            if !IGRoomMessage.existMessage(messageId: igpRoom.igpLastMessage.igpPreviousMessageID) {
                setGap = true
            }
            
            let message = IGRoomMessage(igpMessage: igpRoom.igpLastMessage, roomId: igpRoom.igpID)
            if setGap {
                message.previousMessageId = igpRoom.igpLastMessage.igpMessageID
                message.futureMessageId = igpRoom.igpLastMessage.igpMessageID
            }
            
            if shouldFetchBefore {
                message.shouldFetchBefore = shouldFetchBefore
            }
            
            self.lastMessage = message
            self.sortimgTimestamp = (message.creationTime?.timeIntervalSinceReferenceDate)!
        }
        /*
        if igpRoom.hasIgpLastMessage {
            let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", igpRoom.igpLastMessage.igpMessageID, igpRoom.igpID)
            let realm = try! Realm()
            if let messageInDb = realm.objects(IGRoomMessage.self).filter(predicate).first {
                self.lastMessage = IGRoomMessage(value: messageInDb)
                self.sortimgTimestamp = (messageInDb.creationTime?.timeIntervalSinceReferenceDate)!
            } else {
                
            }
        }
        */
        
        self.pinId = igpRoom.igpPinID
        self.isReadOnly = igpRoom.igpReadOnly
        self.isParticipant = igpRoom.igpIsParticipant
        if igpRoom.hasIgpDraft{
            self.draft = IGRoomDraft(igpDraft: igpRoom.igpDraft, roomId: self.id)
        }
        if igpRoom.hasIgpChatRoomExtra {
            self.chatRoom = IGChatRoom(igpChatRoom: igpRoom.igpChatRoomExtra, id: self.id)
        }
        if igpRoom.hasIgpGroupRoomExtra {
            self.groupRoom = IGGroupRoom(igpGroupRoom: igpRoom.igpGroupRoomExtra, id: self.id)
        }
        if igpRoom.hasIgpChannelRoomExtra {
            self.channelRoom = IGChannelRoom(igpChannelRoom: igpRoom.igpChannelRoomExtra, id: self.id)
        }
        
        self.pinMessage = IGRoomMessage(igpMessage: igpRoom.igpPinnedMessage, roomId: igpRoom.igpID)
        
        if IGHelperPromote.isPromotedRoom(roomId: igpRoom.igpID) {
            self.isPromote = true
        } else {
            self.isPromote = false
        }
    }
    
    class func putOrUpdate(realm: Realm, _ igpRoom: IGPRoom, enableCache: Bool = false) -> IGRoom {
        
        let predicate = NSPredicate(format: "id = %lld", igpRoom.igpID)
        var room: IGRoom! = realm.objects(IGRoom.self).filter(predicate).first
        
        if room == nil {
            room = IGRoom()
            room.id = igpRoom.igpID
        }
        
        room.type = IGRoom.IGType.convert(igpType: igpRoom.igpType)
        room.mute = IGRoom.IGRoomMute.convert(igpType: igpRoom.igpRoomMute)
        
        room.title = igpRoom.igpTitle
        room.initilas = igpRoom.igpInitials
        room.colorString = igpRoom.igpColor
        room.unreadCount = igpRoom.igpUnreadCount
        room.badgeUnreadCount = igpRoom.igpUnreadCount
        room.priority = igpRoom.igpPriority
        room.isDeleted = false
        
        if igpRoom.hasIgpLastMessage {
            var shouldFetchBefore = false
            
            /*if this message not exist set gap otherwise don't change in gap state */
            var setGap = false
            if !IGRoomMessage.existMessage(messageId: igpRoom.igpLastMessage.igpMessageID) {
                shouldFetchBefore = true
                setGap = true
            }
            
            let message = IGRoomMessage.putOrUpdate(realm: realm, igpMessage: igpRoom.igpLastMessage, roomId: igpRoom.igpID, options: IGStructMessageOption(isEnableCache: true))
            if setGap {
                message.previousMessageId = igpRoom.igpLastMessage.igpMessageID
                message.futureMessageId = igpRoom.igpLastMessage.igpMessageID
            }
            
            if shouldFetchBefore {
                message.shouldFetchBefore = shouldFetchBefore
            }
            room.lastMessage = message
            room.sortimgTimestamp = (message.creationTime?.timeIntervalSinceReferenceDate)!
        }
        
        room.pinId = igpRoom.igpPinID
        room.isReadOnly = igpRoom.igpReadOnly
        room.isParticipant = igpRoom.igpIsParticipant
        
        if igpRoom.hasIgpFirstUnreadMessage {
            let firstUnreadMessage = IGRoomMessage.putOrUpdate(igpMessage: igpRoom.igpFirstUnreadMessage, roomId: igpRoom.igpID, options: IGStructMessageOption(isEnableCache: true))
            firstUnreadMessage.futureMessageId = igpRoom.igpFirstUnreadMessage.igpMessageID
            room.firstUnreadMessage = firstUnreadMessage
        }
        
        if igpRoom.hasIgpDraft{
            room.draft = IGRoomDraft.putOrUpdate(realm: realm, igpDraft: igpRoom.igpDraft, roomId: room.id)
        }
        if igpRoom.hasIgpChatRoomExtra {
            room.chatRoom = IGChatRoom.putOrUpdate(realm: realm, igpChatRoom: igpRoom.igpChatRoomExtra, id: room.id)
        }
        if igpRoom.hasIgpGroupRoomExtra {
            room.groupRoom = IGGroupRoom.putOrUpdate(realm: realm, igpGroupRoom: igpRoom.igpGroupRoomExtra, id: room.id)
        }
        if igpRoom.hasIgpChannelRoomExtra {
            room.channelRoom = IGChannelRoom.putOrUpdate(realm: realm, igpChannelRoom: igpRoom.igpChannelRoomExtra, id: room.id)
        }
        
        room.pinMessage = IGRoomMessage.putOrUpdate(realm: realm, igpMessage: igpRoom.igpPinnedMessage, roomId: igpRoom.igpID, options: IGStructMessageOption(isEnableCache: true))
        
        return room
    }
    
    
    //detach from current realm
    func detach() -> IGRoom {
        let detachedRoom = IGRoom(value: self)
        
        if let lastMessage = self.lastMessage {
            let detachedMessage = lastMessage.detach()
            detachedRoom.lastMessage = detachedMessage
        }
        if let draft = self.draft {
            let detachedDraft = draft.detach()
            detachedRoom.draft = detachedDraft
        }
        if let chatRoom = self.chatRoom {
            let detachedchatRoom = chatRoom.detach()
            detachedRoom.chatRoom = detachedchatRoom
        }
        if let groupRoom = self.groupRoom {
            let detachedGroupRoom = groupRoom.detach()
            detachedRoom.groupRoom = detachedGroupRoom
        }
        if let channelRoom = self.channelRoom {
            let detachedChannelRoom = channelRoom.detach()
            detachedRoom.channelRoom = detachedChannelRoom
        }
        
        return detachedRoom
    }
    
    internal static func fetchUsername(room: IGRoom) -> String? {
        if let chat = room.chatRoom {
            return chat.peer?.username
        } else if let group = room.groupRoom {
            if let publicExtra = group.publicExtra {
                return publicExtra.username
            }
        } else if let channel = room.channelRoom {
            if let publicExtra = channel.publicExtra {
                return publicExtra.username
            }
        }
        return nil
    }
    
    /* check room is pinned or not */
    internal static func isPin(roomId: Int64) -> Bool {
         if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld" ,roomId)).first {
            if room.pinId != 0 {
                return true
            }
        }
        return false
    }
    
    /* update unread count when app is in background */
    internal static func updateUnreadCount(roomId: Int64) -> Int {
        let realm = try! Realm()
        try! realm.write {
            if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld" ,roomId)).first {
                room.badgeUnreadCount = room.badgeUnreadCount + 1
            }
        }
        let count : Int = realm.objects(IGRoom.self).filter("isParticipant = 1 AND muteRoom = %d", IGRoom.IGRoomMute.unmute.rawValue).sum(ofProperty: "badgeUnreadCount")
        return count
    }
    
    
    internal static func getRoomIdWithUsername(username: String) -> Int64? {
        
        var roomId: Int64? = nil
        let realm = try! Realm()
        try! realm.write {
            if let room = realm.objects(IGRoom.self).filter(NSPredicate(format: "(groupRoom.publicExtra.username = %@) OR (channelRoom.publicExtra.username = %@)" , username, username)).first {
                roomId = room.id
            }
        }
        return roomId
    }
    
    
    internal static func getRoomInfo(roomId: Int64) -> IGRoom? {
        
        var roomInfo: IGRoom? = nil
        let realm = try! Realm()
        try! realm.write {
            if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld" ,roomId)).first {
                roomInfo = room
            }
        }
        return roomInfo
    }
    
    
    internal static func setParticipant(roomId: Int64, isParticipant: Bool) {
        let realm = try! Realm()
        try! realm.write {
            if let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld" ,roomId)).first {
                room.isParticipant = isParticipant
            }
        }
    }
}


extension IGRoom {
    func setAction(_ action: IGClientAction, id: Int32) {
        switch self.type {
        case .chat:
            IGChatSetActionRequest.Generator.generate(room: self, action: action, actionId: id).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupSetActionRequest.Generator.generate(room: self, action: action, actionId: id).success({ (responseProto) in
                
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .channel:
            break
        }
    }
    
    func currentActionString() -> String {
        if self.currenctActionsByUsers.count == 0 {
            return ""
        }
        
        var string = ""
        var typingUsers          = Array<IGRegisteredUser>()
        var sendingImageUsers    = Array<IGRegisteredUser>()
        var capturingImageUsers  = Array<IGRegisteredUser>()
        var sendingVideoUsers    = Array<IGRegisteredUser>()
        var capturingVideoUsers  = Array<IGRegisteredUser>()
        var sendingAudioUsers    = Array<IGRegisteredUser>()
        var recordingVoiceUsers  = Array<IGRegisteredUser>()
        var sendingVoiceUsers    = Array<IGRegisteredUser>()
        var sendingDocumentUsers = Array<IGRegisteredUser>()
        var sendingGifUsers      = Array<IGRegisteredUser>()
        var sendingFileUsers     = Array<IGRegisteredUser>()
        var sendingLocationUsers = Array<IGRegisteredUser>()
        var choosingContactUsers = Array<IGRegisteredUser>()
        var paintingUsers        = Array<IGRegisteredUser>()
        
        for (_, (user, action)) in self.currenctActionsByUsers {
            switch action {
            case .cancel:
                break
            case .typing:
                typingUsers.append(user)
            case .sendingImage:
                sendingImageUsers.append(user)
            case .capturingImage:
                capturingImageUsers.append(user)
            case .sendingVideo:
                sendingVideoUsers.append(user)
            case .capturingVideo:
                capturingVideoUsers.append(user)
            case .sendingAudio:
                sendingAudioUsers.append(user)
            case .recordingVoice:
                recordingVoiceUsers.append(user)
            case .sendingVoice:
                sendingVoiceUsers.append(user)
            case .sendingDocument:
                sendingDocumentUsers.append(user)
            case .sendingGif:
                sendingGifUsers.append(user)
            case .sendingFile:
                sendingFileUsers.append(user)
            case .sendingLocation:
                sendingLocationUsers.append(user)
            case .choosingContact:
                choosingContactUsers.append(user)
            case .painting:
                paintingUsers.append(user)
            }
        }
        
        if typingUsers.count == 1 {
            string += "\(typingUsers[0].displayName) is typing"
        } else if typingUsers.count == 2{
            string += "\(typingUsers[0].displayName) & \(typingUsers[1].displayName) are typing"
        } else if typingUsers.count > 2 {
            string += "\(typingUsers.count) people are typing"
        }
        
        if sendingImageUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingImageUsers.count == 1 {
            string += "\(sendingImageUsers[0].displayName) is sending image"
        } else if sendingImageUsers.count == 2{
            string += "\(sendingImageUsers[0].displayName)& \(sendingImageUsers[1].displayName) are sending image"
        } else if sendingImageUsers.count > 2 {
            string += "\(sendingImageUsers.count) people are sending image"
        }
        
        if capturingImageUsers.count != 0 && string != "" {
            string += ", "
        }
        if capturingImageUsers.count == 1 {
            string += "\(capturingImageUsers[0].displayName) is capturing image"
        } else if capturingImageUsers.count == 2{
            string += "\(capturingImageUsers[0].displayName)& \(capturingImageUsers[1].displayName) are capturing image"
        } else if capturingImageUsers.count > 2 {
            string += "\(capturingImageUsers.count) people are capturing image"
        }
        
        if sendingVideoUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingVideoUsers.count == 1 {
            string += "\(sendingVideoUsers[0].displayName) is sending video"
        } else if sendingVideoUsers.count == 2{
            string += "\(sendingVideoUsers[0].displayName)& \(sendingVideoUsers[1].displayName) are sending video"
        } else if sendingVideoUsers.count > 2 {
            string += "\(sendingVideoUsers.count) people are sending video"
        }
        
        if capturingVideoUsers.count != 0 && string != "" {
            string += ", "
        }
        if capturingVideoUsers.count == 1 {
            string += "\(capturingVideoUsers[0].displayName) is capturing video"
        } else if capturingVideoUsers.count == 2{
            string += "\(capturingVideoUsers[0].displayName)& \(capturingVideoUsers[1].displayName) are capturing video"
        } else if capturingVideoUsers.count > 2 {
            string += "\(capturingVideoUsers.count) people are capturing video"
        }
        
        if sendingAudioUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingAudioUsers.count == 1 {
            string += "\(sendingAudioUsers[0].displayName) is sending audio"
        } else if sendingAudioUsers.count == 2{
            string += "\(sendingAudioUsers[0].displayName)& \(sendingAudioUsers[1].displayName) are sending audio"
        } else if sendingAudioUsers.count > 2 {
            string += "\(sendingAudioUsers.count) people are sending audio"
        }
        
        if recordingVoiceUsers.count != 0 && string != "" {
            string += ", "
        }
        if recordingVoiceUsers.count == 1 {
            string += "\(recordingVoiceUsers[0].displayName) is recording voice"
        } else if recordingVoiceUsers.count == 2{
            string += "\(recordingVoiceUsers[0].displayName)& \(recordingVoiceUsers[1].displayName) are recording voice"
        } else if recordingVoiceUsers.count > 2 {
            string += "\(recordingVoiceUsers.count) people are recording voice"
        }
        
        if sendingVoiceUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingVoiceUsers.count == 1 {
            string += "\(sendingVoiceUsers[0].displayName) is sending voice"
        } else if sendingVoiceUsers.count == 2{
            string += "\(sendingVoiceUsers[0].displayName)& \(sendingVoiceUsers[1].displayName) are sending voice"
        } else if sendingVoiceUsers.count > 2 {
            string += "\(sendingVoiceUsers.count) people are sending voice"
        }
        
        if sendingVoiceUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingDocumentUsers.count == 1 {
            string += "\(sendingDocumentUsers[0].displayName) is sending document"
        } else if sendingDocumentUsers.count == 2{
            string += "\(sendingDocumentUsers[0].displayName)& \(sendingDocumentUsers[1].displayName) are sending document"
        } else if sendingDocumentUsers.count > 2 {
            string += "\(sendingDocumentUsers.count) people are sending document"
        }
        
        if sendingGifUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingGifUsers.count == 1 {
            string += "\(sendingGifUsers[0].displayName) is sending gif"
        } else if sendingGifUsers.count == 2{
            string += "\(sendingGifUsers[0].displayName)& \(sendingGifUsers[1].displayName) are sending gif"
        } else if sendingGifUsers.count > 2 {
            string += "\(sendingGifUsers.count) people are sending gif"
        }
        
        if sendingFileUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingFileUsers.count == 1 {
            string += "\(sendingFileUsers[0].displayName) is sending file"
        } else if sendingFileUsers.count == 2{
            string += "\(sendingFileUsers[0].displayName)& \(sendingFileUsers[1].displayName) are sending file"
        } else if sendingFileUsers.count > 2 {
            string += "\(sendingFileUsers.count) people are sending file"
        }
        
        
        if sendingLocationUsers.count != 0 && string != "" {
            string += ", "
        }
        if sendingLocationUsers.count == 1 {
            string += "\(sendingLocationUsers[0].displayName) is sending location"
        } else if sendingLocationUsers.count == 2{
            string += "\(sendingLocationUsers[0].displayName)& \(sendingLocationUsers[1].displayName) are sending location"
        } else if sendingLocationUsers.count > 2 {
            string += "\(sendingLocationUsers.count) people are sending location"
        }
        
        if choosingContactUsers.count != 0 && string != "" {
            string += ", "
        }
        if choosingContactUsers.count == 1 {
            string += "\(choosingContactUsers[0].displayName) is sending contact"
        } else if choosingContactUsers.count == 2{
            string += "\(choosingContactUsers[0].displayName)& \(choosingContactUsers[1].displayName) are sending contact"
        } else if choosingContactUsers.count > 2 {
            string += "\(choosingContactUsers.count) people are sending contact"
        }
        
        if paintingUsers.count != 0 && string != "" {
            string += ", "
        }
        if paintingUsers.count == 1 {
            string += "\(paintingUsers[0].displayName) is painting"
        } else if paintingUsers.count == 2{
            string += "\(paintingUsers[0].displayName)& \(paintingUsers[1].displayName) are painting"
        } else if paintingUsers.count > 2 {
            string += "\(paintingUsers.count) people are painting"
        }
        return string
    }

}



extension IGRoom {
    func saveDraft( _ body: String?, replyToMessage: IGRoomMessage?) {
        let finalBody = body?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (self.draft == nil || (self.draft?.message.isEmpty)!) && (finalBody == nil || (finalBody?.isEmpty)!) { //if before really has draft ro currently exist new draft
            return
        }
        
        let draft = IGRoomDraft(message: finalBody, replyTo: replyToMessage?.id, roomId: self.id)
        IGFactory.shared.saveDraft(draft: draft)
        
        switch self.type {
        case .chat:
            IGChatUpdateDraftRequest.Generator.generate(draft: draft).success({ (responseProto) in
                if let updateDraftResponse = responseProto as? IGPChatUpdateDraftResponse {
                    IGChatUpdateDraftRequest.Handler.interpret(response: updateDraftResponse)
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupUpdateDraftRequest.Generator.generate(draft: draft).success({ (responseProto) in
                if let updateDraftResponse = responseProto as? IGPGroupUpdateDraftResponse {
                    IGGroupUpdateDraftRequest.Handler.interpret(response: updateDraftResponse)
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .channel:
            IGChannelUpdateDraftRequest.Generator.generate(draft: draft).success({ (responseProto) in
                if let updateDraftResponse = responseProto as? IGPChannelUpdateDraftResponse {
                    IGChannelUpdateDraftRequest.Handler.interpret(response: updateDraftResponse)
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        }
    }
    
    /* check that room exist in local and user is participant in this room */
    static func existRoomInLocal(roomId: Int64 = 0, userId: Int64 = 0) -> IGRoom? {
        if roomId != 0 {
            let predicate = NSPredicate(format: "id = %lld AND isParticipant = 1", roomId)
            if let room = try! Realm().objects(IGRoom.self).filter(predicate).first {
                return room
            }
        } else if userId != 0 {
            let predicate = NSPredicate(format: "chatRoom.peer.id = %lld AND isParticipant = 1", userId)
            if let room = try! Realm().objects(IGRoom.self).filter(predicate).first {
                return room
            }
        }
        return nil
    }
    
    static func getPinnedMessage(roomId: Int64) -> IGRoomMessage? {
        let predicate = NSPredicate(format: "id == %lld", roomId)
        if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first, let pinnedMessage = room.pinMessage{
            return pinnedMessage
        }
        return nil
    }
    
    /* save state of message in room */
    static func saveMessagePosition(roomId: Int64, saveScrollMessageId: Int64) {
        DispatchQueue.main.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.savedScrollMessageId = saveScrollMessageId
                    }
                }
            }
        }
    }
    
    static func getLastMessage(roomId: Int64) -> IGRoomMessage? {
        let predicate = NSPredicate(format: "id = %lld", roomId)
        if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
            return room.lastMessage
        }
        return nil
    }
}
