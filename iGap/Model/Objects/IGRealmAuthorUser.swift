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

class IGRealmAuthorUser: Object {

    @objc dynamic var userId: Int64 = -1 // userId is exist into the 'IGRegisteredUser' but somtimes client doesn't have userInfo so has to separately save userId
    @objc dynamic var userInfo: IGRegisteredUser!
    
    var user: IGRegisteredUser? {
        get {
            if self.userInfo != nil {
                return self.userInfo
            }
            if let userInfo = IGRegisteredUser.getUserInfo(id: self.userId) {
                return userInfo
            }
            return nil
        }
    }
    
    convenience init(_ author: IGPRoomMessage.IGPAuthor.IGPUser) {
        self.init()
        
        self.userId = author.igpUserID
        
        if let userInfo = IGRegisteredUser.getUserInfo(id: author.igpUserID) {
            self.userInfo = userInfo
            if userInfo.cacheID != author.igpCacheID {
                IGUserInfoRequest.sendRequest(userId: author.igpUserID)
            }
        } else {
            IGUserInfoRequest.sendRequest(userId: author.igpUserID)
        }
    }
    
    convenience init(_ userId: Int64) {
        self.init()
        
        self.userId = userId
        
        if let userInfo = IGRegisteredUser.getUserInfo(id: userId) {
            self.userInfo = userInfo
        }
    }
    
    func detach() -> IGRealmAuthorUser {
        let authorUser = IGRealmAuthorUser(value: self)
        if let userInfo = authorUser.userInfo {
            authorUser.userInfo = userInfo.detach()
        }
        return authorUser
    }
}

