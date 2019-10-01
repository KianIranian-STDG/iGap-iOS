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

class IGRealmChannelExtra: Object {
    
    @objc dynamic var messageId: Int64 = -1
    @objc dynamic var signature: String = "1"
    @objc dynamic var viewsLabel: String = "1"
    @objc dynamic var thumbsUpLabel: String = "1"
    @objc dynamic var thumbsDownLabel: String = "1"
    
    //init from network response
    convenience init(messageId: Int64, igpChannelExtra: IGPRoomMessage.IGPChannelExtra) {
        self.init()
        
        self.messageId = messageId
        self.signature = igpChannelExtra.igpSignature
        self.viewsLabel = igpChannelExtra.igpViewsLabel
        self.thumbsUpLabel = igpChannelExtra.igpThumbsUpLabel
        self.thumbsDownLabel = igpChannelExtra.igpThumbsDownLabel
    }
    
    static func putOrUpdate(realm: Realm, messageId: Int64, igpChannelExtra: IGPRoomMessage.IGPChannelExtra) -> IGRealmChannelExtra {
        let predicate = NSPredicate(format: "messageId = %lld", messageId)
        var channelExtra: IGRealmChannelExtra! = realm.objects(IGRealmChannelExtra.self).filter(predicate).first
        
        if channelExtra == nil {
            channelExtra = IGRealmChannelExtra()
            channelExtra.messageId = messageId
        }
        channelExtra.signature = igpChannelExtra.igpSignature
        channelExtra.viewsLabel = igpChannelExtra.igpViewsLabel
        channelExtra.thumbsUpLabel = igpChannelExtra.igpThumbsUpLabel
        channelExtra.thumbsDownLabel = igpChannelExtra.igpThumbsDownLabel
        
        return channelExtra
    }
    
    //detach from current realm
    func detach() -> IGRealmChannelExtra {
        let detachedChannelExtra = IGRealmChannelExtra(value: self)
        return detachedChannelExtra
    }
    
    
    internal static func addReaction(messageId: Int64, igpChannelAddMessageReactionResponse: IGPChannelAddMessageReactionResponse, reaction: IGPRoomMessageReaction){
        DispatchQueue.main.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "messageId == %lld", messageId)
                    if let channelExtra = IGDatabaseManager.shared.realm.objects(IGRealmChannelExtra.self).filter(predicate).first {
                        if reaction == IGPRoomMessageReaction.thumbsUp {
                            channelExtra.thumbsUpLabel = igpChannelAddMessageReactionResponse.igpReactionCounterLabel
                        } else {
                            channelExtra.thumbsDownLabel = igpChannelAddMessageReactionResponse.igpReactionCounterLabel
                        }
                    }
                }
            }
        }
    }
    
    internal static func updateStatus(roomId: Int64, igpChannelMessageStats: [IGPChannelGetMessagesStatsResponse.IGPStats]){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                for state in igpChannelMessageStats {
                    let predicate = NSPredicate(format: "messageId == %lld", state.igpMessageID)
                    if let channelExtra = IGDatabaseManager.shared.realm.objects(IGRealmChannelExtra.self).filter(predicate).first {
                        channelExtra.viewsLabel = state.igpViewsLabel
                        channelExtra.thumbsUpLabel = state.igpThumbsUpLabel
                        channelExtra.thumbsDownLabel = state.igpThumbsDownLabel
                    }
                }
            }

            IGMessageViewController.messageOnChatReceiveObserver?.onChannelGetMessageState(roomId: roomId)
        }
    }
}
