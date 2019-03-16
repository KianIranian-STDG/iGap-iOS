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

class IGRoomMessageLog: Object {
    enum LogType: Int {
        case userJoined = 0
        case userDeleted
        case roomCreated
        case memberAdded
        case memberKicked
        case memberLeft
        case roomConvertedToPublic
        case roomConvertedToPrivate
        case memberJoinedByInviteLink
        case roomDeleted
        case missedVoiceCall
        case missedVideoCall
        case missedScreenShare
        case missedSecretChat
        case pinnedMessage
        
        static func fromIGP(type: IGPRoomMessageLog.IGPType) -> IGRoomMessageLog.LogType {
            switch type {
            case .userJoined:
                return .userJoined
            case .userDeleted:
                return .userDeleted
            case .roomCreated:
                return .roomCreated
            case .memberAdded:
                return .memberAdded
            case .memberKicked:
                return .memberKicked
            case .memberLeft:
                return .memberLeft
            case .roomConvertedToPublic:
                return .roomConvertedToPublic
            case .roomConvertedToPrivate:
                return .roomConvertedToPrivate
            case .memberJoinedByInviteLink:
                return .memberJoinedByInviteLink
            case .roomDeleted:
                return .roomDeleted
            case .missedVoiceCall:
                return .missedVoiceCall
            case .missedVideoCall:
                return .missedVideoCall
            case .missedSecretChat:
                return .missedSecretChat
            case .missedScreenShare:
                return .missedScreenShare
            case .pinnedMessage:
                return .pinnedMessage
            default:
                return .userJoined
            }
        }
    }
    
    enum ExtraType: Int {
        case noExtra
        case targetUser
        
