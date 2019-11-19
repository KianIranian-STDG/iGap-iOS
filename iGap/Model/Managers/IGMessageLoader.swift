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

/**
 * MessageLoader class for detect message from local db or get message from
 * server and finally return messges that should be load in the collection view
 *
 * Hint: in current class reason of usage for 'onMessageReceive' is return message exactly into the closure of method that started get message
 * so this is possible remove 'onMessageReceive' from all of the methods and use a global protocol
 */
class IGMessageLoader {
    
    private var addToView = false // allow to message for add to recycler view or no
    private var topMore = true // more message exist in local for load in up direction (topMore default value is true for allowing that try load top message )
    private var bottomMore = false // more message exist in local for load in bottom direction
    private var isWaitingForHistoryUpOnline = false // client send request for getHistory, avoid for send request again
    private var isWaitingForHistoryDownOnline = false // client send request for getHistory, avoid for send request again
    private var isWaitingForHistoryUpLocal = false // load message from local db for up direction. use this varible for avoid from multi call for "loadMessage" method at up direction. without this variable local messages will be loaded continuously to end.
    private var isWaitingForHistoryDownLocal = false // load message from local db for down direction. use this varible for avoid from multi call for "loadMessage" method at down direction. without this variable local messages will be loaded continuously to end.
    private var allowGetHistoryUp = true // after insuring for get end of message from server set this false. (set false in history error maybe was wrong , because maybe this was for another error not end  of message, (hint: can check error code for end of message from history))
    private var allowGetHistoryDown = true // after insuring for get end of message from server set this false. (set false in history error maybe was wrong , because maybe this was for another error not end  of message, (hint: can check error code for end of message from history))
    private var firstUpOnline = true // if is firstUpOnline getClientRoomHistory with low limit in UP direction
    private var firstDownOnline = true // if is firstDownOnline getClientRoomHistory with low limit in DOWN direction
    private var gapMessageIdUp: Int64 = 0 // messageId that maybe lost in local
    private var gapMessageIdDown: Int64 = 0 // messageId that maybe lost in local
    private var reachMessageIdUp: Int64 = 0 // messageId that will be checked after getHistory for detect reached to that or no
    private var reachMessageIdDown: Int64 = 0 // messageId that will be checked after getHistory for detect reached to that or no
    private var startFutureMessageIdUp: Int64 = 0 // for get history from local or online in next step use from this param, ( hint : don't use from adapter items, because maybe this item was deleted and in this changeState messageId for get history won't be detected.
    private var startFutureMessageIdDown: Int64 = 0 // for get history from local or online in next step use from this param, ( hint : don't use from adapter items, because maybe this item was deleted and in this changeState messageId for get history won't be detected.
    private var progressIdentifierUp: Int64 = 0 // store identifier for Up progress item and use it if progress not removed from view after check 'instanceOf' in 'progressItem' method
    private var progressIdentifierDown: Int64 = 0 // store identifier for Down progress item and use it if progress not removed from view after check 'instanceOf' in 'progressItem' method
    private var firstVisiblePosition: Int32 = 0 // difference between start of adapter item and items that Showing.
    private var firstVisiblePositionOffset: Int32 = 0 // amount of offset from top of view for first visible item in adapter
    private var visibleItemCount: Int32 = 0 // visible item in recycler view
    private var totalItemCount: Int32 = 0 // all item in recycler view
    private var scrollEnd: Int32 = 80 // (hint: It should be less than MessageLoader.LOCAL_LIMIT) to determine the limits to get to the bottom or top of the list
    private var topProgressId: Int64 = 0 // top real messageId plus one. save this value then for hide top progress find position of message and then remove
    private var bottomProgressId: Int64 = 0 // bottom real messageId minus one. save this value then for hide bottom progress find position of message and then remove
    private var firstLoadUp = true // first load message to the up direction for load from local or from server. after load set this variable to false. now we use this variable for set delay at first time load message.
    private var firstLoadDown = true // first load message to the down direction for load from local or from server. after load set this variable to false. now we use this variable for set delay at first time load message.
    private var forceFirstLoadUp = false // if exist 'unread' or 'savedScrollMessageId' set this param true for allow scroll top to load up message from local or server
    
    private var roomId: Int64 = 0
    private var roomType: IGRoom.IGType!
    private var savedScrollMessageId: Int64 = 0 // should be load chat from a specific message if value is not zero
    private var biggestMessageId: Int64 = 0
    private var messageId: Int64 = 0 // if set messageId this value will be overrided on savedScrollMessageId
    private var firstUnreadMessage: IGRoomMessage!
    private var firstUnreadMessageInChat: IGRoomMessage! // when user is in this room received new message
    private var unreadCount: Int32 = 0 // if unread count is not zero and not exist savedScrollMessageId so should be load chat from a specific message if value is not zero
    private var isShowLayoutUnreadMessage = false
    private let LIMIT_GET_HISTORY_LOW: Int32 = 10
    private let LIMIT_GET_HISTORY_NORMAL: Int32 = 25
    
    public static let STORE_MESSAGE_POSITION_LIMIT = 1
    
    let sortPropertiesUp = [SortDescriptor(keyPath: "creationTime", ascending: false), SortDescriptor(keyPath: "id", ascending: false)]
    let sortPropertiesDown = [SortDescriptor(keyPath: "creationTime", ascending: false), SortDescriptor(keyPath: "id", ascending: true)]
    
    init(room: IGRoom) {
        self.roomId = room.id
        self.roomType = room.type
        setUnreadCount(unreadCount: room.unreadCount)
        setFirstUnreadMessage(firstUnreadMessage: room.firstUnreadMessage)
        setSavedScrollMessageId(savedScrollMessageId: room.savedScrollMessageId)
    }
    
