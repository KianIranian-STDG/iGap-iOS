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

struct IGStructMessageOption {
    
    /**
     * if is gap we need set message id in {@link net.iGap.realm.RealmRoomMessage#previousMessageId}
     * or {@link net.iGap.realm.RealmRoomMessage#futureMessageId} for detect all messages that not
     * exist in local database and we have to fetch messages from server
     */
    public var previousGap = false
    public var futureGap = false
    
    /**
     * if is forward or reply we need create new message with new fake id for avoid from interference
     * forwarded or replied message with main message if exist in another room
     */
    public var isForward = false
    public var isReply = false
    
    /**
     * if is from share media we need set gap if is new message and before not exist in realm
     */
    public var isFromShareMedia = false
    
    /**
     * if is cache enable load room message from memory (from "IGGlobal.importedRoomMessageDic")
     */
    public var isEnableCache = false
    
    
    init(previousGap: Bool = false, futureGap: Bool = false, isForward: Bool = false, isReply: Bool = false, isFromShareMedia: Bool = false, isEnableCache: Bool = false) {
        self.previousGap = previousGap
        self.futureGap = futureGap
        self.isForward = isForward
        self.isReply = isReply
        self.isFromShareMedia = isFromShareMedia
        self.isEnableCache = isEnableCache
    }
}
