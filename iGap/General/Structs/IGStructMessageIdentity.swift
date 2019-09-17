/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

/**
 * Reason of make this struct : when use from primaryKey of fakeMessage(localMessage)
 * after receive resopnse from server app will be crashed because of use realm in incorrect thread,
 * so i used following sturct for save primaryKeyId in another variable for avoid from this crash
 */
struct IGStructMessageIdentity {
    
    var roomMessage : IGRoomMessage!
    var primaryKeyId : String!
    
    init(roomMessage: IGRoomMessage) {
        self.roomMessage = roomMessage
        self.primaryKeyId = roomMessage.primaryKeyId
    }
}