    /*************************************************/
    /******************** Setters ********************/
    
    private func setUnreadCount(unreadCount: Int32) {
        self.unreadCount = unreadCount
    }
    
    private func setFirstUnreadMessage(firstUnreadMessage: IGRoomMessage?) {
        self.firstUnreadMessage = firstUnreadMessage
    }
    
    public func setSavedScrollMessageId(savedScrollMessageId: Int64) {
        self.savedScrollMessageId = savedScrollMessageId
    }

    public func setWaitingHistoryUpLocal(isWaiting: Bool) {
        self.isWaitingForHistoryUpLocal = isWaiting
    }
    
    public func setWaitingHistoryDownLocal(isWaiting: Bool) {
        self.isWaitingForHistoryDownLocal = isWaiting
    }
    
    public func setFirstLoadUp(firstLoadUp: Bool) {
        self.firstLoadUp = firstLoadUp
    }
    
    public func setFirstLoadDown(firstLoadDown: Bool) {
        self.firstLoadDown = firstLoadDown
    }
    
    public func setForceFirstLoadUp(forceFirstLoadUp: Bool) {
        self.forceFirstLoadUp = forceFirstLoadUp
    }
    
    public func isShowingUnreadLayout() -> Bool {
        return isShowLayoutUnreadMessage
    }
    
    public func setDeepLinkMessageId(MessageId: Int64) {
        self.savedScrollMessageId = MessageId
    }
    
    /*************************************************/
    /******************** Getters ********************/
    
    public func allowAddToView() -> Bool {
        return addToView
    }
    
    public func isWaitingHistoryUpLocal() -> Bool {
        return isWaitingForHistoryUpLocal
    }
    
    public func isWaitingHistoryDownLocal() -> Bool {
        return isWaitingForHistoryDownLocal
    }
   
    public func isFetchingUpHistoryLocal(firstLoadUp: Bool) {
        self.firstLoadUp = firstLoadUp
    }
    
    public func isFirstLoadUp() -> Bool {
        return firstLoadUp
    }
    
    public func isFirstLoadDown() -> Bool {
        return firstLoadDown
    }
    
    public func isForceFirstLoadUp() -> Bool {
        return forceFirstLoadUp
    }
    
    /**
     * manage save changeState , unread message , load from local or need get message from server and finally load message
     */
    public func getMessages(onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        var direction: IGPClientGetRoomHistory.IGPDirection!
        var messageInfos: [IGRoomMessage] = []
        /**
         * get message in first enter to chat if has unread get message with down direction
         */
        
        var results: Results<IGRoomMessage>!
        var resultsDown: Results<IGRoomMessage>!
        var resultsUp: Results<IGRoomMessage>!
        
        var fetchMessageId: Int64 = 0 // with this value realm will be queried for get message
        
        if (hasUnread() || hasSavedState()) {
            setForceFirstLoadUp(forceFirstLoadUp: true)
            // TODO - Seems to not need check following code, just use firstUnreadMessage
            if firstUnreadMessage == nil || firstUnreadMessage.isInvalidated || firstUnreadMessage.isDeleted  {
                firstUnreadMessage = getFirstUnreadMessage()
            }
            /**
             * show unread layout and also set firstUnreadMessageId in startFutureMessageIdUp
             * for try load top message and also topMore default value is true for this target
             */
            if (hasUnread()) {
                if (firstUnreadMessage == nil) {
                    resetMessagingValue()
                    getMessages(onMessageReceive: onMessageReceive)
                    return
                }
                makeUnreadLayoutMessage(onMessageReceive: onMessageReceive)
                fetchMessageId = firstUnreadMessage.id
                
            } else {
                fetchMessageId = getSavedState()
                
                if (hasUnread()) {
                    if (firstUnreadMessage == nil) {
                        resetMessagingValue()
                        getMessages(onMessageReceive: onMessageReceive)
                        return
                    }
                    /*
                     countNewMessage = unreadCount;
                     txtNewUnreadMessage.setVisibility(View.VISIBLE);
                     txtNewUnreadMessage.setText(countNewMessage + "");
                     setDownBtnVisible();
                     */
                    firstUnreadMessageInChat = firstUnreadMessage
                }
            }
            
            startFutureMessageIdUp = fetchMessageId
            
            // Hint: is need to do following action?
            // we have firstUnreadMessage but for gapDetection method we need RealmResult so get this message with query; if we change gap detection method will be can use from firstUnreadMessage
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id = %lld ", roomId, fetchMessageId)
            resultsDown = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesDown)
            
            addToView = false
            direction = .down
        } else {
            setFirstLoadDown(firstLoadDown: false)
            addToView = true
            direction = .up
        }
        
