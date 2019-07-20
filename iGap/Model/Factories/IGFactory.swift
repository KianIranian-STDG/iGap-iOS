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
import IGProtoBuff
import SwiftProtobuf

fileprivate class IGFactoryTask: NSObject {
    enum Status {
        case pending
        case executing
        case finished
        case failed
    }
    var task:       ()->()
    var success:    (()->())?
    var error:      (()->())?
    var status:     Status      = .pending
    var randomID:   String      = ""
    var isUpdateStatusRunning : Bool = false
    override init() {
        self.task = {}
        self.randomID = IGGlobal.randomString(length: 64)
        super.init()
    }
    
    init(task: @escaping ()->()) {
        self.task = task
    }
    
    //MARK: Tasks
    convenience init(messageTask igpMessage: IGPRoomMessage, for roomId: Int64, shouldFetchBefore: Bool?) {
        self.init()
        let task = {
            IGFactoryTask(dependencyUserTask: igpMessage.igpAuthor.igpUser.igpUserID, cacheID: igpMessage.igpAuthor.igpUser.igpCacheID).success({
                IGFactoryTask(dependencyRoomTask: igpMessage.igpAuthor.igpRoom.igpRoomID, isParticipane: true).success({
                    IGDatabaseManager.shared.perfrmOnDatabaseThread {
                        let message = IGRoomMessage.putOrUpdate(igpMessage: igpMessage, roomId: roomId)
                        if shouldFetchBefore != nil {
                            message.shouldFetchBefore = shouldFetchBefore!
                        }
                        
                        //check if a message with same data exists in db
                        let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", message.id, roomId)
                        if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                            message.primaryKeyId = messageInDb.primaryKeyId
                            message.shouldFetchBefore = messageInDb.shouldFetchBefore
                        }
                        
                        try! IGDatabaseManager.shared.realm.write {
                            IGDatabaseManager.shared.realm.add(message, update: true)
                        }
                        IGFactory.shared.performInFactoryQueue {
                            self.success!()
                        }
                    }
                }).error ({
                    self.error!()
                }).execute()
            }).error ({
                self.error!()
            }).execute()
        }
        self.task = task
    }
    
    convenience init(roomTask igpRoom: IGPRoom) {
        self.init()
        let task = {
            IGFactoryTask(dependencyUserTask: igpRoom.igpChatRoomExtra.igpPeer.igpID, cacheID: igpRoom.igpChatRoomExtra.igpPeer.igpCacheID).success ({
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    let room = IGRoom(igpRoom: igpRoom)
                    room.isParticipant = true
                    try! IGDatabaseManager.shared.realm.write {
                        IGDatabaseManager.shared.realm.add(room, update: true)
                        /*
                         if let roomInfo = IGHelperGetShareData.setRealmShareInfo(igpRoom: igpRoom, igRoom: room) {
                         IGDatabaseManager.shared.realm.add(roomInfo, update: true)
                         }
                         */
                    }
                    IGFactory.shared.performInFactoryQueue {
                        self.success!()
                    }
                }
            }).error ({
                self.error!()
            }).execute()
        }
        self.task = task
    }
    
    //MARK: Dependencies
    convenience init(dependencyUserTask userID: Int64?, cacheID: String?) {
        self.init()
        let task = {
            if let id = userID, id != 0 {
                var isUserInfoInDatabaseValid = false
                let predicate = NSPredicate(format: "id = %lld", id)
                if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                    if let cID = cacheID, cID != "" {
                        if userInDb.cacheID == cID {
                            isUserInfoInDatabaseValid = true
                        }
                    } else {
                        //if no cache id is provided, assume that user info is in sync with server
                        isUserInfoInDatabaseValid = true
                    }
                }
                if isUserInfoInDatabaseValid {
                    self.success!()
                } else {
                    IGUserInfoRequest.Generator.generate(userID: id).success({ (responseProtoMessage) in
                        IGDatabaseManager.shared.perfrmOnDatabaseThread {
                            switch responseProtoMessage {
                            case let response as IGPUserInfoResponse:
                                let user = IGRegisteredUser(igpUser: response.igpUser)
                                try! IGDatabaseManager.shared.realm.write {
                                    IGDatabaseManager.shared.realm.add(user, update: true)
                                }
                            default:
                                break
                            }
                            IGFactory.shared.performInFactoryQueue {
                                self.success!()
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            self.error!()
                        }
                    }).send()
                }
            } else {
                self.success!()
            }
        }
        self.task = task
    }
    
    convenience init(dependencyRoomTask roomID: Int64?, isParticipane: Bool) {
        self.init()
        let task = {
            //TODO: complete this
            if let id = roomID, id != 0 {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    let predicate = NSPredicate(format: "id = %lld", id)
                    if let roomInDb = try! Realm().objects(IGRoom.self).filter(predicate).first {
                        if roomInDb.isParticipant != isParticipane { // if roomInDb.isParticipant == true {
                            try! IGDatabaseManager.shared.realm.write {
                                roomInDb.isParticipant = isParticipane
                            }
                        }
                        IGFactory.shared.performInFactoryQueue {
                            self.success!()
                        }
                    } else {
                        //fetch room info
                        IGClientGetRoomRequest.Generator.generate(roomId: id).success({ (responseProto) in
                            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                                switch responseProto {
                                case let response as IGPClientGetRoomResponse:
                                    let igpRoom = response.igpRoom
                                    let room = IGRoom(igpRoom: igpRoom)
                                    room.isParticipant = isParticipane
                                    //room.sortimgTimestamp = Date().timeIntervalSinceReferenceDate // don't need update to current time. don't do this for avoid from send room to top of room list
                                    try! IGDatabaseManager.shared.realm.write {
                                        IGDatabaseManager.shared.realm.add(room, update: true)
                                    }
                                default:
                                    break
                                }
                                IGFactory.shared.performInFactoryQueue {
                                    self.success!()
                                }
                            }
                            
                        }).error({ (errorCode, waitTime) in
                            self.error!()
                        }).send()
                    }
                }
            } else {
                self.success!()
            }
        }
        self.task = task
    }
    
    /* create room if new message recieved and room not exist */
    convenience init(createRoomTask roomId: Int64?) {
        self.init()
        let task = {
            if let id = roomId, id != 0 {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    
                    let predicate = NSPredicate(format: "id = %lld", id)
                    if try! Realm().objects(IGRoom.self).filter(predicate).first == nil {
                        IGClientGetRoomRequest.Generator.generate(roomId: id).success({ (responseProto) in
                            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                                if let clientGetRoomResponse = responseProto as? IGPClientGetRoomResponse {
                                    let room = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                    try! IGDatabaseManager.shared.realm.write {
                                        IGDatabaseManager.shared.realm.add(room, update: true)
                                    }
                                }
                                IGFactory.shared.performInFactoryQueue {
                                    self.success!()
                                }
                            }
                            
                        }).error({ (errorCode, waitTime) in
                            self.error!()
                        }).send()
                    } else {
                        IGFactory.shared.performInFactoryQueue {
                            self.success!()
                        }
                    }
                }
            } else {
                self.success!()
            }
        }
        self.task = task
    }
    
    //MARK: Public Setters
    func success(_ success: @escaping ()->()) -> IGFactoryTask {
        self.success = success
        return self
    }
    
    func error(_ error: @escaping ()->()) -> IGFactoryTask {
        self.error = error
        return self
    }
    
    func execute() {
        self.task()
    }
    
    @discardableResult
    func addToQueue(hightPriority: Bool = false) -> IGFactoryTask {
        IGFactory.shared.addToFactoryQueue(task: self, hightPriority: hightPriority)
        return self
    }
}

//MARK: -
class IGFactory: NSObject {
    static let shared = IGFactory()
    
    fileprivate var factoryQueue:  DispatchQueue
    fileprivate var tasks  = [IGFactoryTask]()
    var userIdsToFetchInfo = [Int64]()
    var userIdsFetchInfoCompletionBlock: (()->())?
    
    
    private override init() {
        factoryQueue  = DispatchQueue.main //(label: "im.igap.ios.queue.factory.main")
        super.init()
    }
    
    
    fileprivate func addToFactoryQueue(task: IGFactoryTask, hightPriority: Bool) {
        performInFactoryQueue {
            if hightPriority {
                if self.tasks.count > 0 {
                    self.tasks.insert(task, at: 0)
                } else {
                    self.tasks.append(task)
                }
            } else {
                self.tasks.append(task)
            }
        }
    }
    
    private func performNextFactoryTaskIfPossible () {
        performInFactoryQueue {
            if let task = self.tasks.first {
                if task.status == .pending {
                    task.status = .executing
                    task.execute()
                }
            }
        }
        /*
        performInFactoryQueue {
            if let task = self.tasks.first {
                if task.status == .pending {
                    task.status = .executing
                    task.execute()
                } else {
                    print ("✪ task thread is already busy")
                }
            } else {
                print ("✔︎ no more tasks in queue")
            }
        }
        */
    }
    
