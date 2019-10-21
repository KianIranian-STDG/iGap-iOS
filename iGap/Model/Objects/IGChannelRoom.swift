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

class IGChannelRoom: Object {
    enum IGType: Int {
        case privateRoom = 0
        case publicRoom
        
        static func fromIGP(type: IGPChannelRoom.IGPType) -> IGChannelRoom.IGType {
            switch type {
            case .privateRoom:
                return .privateRoom
            case .publicRoom:
                return .publicRoom
            default:
                return .privateRoom
            }
        }
    }
    
    //MARK: properties
    @objc dynamic  var id:                         Int64                           = -1
    @objc dynamic  var typeRaw:                    IGType.RawValue                 = IGType.privateRoom.rawValue
    @objc dynamic  var roleRaw:                    IGPChannelRoom.IGPRole.RawValue = IGPChannelRoom.IGPRole.member.rawValue
    @objc dynamic  var participantCount:           Int32                           = 0
    @objc dynamic  var participantCountText:       String                          = ""
    @objc dynamic  var roomDescription:            String                          = ""
    @objc dynamic  var avatarCount:                Int32                           = 0
    @objc dynamic  var avatar:                     IGAvatar?
    @objc dynamic  var privateExtra:               IGChannelPrivateExtra?
    @objc dynamic  var publicExtra:                IGChannelPublicExtra?
    @objc dynamic  var isSignature:                Bool                            = false
    @objc dynamic  var hasReaction:                Bool                            = false
    @objc dynamic  var isVerified:                 Bool                            = false
    //MARK: ignored properties
    var type: IGType {
        get {
            if let s = IGType(rawValue: typeRaw) {
                return s
            }
            return .privateRoom
        }
        set {
            typeRaw = newValue.rawValue
        }
    }
    
    var role: IGPChannelRoom.IGPRole {
        get {
            if let s = IGPChannelRoom.IGPRole(rawValue: roleRaw) {
                return s
            }
            return .member
        }
        set {
            roleRaw = newValue.rawValue
        }
    }

    //MARK: override
    override static func ignoredProperties() -> [String] {
        return ["type", "role"]
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    //MARK: init
    convenience init(igpChannelRoom: IGPChannelRoom, id: Int64) {
        self.init()
        self.id = id
        switch igpChannelRoom.igpType {
        case .privateRoom:
            self.type = .privateRoom
        case .publicRoom:
            self.type = .publicRoom
        default:
            break
        }
        switch igpChannelRoom.igpRole {
        case .member:
            self.role = .member
        case .moderator:
            self.role = .moderator
        case .admin:
            self.role = .admin
        case .owner:
            self.role = .owner
        default:
            break
        }
        self.participantCount = igpChannelRoom.igpParticipantsCount
        self.participantCountText = igpChannelRoom.igpParticipantsCountLabel
        self.roomDescription = igpChannelRoom.igpDescription
        self.avatarCount = igpChannelRoom.igpAvatarCount
        if igpChannelRoom.hasIgpAvatar{
            self.avatar = IGAvatar(igpAvatar: igpChannelRoom.igpAvatar)
        }
        if igpChannelRoom.hasIgpPrivateExtra {
            self.privateExtra = IGChannelPrivateExtra(igpPrivateExtra: igpChannelRoom.igpPrivateExtra, id: id)
        }
        if igpChannelRoom.hasIgpPublicExtra{
            self.publicExtra = IGChannelPublicExtra(igpPublicExtra: igpChannelRoom.igpPublicExtra, id: id)
        }
        
        self.isSignature = igpChannelRoom.igpSignature
        self.hasReaction = igpChannelRoom.igpReactionStatus
        self.isVerified = igpChannelRoom.igpVerified
    }
    
    static func putOrUpdate(realm: Realm, igpChannelRoom: IGPChannelRoom, id: Int64) -> IGChannelRoom {
        
        let predicate = NSPredicate(format: "id = %lld", id)
        var channelRoom: IGChannelRoom! = realm.objects(IGChannelRoom.self).filter(predicate).first
        
        if channelRoom == nil {
            channelRoom = IGChannelRoom()
            channelRoom.id = id
        }
        channelRoom.type = IGChannelRoom.IGType.fromIGP(type: igpChannelRoom.igpType)
        channelRoom.role = igpChannelRoom.igpRole
        
        channelRoom.participantCount = igpChannelRoom.igpParticipantsCount
        channelRoom.participantCountText = igpChannelRoom.igpParticipantsCountLabel
        channelRoom.roomDescription = igpChannelRoom.igpDescription
        channelRoom.avatarCount = igpChannelRoom.igpAvatarCount
        channelRoom.isSignature = igpChannelRoom.igpSignature
        channelRoom.hasReaction = igpChannelRoom.igpReactionStatus
        channelRoom.isVerified = igpChannelRoom.igpVerified
        
        if igpChannelRoom.hasIgpAvatar{
            channelRoom.avatar = IGAvatar.putOrUpdate(realm: realm, igpAvatar: igpChannelRoom.igpAvatar)
        }
        if igpChannelRoom.hasIgpPrivateExtra {
            channelRoom.privateExtra = IGChannelPrivateExtra.putOrUpdate(realm: realm, igpPrivateExtra: igpChannelRoom.igpPrivateExtra, id: id)
        }
        if igpChannelRoom.hasIgpPublicExtra{
            channelRoom.publicExtra = IGChannelPublicExtra.putOrUpdate(realm: realm, igpPublicExtra: igpChannelRoom.igpPublicExtra, id: id)
        }
        
        return channelRoom
    }
    
    internal static func updateReactionStatus(roomId: Int64, reactionStatus: Bool){
        DispatchQueue.main.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "id == %lld", roomId)
                    if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first, let channel = room.channelRoom {
                        channel.hasReaction = reactionStatus
                    }
                }
            }
        }
    }
    
    internal static func hasReaction(roomId: Int64) -> Bool {
        let predicate = NSPredicate(format: "id = %lld" ,roomId)
        if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first, let channel = room.channelRoom{
            return channel.hasReaction
        }
        return false
    }
    
    //detach from current realm
    func detach() -> IGChannelRoom {
        let detachedChannelRoom = IGChannelRoom(value: self)
        
        if let avatar = self.avatar {
            let detachedAvatar = avatar.detach()
            detachedChannelRoom.avatar = detachedAvatar
        }
        if let privateExtra = self.privateExtra {
            let detachedPrivateExtra = privateExtra.detach()
            detachedChannelRoom.privateExtra = detachedPrivateExtra
        }
        if let publicExtra = self.publicExtra {
            let detachedPublicExtra = publicExtra.detach()
            detachedChannelRoom.publicExtra = detachedPublicExtra
        }
        
        return detachedChannelRoom
    }

}


