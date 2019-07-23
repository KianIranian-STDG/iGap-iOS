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
    //MARK: properties
    @objc dynamic var id:     Int64   = 0
    @objc dynamic var file:   IGFile?
    
    //MARK: override
    override static func primaryKey() -> String {
        return "id"
    }
    
    //MARK: init
    convenience init(igpAvatar: IGPAvatar) {
        self.init()
        self.id = igpAvatar.igpID
        
        // if file exist reuse it
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
    
    static func putOrUpdate(realm: Realm, igpAvatar: IGPAvatar) -> IGAvatar {
        let predicate = NSPredicate(format: "id = %lld", igpAvatar.igpID)
        var avatar: IGAvatar! = realm.objects(IGAvatar.self).filter(predicate).first
        if avatar == nil {
            avatar = IGAvatar()
            avatar.id = igpAvatar.igpID
        }
        avatar.file = IGFile.putOrUpdate(realm: realm, igpFile: igpAvatar.igpFile, fileType: .image)
        return avatar
    }
    
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