        let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id != %lld AND statusRaw != %d AND statusRaw != %d", roomId, 0, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
        resultsUp = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesUp)
        
        var gapMessageId: Int64!
        
        if (direction == .down) {
            
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id <= %lld AND id != %lld", roomId, fetchMessageId, 0)
            resultsUp = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesUp)
            
            /**
             * if for UP changeState client have message detect gap otherwise try for get online message
             * because maybe client have message but not exist in Realm yet
             */
            
            if (resultsUp.count > 1) {
                let _ = gapDetection(results: resultsUp, direction: .up)
            } else {
                getOnlineMessage(oldMessageId: fetchMessageId, direction: .up, onMessageReceive: onMessageReceive)
            }

            results = resultsDown
            gapMessageId = gapDetection(results: results, direction: direction)
        } else {
            results = resultsUp
            gapMessageId = gapDetection(results: resultsUp, direction: .up)
        }
        
        if (results.count > 0) {
            let methodResult = getLocalMessage(roomId: roomId, messageId: results.first!.id, gapMessageId: gapMessageId, duplicateMessage: true, direction: direction, firstLoad: true)
            messageInfos = methodResult.realmRoomMessages
            
            if (messageInfos.count > 0) {
                if (direction == .up) {
                    topMore = methodResult.hasMore
                    startFutureMessageIdUp = Int64(messageInfos[messageInfos.count - 1].id)
                } else {
                    bottomMore = methodResult.hasMore
                    startFutureMessageIdDown = Int64(messageInfos[messageInfos.count - 1].id)
                }
            } else {
                if (direction == .up) {
                    startFutureMessageIdUp = 0
                } else {
                    startFutureMessageIdDown = 0
                }
            }
            
            /**
             * if gap is exist ,check that reached to gap or not and if
             * reached send request to server for clientGetRoomHistory
             */
            
            if (gapMessageId > 0) {
                let hasSpaceToGap: Bool = methodResult.hasSpaceToGap
                if (!hasSpaceToGap) {
                    var oldMessageId: Int64 = 0;
                    if (messageInfos.count > 0) {
                        /**
                         * this code is correct for UP or DOWN load message result
                         */
                        oldMessageId = Int64(messageInfos[messageInfos.count - 1].id)
                    }
                    /**
                     * send request to server for clientGetRoomHistory
                     */
                    getOnlineMessage(oldMessageId: oldMessageId, direction: direction, onMessageReceive: onMessageReceive)
                }
            } else {
                /**
                 * if gap not exist and also not exist more message in local
                 * send request for get message from server
                 */
                if ((direction == .up && !topMore) || (direction == .down && !bottomMore)) {
                    if (messageInfos.count > 0) {
                        getOnlineMessage(oldMessageId: messageInfos[messageInfos.count - 1].id, direction: direction, onMessageReceive: onMessageReceive)
                    } else {
                        getOnlineMessage(oldMessageId: 0, direction: direction, onMessageReceive: onMessageReceive)
                    }
                }
            }
        } else {
            /** send request to server for get message.
             * if direction is DOWN check again realmRoomMessage for detection
             * that exist any message without checking deleted changeState and if
             * exist use from that messageId instead of zero for getOnlineMessage
             */
            var oldMessageId: Int64 = 0
            if (direction == .down) {
                let predicate = NSPredicate(format: "roomId = %lld AND id = %lld", roomId, fetchMessageId)
                if let realmRoomMessage = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    oldMessageId = realmRoomMessage.id
                }
            }
            /**
             * at this state result count of message is zero so topMore is false, we need to set topMore to false for get second chuck from server
             * (Hint: previously problem was avoid from get history for second chunk, because of topMore was true so we tried to get history just from local!!!)
             */
            self.topMore = false
            getOnlineMessage(oldMessageId: oldMessageId, direction: direction, onMessageReceive: onMessageReceive)
        }
        
        if (direction == .up) {
            onMessageReceive(messageInfos, .up)
        } else {
            onMessageReceive(messageInfos, .down)
            
            // this block of code is for manage unread & save state together
            if (hasSavedState()) {
                
                if (messageId != 0) {
                    /*
                    if (goToPositionWithAnimation(savedScrollMessageId, 1000)) {
                        savedScrollMessageId = 0;
                    }
                    */
                } else {
                    /*
                    int position = mAdapter.findPositionByMessageId(savedScrollMessageId);
                    LinearLayoutManager linearLayout = (LinearLayoutManager) recyclerView.getLayoutManager();
                    linearLayout.scrollToPositionWithOffset(position, firstVisiblePositionOffset);
                    */
                    //savedScrollMessageId = 0;
                }
            }
        }
        
        /*
        if (unreadCount > 0) {
           recyclerView.scrollToPosition(0);
        }
        */
    }
    
    /**
     * manage load message from local or from server(online)
     */
    public func loadMessage(direction: IGPClientGetRoomHistory.IGPDirection, onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        var gapMessageId: Int64 = 0
        var startFutureMessageId: Int64 = 0
        if (direction == .up) {
            setWaitingHistoryUpLocal(isWaiting: true)
            gapMessageId = gapMessageIdUp
            startFutureMessageId = startFutureMessageIdUp
        } else {
            setWaitingHistoryDownLocal(isWaiting: true)
            gapMessageId = gapMessageIdDown
            startFutureMessageId = startFutureMessageIdDown
        }
        
        if ((direction == .up && topMore) || (direction == .down && bottomMore)) {
            let methodResult = getLocalMessage(roomId: roomId, messageId: startFutureMessageId, gapMessageId: gapMessageId, duplicateMessage: false, direction: direction)
            if (direction == .up) {
                topMore = methodResult.hasMore
            } else {
                bottomMore = methodResult.hasMore
            }
            
            let realmRoomMessages = methodResult.realmRoomMessages
            if (realmRoomMessages.count > 0) {
                if (direction == .up) {
                    startFutureMessageIdUp = Int64(realmRoomMessages[realmRoomMessages.count - 1].id)
                } else {
                    startFutureMessageIdDown = Int64(realmRoomMessages[realmRoomMessages.count - 1].id)
                }
            } else {
                /**
                 * don't set zero. when user come to room for first time with -@username-
                 * for example : @public ,this block will be called and set zero this value and finally
                 * don't allow to user for get top history, also seems to this block isn't helpful
                 */
                if (direction == .up) {
                    startFutureMessageIdUp = 0
                } else {
                    startFutureMessageIdDown = 0
                }
            }

            /* send existing message to the view */
            onMessageReceive(realmRoomMessages, direction)
            
            /**
             * if gap is exist ,check that reached to gap or not and if
             * reached send request to server for clientGetRoomHistory
             */
            if (gapMessageId > 0) {
                let hasSpaceToGap: Bool = methodResult.hasSpaceToGap
                if (!hasSpaceToGap) {
                    /**
                     * send request to server for clientGetRoomHistory
                     */
                    var oldMessageId: Int64!
                    if (realmRoomMessages.count > 0) {
                        oldMessageId = Int64(realmRoomMessages[realmRoomMessages.count - 1].id)
                    } else {
                        oldMessageId = gapMessageId
                    }
                    
                    getOnlineMessage(oldMessageId: oldMessageId, direction: direction, onMessageReceive: onMessageReceive)
                }
            }
        } else if (gapMessageId > 0) {
            /**
             * detect old messageId that should get history from server with that
             * (( hint : in scroll changeState never should get online message with messageId = 0
             * in some cases maybe startFutureMessageIdUp Equal to zero , so i used from this if.))
             */
            if (startFutureMessageId != 0) {
                getOnlineMessage(oldMessageId: startFutureMessageId, direction: direction, onMessageReceive: onMessageReceive)
            }
        } else {
            if (((direction == .up && allowGetHistoryUp) || (direction == .down && allowGetHistoryDown)) && startFutureMessageId != 0) {
                getOnlineMessage(oldMessageId: startFutureMessageId, direction: direction, onMessageReceive: onMessageReceive)
            }
        }
    }
    
    /**
     * get message history from server
     *
     * @param oldMessageId if set oldMessageId=0 messages will be get from latest message that exist in server
     */
    private func getOnlineMessage(oldMessageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection, onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        
        if ((direction == .up && !isWaitingForHistoryUpOnline && allowGetHistoryUp) || (direction == .down && !isWaitingForHistoryDownOnline && allowGetHistoryDown)) {
            /**
             * show progress when start for get history from server
             */
            manageProgress(state: .SHOW, direction: direction, messageId: oldMessageId, onMessageReceive: onMessageReceive)
            if (!IGAppManager.sharedManager.isUserLoggiedIn()) {
                getOnlineMessageAfterTimeOut(messageIdGetHistory: oldMessageId, direction: direction, onMessageReceive: onMessageReceive)
                return
            }
            
            var reachMessageId: Int64!
            if (direction == .up) {
                reachMessageId = reachMessageIdUp
                isWaitingForHistoryUpOnline = true
            } else {
                reachMessageId = reachMessageIdDown
                isWaitingForHistoryDownOnline = true
            }
            
            var limit: Int32 = LIMIT_GET_HISTORY_NORMAL
            if ((firstUpOnline && direction == .up) || (firstDownOnline && direction == .down)) {
                limit = LIMIT_GET_HISTORY_LOW
            }
            
            getMessageFromServer(roomId: roomId, messageIdGetHistory: oldMessageId, reachMessageId: reachMessageId, limit: limit, direction: direction, onMessageReceive: onMessageReceive, success: { (roomId, startMessageId, endMessageId, gapReached, jumpOverLocal, direction, onMessageRecieve) in
                // should be check roomId in IGMessageViewController
                /*
                 if (roomId != mRoomId) {
                    return;
                 }
                 */
                /**
                 * hide progress received history
                 */
                self.manageProgress(state: .HIDE, direction: direction)
                
                var realmRoomMessages: Results<IGRoomMessage>!
                var sort: [SortDescriptor]!
                
                if (direction == .up) {
                    self.firstUpOnline = false
                    self.isWaitingForHistoryUpOnline = false
                    self.startFutureMessageIdUp = startMessageId
                    sort = [SortDescriptor(keyPath: "id", ascending: false)]
                } else {
                    self.firstDownOnline = false
                    self.isWaitingForHistoryDownOnline = false
                    self.startFutureMessageIdDown = endMessageId
                    sort = [SortDescriptor(keyPath: "id", ascending: true)]
                }
                
                let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id >= %lld AND id <= %lld", roomId, startMessageId, endMessageId)
                realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sort)
                IGHelperMessageStatus.shared.sendStatus(roomId: roomId, roomType: self.roomType, status: .seen, realmRoomMessages: realmRoomMessages.toArray())
                
                /**
                 * I do this for set addToView true
                 */
                if (direction == .down && realmRoomMessages.count < (self.LIMIT_GET_HISTORY_NORMAL - 1)) {
                    self.getOnlineMessage(oldMessageId: self.startFutureMessageIdDown, direction: direction, onMessageReceive: onMessageReceive)
                }
                
                /**
                 * when reached to gap and not jumped over local, set gapMessageIdUp = 0; do this action
                 * means that gap not exist (need this value for future get message) set topMore/bottomMore
                 * local after that gap reached true for allow that get message from
                 */
                
                if (gapReached && !jumpOverLocal) {
                    if (direction == .up) {
                        self.gapMessageIdUp = 0
                        self.reachMessageIdUp = 0
                        self.topMore = true
                    } else {
                        self.gapMessageIdDown = 0
                        self.reachMessageIdDown = 0
                        self.bottomMore = true
                    }
                    
                    let _ = self.gapDetection(results: realmRoomMessages, direction: direction)
                } else if ((direction == .up && self.isReachedToTopView()) || direction == .down && self.isReachedToBottomView()) {
                    /**
                     * check this changeState because if user is near to top view and not scroll get top message from server
                     */
                    // Hint: Don't exit following code from comment
                    //getOnlineMessage(startFutureMessageId, directionEnum);
                }
                
                onMessageReceive(realmRoomMessages.toArray(), direction)
                
            }, error: {(errorCode, requestWrapper) in
                
                let requestClientGetRoomHistory = requestWrapper.message as! IGPClientGetRoomHistory
                let requestIdentity = requestWrapper.identity as! IGStructClientGetRoomHistoryIdentity
                
                /**
                 * hide progress if have any error
                 */
                self.manageProgress(state: .HIDE, direction: direction)
                
                switch errorCode {
                case .clinetGetRoomHistoryNoMoreMessage:
                    if (requestClientGetRoomHistory.igpDirection == .up) {
                        self.isWaitingForHistoryUpOnline = false
                        self.allowGetHistoryUp = false
                    } else {
                        self.addToView = true
                        self.isWaitingForHistoryDownOnline = false
                        self.allowGetHistoryDown = false
                    }
                    break
                    
                case .timeout:
                    /**
                     * if time out came up try again for get history with previous value
                     */
                    if (requestClientGetRoomHistory.igpDirection == .up) {
                        self.isWaitingForHistoryUpOnline = false
                    } else {
                        self.isWaitingForHistoryDownOnline = false
                    }
                    
                    self.getOnlineMessageAfterTimeOut(messageIdGetHistory: requestIdentity.firstMessageId, direction: direction, onMessageReceive: requestIdentity.onMessageReceive)
                    break
                    
                default:
                    break
                }
            })
        }
    }
    
    private func getOnlineMessageAfterTimeOut(messageIdGetHistory: Int64, direction: IGPClientGetRoomHistory.IGPDirection, onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        if (IGAppManager.sharedManager.isUserLoggiedIn()) {
            getOnlineMessage(oldMessageId: messageIdGetHistory, direction: direction, onMessageReceive: onMessageReceive)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.getOnlineMessageAfterTimeOut(messageIdGetHistory: messageIdGetHistory, direction: direction, onMessageReceive: onMessageReceive)
            }
        }
    }
    
    /**
     * detect gap exist in this room or not
     * (hint : if gapMessageId==0 means that gap not exist)
     * if gapMessageIdUp exist, not compute again
     */
    private func gapDetection(results: Results<IGRoomMessage>, direction: IGPClientGetRoomHistory.IGPDirection) -> Int64 {
        
        if (((direction == .up && gapMessageIdUp == 0) || (direction == .down && gapMessageIdDown == 0)) && results.count > 0) {
            let gapDetection = gapExist(roomId: roomId, messageId: results.first!.id, direction: direction)
            
            if (direction == .up) {
                reachMessageIdUp = gapDetection.reachMessageId
                gapMessageIdUp = gapDetection.gapMessageId
            } else {
                reachMessageIdDown = gapDetection.reachMessageId
                gapMessageIdDown = gapDetection.gapMessageId
            }
            
            return gapDetection.gapMessageId
        }
        
        return 0
    }
    
    /**
     * first set gap for room message for correctly load message and after than call {@link #getMessages()}
     *
     * @param messageId set gap for this message id
     */
    private func setGapAndGetMessage(messageId: Int64, onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        IGFactory.shared.setGap(messageId: messageId)
        getMessages(onMessageReceive: onMessageReceive)
    }

    
    /**
     * return true if now view is near to top
     */
    private func isReachedToTopView() -> Bool {
        return firstVisiblePosition <= 5;
    }
    
    /**
     * return true if now view is near to bottom
     */
    private func isReachedToBottomView() -> Bool {
        return (firstVisiblePosition + visibleItemCount >= (totalItemCount - 5));
    }
    
    /**
     * make unread layout message and add to the view
     */
    private func makeUnreadLayoutMessage(onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) {
        if (unreadCount > 0) {
            isShowLayoutUnreadMessage = true
            let message = IGRoomMessage(body: "\("\(unreadCount)".inLocalizedLanguage()) \(IGStringsManager.UnreadMessage.rawValue.localized)")
            message.type = .unread
            onMessageReceive([message], .down)
        }
    }
    
    
    private func manageProgress(state: ProgressState, direction: IGPClientGetRoomHistory.IGPDirection, messageId: Int64 = 0, onMessageReceive: ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)? = nil) {
        if state == .SHOW {
            if ((topProgressId == 0 && direction == .up)  ||  (bottomProgressId == 0 && direction == .down)) {
                let message = IGRoomMessage(body: "")
                message.type = .progress
                if direction == .up {
                    topProgressId = messageId + 1
                    message.id = topProgressId
                } else {
                    bottomProgressId = messageId - 1
                    message.id = bottomProgressId
                }
                IGMessageViewController.messageOnChatReceiveObserver?.onAddWaitingProgress(message: message, direction: direction)
            }
        } else {
            var fakeMessageId: Int64!
            if direction == .down {
                fakeMessageId = self.bottomProgressId
                self.bottomProgressId = 0
            } else {
                fakeMessageId = self.topProgressId
                self.topProgressId = 0
            }
            IGMessageViewController.messageOnChatReceiveObserver?.onRemoveWaitingProgress(fakeMessageId: fakeMessageId, direction: direction)
        }
    }
    
    
    //Hint : Seems to can't need use current method
    /**
     * return first unread message for current room
     * (reason : use from this method for avoid from closed realm error)
     */
    private func getFirstUnreadMessage() -> IGRoomMessage? {
        let realm = try! Realm()
        let realmRoom = realm.objects(IGRoom.self).filter(NSPredicate(format: "id == %lld", roomId)).first // TODO - try for this query with object instead objects
        if (realmRoom != nil) {
            return realmRoom?.firstUnreadMessage
        }
        return nil
    }
    
    /**
     * check that this room has unread or no
     */
    public func hasUnread() -> Bool {
        return unreadCount > 0
    }
    
    /**
     * check that this room has saved changeState or no
     */
    public func hasSavedState() -> Bool {
        return savedScrollMessageId > 0
    }
    
    /**
     * return saved scroll messageId
     */
    public func getSavedState() -> Int64 {
        return savedScrollMessageId
    }
    
    /**
     * reset to default value for reload message again
     */
    public func resetMessagingValue() {
        //prgWaiting.setVisibility(View.VISIBLE);
        //clearAdapterItems();
        
        addToView = true
        topMore = false
        bottomMore = false
        isWaitingForHistoryUpOnline = false
        isWaitingForHistoryDownOnline = false
        firstLoadDown = true
        firstLoadUp = true
        gapMessageIdUp = 0
        gapMessageIdDown = 0
        reachMessageIdUp = 0
        reachMessageIdDown = 0
        allowGetHistoryUp = true
        allowGetHistoryDown = true
        startFutureMessageIdUp = 0
        startFutureMessageIdDown = 0
        firstVisiblePosition = 0
        visibleItemCount = 0
        totalItemCount = 0
        unreadCount = 0
        biggestMessageId = 0
        savedScrollMessageId = 0
    }

    
    /**************************************************************************/
    /***************************** Message Loader *****************************/
    /**************************************************************************/
    
    
    let LOCAL_LIMIT = 10
    
    /**
     * fetch local message from IGRoomMessage
     *
     * @param roomId           roomId that want show message for that
     * @param messageId        start query with this messageId
     * @param duplicateMessage if set true return message for messageId that used in this method (will be used "lessThanOrEqualTo") otherwise just return less or greater than messageId(will be used "lessThan" method)
     * @param direction        direction for load message up or down
     * @return Object[] ==> [0] -> ArrayList<StructMessageInfo>, [1] -> boolean hasMore, [2] -> boolean hasGap
     */
    
    private func getLocalMessage(roomId: Int64, messageId: Int64, gapMessageId: Int64, duplicateMessage: Bool, direction: IGPClientGetRoomHistory.IGPDirection, firstLoad: Bool = false) -> (realmRoomMessages: [IGRoomMessage], hasMore: Bool, hasSpaceToGap: Bool) {
        
        var hasMore = true
        var hasSpaceToGap = true // TODO - check usage of this variable. if is not need remove it
        var realmRoomMessages: Results<IGRoomMessage>!
        
        if (messageId == 0) {
            return (Array(realmRoomMessages), false, false)
        }
        
        /**
         * get message from RealmRoomMessage
         */
        if (gapMessageId > 0) {
            if (direction == .up) {
                
                let sortPropertiesUp = [SortDescriptor(keyPath: "id", ascending: false)]
                if duplicateMessage {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id >= %lld AND id <= %lld", roomId, gapMessageId, messageId)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesUp)
                } else {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id >= %lld AND id < %lld", roomId, gapMessageId, messageId)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesUp)
                }
            } else {
                let sortPropertiesDown = [SortDescriptor(keyPath: "id", ascending: true)]
                if duplicateMessage {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id >= %lld AND id <= %lld", roomId, messageId, gapMessageId)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesDown)
                } else {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id > %lld AND id <= %lld", roomId, messageId, gapMessageId)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesDown)
                }
            }
        } else {
            if direction == .up {
                
                let sortPropertiesUp = [SortDescriptor(keyPath: "id", ascending: false)]
                if duplicateMessage {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id <= %lld AND id != %lld", roomId, messageId, 0)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesUp)
                } else {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id < %lld AND id != %lld", roomId, messageId, 0)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesUp)
                }
            } else {
                let sortPropertiesDown = [SortDescriptor(keyPath: "id", ascending: true)]
                if duplicateMessage {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id >= %lld AND id != %lld", roomId, messageId, 0)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesDown)
                } else {
                    let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id > %lld AND id != %lld", roomId, messageId, 0)
                    realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesDown)
                }
            }
        }

        var realmRoomMessagesArray: [IGRoomMessage] = []
        /*
        if firstLoad {
            let sortPropertiesFailed = [SortDescriptor(keyPath: "creationTime", ascending: false)]
            let predicate = NSPredicate(format: "roomId = %lld AND statusRaw = %d", roomId, IGRoomMessageStatus.failed.rawValue)
            let locallyMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortPropertiesFailed)
            realmRoomMessagesArray.append(contentsOf: locallyMessages)
        }
        */
        realmRoomMessagesArray.append(contentsOf: Array(realmRoomMessages))
        
        /**
         * manage subList
         */
        if (realmRoomMessagesArray.count > LOCAL_LIMIT) {
            realmRoomMessagesArray = realmRoomMessagesArray.chunks(LOCAL_LIMIT)[0]
        } else {
            /**
             * when run this block means that end of message reached
             * and should be send request to server for get history
             */
            hasMore = false
            hasSpaceToGap = false
            if realmRoomMessagesArray.count > 0 {
                realmRoomMessagesArray = realmRoomMessagesArray.chunks(realmRoomMessagesArray.count)[0]
            }
        }

        return (realmRoomMessagesArray, hasMore, hasSpaceToGap)
    }
 
    private func manageRewriteMessage(roomId: Int64, messages: [IGPRoomMessage]){
        IGGlobal.importedRoomMessageDic.removeAll()
        var rewriteMessageArray: [IGPRoomMessage] = []
        try! IGDatabaseManager.shared.realm.write {
            for message in messages {
                let realmRoomMessage = IGRoomMessage.putOrUpdate(igpMessage: message, roomId: roomId, options: IGStructMessageOption(isEnableCache: true))
                if realmRoomMessage == nil {
                    rewriteMessageArray.append(message)
                }
            }
        }
        if rewriteMessageArray.count > 0 {
            manageRewriteMessage(roomId: roomId, messages: rewriteMessageArray)
        }
    }
    
    private func getMessageFromServer(roomId: Int64, messageIdGetHistory: Int64, reachMessageId: Int64, limit: Int32, direction: IGPClientGetRoomHistory.IGPDirection,
                                      onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void),
                                      success: @escaping ((_ roomId :Int64 , _ startMessageId: Int64, _ endMessageId: Int64, _ gapReached: Bool, _ jumpOverLocal: Bool, _ historyDirection: IGPClientGetRoomHistory.IGPDirection, _ onMessageReceive: ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) -> Void),
                                      error: @escaping ((_ error: IGError, _ requestWrapper: IGRequestWrapper) -> Void)) {
        
        IGClientGetRoomHistoryRequest.Generator.generatePowerful(roomID: roomId, firstMessageID: messageIdGetHistory, reachMessageId: reachMessageId, limit: limit, direction: direction, onMessageReceive: onMessageReceive).successPowerful({ (responseProto, requestWrapper) in
            let identity = requestWrapper.identity as! IGStructClientGetRoomHistoryIdentity
            let reachMessageIdRequest: Int64! = identity.reachMessageId
            
            if let roomHistoryRequest = requestWrapper.message as? IGPClientGetRoomHistory {
                if let roomHistoryResponse = responseProto as? IGPClientGetRoomHistoryResponse {
                    IGRoomMessage.managePutOrUpdate(roomId: roomHistoryRequest.igpRoomID, messages: roomHistoryResponse.igpMessage, options: IGStructMessageOption(isEnableCache: true), completion: {
                        DispatchQueue.main.async {
                            /*
                             var rewriteMessageInfo: [IGPRoomMessage] = []
                             try! IGDatabaseManager.shared.realm.write {
                              for message in roomHistoryResponse.igpMessage {
                                if let savedMessage = IGRoomMessage.putOrUpdate(igpMessage: message, roomId: roomHistoryRequest.igpRoomID, options: IGStructMessageOption(isEnableCache: true)) {
                                    IGDatabaseManager.shared.realm.add(savedMessage)
                                } else {
                                    rewriteMessageInfo.append(message)
                                }
                              }
                             }
                             self.manageRewriteMessage(roomId: roomId, messages: rewriteMessageInfo)
                             */
                            
                            let startMessageId: Int64! = roomHistoryResponse.igpMessage.first?.igpMessageID
                            let endMessageId: Int64! = roomHistoryResponse.igpMessage.last?.igpMessageID
                            
                            /**
                             * convert message from RealmRoomMessage to StructMessageInfo for send to view
                             */
                            
                            var gapReached: Bool = false
                            var jumpOverLocal: Bool = false
                            
                            if (.up == roomHistoryRequest.igpDirection) {
                                if (startMessageId <= reachMessageIdRequest) {
                                    gapReached = true;
                                    /**
                                     * if gapReached now check that future gap is reached or no. if future gap reached this means
                                     * with get this history , client jumped from local messages and now is in another gap
                                     */
                                    
                                    if startMessageId <= self.gapExist(roomId: roomId, messageId: reachMessageId, direction: .up).gapMessageId {
                                        jumpOverLocal = true
                                    }
                                }
                            } else {
                                if (endMessageId >= reachMessageIdRequest) {
                                    gapReached = true
                                    /**
                                     * if gapReached now check that future gap is reached or no. if future gap reached this means
                                     * with get this history , client jumped from local messages and now is in another gap
                                     */
                                    if endMessageId >= self.gapExist(roomId: roomId, messageId: reachMessageId, direction: .down).gapMessageId {
                                        jumpOverLocal = true
                                    }
                                }
                            }
                            
                            // TODO - can do this write in another thread?
                            try! IGDatabaseManager.shared.realm.write {
                                var finalMessageId: Int64!
                                if .up == roomHistoryRequest.igpDirection {
                                    finalMessageId = startMessageId
                                } else {
                                    finalMessageId = endMessageId
                                }
                                
                                /**
                                 * clear before state gap for avoid compute this message for gap state again
                                 */
                                self.clearGap(roomId: roomId, messageId: messageIdGetHistory, finalMessageId: finalMessageId, direction: direction)
                                
                                /**
                                 * if not reached to gap yet and exist reachMessageId
                                 * set new gap state for compute message for gap
                                 */
                                if (jumpOverLocal || (!gapReached && reachMessageId > 0)) {
                                    self.setGap(messageId: finalMessageId, direction: roomHistoryRequest.igpDirection)
                                }
                            }
                            
                            success(roomHistoryRequest.igpRoomID, startMessageId, endMessageId, gapReached, jumpOverLocal, roomHistoryRequest.igpDirection, onMessageReceive)
                        }
                    })
                }
            }
        }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
            error(errorCode, requestWrapper)
        }).send()
    }
    
    
    //*********** detect gap in message
    
    /**
     * detect first RealmRoomMessage with previousMessageId and check
     * this previousMessageId exist in RealmRoomMessage or not
     * if gap exist this method will be returned reachedId.
     * reachedId will be used for calculate that after get clientGetRoomHistory
     * this history really reached to local message and gap filled or no
     *
     * @param roomId    roomId that want show message for that
     * @param messageId start query with this messageId
     * @param direction direction for load message up or down
     * @return [0] -> gapMessageId, [1] -> reachMessageId
     */

    public func gapExist(roomId: Int64, messageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection) -> (gapMessageId: Int64, reachMessageId: Int64) {
        
        //Realm realm = Realm.getDefaultInstance();
        var realmRoomMessage: IGRoomMessage!
        var gapMessageId: Int64 = 0
        var reachMessageId: Int64 = 0
        var checkMessageId: Int64 = 0
        
        /**
         * detect message that have previousMessageId or futureMessageId
         */
        
        if (direction == .up) {
            
            let sortProperties = [SortDescriptor(keyPath: "id", ascending: false)]
            let predicate = NSPredicate(format: "roomId = %lld AND id <= %lld AND previousMessageId != %lld ", roomId, messageId, 0)
            let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
            
            if (realmRoomMessages.count > 0) {
                realmRoomMessage = realmRoomMessages.first
                if realmRoomMessage != nil {
                    checkMessageId = realmRoomMessage.previousMessageId
                }
            }
        } else {
            
            let sortProperties = [SortDescriptor(keyPath: "id", ascending: true)]
            let predicate = NSPredicate(format: "roomId = %lld AND id >= %lld AND futureMessageId != %lld ", roomId, messageId, 0)
            let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
            
            if (realmRoomMessages.count > 0) {
                realmRoomMessage = realmRoomMessages.first
                if (realmRoomMessage != nil) {
                    checkMessageId = realmRoomMessage.futureMessageId
                }
            }
        }
        
        
        /**
         * check that exist any message with (message == checkMessageId) or not
         */
        if (realmRoomMessage != nil) {
            
            let predicate = NSPredicate(format: "id = %lld", checkMessageId)
            let realmRoomMessageGap = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first
            
            /**
             * if any message with checkMessageId isn't exist in local so
             * client don't have this message and should get it from server
             */
            if (realmRoomMessageGap == nil) {
                gapMessageId = checkMessageId
            } else if realmRoomMessageGap!.id == checkMessageId {
                /**
                 * this step means that client insert checkMessageId in itself message
                 */
                gapMessageId = checkMessageId
            }
        }
        
        /**
         * if gap exist now detect reachMessageId
         * (query UP   ==> max of messageId that exist in local and also is lower than messageId that come in this method)
         * (query DOWN ==> min of messageId that exist in local and also is bigger than messageId that come in this method)
         */
        if (gapMessageId > 0) {
            
            if (direction == .up) {
                let sortProperties = [SortDescriptor(keyPath: "id", ascending: true)]
                let predicate = NSPredicate(format: "roomId = %lld AND id < %lld AND previousMessageId = %lld", roomId, realmRoomMessage.id, 0)
                let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                
                if realmRoomMessages.count > 0 {
                    reachMessageId = realmRoomMessages[realmRoomMessages.count - 1].id
                }
                
                if (reachMessageId == 0) {
                    let predicate = NSPredicate(format: "roomId = %lld AND id < %lld", roomId, realmRoomMessage.id)
                    let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                    if realmRoomMessages.count > 0 {
                        reachMessageId = realmRoomMessages[realmRoomMessages.count - 1].id
                    }
                }
                
            } else {
                let sortProperties = [SortDescriptor(keyPath: "id", ascending: true)]
                let predicate = NSPredicate(format: "roomId = %lld AND id > %lld AND futureMessageId = %lld", roomId, realmRoomMessage.id, 0)
                let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                
                if realmRoomMessages.count > 0 {
                    reachMessageId = realmRoomMessages[0].id
                }
                
                if reachMessageId == 0 {
                    let sortProperties = [SortDescriptor(keyPath: "id", ascending: true)]
                    let predicate = NSPredicate(format: "roomId = %lld AND id > %lld", roomId, realmRoomMessage.id)
                    let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                    
                    if realmRoomMessages.count > 0 {
                        reachMessageId = realmRoomMessages[0].id
                    }
                }
            }
        }
        return (gapMessageId, reachMessageId)
    }
    
    
    /**
     * after each get history check all messages that are between first
     * and end message in history response and clear all gap state
     *
     * (hint : don't need use from transaction)
     */
    private func clearGap(roomId: Int64, messageId: Int64, finalMessageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection) {
        
        var fromPosition: Int64!
        var toPosition: Int64!
        
        if (direction == .up) {
            fromPosition = finalMessageId
            toPosition = messageId
        } else {
            fromPosition = messageId
            toPosition = finalMessageId
        }
        
        IGFactory.shared.clearGap(roomId: roomId, fromPosition: fromPosition, toPosition: toPosition)
    }
    
    /**
     * check that this message have previous or future messageId
     *
     * @param direction set direction for detect previous or future
     */
    private func isGap(messageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection) -> Bool {
        
        let predicate = NSPredicate(format: "id = %lld", messageId)
        if let realmRoomMessage = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
            if direction == .up {
                return realmRoomMessage.previousMessageId != 0
            } else {
                return realmRoomMessage.futureMessageId != 0
            }
        }
        return false
    }
    
    /**
     * set new gap state for UP or DOWN state
     * (hint : don't need use from transaction)
     *
     * @param messageId message that want set gapMessageId to that
     */
    private func setGap(messageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection) {
        IGFactory.shared.setGap(messageId: messageId, direction: direction)
    }
}
