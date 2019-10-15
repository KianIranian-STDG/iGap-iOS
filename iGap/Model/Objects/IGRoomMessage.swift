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

class IGRoomMessage: Object {
    @objc dynamic var message:            String?
    @objc dynamic var creationTime:       Date?
    @objc dynamic var updateTime:         Date?
    @objc dynamic var authorHash:         String?
    @objc dynamic var authorUser:         IGRealmAuthorUser? // When sent in a chat/group
    @objc dynamic var authorRoom:         IGRoom?           // When sent in a channel
    @objc dynamic var attachment:         IGFile?
    @objc dynamic var forwardedFrom:      IGRoomMessage?
    @objc dynamic var repliedTo:          IGRoomMessage?
    @objc dynamic var log:                IGRoomMessageLog?
    @objc dynamic var contact:            IGRoomMessageContact?
    @objc dynamic var location:           IGRoomMessageLocation?
    @objc dynamic var wallet:             IGRoomMessageWallet?
    @objc dynamic var additional:         IGRealmAdditional?
    @objc dynamic var channelExtra:       IGRealmChannelExtra?
    @objc dynamic var id:                 Int64                           = -1
    @objc dynamic var roomId:             Int64                           = -1
    @objc dynamic var primaryKeyId:       String?
    @objc dynamic var messageVersion:     Int64                           = -1
    @objc dynamic var previousMessageId:  Int64                           = 0
    @objc dynamic var futureMessageId:    Int64                           = 0
    @objc dynamic var statusVersion:      Int64                           = -1
    @objc dynamic var deleteVersion:      Int64                           = -1
    @objc dynamic var shouldFetchBefore:  Bool                            = false // DEPRECATED
    @objc dynamic var shouldFetchAfter:   Bool                            = false
    @objc dynamic var isFirstMessage:     Bool                            = false
    @objc dynamic var isLastMessage:      Bool                            = false
    @objc dynamic var isEdited:           Bool                            = false
    @objc dynamic var isDeleted:          Bool                            = false
    @objc dynamic var pendingSend:        Bool                            = false
    @objc dynamic var pendingDelivered:   Bool                            = false
    @objc dynamic var pendingSeen:        Bool                            = false
    @objc dynamic var pendingEdit:        Bool                            = false
    @objc dynamic var pendingDelete:      Bool                            = false
    @objc dynamic var isFromSharedMedia:  Bool                            = false
    @objc dynamic var typeRaw:            IGRoomMessageType.RawValue      = IGRoomMessageType.unknown.rawValue
    @objc dynamic var statusRaw:          IGRoomMessageStatus.RawValue    = IGRoomMessageStatus.unknown.rawValue
    @objc dynamic var temporaryId:        String?
    @objc dynamic var randomId:           Int64                           = -1

    var status: IGRoomMessageStatus {
        get {
            if let s = IGRoomMessageStatus(rawValue: statusRaw) {
                return s
            }
            return .unknown
        }
        set {
            statusRaw = newValue.rawValue
        }
    }
    var type : IGRoomMessageType {
        get {
            if let s = IGRoomMessageType(rawValue: typeRaw) {
                return s
            }
            return .unknown
        }
        set {
            typeRaw = newValue.rawValue
        }
    }

    override static func indexedProperties() -> [String] {
        return ["roomId","id"]
    }

    override static func ignoredProperties() -> [String] {
        return ["status", "type"]
    }
    
    override static func primaryKey() -> String {
        return "primaryKeyId"
    }
    
