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

class IGRegisteredUser: Object {
    
    enum IGLastSeenStatus: Int {
        case longTimeAgo = 0
        case lastMonth
        case lastWeek
        case online
        case exactly
        case recently
        case support
        case serviceNotification
        
        static func fromIGP(status: IGPRegisteredUser.IGPStatus) -> IGLastSeenStatus {
            switch status {
            case .longTimeAgo:
                return .longTimeAgo
            case .lastMonth:
                return .lastMonth
            case .lastWeek:
                return .lastWeek
            case .online:
                return .online
            case .exactly:
                return .exactly
            case .recently:
                return .recently
            case .support:
                return .support
            case .serviceNotifications:
                return .serviceNotification
            case .UNRECOGNIZED(_):
                return .longTimeAgo
            }
        }
        
        static func fromIGP(status: IGLastSeenStatus?, lastSeen: Date?) -> String {
            if status == nil {
                return ""
            }
            
            switch status! {
            case .longTimeAgo:
                return IGStringsManager.LongTimeAgo.rawValue.localized
            case .lastMonth:
                return IGStringsManager.LastMonth.rawValue.localized
            case .lastWeek:
                return IGStringsManager.Lastweak.rawValue.localized
            case .online:
                return IGStringsManager.Online.rawValue.localized
            case .exactly:
                if lastSeen == nil {
                    return ""
                }
                return "\(lastSeen!.humanReadableForLastSeen())".inLocalizedLanguage()
            case .recently:
                return IGStringsManager.NavLastSeenRecently.rawValue.localized
            case .support:
                return IGStringsManager.IgapSupport.rawValue.localized
            case .serviceNotification:
                return IGStringsManager.NotificationServices.rawValue.localized
            }
        }
    }
    
    //properties
    @objc dynamic var id:                 Int64                       = -1
    @objc dynamic var phone:              Int64                       = -1
    @objc dynamic var avatarCount:        Int32                       = 0
    @objc dynamic var selfRemove:         Int32                       = -1
    @objc dynamic var cacheID:            String                      = ""
    @objc dynamic var username:           String                      = ""
    @objc dynamic var firstName:          String                      = ""
    @objc dynamic var lastName:           String                      = ""
    @objc dynamic var displayName:        String                      = ""
    @objc dynamic var email:              String?                     = ""
    @objc dynamic var bio:                String?
    @objc dynamic var initials:           String                      = ""
    @objc dynamic var color:              String                      = ""
    @objc dynamic var lastSeen:           Date?
    @objc dynamic var avatar:             IGAvatar?
    @objc dynamic var isDeleted:          Bool                        = false
    @objc dynamic var isMutual:           Bool                        = false //current user have this user in his/her contacts
    @objc dynamic var isInContacts:       Bool                        = false
    @objc dynamic var isBlocked:          Bool                        = false
    @objc dynamic var isVerified:         Bool                        = false
    @objc dynamic var isBot:              Bool                        = false
    @objc dynamic var lastSeenStatusRaw:  IGLastSeenStatus.RawValue   = IGLastSeenStatus.longTimeAgo.rawValue
    
    //ignored properties
    var lastSeenStatus: IGLastSeenStatus {
        get {
            if let s = IGLastSeenStatus(rawValue: lastSeenStatusRaw) {
                return s
            }
            return .longTimeAgo
        }
        set {
            lastSeenStatusRaw = newValue.rawValue
        }
    }
    
