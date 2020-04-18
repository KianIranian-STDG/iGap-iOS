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
    @objc dynamic var targetUserId:   Int64 = -1
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
        
        if let user = message.authorUser?.user {
            if user.username == IGAppManager.sharedManager.username() {
                actorUsernameTitle = IGStringsManager.You.rawValue.localized
            } else {
                actorUsernameTitle = user.displayName
            }
        } else {
            actorUsernameTitle = IGStringsManager.SomeOne.rawValue.localized
        }
        
        var bodyString = ""
        switch (message.log?.type)! {
        case .userJoined:
            if message.authorRoom != nil {
                bodyString = IGStringsManager.JoinedIgap.rawValue.localized
            } else {
                bodyString = actorUsernameTitle + " " + IGStringsManager.JoinedIgap.rawValue.localized
                
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.JoinedIgap.rawValue.localized)"
                    
                } else {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.JoinedIgap.rawValue.localized)"
                }

            }
        case .userDeleted:
            if message.authorRoom != nil {
                bodyString = IGStringsManager.LeftIgap.rawValue.localized
            } else {
                bodyString = actorUsernameTitle + " " + IGStringsManager.LeftIgap.rawValue.localized
                
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.LeftIgap.rawValue.localized)"
                    
                } else {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.LeftIgap.rawValue.localized)"
                }

            }
        case .roomCreated:
            if message.authorRoom != nil {
                bodyString = IGStringsManager.ChannelCreated.rawValue.localized
            } else {
                bodyString = actorUsernameTitle + " " + IGStringsManager.RoomCreated.rawValue.localized
                
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    if actorUsernameTitle == IGStringsManager.You.rawValue.localized {
                        bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.RoomCreatedByU.rawValue.localized)"
                    } else {
                        bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.RoomCreated.rawValue.localized)"
                    }

                    
                } else {
                    if actorUsernameTitle == IGStringsManager.You.rawValue.localized {
                        bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.RoomCreatedByU.rawValue.localized)"
                    } else {
                        bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.RoomCreated.rawValue.localized)"
                    }

                }

            }
            
        case .memberAdded:
            if let target = message.log?.targetUser {
                var targetUserName = ""
                if !target.displayName.isEmpty {
                    targetUserName =  target.displayName
                } else if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
                    targetUserName =  user.displayName
                }
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    bodyString = "‏\(targetUserName) \(IGStringsManager.By.rawValue.localized) \(actorUsernameTitle) \(IGStringsManager.Added.rawValue.localized)"
                    
                } else {
                    bodyString = "‏\(actorUsernameTitle) ‏\(IGStringsManager.By.rawValue.localized) ‏\(IGStringsManager.Added.rawValue.localized) ‏\(targetUserName)"
                }


            } else {
      
                var targetUserName = ""
                if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
                    targetUserName =  user.displayName
                } else {
                    IGUserInfoRequest.sendRequest(userId: message.log!.targetUserId)
                }
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    bodyString = "‏\(targetUserName) \(IGStringsManager.By.rawValue.localized) \(actorUsernameTitle) \(IGStringsManager.Added.rawValue.localized)"
                    
                } else {
                    bodyString = "‏\(targetUserName) \(IGStringsManager.Added.rawValue.localized) \(IGStringsManager.By.rawValue.localized)\(actorUsernameTitle)"
                }



            }

            
        case .memberKicked:

                  if let target = message.log?.targetUser {
                      var targetUserName = ""
                      if !target.displayName.isEmpty {
                          targetUserName =  target.displayName
                      } else if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
                          targetUserName =  user.displayName
                      }
                      if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                          bodyString = "‏\(targetUserName) \(IGStringsManager.By.rawValue.localized) \(actorUsernameTitle) \(IGStringsManager.KickedOut.rawValue.localized)"
                          
                      } else {
                          bodyString = "‏\(actorUsernameTitle) ‏\(IGStringsManager.By.rawValue.localized) ‏\(IGStringsManager.KickedOut.rawValue.localized) ‏\(targetUserName)"
                      }


                  } else {
            
                      var targetUserName = ""
                      if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
                          targetUserName =  user.displayName
                      } else {
                          IGUserInfoRequest.sendRequest(userId: message.log!.targetUserId)
                      }
                      if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                          bodyString = "‏\(targetUserName) \(IGStringsManager.By.rawValue.localized) \(actorUsernameTitle) \(IGStringsManager.KickedOut.rawValue.localized)"
                          
                      } else {
                          bodyString = "‏\(targetUserName) \(IGStringsManager.KickedOut.rawValue.localized) \(IGStringsManager.By.rawValue.localized)\(actorUsernameTitle)"
                      }



                  }
        case .memberLeft:
            
