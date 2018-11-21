/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

enum IGSearchType {
    case bot
    case user
    case channel
    case group
    case message
    case hashtag
}

struct IGLookAndFindStruct {
    
    var room        : IGRoom!
    var user        : IGRegisteredUser!
    var message     : IGRoomMessage!
    var type        : IGSearchType!
    var isHeader    : Bool = false
    
    init(searchUsernameResult: IGPClientSearchUsernameResponse.IGPResult) {
        self.room = setRoom(room: searchUsernameResult.igpRoom)
        self.user = setUser(user: searchUsernameResult.igpUser)
        if searchUsernameResult.igpType == .room {
            if searchUsernameResult.igpRoom.igpType == .channel {
                self.type = .channel
            } else {
                self.type = .group
            }
        } else {
            self.type = .user
        }
    }
    
    init(type: IGSearchType) {
        self.type = type
        self.isHeader = true
    }
    
    init(room: IGRoom) {
        self.room = room
        if room.type == .channel {
            self.type = .channel
        } else {
            self.type = .group
        }
    }
    
    init(user: IGRegisteredUser) {
        self.user = user
        self.type = .user
    }
    
    init(message: IGRoomMessage, type: IGSearchType) {
        self.message = message
        self.type = type
    }
    
    init(room: IGRoom, user: IGRegisteredUser) {
        self.room = room
        self.user = user
        self.type = .user
    }
    
    
    public func setRoom(room: IGPRoom) -> IGRoom{
        let predicate = NSPredicate(format: "id = %lld", room.igpID)
        let realm = try! Realm()
        if let room = realm.objects(IGRoom.self).filter(predicate).first {
            return room
        } else {
            return IGRoom(igpRoom: room)
        }
    }
    
    public func setUser(user: IGPRegisteredUser) -> IGRegisteredUser{
        let predicate = NSPredicate(format: "id = %lld", user.igpID)
        let realm = try! Realm()
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            return userInDb
        } else {
            return IGRegisteredUser(igpUser: user)
        }
    }
}
