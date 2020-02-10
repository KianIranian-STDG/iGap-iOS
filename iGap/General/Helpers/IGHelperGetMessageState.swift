/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

/* manage channel messages for update to latest state */
class IGHelperGetMessageState: UICollectionViewCell {
    
    static let shared = IGHelperGetMessageState()
    
    private let SEND_STATE_DELAY: Double = 5
    private var isWaiting = false // when 'checkLoop' is waiting for call don't run this method again for avoid from run multiple 'DispatchQueue'
    private var getViews: [Int64] = []
    private var getViewsMessage: [Int64: [Int64]] = [:]
    private var syncroniseViewMessageQueue = DispatchQueue(label: "thread-safe-view-message-obj", attributes: .concurrent)
    
    /* add messageId to list for send to server for update to latest message state */
    public func getMessageState(roomId: Int64, messageId: Int64) {
        
        if getViews.contains(messageId) {
            return
        }
        
        if !isWaiting {
            checkTimeOut()
        }
        
        getViews.append(messageId)
        
        if getViewsMessage[roomId] == nil {
            syncroniseViewMessageQueue.async(flags: .barrier) {
                self.getViewsMessage[roomId] = [messageId]
            }
            
        } else {
            var messageIdList = getViewsMessage[roomId]
            if !(messageIdList?.contains(messageId))! {
                messageIdList?.append(messageId)
                getViewsMessage[roomId] = messageIdList
            }
        }
    }
    
    /* send saved messageIdList to server for update state */
    private func sendMessageState() {
        
        for roomId in getViewsMessage.keys {
            let messageIdList = getViewsMessage[roomId]
            getViewsMessage.removeValue(forKey: roomId)
            if (messageIdList?.count)! > 0 {
                IGChannelGetMessagesStatsRequest.sendRequest(roomId: roomId, messageIdList: messageIdList!)
            }
        }
    }
    
    /**
     * clear getViews(ArrayList) .reason : when getViews contain a messageId
     * not allow that messageId send for getState. client clear this
     * array in enter to chat for allow message to get new state
     **/
    public func clearMessageViews() {
        getViews = []
    }
    
    /* if timedOut save message array, send update state request to server and clear message array */
    private func checkTimeOut() {
        isWaiting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + SEND_STATE_DELAY) {
            self.isWaiting = false
            if self.getViewsMessage.count > 0 {
                self.sendMessageState()
                self.checkTimeOut()
            }
        }
    }
}