        static func fromIGP(type: IGPRoomMessageLog.IGPExtraType) -> IGRoomMessageLog.ExtraType {
            switch type {
            case .noExtra:
                return .noExtra
            case .targetUser:
                return .targetUser
            default:
                return .noExtra
            }
        }
    }
    
    
    //properties
    @objc dynamic var id:             String?
    @objc dynamic var typeRaw:        LogType.RawValue    = LogType.userJoined.rawValue
    @objc dynamic var extraTypeRaw:   ExtraType.RawValue  = ExtraType.noExtra.rawValue
    @objc dynamic var targetUser:     IGRegisteredUser?
    //ignored properties
    var type: LogType {
        get {
            if let a = LogType(rawValue: typeRaw) {
                return a
            }
            return .userJoined
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    var extraType: ExtraType {
        get {
            if let a = ExtraType(rawValue: extraTypeRaw){
                return a
            }
            return .noExtra
        }
        
        set {
            extraTypeRaw = newValue.rawValue
        }
    }
    
    
    
    //MARK: - Class methods
    class func textForLogMessage(_ message: IGRoomMessage) -> String {
        var actorUsernameTitle = ""
        
        if let actor = message.authorUser {
            actorUsernameTitle = actor.displayName
        } else {
            actorUsernameTitle = "Someone"
        }
        
        var bodyString = ""
        switch (message.log?.type)! {
        case .userJoined:
            bodyString = actorUsernameTitle + " joined iGap"
        case .userDeleted:
            bodyString = actorUsernameTitle + " deleted their account"
        case .roomCreated:
            if message.authorRoom != nil {
                bodyString = "Channel was created"
            } else {
                bodyString = actorUsernameTitle + " created this room"
            }
        case .memberAdded:
            bodyString = actorUsernameTitle + " added"
        case .memberKicked:
            bodyString = actorUsernameTitle + " kicked"
        case .memberLeft:
            bodyString = actorUsernameTitle + " left"
        case .roomConvertedToPublic:
            if message.authorRoom != nil {
                bodyString = "This channel is now public"
            } else {
                bodyString = actorUsernameTitle + " changed room to public"
            }
        case .roomConvertedToPrivate:
            if message.authorRoom != nil {
                bodyString = "This channel is now private"
            } else {
                bodyString = actorUsernameTitle + " changed room to private"
            }
        case .memberJoinedByInviteLink:
            bodyString = actorUsernameTitle + " joined via invite link"
        case .roomDeleted:
            bodyString = "This room was deleted"
        case .missedVoiceCall:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = "Did not respond to your voice call"
            }else {
                bodyString = "Missed voice call"
            }
        case .missedVideoCall:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = "Did not respond to your video call"
            }else {
                bodyString = "Missed video call"
            }
        case .missedScreenShare:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = "Did not respond to your screen share"
            }else {
                bodyString = "Missed screen share"
            }
        case .missedSecretChat:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = "Did not respond to your secret chat"
            }else {
                bodyString = "Missed secret chat"
            }
        case .pinnedMessage:
            bodyString = IGRoomMessage.detectPinMessage(message: IGRoom.getPinnedMessage(roomId: message.roomId))
        }
        
        if let target = message.log?.targetUser {
            bodyString =  bodyString + " " + target.displayName
        }
        
        return bodyString
    }
    
    //MARK: - Instance methods
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["type", "extraType"]
    }
    
    convenience init(igpRoomMessageLog: IGPRoomMessageLog, for message: IGRoomMessage) {
        self.init()
        self.id = message.primaryKeyId
        
        
        switch igpRoomMessageLog.igpType {
        case .userJoined:
            self.type = .userJoined
        case .userDeleted:
            self.type = .userDeleted
        case .roomCreated:
            self.type = .roomCreated
        case .memberAdded:
            self.type = .memberAdded
        case .memberKicked:
            self.type = .memberKicked
        case .memberLeft:
            self.type = .memberLeft
        case .roomConvertedToPublic:
            self.type = .roomConvertedToPublic
        case .roomConvertedToPrivate:
            self.type = .roomConvertedToPrivate
        case .memberJoinedByInviteLink:
            self.type = .memberJoinedByInviteLink
        case .roomDeleted:
            self.type = .roomDeleted
        case .missedVoiceCall:
            self.type = .missedVoiceCall
        case .missedVideoCall:
            self.type = .missedVideoCall
        case .missedSecretChat:
            self.type = .missedSecretChat
        case .missedScreenShare:
            self.type = .missedScreenShare
        case .pinnedMessage:
            self.type = .pinnedMessage
        default:
            break
        }
        
        switch igpRoomMessageLog.igpExtraType {
        case .noExtra:
            self.extraType = .noExtra
        case .targetUser:
            self.extraType = .targetUser
        default:
            break
        }
        
        if igpRoomMessageLog.hasIgpTargetUser {
            let predicate = NSPredicate(format: "id = %lld", igpRoomMessageLog.igpTargetUser.igpID)
            let realm = try! Realm()
            if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                self.targetUser = userInDb
            }
        }
    }
    
    static func putOrUpdate(realm: Realm, igpRoomMessageLog: IGPRoomMessageLog, for message: IGRoomMessage) -> IGRoomMessageLog {
        
        let predicate = NSPredicate(format: "id = %@", message.primaryKeyId!)
        var logInDb: IGRoomMessageLog! = realm.objects(IGRoomMessageLog.self).filter(predicate).first

        if logInDb == nil {
            logInDb = IGRoomMessageLog()
            logInDb.id = message.primaryKeyId
        }
        
        logInDb.type = IGRoomMessageLog.LogType.fromIGP(type: igpRoomMessageLog.igpType)
        logInDb.extraType = IGRoomMessageLog.ExtraType.fromIGP(type: igpRoomMessageLog.igpExtraType)
        
        if igpRoomMessageLog.hasIgpTargetUser {
            let predicate = NSPredicate(format: "id = %lld", igpRoomMessageLog.igpTargetUser.igpID)
            if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                logInDb.targetUser = userInDb
            }
        }
        
        return logInDb
    }
    
    //detach from current realm
    func detach() -> IGRoomMessageLog {
        let detachedRoomMessageLog = IGRoomMessageLog(value: self)
        if let user = self.targetUser {
            let detachedUser = user.detach()
            detachedRoomMessageLog.targetUser = detachedUser
        }
        return detachedRoomMessageLog
    }
    
}
