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

class IGHelperMessage {
    
    static let shared = IGHelperMessage()
    
    public func handleMessageResponse(roomId: Int64, roomMessage: IGPRoomMessage, roomType: IGPRoom.IGPType, sender: Bool, structMessageIdentity: IGStructMessageIdentity?) {
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
            
            if let primaryKeyId = structMessageIdentity?.primaryKeyId {
                IGRoomMessage.deleteMessage(primaryKeyId: primaryKeyId)
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
                        room?.isParticipant = true
                        if let messageTime = realmRoomMessage?.creationTime?.timeIntervalSinceReferenceDate {
                            room?.sortimgTimestamp = messageTime
                        }
                    }
                } else {
                    room?.lastMessage = realmRoomMessage
                    room?.isParticipant = true
                    if let messageTime = realmRoomMessage?.creationTime?.timeIntervalSinceReferenceDate {
                        room?.sortimgTimestamp = messageTime
                    }
                }
            }
        }
        
        if (sender) {
            /**
             * invoke following callback when I'm the sender and the message has updated
             */
            IGMessageViewController.messageOnChatReceiveObserver?.onMessageUpdate(roomId: roomId, message: roomMessage, identity: structMessageIdentity!.roomMessage)
        } else {
            ///play send sound

            /**
             * invoke following callback when i'm not the sender, because i already done everything after sending message
             */
            IGMessageViewController.messageOnChatReceiveObserver?.onMessageRecieveInChatPage(roomId: roomId, message: roomMessage, roomType: roomType)
        }
        IGRecentsTableViewController.messageReceiveDelegat?.onMessageRecieveInRoomList(roomId: roomId ,messages: [roomMessage])
    }
    
    
    /** first check message existance in local THEN if message is not exist in local fetch message from server */
    public func getMessage(roomId: Int64, messageId: Int64, completion: @escaping (_ message: IGRoomMessage?) -> ()){
        
        if let message = IGRoomMessage.getMessageWithId(roomId: roomId, messageId: messageId) {
            if message.isDeleted {
                IGGlobal.prgHide()
                showDeletedMessageAlert()
            } else {
                completion(message)
            }
            return
        }
        
        IGClientGetRoomMessageRequest.Generator.generate(roomId: roomId, messageId: messageId, completion: completion).successPowerful({ (protoResponse, requestWrapper) in
            if let clientGetRoomMesasgeResponse = protoResponse as? IGPClientGetRoomMessageResponse {
                if let completion = requestWrapper.identity as? ((_ message: IGRoomMessage?) -> ()) {
                    if let requestMessage = requestWrapper.message as? IGPClientGetRoomMessage {
                        IGClientGetRoomMessageRequest.Handler.interpret(response: clientGetRoomMesasgeResponse, roomId: requestMessage.igpRoomID) { (message) in
                            if clientGetRoomMesasgeResponse.igpMessage.igpDeleted {
                                IGGlobal.prgHide()
                                self.showDeletedMessageAlert()
                            } else {
                                completion(message)
                            }
                        }
                    }
                }
            }
        }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
            if let completion = requestWrapper.identity as? ((_ messageId: IGRoomMessage?) -> ()) {
                completion(nil)
            }
        }).send()
    }
    
    private func showDeletedMessageAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "DELETED_MESSAGE_2".localizedNew, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil))
            UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
        }
    }
}