    private func removeTaskFromQueueAndPerformNext(_ task: IGFactoryTask) {
        performInFactoryQueue {
            if let index = self.tasks.firstIndex(of: task) {
                self.tasks.remove(at: index)
                self.performNextFactoryTaskIfPossible()
            }
        }
    }
    
    fileprivate func performInFactoryQueue(task: @escaping ()->()) {
        factoryQueue.async {
            task()
        }
    }
    
    //let task = getFactoryTask()
    fileprivate func getFactoryTask() -> IGFactoryTask? {
        return nil//IGFactoryTask()
    }
    
    //self.setFactoryTaskSuccess(task: task)
    fileprivate func setFactoryTaskSuccess(task: IGFactoryTask?) {
        if task == nil {return}
        task!.success!()
    }
    
    //self.setFactoryTaskError(task: task)
    fileprivate func setFactoryTaskError(task: IGFactoryTask?) {
        if task == nil {return}
        task!.error!()
    }
    
    //self.doFactoryTask(task: task)
    fileprivate func doFactoryTask(task: IGFactoryTask?){
        if task == nil {return}
        
        task!.success ({
            self.removeTaskFromQueueAndPerformNext(task!)
        }).error ({
            self.removeTaskFromQueueAndPerformNext(task!)
        }).addToQueue()
        self.performNextFactoryTaskIfPossible()
    }
    
    //self.doFactoryTaskWithoutPerform(task: task)
    fileprivate func doFactoryTaskWithoutPerform(task: IGFactoryTask?){
        if task == nil {return}
        
        task!.success ({
            self.removeTaskFromQueueAndPerformNext(task!)
        }).error ({
            self.removeTaskFromQueueAndPerformNext(task!)
        }).addToQueue()
    }
    
    //self.doFactoryTaskList(tasks: tasks)
    fileprivate func doFactoryTaskList(tasks: [IGFactoryTask?]){
        for task in tasks {
            doFactoryTaskWithoutPerform(task: task)
        }
        self.performNextFactoryTaskIfPossible()
    }
    
