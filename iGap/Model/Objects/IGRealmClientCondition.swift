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

class IGRealmOfflineSeen: Object {
    
    @objc dynamic var roomId:    Int64 = 0
    @objc dynamic var messageId: Int64 = 0
    
    convenience init(roomId: Int64, messageId: Int64) {
        self.init()
        self.roomId = roomId
        self.messageId = messageId
    }
}
