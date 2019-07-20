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
import RealmSwift

class IGHelperMessageResponse {
    
    static let shared = IGHelperMessageResponse()
    
    public func handleMessage(roomId: Int64, roomMessage: IGPRoomMessage, roomType: IGPRoom.IGPType, sender: Bool, oldMessage: IGRoomMessage?) {
        let realm = try! Realm()
        try! realm.write {
            
            /**
             * put message to realm
             */
            let realmRoomMessage = IGRoomMessage.putOrUpdate(igpMessage: roomMessage, roomId: roomId, options: IGStructMessageOption(isGap: true))
            let room = realm.objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", roomId)).first
            
            /**
             * because user may have more than one device, his another device should not
             * be recipient but sender. so I check current userId with room message user id,
             * and if not equals and response is null, so we sure recipient is another user
             */
            if roomMessage.igpAuthor.igpHash != IGAppManager.sharedManager.authorHash() {
                /**
                 * i'm recipient
                 *
                 * if author has user check that client have latest info for this user or no
                 * if author don't have use this means that message is from channel so client
                 * don't have user id for message sender for get info
                 */
                if (roomMessage.igpAuthor.hasIgpUser) {
                    let _ = IGRegisteredUser.needUpdateUser(userId: roomMessage.igpAuthor.igpUser.igpUserID, cacheId: roomMessage.igpAuthor.igpUser.igpCacheID)
                }
            }
            
            //TODO - do better action instead repeat method with delay
            if (oldMessage != nil) {
                IGRoomMessage.deleteMessage(primaryKeyId: oldMessage!.primaryKeyId!)
            }
            
            if (room == nil) {
                /**
                 * if first message received but the room doesn't exist, send request for create new room
                 */
                IGClientGetRoomRequest.sendRequest(roomId: roomId)
            } else {
                
                /**
                 * update unread count if new messageId that received is bigger than latest messageId that exist
                 */
                
                if (roomMessage.igpAuthor.igpHash != IGAppManager.sharedManager.authorHash()) && (room?.lastMessage == nil || (room?.lastMessage!.id)! < roomMessage.igpMessageID) {
                    room?.unreadCount = room!.unreadCount + 1
                }
                
                /*
                if roomMessage.igpAuthor.igpHash != IGAppManager.sharedManager.authorHash() {
                    if roomMessage.igpStatus != IGPRoomMessageStatus.seen {
                        // manage show local notification
                    }
                }
                */
                
                /**
                 * update last message sent/received in room table
                 */
                if let lastMessage = room?.lastMessage {
                    if lastMessage.id <= roomMessage.igpMessageID {
                        room?.lastMessage = realmRoomMessage
                        if let messageTime = realmRoomMessage.creationTime?.timeIntervalSinceReferenceDate {
                            room!.sortimgTimestamp = messageTime
                        }
                    }
                } else {
                    room?.lastMessage = realmRoomMessage
                    if let messageTime = realmRoomMessage.creationTime?.timeIntervalSinceReferenceDate {
                        room!.sortimgTimestamp = messageTime
                    }
                }
            }
        }
        
        if (sender) {
            /**
             * invoke following callback when I'm the sender and the message has updated
             */
            IGMessageViewController.messageOnChatReceiveObserver?.onMessageUpdate(roomId: roomId, message: roomMessage, identity: oldMessage!)
        } else {
            /**
             * invoke following callback when i'm not the sender, because i already done everything after sending message
             */
            IGMessageViewController.messageOnChatReceiveObserver?.onMessageRecieveInChatPage(roomId: roomId, message: roomMessage, roomType: roomType)
        }
        IGRecentsTableViewController.messageReceiveDelegat?.onMessageRecieveInRoomList(messages: [roomMessage])
    }
}
