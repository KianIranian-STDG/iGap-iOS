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

class IGAvatar: Object{

    @objc dynamic var id:     Int64   = 0
    @objc dynamic var ownerId:Int64   = 0 // userId for users and roomId for rooms
    @objc dynamic var file:   IGFile?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["ownerId"]
    }
    
    convenience init(igpAvatar: IGPAvatar, ownerId: Int64) {
        self.init()
        self.id = igpAvatar.igpID
        self.ownerId = ownerId
        let predicateAvatar = NSPredicate(format: "cacheID = %@", igpAvatar.igpFile.igpCacheID)
        let avatarFile = try! Realm().objects(IGFile.self).filter(predicateAvatar).first
        if avatarFile == nil {
            self.file = IGFile(igpFile: igpAvatar.igpFile, type: .image)
        } else {
            self.file = avatarFile
        }
    }
    
    convenience init(avatarId: Int64, file: IGFile) {
        self.init()
        self.id = avatarId
        self.file = file
    }
    
    //MARK:- Avatar Update
    
    public static func putOrUpdate(igpAvatar: IGPAvatar, ownerId: Int64) -> IGAvatar {
        let predicate = NSPredicate(format: "id = %lld", igpAvatar.igpID)
        var avatar: IGAvatar! = IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(predicate).first
        if avatar == nil {
            avatar = IGAvatar()
            avatar.id = igpAvatar.igpID
        }
        avatar.ownerId = ownerId
        avatar.file = IGFile.putOrUpdate(igpFile: igpAvatar.igpFile, fileType: .image, filePathType: .avatar)
        IGDatabaseManager.shared.realm.add(avatar)
        return avatar
    }
    
    /** put avatar to realm and manage need delete any avatar for this ownerId or no */
    public static func putOrUpdateAndManageDelete(ownerId: Int64, igpAvatar: IGPAvatar) -> IGAvatar {

        /** if bigger than avatar.igpID exist avatar means that user deleted an avatar which has more priority */
        IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "ownerId == %lld AND id > %lld", ownerId, igpAvatar.igpID)))
        
        var avatar = IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "id == %lld", igpAvatar.igpID)).first
        if avatar == nil {
            avatar = IGAvatar()
            avatar!.id = igpAvatar.igpID
            avatar!.ownerId = ownerId
        }
        avatar!.file = IGFile.putOrUpdate(igpFile: igpAvatar.igpFile, fileType: IGFile.FileType.image, filePathType: .avatar)
        IGDatabaseManager.shared.realm.add(avatar!)
        
        return avatar!
    }
    
    //MARK:- Avatar Fetch
    
    public static func getAvatarsLocalList(ownerId: Int64) -> Results<IGAvatar> {
        return IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "ownerId == %lld", ownerId)).sorted(byKeyPath: "id", ascending: false)
    }
    
    /**
     * return latest avatar with this ownerId
     *
     * @param ownerId if is user set userId and if is room set roomId
     * @return return latest RealmAvatar for this ownerId
     */
    public static func getLastAvatar(ownerId: Int64) -> IGAvatar? {
        return IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "ownerId == %lld", ownerId)).sorted(byKeyPath: "id", ascending: false).first
    }
    
    public static func hasAvatar(ownerId: Int64) -> Bool {
        return IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "ownerId == %lld", ownerId)).sorted(byKeyPath: "id", ascending: false).first != nil
    }
    
    //MARK:- Avatar Add
    
    public static func addAvatarList(ownerId: Int64, avatars: [IGPAvatar]){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                for avatar in avatars {
                    IGDatabaseManager.shared.realm.add(IGAvatar.putOrUpdate(igpAvatar: avatar, ownerId: ownerId), update: .modified)
                }
            }
        }
    }

    
    //MARK:- Avatar Delete
    /**
     * Hint:use in transaction
     * delete all avatars from RealmAvatar
     *
     * @param ownerId use this id for delete from RealmAvatar
     */
    public static func deleteAllAvatars(ownerId: Int64) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "ownerId == %lld", ownerId)))
            }
        }
    }
    
    public static func deleteAvatar(roomId: Int64 = 0, avatarId: Int64) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "id == %lld", avatarId)))
            }
            if roomId != 0 {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    try! IGDatabaseManager.shared.realm.write {
                        IGRoom.updateAvatar(roomId: roomId, avatar: IGAvatar.getLastAvatar(ownerId: roomId))
                    }
                }
            }
        }
    }
    
    public static func deleteAllAvatarsTest(ownerId: Int64) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let avatars = IGDatabaseManager.shared.realm.objects(IGAvatar.self).filter(NSPredicate(format: "ownerId == %lld", ownerId)).sorted(byKeyPath: "id", ascending: true)
                for (index,avatar) in avatars.enumerated() {
                    if index < avatars.count-2 {
                        IGDatabaseManager.shared.realm.delete(avatar)
                    }
                }
            }
        }
    }
    
    
    //MARK:- Avatar Detach
    //detach from current realm
    func detach() -> IGAvatar {
        let detahcedAvatar = IGAvatar(value: self)
        if let file = detahcedAvatar.file {
            let detachedFile = file.detach()
            detahcedAvatar.file = detachedFile
        }
        return detahcedAvatar
    }
}