//            bodyString = actorUsernameTitle + " " + IGStringsManager.LeftPage.rawValue.localized
            if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.LeftPage.rawValue.localized)"
                
            } else {
                bodyString = "‏\(IGStringsManager.LeftPage.rawValue.localized) \(actorUsernameTitle)"
            }

        case .roomConvertedToPublic:

            
            if message.authorRoom != nil {
                bodyString = IGStringsManager.PublicChannel.rawValue.localized
            } else {
                bodyString = actorUsernameTitle + " " + IGStringsManager.RoomCreated.rawValue.localized
                
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.ConvertedToPublic.rawValue.localized)"
                    
                } else {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.ConvertedToPublic.rawValue.localized)"
                }

            }
            
        case .roomConvertedToPrivate:

            
            
            if message.authorRoom != nil {
                bodyString = IGStringsManager.PrivateChannel.rawValue.localized
            } else {
                bodyString = actorUsernameTitle + " " + IGStringsManager.ConvertedToPrivate.rawValue.localized
                
                if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.ConvertedToPrivate.rawValue.localized)"
                    
                } else {
                    bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.ConvertedToPrivate.rawValue.localized)"
                }

            }

        case .memberJoinedByInviteLink:
//            bodyString = actorUsernameTitle + " " + IGStringsManager.JoinedByInvite.rawValue.localized
            

            if SMLangUtil.loadLanguage() == "fa" || SMLangUtil.loadLanguage() == "ar" {
                bodyString = "‏\(actorUsernameTitle) \(IGStringsManager.JoinedByInvite.rawValue.localized)"
                
            } else {
                bodyString = "‏\(IGStringsManager.JoinedByInvite.rawValue.localized) \(actorUsernameTitle)"
            }


            
        case .roomDeleted:
            bodyString = IGStringsManager.DeletedRoom.rawValue.localized
        case .missedVoiceCall:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = IGStringsManager.DidNotResponseToVoiceCall.rawValue.localized
            }else {
                bodyString = IGStringsManager.MissedVoiceCall.rawValue.localized
            }
        case .missedVideoCall:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = IGStringsManager.DidNotResponseToVideoCall.rawValue.localized
            }else {
                bodyString = IGStringsManager.MissedVideoCall.rawValue.localized
            }
        case .missedScreenShare:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = "Did not respond to your screen share"
            }else {
                bodyString = "Missed screen share"
            }
        case .missedSecretChat:
            if message.authorHash==IGAppManager.sharedManager.authorHash(){
                bodyString = "DID_NOT_RESPOND_TO_SCHAT"
            }else {
                bodyString = "Missed secret chat"
            }
        case .pinnedMessage:

            bodyString = IGRoomMessage.detectPinMessage(message: message)//IGRoom.getPinnedMessage(roomId: message.roomId)
            if bodyString.count >= 40 {
                bodyString = bodyString.substring(0, 35) + "..."
            }
        }
        
//        if let target = message.log?.targetUser {
//            if !target.displayName.isEmpty {
//                bodyString =  bodyString + " " + target.displayName
//            } else if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
//                bodyString =  bodyString + " " + user.displayName
//            }
//        } else {
//            if let user = IGRegisteredUser.getUserInfo(id: message.log!.targetUserId) {
//                bodyString =  bodyString + " " + user.displayName
//            } else {
//                IGUserInfoRequest.sendRequest(userId: message.log!.targetUserId)
//            }
//        }
        
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
        
        self.targetUserId = igpRoomMessageLog.igpTargetUser.igpID
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
        
        logInDb.targetUserId = igpRoomMessageLog.igpTargetUser.igpID
        logInDb.type = IGRoomMessageLog.LogType.fromIGP(type: igpRoomMessageLog.igpType)
        logInDb.extraType = IGRoomMessageLog.ExtraType.fromIGP(type: igpRoomMessageLog.igpExtraType)
        
        if igpRoomMessageLog.hasIgpTargetUser {
            let predicate = NSPredicate(format: "id = %lld", igpRoomMessageLog.igpTargetUser.igpID)
            if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
                logInDb.targetUser = userInDb
            }
        } else {
            IGUserInfoRequest.sendRequest(userId: igpRoomMessageLog.igpTargetUser.igpID)
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