    //override
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["lastSeenStatus"]
    }
    
    //initilizers
    convenience init(id: Int64, cacheID: String) {
        self.init()
        self.id = id
        self.cacheID = cacheID
    }
    
    convenience init(igpAuthor : IGPRoomMessage.IGPAuthor) {
        self.init()
        self.id = igpAuthor.igpUser.igpUserID
        self.cacheID = igpAuthor.igpUser.igpCacheID
    }
    
    convenience init(igpUser: IGPRegisteredUser) {
        self.init()
        self.id = igpUser.igpID
        self.phone = igpUser.igpPhone
        self.avatarCount = igpUser.igpAvatarCount
        self.cacheID = igpUser.igpCacheID
        self.username = igpUser.igpUsername
        self.firstName = igpUser.igpFirstName
        self.lastName = igpUser.igpLastName
        self.displayName = igpUser.igpDisplayName
        self.initials = igpUser.igpInitials
        self.color = igpUser.igpColor
        self.bio = igpUser.igpBio
        switch igpUser.igpStatus {
        case .longTimeAgo:
            self.lastSeenStatus = .longTimeAgo
        case .lastMonth:
            self.lastSeenStatus = .lastMonth
        case .lastWeek:
            self.lastSeenStatus = .lastWeek
        case .online:
            self.lastSeenStatus = .online
        case .exactly:
            self.lastSeenStatus = .exactly
        case .recently:
            self.lastSeenStatus = .recently
        case .support:
            self.lastSeenStatus = .support
        case .serviceNotifications:
            self.lastSeenStatus = .serviceNotification
        case .UNRECOGNIZED(_):
            self.lastSeenStatus = .longTimeAgo
        }
        
        self.lastSeen = Date(timeIntervalSince1970: TimeInterval(igpUser.igpLastSeen))
        self.isDeleted = igpUser.igpDeleted
        self.isMutual = igpUser.igpMutual
        if igpUser.hasIgpAvatar{
            self.avatar = IGAvatar(igpAvatar: igpUser.igpAvatar, ownerId: igpUser.igpID)//.detach()
        }
        
        self.isVerified = igpUser.igpVerified
        self.isBot = igpUser.igpBot
        let oldInfo = IGRegisteredUser.fetchOldInfo(userId: igpUser.igpID)
        self.isInContacts = oldInfo.isInContact
        self.isBlocked = oldInfo.isBlocked
    }
    
    static func putOrUpdate(realm: Realm? = nil, igpUser: IGPRegisteredUser) -> IGRegisteredUser {
        
        var realmFinal: Realm! = realm
        if realmFinal == nil {
            realmFinal = IGDatabaseManager.shared.realm
        }
        
        let predicate = NSPredicate(format: "id = %lld", igpUser.igpID)
        var user: IGRegisteredUser! = realmFinal.objects(IGRegisteredUser.self).filter(predicate).first
        
        if user == nil {
            user = IGRegisteredUser()
            user.id = igpUser.igpID
        }
        
        user.phone = igpUser.igpPhone
        user.avatarCount = igpUser.igpAvatarCount
        user.cacheID = igpUser.igpCacheID
        user.username = igpUser.igpUsername
        user.firstName = igpUser.igpFirstName
        user.lastName = igpUser.igpLastName
        user.displayName = igpUser.igpDisplayName
        user.initials = igpUser.igpInitials
        user.color = igpUser.igpColor
        user.lastSeenStatus = IGRegisteredUser.IGLastSeenStatus.fromIGP(status: igpUser.igpStatus)
        user.lastSeen = Date(timeIntervalSince1970: TimeInterval(igpUser.igpLastSeen))
        user.isDeleted = igpUser.igpDeleted
        user.isMutual = igpUser.igpMutual
        user.isVerified = igpUser.igpVerified
        user.isBot = igpUser.igpBot
        user.bio = igpUser.igpBio

        if igpUser.hasIgpAvatar {
            user.avatar = IGAvatar.putOrUpdateAndManageDelete(ownerId: igpUser.igpID, igpAvatar: igpUser.igpAvatar)
        }
        return user
    }
    
    /**
     * compare user cacheId , if was equal don't do anything
     * otherwise send request for get user info
     *
     * @param userId  userId for get old cacheId from RealmRegisteredInfo
     * @param cacheId new cacheId
     * @return return true if need update otherwise return false
     */
    
    public static func needUpdateUser(userId: Int64, cacheId: String?) -> Bool {
        let realmRegisteredInfo = IGRegisteredUser.getUserInfo(id: userId)
        if (realmRegisteredInfo != nil && cacheId != nil && realmRegisteredInfo?.cacheID == cacheId) {
            return false
        }
        IGUserInfoRequest.sendRequestAvoidDuplicate(userId: userId)
        return true
    }

    
    //detach from current realm
    func detach() -> IGRegisteredUser {
        let detachedUser = IGRegisteredUser(value: self)
        if let avatar = detachedUser.avatar {
            let detachedAvatar = avatar.detach()
            detachedUser.avatar = detachedAvatar
        }
        return detachedUser
    }

    internal static func getUserIdWithPhone(phone: String?) -> Int64? {
        if phone != nil && !(phone?.isEmpty)! , let phoneNumber = Int64(phone!) {
            if let user = try! Realm().objects(IGRegisteredUser.self).filter(NSPredicate(format: "phone = %lld", phoneNumber)).first {
                return user.id
            }
        }
        return nil
    }
    
    internal static func getUserInfo(id: Int64) -> IGRegisteredUser? {
        if let user = try! Realm().objects(IGRegisteredUser.self).filter(NSPredicate(format: "id = %lld", id)).first {
            return user
        }
        return nil
    }
    
    internal static func fetchOldInfo(userId: Int64) -> (isInContact: Bool, isBlocked: Bool) {
        if let user = try! Realm().objects(IGRegisteredUser.self).filter(NSPredicate(format: "id = %lld", userId)).first {
            return (user.isInContacts, user.isBlocked)
        }
        return (false, false)
    }
    
    internal static func getPhoneWithUserId(userId: Int64) -> String? {
        if let user = try! Realm().objects(IGRegisteredUser.self).filter(NSPredicate(format: "id = %lld", userId)).first {
            return String(describing: user.phone) 
        }
        return nil
    }
}
