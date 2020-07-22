/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import IGProtoBuff
import SwiftProtobuf
import RealmSwift
import SwiftEventBus

class IGMessageSender {
    static let defaultSender = IGMessageSender()
    fileprivate var messagesWithAttachmentQueue: DispatchQueue //should wait for download to complete
    fileprivate var plainMessagesArray = [IGMessageSenderTask]()
    fileprivate var messagesWithAttachmentArray = [IGMessageSenderTask]()
    
    private init() {
        messagesWithAttachmentQueue = DispatchQueue(label: "im.igap.ios.queue.message.attachment")
    }
    
    func send(message: IGRoomMessage, to room: IGRoom) {
        let task = IGMessageSenderTask(message: message, room: room)
        if message.attachment != nil {
            addTaskToMessagesWithAttachmentQueue(task)
        } else {
            addTaskToPlainMessagesQueue(task)
        }
    }
    
    func sendSingleForward(message: IGRoomMessage, to room: IGRoom, success: @escaping (() -> Void), error: @escaping (() -> Void)) {
        let task = IGMessageSenderTask(message: message, room: room)
        if message.attachment != nil {
            sendSingleFileForward(messageTask: task, success: success, error: error)
        } else {
            sendSingleTextForward(messageTask: task, success: success, error: error)
        }
    }
    
    func sendSticker(message: IGRoomMessage, to room: IGRoom) {
        let task = IGMessageSenderTask(message: message, room: room)
        addTaskToPlainMessagesQueue(task)
    }
    
    func resend(message: IGRoomMessage, to room: IGRoom) {
        IGFactory.shared.updateMessageStatus(primaryKeyId: message.primaryKeyId!, status: .sending)
        SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(room.id)", sender: (action: ChatMessageAction.locallyUpdateStatus, localMessage: message))
    }
    
    func resendAllSendingMessage(roomId: Int64 = 0){
        var count:Double = 0
        let realm = try! Realm()
        var predicate = NSPredicate(format: "statusRaw = %d", IGRoomMessageStatus.sending.rawValue)
        if roomId != 0 {
            predicate = NSPredicate(format: "roomId = %lld AND statusRaw = %d", roomId, IGRoomMessageStatus.sending.rawValue)
        }
        
        for message in realm.objects(IGRoomMessage.self).filter(predicate) {
            DispatchQueue.main.asyncAfter(deadline: .now() + count){
                if !message.isInvalidated {
                    count = count + 1
                    let room = realm.objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", message.roomId)).first
                    if room != nil && !room!.isInvalidated {
                        IGMessageSender.defaultSender.resend(message: message, to: room!)
                    }
                }
            }
        }
    }
    
