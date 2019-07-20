/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff

struct IGStructClientGetRoomHistoryIdentity {
    
    var firstMessageId : Int64!
    var reachMessageId : Int64!
    var onMessageReceive: ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> ())
    
    init(firstMessageId: Int64, reachMessageId: Int64, onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        self.firstMessageId = firstMessageId
        self.reachMessageId = reachMessageId
        self.onMessageReceive = onMessageReceive
    }
}
