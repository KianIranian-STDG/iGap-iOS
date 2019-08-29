/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import SwiftyJSON

struct IGForwardStruct {

    var id: Int64!
    var typeRaw: IGRoom.IGType!
    var displayName: String!
    var initials: String!
    var color: String!
    var avatar: IGAvatar? = nil
    var selected: Bool = false
    
    init(_ room: IGRoom) {
        if room.typeRaw == IGRoom.IGType.chat.rawValue {
            self.id = (room.chatRoom?.peer!.id)!
            self.typeRaw = .chat
            self.avatar = room.chatRoom!.peer!.avatar
        } else if room.typeRaw == IGRoom.IGType.group.rawValue {
            self.id = room.id
            self.typeRaw = .group
            self.avatar = room.groupRoom?.avatar
        } else if room.typeRaw == IGRoom.IGType.channel.rawValue {
            self.id = room.id
            self.typeRaw = .channel
            self.avatar = room.channelRoom?.avatar
        }
        self.displayName = room.title!
        self.initials = room.initilas!
        self.color = room.colorString
        self.selected = false
    }
    
    init(_ user: IGRegisteredUser) {
        self.id = user.id
        self.typeRaw = .chat
        self.avatar = user.avatar
        self.displayName = user.displayName
        self.initials = user.initials
        self.color = user.color
        self.selected = false
    }
}
