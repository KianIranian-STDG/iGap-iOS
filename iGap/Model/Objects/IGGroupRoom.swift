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

class IGGroupRoom: Object {
    enum IGType: Int {
        case privateRoom = 0
        case publicRoom
        
        static func fromIGP(type: IGPGroupRoom.IGPType) -> IGGroupRoom.IGType {
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
    enum IGRole: Int {
        case member = 0
        case moderator
        case admin
        case owner
    }

    
    //MARK: properties
    @objc dynamic var id:                         Int64                           = -1
    @objc dynamic var typeRaw:                    IGType.RawValue                 = IGType.privateRoom.rawValue
    @objc dynamic var roleRaw:                    IGPGroupRoom.IGPRole.RawValue   = IGPGroupRoom.IGPRole.member.rawValue
    @objc dynamic var participantCount:           Int32                           = 0
    @objc dynamic var participantCountText:       String                          = ""
    @objc dynamic var participantCountLimit:      Int32                           = 0
    @objc dynamic var participantCountLimitText:  String                          = ""
    @objc dynamic var roomDescription:            String                          = ""
    @objc dynamic var avatarCount:                Int32                           = 0
    @objc dynamic var avatar:                     IGAvatar?
    @objc dynamic var privateExtra:               IGGroupPrivateExtra?
    @objc dynamic var publicExtra:                IGGroupPublicExtra?
    
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
    var role: IGPGroupRoom.IGPRole {
        get {
            if let s = IGPGroupRoom.IGPRole(rawValue: roleRaw) {
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
    convenience init(igpGroupRoom: IGPGroupRoom, id: Int64) {
        self.init()
        self.id = id
        switch igpGroupRoom.igpType {
        case .privateRoom:
            self.type = .privateRoom
        case .publicRoom:
            self.type = .publicRoom
        default:
            break
        }
        switch igpGroupRoom.igpRole {
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
        self.participantCount = igpGroupRoom.igpParticipantsCount
        self.participantCountText = igpGroupRoom.igpParticipantsCountLabel
        self.participantCountLimit = igpGroupRoom.igpParticipantsCountLimit
        self.participantCountLimitText = igpGroupRoom.igpParticipantsCountLimitLabel
        self.roomDescription = igpGroupRoom.igpDescription
        self.avatarCount = igpGroupRoom.igpAvatarCount
        if igpGroupRoom.hasIgpAvatar {
            self.avatar = IGAvatar(igpAvatar: igpGroupRoom.igpAvatar, ownerId: id)
        }
        if igpGroupRoom.hasIgpPrivateExtra {
            self.privateExtra = IGGroupPrivateExtra(igpPrivateExtra: igpGroupRoom.igpPrivateExtra, id: id)
        }
        if igpGroupRoom.hasIgpPublicExtra {
            self.publicExtra = IGGroupPublicExtra(igpPublicExtra: igpGroupRoom.igpPublicExtra, id: id)
        }
    }
    
    static func putOrUpdate(realm: Realm, igpGroupRoom: IGPGroupRoom, id: Int64) -> IGGroupRoom {
        
        let predicate = NSPredicate(format: "id = %lld", id)
        var groupRoom: IGGroupRoom! = realm.objects(IGGroupRoom.self).filter(predicate).first
        
        if groupRoom == nil {
            groupRoom = IGGroupRoom()
            groupRoom.id = id
        }
        
        groupRoom.type = IGGroupRoom.IGType.fromIGP(type: igpGroupRoom.igpType)
        groupRoom.role = igpGroupRoom.igpRole
        
        groupRoom.participantCount = igpGroupRoom.igpParticipantsCount
        groupRoom.participantCountText = igpGroupRoom.igpParticipantsCountLabel
        groupRoom.participantCountLimit = igpGroupRoom.igpParticipantsCountLimit
        groupRoom.participantCountLimitText = igpGroupRoom.igpParticipantsCountLimitLabel
        groupRoom.roomDescription = igpGroupRoom.igpDescription
        groupRoom.avatarCount = igpGroupRoom.igpAvatarCount
        
        if igpGroupRoom.hasIgpAvatar {
            groupRoom.avatar = IGAvatar.putOrUpdateAndManageDelete(ownerId: id, igpAvatar: igpGroupRoom.igpAvatar)
        }
        if igpGroupRoom.hasIgpPrivateExtra {
            groupRoom.privateExtra = IGGroupPrivateExtra.putOrUpdate(realm: realm, igpPrivateExtra: igpGroupRoom.igpPrivateExtra, id: id)
        }
        if igpGroupRoom.hasIgpPublicExtra {
            groupRoom.publicExtra = IGGroupPublicExtra.put(realm: realm, igpPublicExtra: igpGroupRoom.igpPublicExtra, id: id)
        }
        
        return groupRoom
    }
    
    //detach from current realm
    func detach() -> IGGroupRoom {
        let detachedGroupRoom = IGGroupRoom(value: self)
        
        if let avatar = self.avatar {
            let detachedAvatar = avatar.detach()
            detachedGroupRoom.avatar = detachedAvatar
        }
        if let privateExtra = self.privateExtra {
            let detachedPrivateExtra = privateExtra.detach()
            detachedGroupRoom.privateExtra = detachedPrivateExtra
        }
        if let publicExtra = self.publicExtra {
            let detachedPublicExtra = publicExtra.detach()
            detachedGroupRoom.publicExtra = detachedPublicExtra
        }
        //assert(detachedGroupRoom.avatar?.realm == nil, "avatar has realm")
        //assert(detachedGroupRoom.privateExtra?.realm == nil, "detachedGroupRoom.privateExtra has realm")
        //assert(detachedGroupRoom.publicExtra?.realm == nil, "detachedGroupRoom.publicExtra has realm")
        
        return detachedGroupRoom
    }
}


class IGGroupPrivateExtra: Object {
    @objc dynamic var id:             Int64   = -1
    @objc dynamic var inviteLink:     String  = ""
    @objc dynamic var inviteToken:    String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPrivateExtra: IGPGroupRoom.IGPPrivateExtra, id: Int64) {
        self.init()
        self.id = id
        self.inviteLink = igpPrivateExtra.igpInviteLink
        self.inviteToken = igpPrivateExtra.igpInviteToken
    }
    
    static func putOrUpdate(realm: Realm, igpPrivateExtra: IGPGroupRoom.IGPPrivateExtra, id: Int64) -> IGGroupPrivateExtra {
        let predicate = NSPredicate(format: "id = %lld", id)
        var privateExtra: IGGroupPrivateExtra! = realm.objects(IGGroupPrivateExtra.self).filter(predicate).first
        if privateExtra == nil {
            privateExtra = IGGroupPrivateExtra()
            privateExtra.id = id
        }
        privateExtra.inviteLink = igpPrivateExtra.igpInviteLink
        privateExtra.inviteToken = igpPrivateExtra.igpInviteToken
        return privateExtra
    }
    
    //detach from current realm
    func detach() -> IGGroupPrivateExtra {
        return IGGroupPrivateExtra(value: self)
    }
}

class IGGroupPublicExtra: Object {
    @objc dynamic var id:         Int64   = -1
    @objc dynamic var username:   String  = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    convenience init(igpPublicExtra: IGPGroupRoom.IGPPublicExtra, id: Int64) {
        self.init()
        self.id = id
        self.username = igpPublicExtra.igpUsername
    }
    
    convenience init(id: Int64, username: String) {
        self.init()
        self.id = id
        self.username = username
    }
    
    static func put(realm: Realm, igpPublicExtra: IGPGroupRoom.IGPPublicExtra, id: Int64) -> IGGroupPublicExtra {
        let predicate = NSPredicate(format: "id = %lld", id)
        var publicExtra: IGGroupPublicExtra! = realm.objects(IGGroupPublicExtra.self).filter(predicate).first
        if publicExtra == nil {
            publicExtra = IGGroupPublicExtra()
            publicExtra.id = id
        }
        publicExtra.username = igpPublicExtra.igpUsername
        return publicExtra
    }
    
    //detach from current realm
    func detach() -> IGGroupPublicExtra {
        return IGGroupPublicExtra(value: self)
    }
}