    /* Hint: Currently just use this constructor in the share media view controllers
     * because use if use from putOrUpdate for those states app will be crashed, for write in db without transaction
     */
    convenience init(igpMessage: IGPRoomMessage, roomId: Int64, isForward: Bool = false, isReply: Bool = false) {
        self.init()
        let realm = try! Realm()
        self.id = igpMessage.igpMessageID
        if !isForward && !isReply {
            self.roomId = roomId
        }
        self.primaryKeyId = IGRoomMessage.generatePrimaryKey(messageID: igpMessage.igpMessageID, roomID: roomId, isForward: isForward, isReply: isReply)
        self.messageVersion = igpMessage.igpMessageVersion
        self.isDeleted = igpMessage.igpDeleted
        
        switch igpMessage.igpStatus {
        case .failed:
            self.status = .failed
        case .sending:
            self.status = .sending
        case .sent:
            self.status = .sent
        case .delivered:
            self.status = .delivered
        case .seen:
            self.status = .seen
        case .listened:
            self.status = .listened
        default:
            self.status = .unknown
        }
        if igpMessage.igpStatusVersion != 0 {
            self.statusVersion = igpMessage.igpStatusVersion
        }
        self.type = IGRoomMessageType.unknown.fromIGP(igpMessage.igpMessageType, igpRoomMessage: igpMessage)
        self.message = igpMessage.igpMessage
        
        if igpMessage.hasIgpAttachment {
            let predicate = NSPredicate(format: "cacheID = %@", igpMessage.igpAttachment.igpCacheID)
            if let fileInDb = realm.objects(IGFile.self).filter(predicate).first {
                self.attachment = fileInDb
            } else {
                self.attachment = IGFile(igpFile: igpMessage.igpAttachment, messageType: self.type)
                if self.attachment?.fileNameOnDisk == nil {
                    self.attachment!.downloadUploadPercent = 0.0
                    self.attachment!.status = .readyToDownload
                } else if !(self.attachment?.isInUploadLevels())!{
                    self.attachment!.downloadUploadPercent = 1.0
                    self.attachment!.status = .ready
                }
            }
        }
        if igpMessage.hasIgpAuthor {
            let author = igpMessage.igpAuthor
            if author.igpHash != "" {
                self.authorHash = author.igpHash
            }
            
            if author.hasIgpUser {
                self.authorUser = IGRealmAuthorUser(author.igpUser)
                self.authorRoom = nil
                
            } else if author.hasIgpRoom {
                let authorRoom = author.igpRoom
                //read realm for existing room
                let predicate = NSPredicate(format: "id = %lld", authorRoom.igpRoomID)
                if let roomInDb = realm.objects(IGRoom.self).filter(predicate).first {
                    self.authorRoom = roomInDb
                    self.authorUser = nil
                } else {
                    //if your code reaches here there is something wrong
                    //you MUST fetch all dependecies befor performing any action
                    //assertionFailure()
                }
            }
        }
        if igpMessage.hasIgpLocation {
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            if let locaitonInDb = realm.objects(IGRoomMessageLocation.self).filter(predicate).first {
                self.location = locaitonInDb
            } else {
                self.location = IGRoomMessageLocation(igpRoomMessageLocation: igpMessage.igpLocation, for: self)
            }
        }
        if igpMessage.hasIgpWallet {
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            if let wallet = realm.objects(IGRoomMessageWallet.self).filter(predicate).first {
                self.wallet = wallet
            } else {
                self.wallet = IGRoomMessageWallet(igpRoomMessageWallet: igpMessage.igpWallet, for: self)
            }
        }
        if igpMessage.hasIgpLog {
            //TODO: check if using self.primaryKeyId is good
            //otherwise use a combinatoin of id and room
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            if let logInDb = realm.objects(IGRoomMessageLog.self).filter(predicate).first {
                self.log = logInDb
            } else {
                self.log = IGRoomMessageLog(igpRoomMessageLog: igpMessage.igpLog, for: self)
            }
        }
        if igpMessage.hasIgpContact {
            let predicate = NSPredicate(format: "id = %@", self.primaryKeyId!)
            if let contactInDb = realm.objects(IGRoomMessageContact.self).filter(predicate).first {
                self.contact = contactInDb
            } else {
                self.contact = IGRoomMessageContact(igpRoomMessageContact: igpMessage.igpContact, for: self)
            }
        }
        if igpMessage.hasIgpChannelExtra {
            self.channelExtra = IGRealmChannelExtra(messageId: igpMessage.igpMessageID, igpChannelExtra: igpMessage.igpChannelExtra)
        }
        
        self.isEdited = igpMessage.igpEdited
        self.creationTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpCreateTime))
        self.updateTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpUpdateTime))
        if igpMessage.hasIgpForwardFrom {
            if igpMessage.igpForwardFrom.igpAuthor.hasIgpRoom {
                print("found that")
            }
            self.forwardedFrom = IGRoomMessage(igpMessage: igpMessage.igpForwardFrom, roomId: roomId, isForward: true)
        }
        if igpMessage.hasIgpReplyTo {
            self.repliedTo = IGRoomMessage(igpMessage: igpMessage.igpReplyTo, roomId: roomId, isReply: true)
        }
        if igpMessage.igpPreviousMessageID != 0 {
            self.previousMessageId = igpMessage.igpPreviousMessageID
        }
        
        self.randomId = igpMessage.igpRandomID
        
        self.additional = IGRealmAdditional(message: igpMessage)
    }
    
    //used when sending a message
    convenience init(body: String) {
        self.init()
        self.isDeleted = false
        if body != "" {
            self.message = body
        } else {
            self.message = nil
        }
        self.creationTime = Date()
        self.status = IGRoomMessageStatus.sending
        self.temporaryId = IGGlobal.randomString(length: 64)
        self.primaryKeyId = IGGlobal.randomString(length: 64)
        self.randomId = IGGlobal.randomId()
        // Hint: following code has crash
        //self.authorUser = IGRealmAuthorUser(IGAppManager.sharedManager.userID()!)
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        let realm = try! Realm()
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            self.authorUser?.userInfo = userInDb
            self.authorUser?.userId = userInDb.id
        }
        self.authorHash = IGAppManager.sharedManager.authorHash()
    }
    
    class func generatePrimaryKey(messageID: Int64, roomID: Int64, isForward: Bool = false, isReply: Bool = false) -> String {
        var prefix = ""
        if isForward {
            prefix = "F_"
        } else if isReply {
            prefix = "R_"
        }
        // generate random string for create a distinction for upload same file simultaneously
        return "\(prefix)\(messageID)_\(roomID)"// + IGGlobal.randomString(length: 3)
    }
    
    static func makeCardToCardRequest(message: String) -> IGRoomMessage {
        let message = IGRoomMessage(body: message)
        let additionalData = "[[{\"actionType\":\(IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue),\"label\":\"CARD_TO_CARD\",\"imageUrl\":\"\",\"value\":\(IGAppManager.sharedManager.userID()!)}]]"
        let additional = IGRealmAdditional(additionalData: additionalData, additionalType: Int32(AdditionalType.UNDER_MESSAGE_BUTTON.rawValue))
        message.additional = additional
        return message
    }
    
    static func makeCardToCardRequestWithAmount(messageText: String,amount: String,cardNumber:String) -> IGRoomMessage {
        let message = IGRoomMessage(body: messageText)
        let additionalData = "[[{\"actionType\":\(IGPDiscoveryField.IGPButtonActionType.cardToCard.rawValue),\"label\":\"CARD_TO_CARD\",\"imageUrl\":\"\",\"value\":{\"userId\":\(IGAppManager.sharedManager.userID()!),\"amount\":\(amount),\"cardNumber\":\(cardNumber)}}]]"
        let additional = IGRealmAdditional(additionalData: additionalData, additionalType: Int32(AdditionalType.CARD_TO_CARD_PAY.rawValue))
        message.additional = additional
        return message
    }
    
    static func putOrUpdate(igpMessage: IGPRoomMessage, roomId: Int64, options: IGStructMessageOption = IGStructMessageOption(), completion: @escaping (_ message: IGRoomMessage) -> ()) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                if let message = IGRoomMessage.putOrUpdate(igpMessage: igpMessage, roomId: roomId, options: options) {
                    IGDatabaseManager.shared.realm.add(message, update: .modified)
                }
            }
            // TODO - find better solution instead delay, now need to delay for insure that data after get from realm really is exist 
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let message = IGRoomMessage.getMessageWithId(roomId: roomId, messageId: igpMessage.igpMessageID) {
                    completion(message)
                }
            }
        }
    }
    
    static func putOrUpdate(realm: Realm? = nil, igpMessage: IGPRoomMessage, roomId: Int64, options: IGStructMessageOption = IGStructMessageOption()) -> IGRoomMessage? {
        
        var messageId: Int64 = igpMessage.igpMessageID
        if options.isReply || options.isForward {
            messageId = igpMessage.igpMessageID * -1
        }
        
        if options.isEnableCache, let _ = IGGlobal.importedRoomMessageDic[messageId] { //, !message.isInvalidated {
            return nil
        }
        
        // read imported room message from cache for avoid from duplicate primaryKey
        // (IMPORTANT_HINT) : fill this value for put message from get room list and clear cache after do this work
        
        //Hint: don't use cache for forwarded or replied message for avoid from override multi forward message
        //if options.isEnableCache, let _ = IGGlobal.importedRoomMessageDic[messageId] { //, !message.isInvalidated {
        //    print("FFF || Cache: \(messageId)")
        //    return nil
        //}
        
        /*
        var realmFinal: Realm! = realm
        if realmFinal == nil {
            realmFinal = try! Realm()
        }
        */
        
        let realmFinal = IGDatabaseManager.shared.realm
        let primaryKeyId = IGRoomMessage.generatePrimaryKey(messageID: messageId, roomID: roomId, isForward: options.isForward, isReply: options.isReply)
        let predicate = NSPredicate(format: "(id = %lld AND roomId = %lld) OR (primaryKeyId = %@)", messageId, roomId, primaryKeyId) // i checked primaryKeyId because sometimes was exist in realm
        var message: IGRoomMessage! = realmFinal.objects(IGRoomMessage.self).filter(predicate).first
        
        if message == nil {
            message = IGRoomMessage()
            message.primaryKeyId = primaryKeyId
        }
        
        message.roomId = roomId
        message.id = messageId
        message.message = igpMessage.igpMessage
        message.messageVersion = igpMessage.igpMessageVersion
        message.isDeleted = igpMessage.igpDeleted
        message.isEdited = igpMessage.igpEdited
        message.creationTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpCreateTime))
        message.updateTime = Date(timeIntervalSince1970: TimeInterval(igpMessage.igpUpdateTime))
        message.randomId = igpMessage.igpRandomID
        
        message.status = IGRoomMessageStatus.fromIGP(status: igpMessage.igpStatus)
        message.type = IGRoomMessageType.unknown.fromIGP(igpMessage.igpMessageType, igpRoomMessage: igpMessage)
        
        if igpMessage.igpStatusVersion != 0 {
            message.statusVersion = igpMessage.igpStatusVersion
        }
        if igpMessage.igpPreviousMessageID != 0 {
            message.previousMessageId = igpMessage.igpPreviousMessageID
        }
        if igpMessage.hasIgpAuthor {
            let author = igpMessage.igpAuthor
            if author.igpHash != "" {
                message.authorHash = author.igpHash
            }

            if author.hasIgpUser {
                message.authorUser = IGRealmAuthorUser(author.igpUser)
                message.authorRoom = nil
                
            } else if author.hasIgpRoom {
                let authorRoom = author.igpRoom
                let predicate = NSPredicate(format: "id = %lld", authorRoom.igpRoomID)
                if let roomInDb = realmFinal.objects(IGRoom.self).filter(predicate).first {
                    message.authorRoom = roomInDb
                    message.authorUser = nil
                }
            }
        }
        
        if igpMessage.hasIgpAttachment {
            message.attachment = IGFile.putOrUpdate(realm: realmFinal, igpFile: igpMessage.igpAttachment, fileType: IGFile.FileType.convertToFileType(messageType: message!.type) , enableCache: true)
        }
        if igpMessage.hasIgpLocation {
            message.location = IGRoomMessageLocation.putOrUpdate(realm: realmFinal, igpRoomMessageLocation: igpMessage.igpLocation, for: message)
        }
        if igpMessage.hasIgpWallet {
            message.wallet = IGRoomMessageWallet.putOrUpdate(realm: realmFinal, igpRoomMessageWallet: igpMessage.igpWallet, for: message)
        }
        if igpMessage.hasIgpLog {
            message.log = IGRoomMessageLog.putOrUpdate(realm: realmFinal, igpRoomMessageLog: igpMessage.igpLog, for: message)
        }
        if igpMessage.hasIgpContact {
            message.contact = IGRoomMessageContact.putOrUpdate(realm: realmFinal, igpRoomMessageContact: igpMessage.igpContact, for: message)
        }
        if igpMessage.hasIgpForwardFrom {
            message.forwardedFrom = IGRoomMessage.putOrUpdate(realm: realmFinal, igpMessage: igpMessage.igpForwardFrom, roomId: -1, options: IGStructMessageOption(isForward: true, isEnableCache: true))
        }
        if igpMessage.hasIgpReplyTo {
            message.repliedTo = IGRoomMessage.putOrUpdate(realm: realmFinal, igpMessage: igpMessage.igpReplyTo, roomId: -1, options: IGStructMessageOption(isReply: true, isEnableCache: true))
        }
        if igpMessage.hasIgpChannelExtra {
            message.channelExtra = IGRealmChannelExtra.putOrUpdate(realm: realmFinal, messageId: igpMessage.igpMessageID, igpChannelExtra: igpMessage.igpChannelExtra)
        }
        
        message.additional = IGRealmAdditional.put(realm: realmFinal, message: igpMessage)
        
        // TODO - HINT: if is from share media do following code. following code not handled yet!
        // ofcourse currently we don't update "IGRoomMessage" from share media so now don't need to update following param here
        /*
         message.previousMessageId = message.id
         message.futureMessageId = message.id
         */
        
        if options.previousGap {
            message.previousMessageId = igpMessage.igpPreviousMessageID
        }
        if options.futureGap {
            message.futureMessageId = igpMessage.igpMessageID
        }
        
        if options.isEnableCache && (!options.isReply && !options.isForward) {
            IGGlobal.importedRoomMessageDic[message.id] = message
        }
        
        return message
    }
    
    internal static func detectPinMessage(message: IGRoomMessage?) -> String {
        
        if message == nil {
            return "unpinned message"
        }
        
        var finalMessage = message
        if let forward = message!.forwardedFrom {
            finalMessage = forward
        } else if let reply = message!.repliedTo {
            finalMessage = reply
        }
        
        let messageType = finalMessage!.type
        let pinText = "is pinned"
        
        if messageType == .text ||
            messageType == .log ||
            messageType == .imageAndText ||
            messageType == .videoAndText ||
            messageType == .gifAndText ||
            messageType == .audioAndText ||
            messageType == .fileAndText {
            
            return "'\(finalMessage!.message!)' \(pinText)"
        } else if messageType == .image  {
            return "'image' \(pinText)"
        } else if messageType == .video {
            return "'video' \(pinText)"
        } else if messageType == .gif {
            return "'gif' \(pinText)"
        } else if messageType == .audio {
            return "'audio' \(pinText)"
        } else if messageType == .file {
            return "'file' \(pinText)"
        } else if messageType == .contact {
            return "'contact' \(pinText)"
        } else if messageType == .voice {
            return "'voice' \(pinText)"
        } else if messageType == .location {
            return "'location' \(pinText)"
        } else if messageType == .sticker {
            return "'sticker' \(pinText)"
        }
        
        return "'unknown' pinned message"
    }
    
    internal static func detectPinMessageProto(message: IGPRoomMessage) -> String{
        
        var finalMessage = message
        if message.hasIgpForwardFrom {
            finalMessage = message.igpForwardFrom
        }
        
        let messageType = finalMessage.igpMessageType
        let pinText = "is pinned"
        
        
        if messageType == .text ||
            messageType == .imageText ||
            messageType == .videoText ||
            messageType == .gifText ||
            messageType == .audioText ||
            messageType == .fileText {
            
            return "'\(finalMessage.igpMessage)' \(pinText)"
        } else if messageType == .image {
            return "'image' \(pinText)"
        } else if messageType == .video {
            return "'video' \(pinText)"
        } else if messageType == .gif {
            return "'gif' \(pinText)"
        } else if messageType == .audio {
            return "'audio' \(pinText)"
        } else if messageType == .file {
            return "'file' \(pinText)"
        } else if messageType == .contact {
            return "'contact' \(pinText)"
        } else if messageType == .voice {
            return "'voice' \(pinText)"
        } else if messageType == .location {
            return "'location' \(pinText)"
        }
        
        return "'unknown' pinned message"
    }
    
    //detach from current realm
    func detach() -> IGRoomMessage {
        let detachedMessage = IGRoomMessage(value: self)
        
        if let author = self.authorUser {
            let detachedAuthor = author.detach()
            detachedMessage.authorUser = detachedAuthor
        }
        if let author = self.authorRoom {
            let detachedAuthor = author.detach()
            detachedMessage.authorRoom = detachedAuthor
        }
        if let attach = self.attachment {
            let detachedAttachment = attach.detach()
            detachedMessage.attachment = detachedAttachment
        }
        if let forwardedFrom = self.forwardedFrom {
            let detachedForwarded = forwardedFrom.detach()
            detachedMessage.forwardedFrom = detachedForwarded
        }
       
        if let reply = self.repliedTo {
            let detachedReply = reply.detach()
            detachedMessage.repliedTo = detachedReply
        }
        if let log = self.log {
            let detachedLog = log.detach()
            detachedMessage.log = detachedLog
        }
        if let contact = self.contact {
            let detachedContact = contact.detach()
            detachedMessage.contact = detachedContact
        }
        if let location = self.location {
            let detachedLocation = location.detach()
            detachedMessage.location = detachedLocation
        }
        if let additional = self.additional {
            let detachedAdditional = additional.detach()
            detachedMessage.additional = detachedAdditional
        }
        
        return detachedMessage
    }
    
    public func getFinalMessage() -> IGRoomMessage {
        if let forward = self.forwardedFrom {
            return forward
        }
        return self
    }
    
    internal static func makeCopyOfMessage(message: IGRoomMessage) -> IGRoomMessage {
        let finalMessage = IGRoomMessage()
        finalMessage.id = message.id
        finalMessage.message = message.message
        finalMessage.type = message.type
        finalMessage.isDeleted = message.isDeleted
        finalMessage.creationTime = message.creationTime
        finalMessage.status = message.status
        finalMessage.temporaryId = message.temporaryId
        finalMessage.primaryKeyId = message.primaryKeyId
        finalMessage.randomId = message.randomId
        finalMessage.authorUser = message.authorUser
        finalMessage.authorHash = message.authorHash
        finalMessage.attachment = message.attachment
        finalMessage.additional = message.additional
        return finalMessage
    }
    
    /* use this method for delete channel messages for get messages from server again and update vote actions data */
    internal static func deleteAllChannelMessages(){
        DispatchQueue.main.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "typeRaw == %d", IGRoom.IGType.channel.rawValue)
                    for room in IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate) {
                        IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(NSPredicate(format: "roomId == %lld", room.id))) // delete all room messages
                    }
                }
            }
        }
    }
    
    /** return true if message exist and is not deleted */
    internal static func existMessage(roomId: Int64 = 0, messageId: Int64) -> Bool {
        if messageId == 0 {
            return false
        }
        
        var predicate = NSPredicate(format: "id == %lld", messageId)
        if roomId != 0 {
            predicate = NSPredicate(format: "id == %lld AND roomId == %lld", messageId, roomId)
        }
        
        if let message = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first, message.isDeleted == false {
            return true
        }
        
        return false
    }
    
    internal static func fetchForwardMessage(roomId: Int64, messageId: Int64) -> IGRoomMessage? {
        let predicate = NSPredicate(format: "roomId == %lld AND forwardedFrom.id == %lld", roomId, messageId)
        return IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first
    }
    
    internal static func getMessageWithId(roomId: Int64 = 0, messageId: Int64) -> IGRoomMessage? {
        var predicate = NSPredicate(format: "id == %lld", messageId)
        if roomId != 0 {
            predicate = NSPredicate(format: "id == %lld AND roomId == %lld", messageId, roomId)
        }
        return IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first
    }
    
    internal static func getMessageWithPrimaryKeyId(primaryKeyId: String) -> IGRoomMessage? {
        return IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(NSPredicate(format: "primaryKeyId = %@", primaryKeyId)).first
    }
    
    internal static func deleteMessage(primaryKeyId: String, retry: Bool = true) {
        if let message = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(NSPredicate(format: "primaryKeyId = %@", primaryKeyId)).first {
            IGDatabaseManager.shared.realm.delete(message)
        } else if retry {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                try! IGDatabaseManager.shared.realm.write {
                    IGRoomMessage.deleteMessage(primaryKeyId: primaryKeyId, retry: false)
                }
            }
        }
    }
    
    internal static func clearLocalMessage(roomId: Int64) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(NSPredicate(format: "id == %lld", roomId)).first {
                    room.savedScrollMessageId = 0
                    if let pinMessage = room.pinMessage {
                        room.pinMessage?.futureMessageId = pinMessage.id
                        room.pinMessage?.previousMessageId = pinMessage.id
                    }
                    if let lastMessage = room.lastMessage {
                        room.lastMessage?.previousMessageId = lastMessage.id
                    }
                    // filter lastMessage & pinMessage for avoid from delete message
                    let allMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(NSPredicate(format: "roomId == %lld AND id != %lld AND id != %lld", roomId, (room.lastMessage?.id ?? 0), (room.pinMessage?.id ?? 0)))
                    IGDatabaseManager.shared.realm.delete(allMessages)
                }
            }
        }
    }
    
    /**
     * for write a list of message, need to manage duplicate message for avoid from "duplicate primary key" crash.
     * this method will be managed write same message into the realm, with make an array from duplicate message and
     * retry this method for write from duplicate array message, and do this action until finish all messages.
     */
    internal static func managePutOrUpdate(roomId: Int64, messages: [IGPRoomMessage], options: IGStructMessageOption = IGStructMessageOption()){
        
        if messages.count == 0 {
            return
        }
        
        var duplicateMessageInfo: [IGPRoomMessage] = []
        try! IGDatabaseManager.shared.realm.write {
            for message in messages {
                if let savedMessage = IGRoomMessage.putOrUpdate(igpMessage: message, roomId: roomId, options: options) {
                    IGDatabaseManager.shared.realm.add(savedMessage)
                } else {
                    duplicateMessageInfo.append(message)
                }
            }
        }
        
        manageRewriteMessage(roomId: roomId, messages: duplicateMessageInfo, options: options)
    }
    
    private static func manageRewriteMessage(roomId: Int64, messages: [IGPRoomMessage], options: IGStructMessageOption = IGStructMessageOption()){
        IGGlobal.importedRoomMessageDic.removeAll()
        var rewriteMessageArray: [IGPRoomMessage] = []
        try! IGDatabaseManager.shared.realm.write {
            for message in messages {
                let realmRoomMessage = IGRoomMessage.putOrUpdate(igpMessage: message, roomId: roomId, options: options)
                if realmRoomMessage == nil {
                    rewriteMessageArray.append(message)
                }
            }
        }
        if rewriteMessageArray.count > 0 {
            manageRewriteMessage(roomId: roomId, messages: rewriteMessageArray, options: options)
        }
    }
}