class IGChannelPrivateExtra: Object {
    @objc dynamic  var id:             Int64   = -1
    @objc dynamic  var inviteLink:     String  = ""
    @objc dynamic  var inviteToken:    String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPrivateExtra: IGPChannelRoom.IGPPrivateExtra, id: Int64) {
        self.init()
        self.id = id
        self.inviteLink = igpPrivateExtra.igpInviteLink
        self.inviteToken = igpPrivateExtra.igpInviteToken
    }
    
    static func putOrUpdate(realm: Realm, igpPrivateExtra: IGPChannelRoom.IGPPrivateExtra, id: Int64) -> IGChannelPrivateExtra {
        let predicate = NSPredicate(format: "id = %lld", id)
        var channelPrivateExtra: IGChannelPrivateExtra! = realm.objects(IGChannelPrivateExtra.self).filter(predicate).first
        if channelPrivateExtra == nil {
            channelPrivateExtra = IGChannelPrivateExtra()
            channelPrivateExtra.id = id
        }
        channelPrivateExtra.inviteLink = igpPrivateExtra.igpInviteLink
        channelPrivateExtra.inviteToken = igpPrivateExtra.igpInviteToken
        return channelPrivateExtra
    }
    
    //detach from current realm
    func detach() -> IGChannelPrivateExtra {
        return IGChannelPrivateExtra(value: self)
    }
}

class IGChannelPublicExtra: Object {
    @objc dynamic  var id:         Int64   = -1
    @objc dynamic  var username:   String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPublicExtra: IGPChannelRoom.IGPPublicExtra, id: Int64) {
        self.init()
        self.id = id
        self.username = igpPublicExtra.igpUsername
    }
    
    convenience init(id: Int64, username: String) {
        self.init()
        self.id = id
        self.username = username
    }
    
    static func putOrUpdate(realm: Realm, igpPublicExtra: IGPChannelRoom.IGPPublicExtra, id: Int64) -> IGChannelPublicExtra {
        let predicate = NSPredicate(format: "id = %lld", id)
        var channelPublicExtra: IGChannelPublicExtra! = realm.objects(IGChannelPublicExtra.self).filter(predicate).first
        if channelPublicExtra == nil {
            channelPublicExtra = IGChannelPublicExtra()
            channelPublicExtra.id = id
        }
        channelPublicExtra.username = igpPublicExtra.igpUsername
        return channelPublicExtra
    }
    
    //detach from current realm
    func detach() -> IGChannelPublicExtra {
        return IGChannelPublicExtra(value: self)
    }
}
