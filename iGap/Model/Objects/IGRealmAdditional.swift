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

class IGRealmAdditional: Object {
    
    @objc dynamic var dataType:       Int32   = -1
    @objc dynamic var data:           String?
    
    convenience init(message: IGPRoomMessage) {
        self.init()
        
        self.dataType = message.igpAdditionalType
        self.data = message.igpAdditionalData
    }
    
    convenience init(additionalData: String, additionalType: Int32) {
        self.init()
        
        self.dataType = additionalType
        self.data = additionalData
    }
}
