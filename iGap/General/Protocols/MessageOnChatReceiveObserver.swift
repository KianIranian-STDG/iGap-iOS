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

protocol MessageOnChatReceiveObserver {
    func onMessageRecieveInChatPage(roomId: Int64, message: IGPRoomMessage, roomType: IGPRoom.IGPType)
    func onMessageUpdate(roomId: Int64, message: IGPRoomMessage, identity: IGRoomMessage) /* identity is client message without receive any response from server */
    func onMessageUpdateStatus(messageId: Int64)
    func onLocalMessageUpdateStatus(localMessage: IGRoomMessage) /* identity is client message without receive any response from server */
    func onMessageEdit(messageId: Int64, roomId: Int64, message: String, messageType: IGPRoomMessageType, messageVersion: Int64)
    func onMessageDelete(roomId: Int64, messageId: Int64)
}