    func failSendingMessage(){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            let predicate = NSPredicate(format: "statusRaw = %d", IGRoomMessageStatus.sending.rawValue)
            try! IGDatabaseManager.shared.realm.write {
                IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).setValue(IGRoomMessageStatus.failed.rawValue, forKey: "statusRaw")
            }
        }
    }
    
    func removeMessagesWithAttachmentTask(cacheID: String){
        if let task = getAttachemntTaskWithFilePrimaryKeyId(cacheID: cacheID) {
            if let index = messagesWithAttachmentArray.firstIndex(of: task) {
                messagesWithAttachmentArray.remove(at: index)
            }
        }
    }
    
    func faileMessage(identity: Any?) {
        if let structMessageIdentity = identity as? IGStructMessageIdentity {
            IGFactory.shared.updateMessageStatusToFail(message: structMessageIdentity.roomMessage, primaryKey: structMessageIdentity.primaryKeyId)
        }
    }
    
    func faileFileMessage(uploadTask: IGUploadTask) {
        DispatchQueue.main.async {
            IGUploadManager.sharedManager.cancelUpload(attachment: uploadTask.file, deleteMessage: false)
            IGFactory.shared.updateMessageStatus(primaryKeyId: uploadTask.file.cacheID!, status: .failed, hasAttachment: true)
        }
    }
    
    func deleteFailedMessage(primaryKeyId: String?, hasAttachment: Bool = false) {
        if primaryKeyId == nil {return}
        
        if hasAttachment {
            removeMessagesWithAttachmentTask(cacheID: primaryKeyId!) // do this for file
        } else {
            removeTaskFromPlainMessagesQueue(getPlainTaskWithMessagePrimaryKeyId(primaryKeyId: primaryKeyId!))
        }
        
        IGFactory.shared.deleteMessageWithPrimaryKeyId(primaryKeyId: primaryKeyId, hasAttachment: hasAttachment)
    }
    
    //MARK: Queue Handler
    private func addTaskToPlainMessagesQueue(_ task: IGMessageSenderTask) {
        sendNextPlainRequest(task)
    }
    
    fileprivate func removeTaskFromPlainMessagesQueue(_ task: IGMessageSenderTask?) {
        if task == nil {return}
        
        if let index = plainMessagesArray.firstIndex(of: task!) {
            plainMessagesArray.remove(at: index)
        }
    }
    
    private func addTaskToMessagesWithAttachmentQueue(_ task: IGMessageSenderTask) {
        messagesWithAttachmentArray.append(task)
        /** start upload when is first item otherwise just fill upload array and after than finish upload, next item automatically will be started!*/
        if messagesWithAttachmentArray.count == 1 {
            uploadAttahcmentForNextRequest()
        }
    }
    
    private func moveMesageFromAttachmentedQueueToPlainQueue(_ task: IGMessageSenderTask) {
        if let index = messagesWithAttachmentArray.firstIndex(of: task) {
            messagesWithAttachmentArray.remove(at: index)
            print("=-=-=-=-=- 1111: ", task.uploadTask?.file.token ?? "")
            addTaskToPlainMessagesQueue(task)
            uploadAttahcmentForNextRequest()
        }
    }
    
    private func getPlainTaskWithMessagePrimaryKeyId(primaryKeyId: String) -> IGMessageSenderTask? {
        for task in plainMessagesArray {
            if task.message.primaryKeyId! == primaryKeyId {
                return task
            }
        }
        return nil
    }
    
    private func getAttachemntTaskWithFilePrimaryKeyId(cacheID: String) -> IGMessageSenderTask? {
        for task in messagesWithAttachmentArray {
            if task.message.attachment!.cacheID! == cacheID {
                return task
            }
        }
        return nil
    }
    
    
    //MARK: Send Next
    func sendNextPlainRequest(_ nextMessageTask: IGMessageSenderTask) {
        
        //IGMessageLoader.getInstance(room: nextMessageTask.room, forceNew: false).setInsuringGap(messageId: nextMessageTask.message.id, direction: .up)
        
        switch nextMessageTask.room.type {
        case .chat:
            IGChatSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.file.token).successPowerful({ (protoResponse, requestWrapper) in
                if let chatSendMessageResponse = protoResponse as? IGPChatSendMessageResponse, let oldMessage = requestWrapper.identity as? IGStructMessageIdentity {
                    IGChatSendMessageRequest.Handler.interpret(response: chatSendMessageResponse, identity: oldMessage)
                    if chatSendMessageResponse.igpResponse.igpID.isEmpty {
                        IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: chatSendMessageResponse.igpRoomMessage)
                    }
                }
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                self.faileMessage(identity: requestWrapper.identity)
            }).send()
            break
            
        case .group:
            IGGroupSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.file.token).successPowerful({ (protoResponse, requestWrapper) in
                if let groupSendMessageResponse = protoResponse as? IGPGroupSendMessageResponse, let oldMessage = requestWrapper.identity as? IGStructMessageIdentity {
                    IGGroupSendMessageRequest.Handler.interpret(response: groupSendMessageResponse, identity: oldMessage)
                    if groupSendMessageResponse.igpResponse.igpID.isEmpty {
                        IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: groupSendMessageResponse.igpRoomMessage)
                    }
                }
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                self.faileMessage(identity: requestWrapper.identity)
            }).send()
            break
            
        case .channel:
            IGChannelSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.file.token).successPowerful({ (protoResponse, requestWrapper) in
                if let channelSendMessageResponse = protoResponse as? IGPChannelSendMessageResponse, let oldMessage = requestWrapper.identity as? IGStructMessageIdentity {
                    IGChannelSendMessageRequest.Handler.interpret(response: channelSendMessageResponse, identity: oldMessage)
                    if channelSendMessageResponse.igpResponse.igpID.isEmpty {
                        IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: channelSendMessageResponse.igpRoomMessage)
                    }
                }
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                self.faileMessage(identity: requestWrapper.identity)
            }).send()
            break
        }
    }
    
    func uploadAttahcmentForNextRequest() {
        if let nextMessageToUpload = messagesWithAttachmentArray.first {
            if let nextMessageUploadTask = IGUploadManager.sharedManager.upload(file: nextMessageToUpload.message.attachment!, start: {
                self.fileUploadStarted(nextMessageToUpload)
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                DispatchQueue.main.async {
                    self.fileUploadEnded(nextMessageToUpload)
                    for task in self.messagesWithAttachmentArray {
                        if task.uploadTask == uploadTask {
                            self.moveMesageFromAttachmentedQueueToPlainQueue(task)
                        }
                    }
                }
            }, failure: { 
                self.fileUploadEnded(nextMessageToUpload)
                IGFactory.shared.updateMessageStatusToFail(message: nextMessageToUpload.message)
            }) {
                nextMessageToUpload.uploadTask = nextMessageUploadTask
            }
        }
    }
    
    /* send single forward message and return success state with clouser for open chat room */
    private func sendSingleTextForward(messageTask: IGMessageSenderTask, success: @escaping (() -> Void), error: @escaping (() -> Void)) {
        switch messageTask.room.type {
        case .chat:
            IGChatSendMessageRequest.Generator.generate(message: messageTask.message, room: messageTask.room, attachmentToken: messageTask.uploadTask?.file.token ?? "").successPowerful({ (protoResponse, requestWrapper) in
                if let chatSendMessageResponse = protoResponse as? IGPChatSendMessageResponse, let oldMessage = requestWrapper.identity as? IGStructMessageIdentity {
                    IGChatSendMessageRequest.Handler.interpret(response: chatSendMessageResponse, identity: oldMessage)
                    if chatSendMessageResponse.igpResponse.igpID.isEmpty {
                        IGFactory.shared.updateSendingMessageStatus(messageTask.message, with: chatSendMessageResponse.igpRoomMessage)
                    }
                    success()
                }
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                error()
                self.faileMessage(identity: requestWrapper.identity)
            }).send()
            break
            
        case .group:
            IGGroupSendMessageRequest.Generator.generate(message: messageTask.message, room: messageTask.room, attachmentToken: messageTask.uploadTask?.file.token ?? "").successPowerful({ (protoResponse, requestWrapper) in
                if let groupSendMessageResponse = protoResponse as? IGPGroupSendMessageResponse, let oldMessage = requestWrapper.identity as? IGStructMessageIdentity {
                    IGGroupSendMessageRequest.Handler.interpret(response: groupSendMessageResponse, identity: oldMessage)
                    if groupSendMessageResponse.igpResponse.igpID.isEmpty {
                        IGFactory.shared.updateSendingMessageStatus(messageTask.message, with: groupSendMessageResponse.igpRoomMessage)
                    }
                    success()
                }
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                error()
                self.faileMessage(identity: requestWrapper.identity)
            }).send()
            break
            
        case .channel:
            IGChannelSendMessageRequest.Generator.generate(message: messageTask.message, room: messageTask.room, attachmentToken: messageTask.uploadTask?.file.token ?? "").successPowerful({ (protoResponse, requestWrapper) in
                if let channelSendMessageResponse = protoResponse as? IGPChannelSendMessageResponse, let oldMessage = requestWrapper.identity as? IGStructMessageIdentity {
                    IGChannelSendMessageRequest.Handler.interpret(response: channelSendMessageResponse, identity: oldMessage)
                    if channelSendMessageResponse.igpResponse.igpID.isEmpty {
                        IGFactory.shared.updateSendingMessageStatus(messageTask.message, with: channelSendMessageResponse.igpRoomMessage)
                    }
                    success()
                }
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                error()
                self.faileMessage(identity: requestWrapper.identity)
            }).send()
            break
        }
    }
    
    private func sendSingleFileForward(messageTask: IGMessageSenderTask, success: @escaping (() -> Void), error: @escaping (() -> Void)) {
        if let nextMessageUploadTask = IGUploadManager.sharedManager.upload(file: messageTask.message.attachment!, start: {
            self.fileUploadStarted(messageTask)
        }, progress: { (progress) in
        }, completion: { (uploadTask) in
            self.fileUploadEnded(messageTask)
            self.sendSingleTextForward(messageTask: messageTask, success: success, error: error)
        }, failure: {
            self.fileUploadEnded(messageTask)
        }) {
            messageTask.uploadTask = nextMessageUploadTask
        }
    }
    
    
    private func fileUploadStarted(_ task: IGMessageSenderTask) {
        switch task.message.type {
        case .image, .imageAndText:
            IGClientActionManager.shared.sendSendingImage(file: task.message.attachment!, for: task.room)
            break
        case .video, .videoAndText:
            IGClientActionManager.shared.sendSendingVideo(file: task.message.attachment!, for: task.room)
            break
        case .audio, .audioAndText:
            IGClientActionManager.shared.sendSendingAudio(file: task.message.attachment!, for: task.room)
            break
        case .voice:
            IGClientActionManager.shared.sendSendingVoice(file: task.message.attachment!, for: task.room)
            break
        case .file, .fileAndText:
            IGClientActionManager.shared.sendSendingFile(file: task.message.attachment!, for: task.room)
            break
        case .gif, .gifAndText:
            IGClientActionManager.shared.sendSendingGif(file: task.message.attachment!, for: task.room)
            break
        default:
            break
        }
    }
    
    private func fileUploadEnded(_ task: IGMessageSenderTask) {
        switch task.message.type {
        case .image, .imageAndText:
            IGClientActionManager.shared.cancelSendingImage(file: task.message.attachment!, for: task.room)
            break
        case .video, .videoAndText:
            IGClientActionManager.shared.cancelSendingVideo(file: task.message.attachment!, for: task.room)
            break
        case .audio, .audioAndText:
            IGClientActionManager.shared.cancelSendingAudio(file: task.message.attachment!, for: task.room)
            break
        case .voice:
            IGClientActionManager.shared.cancelSendingVoice(file: task.message.attachment!, for: task.room)
            break
        case .file, .fileAndText:
            IGClientActionManager.shared.cancelSendingFile(file: task.message.attachment!, for: task.room)
            break
        case .gif, .gifAndText:
            IGClientActionManager.shared.cancelSendingGif(file: task.message.attachment!, for: task.room)
            break
        default:
            break
        }
    }
}


//MARK: -
class IGMessageSenderTask: NSObject{
    var message: IGRoomMessage
    var room: IGRoom
    var uploadTask: IGUploadTask?
    
    init(message: IGRoomMessage, room: IGRoom) {
        self.message = message
        self.room = room
        super.init()
    }
}
