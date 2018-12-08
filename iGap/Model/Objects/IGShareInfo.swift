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
import UIKit
import IGProtoBuff

class IGShareInfo: Object {
    @objc dynamic  var id:            Int64                    = -1
    @objc dynamic  var itemId:        Int64                    = -1 // for contact & chatRoom is userId otherwise is roomId
    @objc dynamic  var type:          IGPRoom.IGPType.RawValue = 0
    @objc dynamic  var title:         String?
    @objc dynamic  var initials:      String?
    @objc dynamic  var initialsColor: String?
    @objc dynamic  var imageData:     Data?

    
    override static func primaryKey() -> String {
        return "id"
    }
    
    /* use this constructor for fill rooms info into the share info */
    convenience init(igpRoom: IGPRoom, id: Int64, imageData: Data?) {
        self.init()
        
        self.id = igpRoom.igpID
        self.itemId = id // userId for chat
        self.type = igpRoom.igpType.rawValue
        self.title = igpRoom.igpTitle
        self.initials = igpRoom.igpInitials
        self.initialsColor = igpRoom.igpColor
        self.imageData = imageData
    }
    
    /* use this constructor for fill contacts info into the share info */
    convenience init(igpUser: IGPRegisteredUser, imageData: Data?) {
        self.init()
        
        self.id = igpUser.igpID
        self.itemId = igpUser.igpID
        self.type = 4 // chat = 1, group = 2, channel = 3, contacts = 4
        self.title = igpUser.igpDisplayName
        self.initials = igpUser.igpInitials
        self.initialsColor = igpUser.igpColor
        self.imageData = imageData
    }
}