    //MARK: ▶︎▶︎ Client Search Username
    func saveSearchUsernameResult(_ searchUsernameResult: [IGPClientSearchUsernameResponse.IGPResult] ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    for searchUsername in searchUsernameResult {
                        
                        var predicate: NSPredicate!
                        
                        if searchUsername.igpType.rawValue == IGPClientSearchUsernameResponse.IGPResult.IGPType.room.rawValue {
                            predicate = NSPredicate(format: "room.id = %lld", searchUsername.igpRoom.igpID)
                        } else {
                            predicate = NSPredicate(format: "user.id = %lld", searchUsername.igpUser.igpID)
                        }
                        
                        if let searchResult = IGDatabaseManager.shared.realm.objects(IGRealmClientSearchUsername.self).filter(predicate).first {
                            searchResult.room = searchResult.setRoom(room: searchUsername.igpRoom)
                            searchResult.user = searchResult.setUser(user: searchUsername.igpUser)
                            searchResult.type = searchUsername.igpType.rawValue
                        } else {
                            IGDatabaseManager.shared.realm.add(IGRealmClientSearchUsername(searchUsernameResult: searchUsername))
                        }
                        
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    
    //MARK: --------------------------------------------------------
    //MARK: ▶︎▶︎ Messages
    func saveIgpMessagesToDatabase(_ igpMessages: [IGPRoomMessage], for roomId: Int64, updateLastMessage: Bool, isFromSharedMedia: Bool?, isFromSendMessage: Bool=false) {
        
        if IGRecentsTableViewController.messageReceiveDelegat != nil {
            IGRecentsTableViewController.messageReceiveDelegat.onMessageRecieve(messages: igpMessages)
        }
        
        var userIDs = [Int64: String]()
        var roomIDs = Set<Int64>()
        
        for igpMessage in igpMessages {
            if igpMessage.hasIgpAuthor {
                if igpMessage.igpAuthor.hasIgpRoom {
                    let igpAuthorRoom = igpMessage.igpAuthor.igpRoom.igpRoomID
                    roomIDs.insert(igpAuthorRoom)
                } else if igpMessage.igpAuthor.hasIgpUser {
                    let igpAuthorUserId      = igpMessage.igpAuthor.igpUser.igpUserID
                    let igpAuthorUserCacheId = igpMessage.igpAuthor.igpUser.igpCacheID
                    userIDs[igpAuthorUserId] = igpAuthorUserCacheId
                }
            }
            
            
            if igpMessage.hasIgpForwardFrom {
                if igpMessage.igpForwardFrom.igpAuthor.hasIgpRoom {
                    roomIDs.insert(igpMessage.igpForwardFrom.igpAuthor.igpRoom.igpRoomID)
                } else if igpMessage.igpForwardFrom.igpAuthor.hasIgpUser {
                    let igpAuthorUserId      = igpMessage.igpForwardFrom.igpAuthor.igpUser.igpUserID
                    let igpAuthorUserCacheId = igpMessage.igpForwardFrom.igpAuthor.igpUser.igpCacheID
                    userIDs[igpAuthorUserId] = igpAuthorUserCacheId
                }
            }
        }
        
        //Step 0: create an array of tasks
        var tasks = [IGFactoryTask]()
        
        //Step 1: create tasks for users
        for userIDs in userIDs {
            let task = IGFactoryTask(dependencyUserTask: userIDs.key, cacheID: userIDs.value)
            tasks.append(task)
        }
        
        //Step 2: create tasks for rooms
        /*
         for roomId in roomIDs {
         let task = IGFactoryTask(dependencyRoomTask: roomId, isParticipane: false)
         tasks.append(task)
         }
         */
        
        //Step 3: create room if this is a new conversation
        let task = IGFactoryTask(createRoomTask: roomId)
        tasks.append(task)
        
        //Step 4: create a task for all messages
        let messagesTask = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                var shouldFetchBefore = true
                if let igpMessage = igpMessages.first {
                    var messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id = %lld", roomId, igpMessage.igpMessageID)
                    if let _ = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(messagePredicate).first {
                        //message is already present
                        //if not first message in db -> no need to fetch before
                        //if is first message in db  -> fetch
                        messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", roomId)
                        if let firstRoomMessageInDb = try! Realm().objects(IGRoomMessage.self).filter(messagePredicate).first {
                            if firstRoomMessageInDb.id == igpMessage.igpMessageID {
                                shouldFetchBefore = false
                            }
                        }
                    }
                    if isFromSharedMedia! {
                        messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id = %lld AND isFromSharedMedia == false", roomId, igpMessage.igpPreviousMessageID)
                        if let messageInDB = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(messagePredicate).first {
                            messageInDB.isFromSharedMedia = true
                        }
                    }
                    
                    if igpMessage.igpPreviousMessageID != 0 {
                        messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id = %lld", roomId, igpMessage.igpPreviousMessageID)
                        if let _ = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(messagePredicate).first {
                            //message is already present -> no need to fetch before
                            shouldFetchBefore = false
                        }
                    }
                }
                IGDatabaseManager.shared.realm.beginWrite()
                for (index, igpMessage) in igpMessages.enumerated() {
                    let message = IGRoomMessage.putOrUpdate(igpMessage: igpMessage, roomId: roomId)
                    
                    // Hint: don't need following code, because currently using from 'IGRoomMessage.putOrUpdate'
                    /*
                    let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", message.id, roomId)
                    if let messageInDb = try! Realm().objects(IGRoomMessage.self).filter(predicate).first {
                        message.primaryKeyId = messageInDb.primaryKeyId
                        
                        // update attachment type with server resposne. e.g. user send file message but get gif message in response, so we need update type
                        // TODO - saeed - update all file params with server response
                        if let attachment = message.attachment {
                            attachment.type = IGFile.getFileType(messageType: message.type)
                        }
                    }
                    */
                    
                    if isFromSendMessage {
                        message.shouldFetchBefore = (igpMessage.igpPreviousMessageID == 0 ? false : true );
                    }
                    else if shouldFetchBefore && ((index == 0 && igpMessages.count > 1) || (igpMessage.igpPreviousMessageID != 0)) {
                        message.shouldFetchBefore = true
                    } else {
                        message.shouldFetchBefore = false
                    }
                    
                    IGDatabaseManager.shared.realm.add(message, update: true)
                }
                try! IGDatabaseManager.shared.realm.commitWrite()
                
                //check if should update last messages and unread count
                var shouldUpdateLastMessage = false
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    if let lastMessage = igpMessages.last {
                        if let lastMessageInDb = roomInDb.lastMessage {
                            if lastMessage.igpMessageID > lastMessageInDb.id {
                                shouldUpdateLastMessage = true
                            }
                        } else {
                            shouldUpdateLastMessage = true
                        }
                    } else {
                        shouldUpdateLastMessage = false
                    }
                }
                if shouldUpdateLastMessage {
                    self.updateRoomLastMessageIfPossible(roomID: roomId)
                }
                IGFactory.shared.performInFactoryQueue {
                    self.setFactoryTaskSuccess(task: messagesTask)
                }
            }
        }
        if messagesTask != nil {
            tasks.append(messagesTask!)
        }
        self.doFactoryTaskList(tasks: tasks)
    }
    
    
    func updateIgpMessagesToDatabase(_ igpMessage: IGPRoomMessage, primaryKeyId: String, roomId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let message = IGRoomMessage.putOrUpdate(igpMessage: igpMessage, roomId: roomId)
                    message.primaryKeyId = primaryKeyId
                    /*
                     if igpMessage.igpAdditionalType == AdditionalType.STICKER.rawValue {
                     message.type = .sticker
                     }
                     */
                    IGDatabaseManager.shared.realm.add(message, update: true)
                    
                    self.updateRoomLastMessageIfPossible(roomID: roomId)

                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveNewlyWriitenMessageToDatabase(_ message: IGRoomMessage) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.add(message, update: true)
                }
                let roomId = message.roomId
                IGFactory.shared.performInFactoryQueue {
                    self.updateRoomLastMessageIfPossible(roomID: roomId)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateRoomLastMessageIfPossible(roomID: Int64) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            let predicate = NSPredicate(format: "id = %lld", roomID)
            if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                if !(roomInDb.isInvalidated) {
                    var shouldIncreamentUnreadCount = true
                    var lastMessage: IGRoomMessage?
                    let messagePredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false", roomID)
                    
                    if let lastMessageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(messagePredicate).sorted(byKeyPath: "creationTime").last {
                        if !(lastMessageInDb.isInvalidated) {
                            if let authorHash = lastMessageInDb.authorHash {
                                if authorHash == IGAppManager.sharedManager.authorHash() {
                                    shouldIncreamentUnreadCount = false
                                }
                            }
                            
                            if roomInDb.lastMessage?.id == lastMessageInDb.id {
                                return
                            }
                            lastMessage = lastMessageInDb
                        }
                        else {
                            print("RLM EXEPTION ERR lastMessageInDb IS INVALIDATED",String(describing: self))

                        }
                    } else {
                        //room has no message
                        shouldIncreamentUnreadCount = false
                    }
                    
                    var notificationTokens = [NotificationToken]()
                    if let notificationToken = IGAppManager.sharedManager.currentMessagesNotificationToekn {
                        notificationTokens.append(notificationToken)
                    }
                    IGDatabaseManager.shared.realm.beginWrite()
                    if shouldIncreamentUnreadCount {
                        let unreadCount = roomInDb.unreadCount + 1
                        if !AppDelegate.appIsInBackground {
                            roomInDb.badgeUnreadCount = unreadCount
                        }
                        roomInDb.unreadCount = unreadCount
                    }
                    roomInDb.lastMessage = lastMessage
                    if let messageTime = lastMessage?.creationTime?.timeIntervalSinceReferenceDate {
                        roomInDb.sortimgTimestamp = messageTime
                    }
                    do {
                        try IGDatabaseManager.shared.realm.commitWrite()
                        
                    } catch let error as NSError {
                        print("RLM EXEPTION ERR HAPPENDED SAVE ROOMS TO DB:",String(describing: self),error)
                    }
                }
                else {
                    print("RLM EXEPTION ERR ROOMINDB IS INVALIDATED",String(describing: self))

                }
            }
        }
    }
    
    func updateSendingMessageStatus(_ temporaryMessageInDb: IGRoomMessage, with igpMessageFromServer: IGPRoomMessage) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let message = IGRoomMessage.putOrUpdate(igpMessage: igpMessageFromServer, roomId: temporaryMessageInDb.roomId)
                if let tempId = temporaryMessageInDb.temporaryId {
                    let predicate = NSPredicate(format: "temporaryId = %@", tempId)
                    if let tempMessageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                        message.primaryKeyId = tempMessageInDb.primaryKeyId
                        try! IGDatabaseManager.shared.realm.write {
                            IGDatabaseManager.shared.realm.add(message, update: true)
                        }
                    }
                }
                let roomId = message.roomId
                IGFactory.shared.performInFactoryQueue {
                    
                    self.updateRoomLastMessageIfPossible(roomID: roomId)
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateMessageStatus(primaryKeyId: String, status: IGRoomMessageStatus, hasAttachment: Bool = false) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                var predicate: NSPredicate!
                
                if hasAttachment {
                    predicate = NSPredicate(format: "attachment.primaryKeyId = %@", primaryKeyId)
                } else {
                    predicate = NSPredicate(format: "primaryKeyId = %@", primaryKeyId)
                }
                
                try! IGDatabaseManager.shared.realm.write {
                    if let message = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                        message.status = status
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    //for an already sent message (sent -> delivered -> seen)
    func updateMessageStatus(_ messageID: Int64, roomID: Int64, status: IGPRoomMessageStatus, statusVersion: Int64, updaterAuthorHash: String, response: IGPResponse) {
        
        if response.igpID.isEmpty { // update status isn't from current device
            if IGAppManager.sharedManager.authorHash() == updaterAuthorHash && status == .seen {
                markAllMessagesAsRead(roomId: roomID, clearId: messageID)
            }
        }
        
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld AND roomId = %lld",messageID, roomID)
                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        switch status {
                        case .delivered:
                            messageInDb.status = .delivered
                        case .sending:
                            messageInDb.status = .sending
                        case .sent:
                            messageInDb.status = .sent
                        case .seen:
                            messageInDb.status = .seen
                        case .failed:
                            messageInDb.status = .failed
                        case .listened:
                            messageInDb.status = .listened
                        default:
                            break
                        }
                        messageInDb.statusVersion = statusVersion
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
            
        }
        //self.doFactoryTask(task: task)
    }
    
    func editMessage(_ messageID: Int64, roomID: Int64, message: String, messageType: IGRoomMessageType, messageVersion: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld AND roomId = %lld",messageID, roomID)
                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        messageInDb.isEdited = true
                        messageInDb.message = message
                        messageInDb.type = messageType
                        messageInDb.messageVersion = messageVersion
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setMessageDeleted(_ messageID: Int64, roomID: Int64, deleteVersion: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld AND roomId = %lld",messageID, roomID)
                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        messageInDb.isDeleted = true
                        messageInDb.deleteVersion = deleteVersion
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func deleteMessageWithPrimaryKeyId(primaryKeyId: String?, hasAttachment: Bool = false) {
        if primaryKeyId == nil {
            return
        }
        
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                var predicate: NSPredicate!
                if hasAttachment {
                    predicate = NSPredicate(format: "attachment.primaryKeyId = %@", primaryKeyId!)
                } else {
                    predicate = NSPredicate(format: "primaryKeyId = %@", primaryKeyId!)
                }
                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        IGDatabaseManager.shared.realm.delete(messageInDb)
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func deleteAllMessages(roomId: Int64){
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "roomId = %lld", roomId)
                let messages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate)
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.delete(messages)
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setClearMessageHistory(_ roomID : Int64, clearID: Int64 ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    let roomPredicate = NSPredicate(format: "id = %lld", roomID)
                    if  let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(roomPredicate).first {
                        if clearID == 0 || room.lastMessage == nil || (room.lastMessage?.id)! <= clearID {
                            room.clearId = clearID
                            room.lastMessage = nil
                        }
                        
                        //delete all messageId that is lower than clearId
                        let messagePredicate = NSPredicate(format: "roomId = %lld AND id <= %lld", roomID, clearID)
                        IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(messagePredicate))
                    }
                    
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    //TODO: merge with leftRoomInDatabase
    func setDeleteRoom(roomID : Int64){
        IGFactory.shared.deleteShareInfo(id: roomID, isContact: false)
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld",roomID)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.isParticipant = false
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setMessageNeedsToFetchBefore(_ state: Bool, messageId: Int64, roomId : Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", messageId, roomId)
                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        messageInDb.shouldFetchBefore = state
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setMessageIsLastMesssageInRoom(messageId: Int64, roomId : Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", messageId, roomId)
                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        messageInDb.isLastMessage = true
                        messageInDb.shouldFetchBefore = false
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    //MARK: --------------------------------------------------------
    //MARK: ▶︎▶︎ User
    func updateUserStatus(_ userId: Int64, status: IGRegisteredUser.IGLastSeenStatus) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                let predicate = NSPredicate(format: "id = %lld", userId)
                if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb.lastSeenStatus = status
                        userInDb.lastSeen = Date()
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    /* set "isInContacts" to false when "isDeleted" is true */
    func clearExtraContacts(){
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    try! Realm().objects(IGRegisteredUser.self).filter("isDeleted == 1").setValue(false, forKey: "isInContacts")
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func markContactsAsDeleted(){
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter("isDeleted == false").setValue(true, forKey: "isDeleted")
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveContactsToDatabase(_ contacts:[IGContact]) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                for contact in contacts {
                    try! IGDatabaseManager.shared.realm.write {
                        IGDatabaseManager.shared.realm.add(contact, update: true)
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func contactDelete(phone: Int64) {
        
        let predicate = NSPredicate(format: "phone == %lld", phone)
        if let contact = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
            IGFactory.shared.deleteShareInfo(id: contact.id)
        }
        
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    
                    let predicate = NSPredicate(format: "phone == %lld", phone)
                    if let contact = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                        contact.isInContacts = false
                        contact.phone = 0
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func contactEdit(contactEditInfo: IGPUserContactsEditResponse) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    
                    let predicate = NSPredicate(format: "phone == %lld", contactEditInfo.igpPhone)
                    if let contact = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                        contact.firstName = contactEditInfo.igpFirstName
                        contact.lastName = contactEditInfo.igpLastName
                        contact.displayName = contactEditInfo.igpFirstName + " " + contactEditInfo.igpLastName
                        contact.initials = contactEditInfo.igpInitials
                        
                        /**
                         * set data to 'IGRoom' for run 'RealmCollectionChange' and update room title in view
                         **/
                        let predicateRoom = NSPredicate(format: "chatRoom.peer.id == %lld", contact.id)
                        if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicateRoom).first {
                            room.title = contactEditInfo.igpFirstName + " " + contactEditInfo.igpLastName
                        }
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveGroupMemberListToDatabase(_ igpMembers: [IGPGroupGetMemberListResponse.IGPMember], roomId: Int64) {
        var memberUserIDs = Set<Int64>()
        for igpMember in igpMembers {
            if igpMember.igpUserID != 0 {
                let memberUserId = igpMember.igpUserID
                memberUserIDs.insert(memberUserId)
            }
        }
        var tasks = [IGFactoryTask]()
        
        for memberUserId in memberUserIDs {
            let task = IGFactoryTask(dependencyUserTask: memberUserId, cacheID: nil)
            tasks.append(task)
        }
        
        let membersTask = getFactoryTask()
        factoryQueue.async {
            
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                IGDatabaseManager.shared.realm.beginWrite()
                for igpMember in igpMembers {
                    let predicate = NSPredicate(format: "id = %lld", igpMember.igpUserID )
                    if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                        let groupMember = IGGroupMember(igpMember: igpMember, roomId: roomId)
                        groupMember.user = userInDb
                        var role: IGGroupMember.IGRole = .member
                        switch igpMember.igpRole {
                        case .admin:
                            role = .admin
                        case .member:
                            role = .member
                        case .moderator:
                            role = .moderator
                        case .owner:
                            role = .owner
                        default:
                            break
                        }
                        groupMember.role = role
                        IGDatabaseManager.shared.realm.add(groupMember, update: true)
                    }
                }
                try! IGDatabaseManager.shared.realm.commitWrite()
                IGFactory.shared.performInFactoryQueue {
                    self.setFactoryTaskSuccess(task: membersTask)
                }
            }
        }
        
        if membersTask != nil {
            tasks.append(membersTask!)
        }
        self.doFactoryTaskList(tasks: tasks)
    }
    
    
    func saveChannelMemberListToDatabase(_ igpMembers: [IGPChannelGetMemberListResponse.IGPMember], roomId: Int64) {
        var memberUserIDs = Set<Int64>()
        for igpMember in igpMembers {
            if igpMember.igpUserID != 0 {
                let memberUserId = igpMember.igpUserID
                memberUserIDs.insert(memberUserId)
            }
        }
        var tasks = [IGFactoryTask]()
        
        for memberUserId in memberUserIDs {
            let task = IGFactoryTask(dependencyUserTask: memberUserId, cacheID: nil)
            tasks.append(task)
        }
        
        let membersTask = getFactoryTask()
        factoryQueue.async {
            
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                IGDatabaseManager.shared.realm.beginWrite()
                for (_, igpMember) in igpMembers.enumerated() {
                    let predicate = NSPredicate(format: "id = %lld", igpMember.igpUserID )
                    if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                        let channelMember = IGChannelMember(igpMember: igpMember, roomId: roomId)
                        channelMember.user = userInDb
                        var role: IGChannelMember.IGRole = .member
                        switch igpMember.igpRole {
                        case .admin:
                            role = .admin
                        case .member:
                            role = .member
                        case .moderator:
                            role = .moderator
                        case .owner:
                            role = .owner
                        default:
                            break
                        }
                        channelMember.role = role
                        IGDatabaseManager.shared.realm.add(channelMember, update: true)
                    }
                }
                try! IGDatabaseManager.shared.realm.commitWrite()
                IGFactory.shared.performInFactoryQueue {
                    self.setFactoryTaskSuccess(task: membersTask)
                }
            }
        }
        
        if membersTask != nil {
            tasks.append(membersTask!)
        }
        self.doFactoryTaskList(tasks: tasks)
    }
    
    func kickChannelMemberFromDatabase(roomId: Int64 , memberId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "userID = %lld AND roomID = %lld", memberId, roomId)
                if let memberInDb = try! Realm().objects(IGChannelMember.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        IGDatabaseManager.shared.realm.delete(memberInDb)
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    //TODO: Merge with demoteRoleInGroup
    func demoteRoleInChannel(roomId: Int64 , memberId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "userID = %lld AND roomID = %lld", memberId, roomId)
                if let memberInDb = try! Realm().objects(IGChannelMember.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        memberInDb.role = .member
                    }
                }
                
                self.updateRoomReadOnly(roomId: roomId, memberId: memberId, readOnly: true)
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    //TODO: merge with setDeleteRoom
    func leftRoomInDatabase(roomID: Int64, memberId: Int64) {
        IGFactory.shared.deleteShareInfo(id: roomID, isContact: false)
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                if IGAppManager.sharedManager.userID() == memberId {
                    self.deleteAllMessages(roomId: roomID)
                    let predicate = NSPredicate(format: "id = %lld", roomID)
                    if let roomInDb = try! Realm().objects(IGRoom.self).filter(predicate).first {
                        try! IGDatabaseManager.shared.realm.write {
                            roomInDb.isParticipant = false
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func kickGroupMembersFromDatabase(roomId: Int64 , memberId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "userID = %lld AND roomID = %lld", memberId, roomId)
                if let memberInDb = try! Realm().objects(IGGroupMember.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        IGDatabaseManager.shared.realm.delete(memberInDb)
                    }
                }
                self.updateRoomReadOnly(roomId: roomId, memberId: memberId, readOnly: true)
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateRoomReadOnly(roomId: Int64 , memberId: Int64, readOnly: Bool) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                if memberId == IGAppManager.sharedManager.userID() {
                    try! IGDatabaseManager.shared.realm.write {
                        let predicate = NSPredicate(format: "id = %lld", roomId)
                        let room = try! Realm().objects(IGRoom.self).filter(predicate).first
                        room?.isReadOnly = readOnly
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    
    //TODO: Merge with demoteRoleInChannel
    func demoteRoleInGroup(roomId: Int64 , memberId : Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "userID = %lld AND roomID = %lld", memberId, roomId)
                if let memberInDb = try! Realm().objects(IGGroupMember.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        memberInDb.role = .member
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
        
    }
    
    
    func addRegistredContacts(_ igpContacts: [IGPUserContactsImportResponse.IGPContact]) {
        for igpContact in igpContacts {
            let registredUserID = igpContact.igpUserID
            //let task = getFactoryTask()
            factoryQueue.async {
                IGFactoryTask.init(dependencyUserTask: registredUserID, cacheID: nil).success ({
                    IGDatabaseManager.shared.perfrmOnDatabaseThread {
                        
                        let predicate = NSPredicate(format: "id = %lld", registredUserID)
                        if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                            let phone = igpContact.igpClientID
                            let cotactPredicate = NSPredicate(format: "phoneNumber = %@", phone)
                            if let contactInDB = try! Realm().objects(IGContact.self).filter(cotactPredicate).first {
                                try! IGDatabaseManager.shared.realm.write {
                                    contactInDB.user = userInDb
                                }
                            }
                        }
                        IGFactory.shared.performInFactoryQueue {
                            //self.setFactoryTaskSuccess(task: task)
                        }
                    }
                }).error ({
                    //self.setFactoryTaskError(task: task)
                }).execute()
            }
            //self.doFactoryTaskWithoutPerform(task: task)
        }
        self.performNextFactoryTaskIfPossible()
    }
    
    func saveRegistredContactsUsers(_ igpRegistredUsers: [IGPRegisteredUser]) {
        //for igpRegistredUser in igpRegistredUsers {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                var delay = 0.0
                var savedCount = 0
                let registredUsersArray = igpRegistredUsers.chunks(15)
                for registredUsers in registredUsersArray {
                    for userInfo in registredUsers {
                        delay += 0.5
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            try! IGDatabaseManager.shared.realm.write {
                                let registeredUser = IGRegisteredUser.putOrUpdate(realm: IGDatabaseManager.shared.realm, igpUser: userInfo)
                                registeredUser.isInContacts = true
                                IGDatabaseManager.shared.realm.add(registeredUser, update: true)
                                //IGDatabaseManager.shared.realm.add(IGHelperGetShareData.setRealmShareInfo(igpUser: igpRegistredUser, igUser: user), update: true)
                            }
                            
                            savedCount = savedCount + 1
                            if savedCount == igpRegistredUsers.count { //after add all contacts to db do contact clearization
                                self.clearExtraContacts()
                            }
                        }
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
            
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveRegistredUsers(_ igpRegistredUsers: [IGPRegisteredUser]) {
        for igpRegistredUser in igpRegistredUsers {
            //let task = getFactoryTask()
            factoryQueue.async {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    try! IGDatabaseManager.shared.realm.write {
                        let user = IGRegisteredUser(igpUser: igpRegistredUser)
                        IGDatabaseManager.shared.realm.add(user, update: true)
                        let predicate = NSPredicate(format: "id = %lld", user.id)
                        if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                            let cotactPredicate = NSPredicate(format: "phoneNumber = %@", "\(user.phone)")
                            if let contactInDB = try! Realm().objects(IGContact.self).filter(cotactPredicate).first {
                                contactInDB.user = userInDb
                            }
                        }
                    }
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                }
            }
            //self.doFactoryTaskWithoutPerform(task: task)
        }
        self.performNextFactoryTaskIfPossible()
    }
    
    func updateUserInfoExpired(_ userId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGFactoryTask(dependencyUserTask: userId, cacheID: nil).success ({
                IGDatabaseManager.shared.perfrmOnDatabaseThread ({
                    
                    let predicate = NSPredicate(format: "id = %lld", userId)
                    if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                        try! IGDatabaseManager.shared.realm.write {
                            if userInDb.lastSeenStatus == .online {
                                self.updateUserStatus(userId, status: .longTimeAgo)
                            } else if userInDb.lastSeenStatus == .longTimeAgo {
                                self.updateUserStatus(userId, status: .online)
                                
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNoticationForPushUserExpire),
                                                            object: nil,
                                                            userInfo: ["user": userId])
                        }
                    }
                    
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                })
            }).error ({
                //self.setFactoryTaskError(task: task)
            }).execute()
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveBlockedUsers(_ blockedUsers : [IGPUserContactsGetBlockedListResponse.IGPUser]){
        for blockedUser in blockedUsers {
            //let task = getFactoryTask()
            factoryQueue.async {
                IGFactoryTask(dependencyUserTask: blockedUser.igpUserID, cacheID: nil).success ({
                    IGDatabaseManager.shared.perfrmOnDatabaseThread ({
                        
                        let predicate = NSPredicate(format: "id = %lld", blockedUser.igpUserID)
                        if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                            try! IGDatabaseManager.shared.realm.write {
                                userInDb.isBlocked = true
                            }
                        }
                        
                        IGFactory.shared.performInFactoryQueue {
                            //self.setFactoryTaskSuccess(task: task)
                        }
                    })
                }).error ({
                    //self.setFactoryTaskError(task: task)
                }).execute()
            }
            //self.doFactoryTaskWithoutPerform(task: task)
        }
        self.performNextFactoryTaskIfPossible()
    }
    
    func updateBlockedUser(_ blockedUserId: Int64, blocked: Bool ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGFactoryTask(dependencyUserTask: blockedUserId, cacheID: nil).success ({
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    
                    let predicate = NSPredicate(format: "id = %lld", blockedUserId)
                    if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                        try! IGDatabaseManager.shared.realm.write {
                            userInDb.isBlocked = blocked
                        }
                    }
                    
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                }
            }).error ({
                //self.setFactoryTaskError(task: task)
            }).execute()
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateUserNickname(_ userId: Int64, nickname: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", userId)
                if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb.displayName = nickname
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateUserEmail(_ userId: Int64, email: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", userId)
                if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb.email = email
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateProfileUsername(_ userID: Int64, username: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", userID)
                if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb.username = username
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateUserSelfRemove(_ userId: Int64, selfRemove:Int32) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", userId)
                if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb.selfRemove = selfRemove
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateProfileGender(_ userId: Int64 , igpGender: IGPGender) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGFactoryTask(dependencyUserTask: userId, cacheID: nil).success({
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    var gender: IGGender
                    switch igpGender {
                    case .male:
                        gender = .male
                    case .female:
                        gender = .female
                    case .unknown :
                        gender = .unknown
                    default:
                        gender = .male
                    }
                    let userPredicate = NSPredicate(format: "id = %lld", userId)
                    let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(userPredicate).first
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb?.gender = gender
                    }
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                }
            }).error ({
                //self.setFactoryTaskError(task: task)
            }).execute()
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateUserAvatar(_ userId: Int64, igpAvatar: IGPAvatar) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let avatar = IGAvatar(igpAvatar: igpAvatar)
                let predicate = NSPredicate(format: "id = %lld", userId)
                if let userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        userInDb.avatar = avatar
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateUserPrivacy(_ igPrivacyType: IGPrivacyType , igPrivacyLevel: IGPrivacyLevel) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    if let userPrivacyInDb = IGDatabaseManager.shared.realm.objects(IGUserPrivacy.self).first {
                        switch igPrivacyType {
                        case .avatar:
                            userPrivacyInDb.avatar = igPrivacyLevel
                        case .channelInvite:
                            userPrivacyInDb.channelInvite = igPrivacyLevel
                        case .groupInvite:
                            userPrivacyInDb.groupInvite = igPrivacyLevel
                        case .userStatus:
                            userPrivacyInDb.userStatus = igPrivacyLevel
                        case .voiceCalling:
                            userPrivacyInDb.voiceCalling = igPrivacyLevel
                        case .videoCalling:
                            userPrivacyInDb.videoCalling = igPrivacyLevel
                        case .screenSharing:
                            userPrivacyInDb.screenSharing = igPrivacyLevel
                        case .secretChat:
                            userPrivacyInDb.secretChat = igPrivacyLevel
                        }
                    } else {
                        let userPrivacy = IGUserPrivacy()
                        switch igPrivacyType {
                        case .avatar:
                            userPrivacy.avatar = igPrivacyLevel
                        case .channelInvite:
                            userPrivacy.channelInvite = igPrivacyLevel
                        case .groupInvite:
                            userPrivacy.groupInvite = igPrivacyLevel
                        case .userStatus:
                            userPrivacy.userStatus = igPrivacyLevel
                        case .voiceCalling:
                            userPrivacy.voiceCalling = igPrivacyLevel
                        case .videoCalling:
                            userPrivacy.videoCalling = igPrivacyLevel
                        case .screenSharing:
                            userPrivacy.screenSharing = igPrivacyLevel
                        case .secretChat:
                            userPrivacy.secretChat = igPrivacyLevel
                        }
                        IGDatabaseManager.shared.realm.add(userPrivacy, update: true)
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateBio(bio: String) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
                try! IGDatabaseManager.shared.realm.write {
                    if let userRegister = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first {
                        userRegister.bio = bio
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setSignalingConfiguration(configuration: IGPSignalingGetConfigurationResponse) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    if let signaling = IGDatabaseManager.shared.realm.objects(IGSignaling.self).first {
                        signaling.voiceCalling = configuration.igpVoiceCalling
                        signaling.videoCalling = configuration.igpVideoCalling
                        signaling.secretChat = configuration.igpSecretChat
                        signaling.screenSharing = configuration.igpScreenSharing
                        
                        signaling.iceServer.removeAll()
                        for iceServer in configuration.igpIceServer {
                            signaling.iceServer.append(IGIceServer(iceServer: iceServer))
                        }
                    } else {
                        IGDatabaseManager.shared.realm.add(IGSignaling(signalingConfiguration: configuration))
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setCallLog(callLog: IGPSignalingGetLogResponse.IGPSignalingLog) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    
                    let predicate = NSPredicate(format: "id = %lld", callLog.igpID)
                    if let _ = IGDatabaseManager.shared.realm.objects(IGRealmCallLog.self).filter(predicate).first {
                        IGDatabaseManager.shared.realm.add(IGRealmCallLog(signalingLog: callLog), update: true)
                    } else {
                        IGDatabaseManager.shared.realm.add(IGRealmCallLog(signalingLog: callLog))
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func clearCallLog() {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    let callLogs = try! Realm().objects(IGRealmCallLog.self)
                    if !callLogs.isEmpty {
                        IGDatabaseManager.shared.realm.delete(callLogs)
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setMapNearbyUsersDistance(nearbyDistance: IGPGeoGetNearbyDistanceResponse.IGPResult) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    
                    let predicate = NSPredicate(format: "id = %lld", nearbyDistance.igpUserID)
                    if let _ = IGDatabaseManager.shared.realm.objects(IGRealmMapNearbyDistance.self).filter(predicate).first {
                        IGDatabaseManager.shared.realm.add(IGRealmMapNearbyDistance(nearbyDistance: nearbyDistance), update: true)
                    } else {
                        IGDatabaseManager.shared.realm.add(IGRealmMapNearbyDistance(nearbyDistance: nearbyDistance))
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateNearbyDistanceComment(userId: Int64, comment: String) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "id = %lld", userId)
                    if let nearbyDistance = IGDatabaseManager.shared.realm.objects(IGRealmMapNearbyDistance.self).filter(predicate).first {
                        nearbyDistance.comment = comment
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    //MARK: --------------------------------------------------------
    //MARK: ▶︎▶︎ Rooms
    
    /* change isDeleted value to "true" for rooms that not exist in server response */
    func markRoomsAsDeleted(igpRooms : [IGPRoom]){
        //let task = getFactoryTask()
        let task = IGFactoryTask()
        task.task = {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.objects(IGRoom.self).filter("isDeleted == 0").setValue(true, forKey: "isDeleted")
                }
                
                // Hint : don't need fetch difference list and set all isDeleted params. now we just set all data just with one query
                /*
                 var array1: Array<Int64> = Array()
                 var array2: Array<Int64> = Array()
                 
                 for room in igpRooms {
                 array1.append(room.igpID)
                 }
                 
                 let predicate = NSPredicate(format: "isParticipant == 1")
                 for room in IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate) {
                 array2.append(room.id)
                 }
                 
                 let differenceRoomId = array1.difference(from: array2)
                 
                 try! IGDatabaseManager.shared.realm.write {
                 for roomId in differenceRoomId {
                 let predicate = NSPredicate(format: "id = %lld", roomId)
                 if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                 roomInDb.isParticipant = false //roomInDb.isDeleted = true
                 }
                 
                 /*
                 let predicateShareInfo = NSPredicate(format: "id = %lld AND type != %d", roomId, 4)
                 /* set "isParticipant = false" and after get all rooms clear all share info if yet "isParticipant == false" */
                 if let shareInfoInDb = IGDatabaseManager.shared.realm.objects(IGShareInfo.self).filter(predicateShareInfo).first {
                 shareInfoInDb.isParticipant = false
                 }
                 */
                 }
                 }
                 */
                
                IGFactory.shared.performInFactoryQueue {
                    self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        self.doFactoryTask(task: task)
    }
    
    func removeDeletedRooms(){
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(NSPredicate(format: "isDeleted == 1")))
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    /* clear share info if "isParticipant == false" */
    func deleteShareInfo(removeRoom: Bool = true){
        /*
         //let task = getFactoryTask()
         factoryQueue.async {
         IGDatabaseManager.shared.perfrmOnDatabaseThread {
         
         var predicate = NSPredicate(format: "isParticipant != 1 AND type == %d", 4) //  contact == 4
         if removeRoom {
         predicate = NSPredicate(format: "isParticipant != 1 AND type != %d", 4)
         }
         let shareInfos = IGDatabaseManager.shared.realm.objects(IGShareInfo.self).filter(predicate)
         try! IGDatabaseManager.shared.realm.write {
         IGDatabaseManager.shared.realm.delete(shareInfos)
         }
         
         IGFactory.shared.performInFactoryQueue {
         //self.setFactoryTaskSuccess(task: task)
         }
         }
         }
         //self.doFactoryTask(task: task)
         */
    }
    
    func deleteShareInfo(id: Int64, isContact: Bool = true){
        /*
         //let task = getFactoryTask()
         factoryQueue.async {
         IGDatabaseManager.shared.perfrmOnDatabaseThread {
         
         var predicate = NSPredicate(format: "id == %lld AND type == %d", id, 4) //  contact == 4
         if !isContact {
         predicate = NSPredicate(format: "id == %lld AND type != %d", id, 4)
         }
         let shareInfos = IGDatabaseManager.shared.realm.objects(IGShareInfo.self).filter(predicate)
         try! IGDatabaseManager.shared.realm.write {
         IGDatabaseManager.shared.realm.delete(shareInfos)
         }
         
         IGFactory.shared.performInFactoryQueue {
         //self.setFactoryTaskSuccess(task: task)
         }
         }
         }
         //self.doFactoryTask(task: task)
         */
    }
    
    func removeShareInfoContactParticipant(){
        /*
         //let task = getFactoryTask()
         factoryQueue.async {
         IGDatabaseManager.shared.perfrmOnDatabaseThread {
         
         let predicate = NSPredicate(format: "isParticipant == 1 AND type == %d", 4) //  contact == 4
         let shareInfos = IGDatabaseManager.shared.realm.objects(IGShareInfo.self).filter(predicate)
         try! IGDatabaseManager.shared.realm.write {
         for shareInfo in shareInfos {
         shareInfo.isParticipant = false
         }
         }
         
         IGFactory.shared.performInFactoryQueue {
         //self.setFactoryTaskSuccess(task: task)
         }
         }
         }
         //self.doFactoryTask(task: task)
         */
    }
    
    /*
    func saveRoomsToDatabase(_ rooms: [IGPRoom], ignoreLastMessage: Bool, removeDeleted: Bool = false) {
        //Step 1: save last message to db
        if !ignoreLastMessage {
            for igpRoom in rooms {
                if igpRoom.hasIgpLastMessage {
                    let lastIGPMessage = igpRoom.igpLastMessage
                    let task = IGFactoryTask(messageTask: lastIGPMessage, for: igpRoom.igpID, shouldFetchBefore: true)
                    task.success ({
                        self.removeTaskFromQueueAndPerformNext(task)
                    }).error ({
                        self.removeTaskFromQueueAndPerformNext(task)
                    }).addToQueue()
                }
            }
        }
        
        for igpRoom in rooms {
            let task = IGFactoryTask(roomTask: igpRoom)
            task.success ({
                self.removeTaskFromQueueAndPerformNext(task)
            }).error ({
                self.removeTaskFromQueueAndPerformNext(task)
            }).addToQueue()
        }
        
        if removeDeleted {
            let task = IGFactoryTask()
            task.task = {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                        try! IGDatabaseManager.shared.realm.write {
                            IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(NSPredicate(format: "isDeleted == 1")))
                        }
                    }
                    
                    IGFactory.shared.performInFactoryQueue {
                        self.setFactoryTaskSuccess(task: task)
                    }
                }
            }
            self.doFactoryTask(task: task)
        } else {
            self.performNextFactoryTaskIfPossible()
        }
    }
    */
    
    func saveRoomsToDatabase(_ rooms: [IGPRoom], ignoreLastMessage: Bool, removeDeleted: Bool = false) {
        
        let task = IGFactoryTask()
        task.task = {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                do {
                    for igpRoom in rooms {
                        try! IGDatabaseManager.shared.realm.write {
                            IGDatabaseManager.shared.realm.add(IGRoom.putOrUpdate(realm: IGDatabaseManager.shared.realm, igpRoom))
                        }
                        
                        IGFactory.shared.performInFactoryQueue {
                            self.setFactoryTaskSuccess(task: task)
                        }
                    }
                } catch let error as NSError {
                    print("RLM EXEPTION ERR HAPPENDED SAVE ROOMS TO DB:",String(describing: self),error)
                }
            }
        }
        task.success ({
            self.removeTaskFromQueueAndPerformNext(task)
        }).error ({
            self.removeTaskFromQueueAndPerformNext(task)
        }).addToQueue()
        
        if removeDeleted {
            let task = IGFactoryTask()
            task.task = {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    try! IGDatabaseManager.shared.realm.write {
                        IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(NSPredicate(format: "isDeleted == 1")))
                    }
                    
                    IGFactory.shared.performInFactoryQueue {
                        self.setFactoryTaskSuccess(task: task)
                    }
                }
            }
            self.doFactoryTask(task: task)
        } else {
            self.performNextFactoryTaskIfPossible()
        }
    }
    
    func saveRoomToDatabase(_ igpRoom: IGPRoom, isParticipant: Bool?) {
        //let task = getFactoryTask()
        
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let room = IGRoom(igpRoom: igpRoom)
                if isParticipant == nil {
                    // should retain current state: if in db -> read from db else not participant
                    let predicate = NSPredicate(format: "id = %lld", room.id)
                    if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                        room.isParticipant = roomInDb.isParticipant
                    } else {
                        room.isParticipant = false
                    }
                } else {
                    room.isParticipant = isParticipant!
                }
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.add(room, update: true)
                    /*
                     if let roomInfo = IGHelperGetShareData.setRealmShareInfo(igpRoom: igpRoom, igRoom: room) {
                     IGDatabaseManager.shared.realm.add(roomInfo, update: true)
                     }
                     */
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func markAllMessagesAsRead(roomId: Int64, clearId: Int64 = 0) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    /* if clearId is lower than latest messageId don't clear message */
                    if clearId == 0 || roomInDb.lastMessage == nil || (roomInDb.lastMessage?.id)! <= clearId {
                        try! IGDatabaseManager.shared.realm.write {
                            roomInDb.badgeUnreadCount = 0
                            roomInDb.unreadCount = 0
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func muteRoom(roomId: Int64, roomMute: IGRoom.IGRoomMute) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.mute = roomMute
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func pinRoom(roomId: Int64, pinId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.pinId = pinId
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func promoteRoom(roomId: Int64, isPromote: Bool = true) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.isPromote = isPromote
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func clearPromote(roomId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "id = %lld", roomId)
                    if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                        room.isPromote = false
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func editChannelRooms(roomID : Int64 , roomName: String , roomDescription : String ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomID)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.title = roomName
                        roomInDb.channelRoom?.roomDescription = roomDescription
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func removeGroupUserName (_ roomID : Int64 ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomID)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.groupRoom?.type = .privateRoom
                        roomInDb.groupRoom?.publicExtra?.username = ""
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func romoveChannelUserName (_ roomID: Int64 ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomID)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.channelRoom?.type = .privateRoom
                        roomInDb.channelRoom?.publicExtra?.username = ""
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func editGroupRooms(roomID: Int64 , roomName: String , roomDesc: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomID)
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.title = roomName
                        roomInDb.groupRoom?.roomDescription = roomDesc
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateGroupUsername(_ username: String, roomId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                
                let publicExtraPredicate = NSPredicate(format: "id = %lld", roomId)
                var publicExtra: IGGroupPublicExtra!
                if let publicExtraInDb = IGDatabaseManager.shared.realm.objects(IGGroupPublicExtra.self).filter(publicExtraPredicate).first {
                    publicExtra = publicExtraInDb
                } else {
                    publicExtra = IGGroupPublicExtra(id: roomId, username: username)
                }
                
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(roomPredicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        publicExtra.username = username
                        roomInDb.groupRoom?.type = .publicRoom
                        roomInDb.groupRoom?.publicExtra = publicExtra
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateChannelUserName( userName: String , roomID : Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomID)
                let publicExtraPredicate = NSPredicate(format: "id = %lld", roomID)
                
                if let roomInDb = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(roomPredicate).first {
                    var publicExtra: IGChannelPublicExtra!
                    if let publicExtraInDb = IGDatabaseManager.shared.realm.objects(IGChannelPublicExtra.self).filter(publicExtraPredicate).first {
                        publicExtra = publicExtraInDb
                    } else {
                        publicExtra = IGChannelPublicExtra(id: roomID, username: userName)
                    }
                    
                    try! IGDatabaseManager.shared.realm.write {
                        publicExtra.username = userName
                        roomInDb.channelRoom?.type = .publicRoom
                        roomInDb.channelRoom?.publicExtra = publicExtra
                        roomInDb.channelRoom?.privateExtra = nil
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updatChannelRoomSignature(_ roomId: Int64 , signatureStatus: Bool) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.channelRoom?.isSignature = signatureStatus
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
        
    }
    
    func revokePrivateRoomLink(roomId: Int64 , invitedLink: String , invitedToken: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        if roomInDb.channelRoom != nil {
                            roomInDb.channelRoom?.privateExtra?.inviteLink = invitedLink
                            roomInDb.channelRoom?.privateExtra?.inviteToken = invitedToken
                        }
                        if roomInDb.groupRoom != nil {
                            roomInDb.groupRoom?.privateExtra?.inviteLink = invitedLink
                            roomInDb.groupRoom?.privateExtra?.inviteToken = invitedToken
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    
    func setActionForRoom(action: IGClientAction, userId:Int64, roomId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGFactoryTask(dependencyRoomTask: roomId, isParticipane: true).success({
                IGFactoryTask(dependencyUserTask: userId, cacheID: nil).success({ 
                    let userPredicate = NSPredicate(format: "id = %lld", userId)
                    let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                    if let user = try! Realm().objects(IGRegisteredUser.self).filter(userPredicate).first, let room = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                        let userRef = ThreadSafeReference(to: user)
                        let roomRef = ThreadSafeReference(to: room)
                        
                        IGRoomManager.shared.set(action, for: roomRef, from: userRef)
                    }
                    //self.setFactoryTaskSuccess(task: task)
                }).error({ 
                    //self.setFactoryTaskError(task: task)
                }).execute()
            }).error({ 
                //self.setFactoryTaskError(task: task)
            }).execute()
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateRoomParticipant(roomId: Int64, isParticipant: Bool){
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        room.isParticipant = isParticipant
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func addGroupMemberToDatabase(_ userID: Int64 , roomID: Int64 , memberRole : IGGroupMember.IGRole) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGFactoryTask.init(dependencyUserTask: userID, cacheID: nil).success ({
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    let predicate = NSPredicate(format: "id = %lld", userID)
                    if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                        let memberPredicate = NSPredicate(format: "userID = %lld", userID)
                        if let memberIndb = try! Realm().objects(IGGroupMember.self).filter(memberPredicate).first {
                            try! IGDatabaseManager.shared.realm.write {
                                memberIndb.user = userInDb
                                memberIndb.role = memberRole
                            }
                            
                        }
                    }
                    
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                }
            }).error ({
                //self.setFactoryTaskError(task: task)
            }).execute()
        }
        //self.doFactoryTask(task: task)
    }
    
    func addChannelMemberToDatabase(memberId: Int64 , memberRole : IGChannelMember.IGRole , roomId: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGFactoryTask(dependencyRoomTask: roomId, isParticipane: true).success ({
                IGFactoryTask.init(dependencyUserTask: memberId, cacheID: nil).success ({
                    IGDatabaseManager.shared.perfrmOnDatabaseThread {
                        let predicate = NSPredicate(format: "id = %lld", memberId)
                        if let userInDb = try! Realm().objects(IGRegisteredUser.self).filter(predicate).first {
                            let channelMemberPredicate = NSPredicate(format: "userID = %lld", memberId)
                            if let memberInDb = try! Realm().objects(IGChannelMember.self).filter(channelMemberPredicate).first {
                                try! IGDatabaseManager.shared.realm.write {
                                    memberInDb.user = userInDb
                                    memberInDb.role = memberRole
                                    memberInDb.roomID = roomId
                                }
                            }
                        }
                        
                        if memberRole == .admin || memberRole == .moderator {
                            self.updateRoomReadOnly(roomId: roomId, memberId: memberId, readOnly: false)
                        }
                        
                        IGFactory.shared.performInFactoryQueue {
                            //self.setFactoryTaskSuccess(task: task)
                        }
                    }
                }).error ({
                    //self.setFactoryTaskError(task: task)
                }).execute()
            }).error ({
                
            }).execute()
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateGroupAvatar(_ roomId: Int64, igpAvatar: IGPAvatar) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let avatar = IGAvatar(igpAvatar: igpAvatar)
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGGroupRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.avatar = avatar
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateChannelAvatar(_ roomId: Int64, igpAvatar: IGPAvatar) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                let avatar = IGAvatar(igpAvatar: igpAvatar)
                let predicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGChannelRoom.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.avatar = avatar
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }            
        }
        //self.doFactoryTask(task: task)
    }
    
    //MARK: --------------------------------------------------------
    //MARK: ▶︎▶︎ File
    /* just use this method for sticker. because we need insert info
     * with file type, and file type detection is impossible.
     * for example detect current file info is for image or sticker ?!
     */
    func addStickerFileToDatabse(igpFile: IGPFile, completion: @escaping ((_ token :IGFile) -> Void)) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let newFile = IGFile(igpFile: igpFile, type: IGFile.FileType.sticker)
                
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.add(newFile, update: true)
                }
                
                completion(newFile)
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func removeFileNameOnDisk(primaryKeyId: String, status: IGFile.Status) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "primaryKeyId = %@", primaryKeyId)
                    if let file = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(predicate).first {
                        file.fileNameOnDisk = nil
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateFileInDatabe(_ file: IGFile, with igpFile: IGPFile) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let newFile = IGFile(igpFile: igpFile, type: file.type)
                newFile.type = file.type
                newFile.primaryKeyId = file.primaryKeyId
                newFile.fileNameOnDisk = file.fileNameOnDisk
                
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.add(newFile, update: true)
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func addNameOnDiskToFile(_ file: IGFile, name: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let predicate = NSPredicate(format: "cacheID = %@", file.cacheID!)
                if let fileInDb = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(predicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        fileInDb.fileNameOnDisk = name
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveDraft(draft: IGRoomDraft) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", draft.roomId)
                if let roomInDb = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        let draftInDb = IGRoomDraft.putOrUpdate(message: draft.message, replyTo: draft.replyTo, roomId: draft.roomId)
                        roomInDb.draft = draftInDb
                        if draftInDb.time != 0 { // if has draft time, update value to sortimgTimestamp fot sort in room list
                            roomInDb.sortimgTimestamp = Double(draftInDb.time)
                        } else {
                            if let lastMessage = roomInDb.lastMessage {
                                let predicateMessage = NSPredicate(format: "id = %lld AND roomId = %lld", (lastMessage.id), roomInDb.id)
                                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicateMessage).first {
                                    roomInDb.sortimgTimestamp = (messageInDb.creationTime?.timeIntervalSinceReferenceDate)!
                                }
                            } else {
                                roomInDb.sortimgTimestamp = 0
                            }
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveDraft(roomId: Int64, igpDraft: IGPRoomDraft) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        let draftInDb = IGRoomDraft.putOrUpdate(realm: IGDatabaseManager.shared.realm, igpDraft: igpDraft, roomId: roomId)
                        roomInDb.draft = draftInDb
                        if draftInDb.time != 0 { // if has draft time, update value to sortimgTimestamp fot sort in room list
                            roomInDb.sortimgTimestamp = Double(draftInDb.time)
                        } else {
                            if let lastMessage = roomInDb.lastMessage {
                                let predicateMessage = NSPredicate(format: "id = %lld AND roomId = %lld", (lastMessage.id), roomInDb.id)
                                if let messageInDb = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicateMessage).first {
                                    roomInDb.sortimgTimestamp = (messageInDb.creationTime?.timeIntervalSinceReferenceDate)!
                                }
                            } else {
                                roomInDb.sortimgTimestamp = 0
                            }
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func convertChatToGroup(roomId: Int64, roomName: String , roomRole : IGGroupMember.IGRole , roomDescription: String ) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.type = .group
                        roomInDb.isParticipant = true
                        roomInDb.title = roomName
                        roomInDb.groupRoom?.roomDescription = roomDescription
                        roomInDb.groupRoom?.role = roomRole
                        roomInDb.sortimgTimestamp = Date().timeIntervalSinceReferenceDate
                    }
                    
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
                
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func roomPinMessage(roomId: Int64, messageId: Int64 = 0) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                let roomPredicate = NSPredicate(format: "id = %lld", roomId)
                if let roomInDb = try! Realm().objects(IGRoom.self).filter(roomPredicate).first {
                    
                    var pinMessage : IGRoomMessage? = nil
                    
                    if messageId != 0 {
                        let messagePredicate = NSPredicate(format: "id = %lld", messageId)
                        pinMessage = try! Realm().objects(IGRoomMessage.self).filter(messagePredicate).first
                    }
                    
                    try! IGDatabaseManager.shared.realm.write {
                        roomInDb.pinMessage = pinMessage
                        if messageId == 0 {
                            if pinMessage != nil {
                                roomInDb.deletedPinMessageId = (pinMessage?.id)!
                            }
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func saveWallpaper(wallpapers: [IGPWallpaper]) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.add(IGRealmWallpaper(wallpapers: wallpapers))
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setWallpaperFile(wallpaper: NSData?) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                if let wallpapers = IGDatabaseManager.shared.realm.objects(IGRealmWallpaper.self).first {
                    try! IGDatabaseManager.shared.realm.write {
                        if wallpaper != nil {
                            wallpapers.selectedFile = wallpaper
                        } else {
                            wallpapers.selectedFile = nil
                        }
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setWallpaperSolidColor(solidColor: String?) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                
                if let wallpapers = IGDatabaseManager.shared.realm.objects(IGRealmWallpaper.self).first {
                    try! IGDatabaseManager.shared.realm.write {
                        wallpapers.selectedColor = solidColor
                    }
                }
                
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func addOfflineSeen(roomId: Int64, messageId: Int64, status: IGPRoomMessageStatus) {
        if status != .seen {return}
        
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.add(IGRealmOfflineSeen(roomId: roomId, messageId: messageId))
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func removeOfflineSeen(roomId: Int64, messageId: Int64, status: IGPRoomMessageStatus) {
        if status != .seen {return}
        
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    if let offlineSeen = IGDatabaseManager.shared.realm.objects(IGRealmOfflineSeen.self).filter("roomId = %lld", roomId).first {
                        IGDatabaseManager.shared.realm.delete(offlineSeen)
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    
    func addSticker(stickers: [StickerTab]) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    
                    for sticker in stickers {
                        let stickerItems: List<IGRealmStickerItem> = List<IGRealmStickerItem>()
                        for stickerItem in sticker.stickers {
                            stickerItems.append(IGRealmStickerItem(sticker: stickerItem))
                        }
                        
                        IGDatabaseManager.shared.realm.add(IGRealmSticker(sticker: sticker, stickerItems: stickerItems), update: true)
                    }
                    
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func removeSticker(groupId: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "id = %@", groupId)
                    if let stickerItem = IGDatabaseManager.shared.realm.objects(IGRealmSticker.self).filter(predicate).first {
                        IGDatabaseManager.shared.realm.delete(stickerItem)
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func removeAllSticker() {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRealmSticker.self))
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    
    func addDiscoveryPageInfo(discoveryList: [IGPDiscovery]) {
        removeDiscoveryPageInfo()
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    for discovery in discoveryList {
                        IGDatabaseManager.shared.realm.add(IGRealmDiscovery(discovery: discovery))
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func removeDiscoveryPageInfo() {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRealmDiscovery.self))
                    IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRealmDiscoveryField.self))
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func setRepresenter(phoneNumber: String) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    if let session = IGDatabaseManager.shared.realm.objects(IGSessionInfo.self).first {
                        session.representer = phoneNumber
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func clearGap(roomId: Int64, fromPosition: Int64, toPosition: Int64) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    // TODO - set all these values with list, without loop
                    let predicate = NSPredicate(format: "roomId = %lld AND id >= %lld AND id <= %lld", roomId, fromPosition, toPosition)
                    for realmRoomMessage in IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate) {
                        realmRoomMessage.previousMessageId = 0
                        realmRoomMessage.futureMessageId = 0
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    /* if don't set direction, messageId will be set for both of previousMessageId & futureMessageId */
    func setGap(messageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection? = nil) {
        //let task = getFactoryTask()
        factoryQueue.async {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    let predicate = NSPredicate(format: "id = %lld", messageId)
                    if let realmRoomMessage = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                        if direction == nil {
                            realmRoomMessage.previousMessageId = messageId
                            realmRoomMessage.futureMessageId = messageId
                        } else {
                            if (direction == .up) {
                                realmRoomMessage.previousMessageId = messageId
                            } else {
                                realmRoomMessage.futureMessageId = messageId
                            }
                        }
                    }
                }
                IGFactory.shared.performInFactoryQueue {
                    //self.setFactoryTaskSuccess(task: task)
                }
            }
        }
        //self.doFactoryTask(task: task)
    }
    
    func updateFirstUnreadMessage(roomId: Int64, messageId: Int64) {
        //TODO - call this method after set message into the db
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            //let task = getFactoryTask()
            self.factoryQueue.async {
                IGDatabaseManager.shared.perfrmOnDatabaseThread {
                    try! IGDatabaseManager.shared.realm.write {
                        
                        let predicateRoom = NSPredicate(format: "id = %lld", roomId)
                        if let room = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(predicateRoom).first, room.unreadCount <= 1 {
                            let predicate = NSPredicate(format: "id = %lld", messageId)
                            if let realmRoomMessage = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first {
                                realmRoomMessage.futureMessageId = realmRoomMessage.id
                                room.firstUnreadMessage = realmRoomMessage
                            }
                        }
                    }
                    IGFactory.shared.performInFactoryQueue {
                        //self.setFactoryTaskSuccess(task: task)
                    }
                }
            }
            //self.doFactoryTask(task: task)
        }
    }
}
