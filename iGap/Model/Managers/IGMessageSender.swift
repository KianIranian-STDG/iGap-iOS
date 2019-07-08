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

class IGMessageSender {
    static let defaultSender = IGMessageSender()
    fileprivate var plainMessagesQueue: DispatchQueue
    fileprivate var messagesWithAttachmentQueue: DispatchQueue //should wait for download to complete
    fileprivate var plainMessagesArray = [IGMessageSenderTask]()
    fileprivate var messagesWithAttachmentArray = [IGMessageSenderTask]()
    
    private init() {
        plainMessagesQueue = DispatchQueue(label: "im.igap.ios.queue.message.plain")
        messagesWithAttachmentQueue = DispatchQueue(label: "im.igap.ios.queue.message.attachment")
    }
    
    func send(message: IGRoomMessage, to room: IGRoom, sendRequest: Bool = true) {
        let task = IGMessageSenderTask(message: message, room: room)
        if message.attachment != nil {
            addTaskToMessagesWithAttachmentQueue(task, sendRequest: sendRequest)
        } else {
            addTaskToPlainMessagesQueue(task, sendRequest: sendRequest)
        }
    }
    
    func sendSticker(message: IGRoomMessage, to room: IGRoom) {
        let task = IGMessageSenderTask(message: message, room: room)
        addTaskToPlainMessagesQueue(task)
    }
    
    func resend(message: IGRoomMessage, to room: IGRoom) {
        IGFactory.shared.updateMessageStatus(primaryKeyId: message.primaryKeyId!, status: .sending)
        let message = makeCopyOfMessage(message: message)
        if message.type == .sticker {
            sendSticker(message: message, to: room)
        } else {
            send(message: message, to: room)
        }
    }
    
    func resendAllSendingMessage(roomId: Int64 = 0){
        do {
            var count:Double = 0

            let realm = try Realm()
            var predicate = NSPredicate(format: "statusRaw = %d", IGRoomMessageStatus.sending.rawValue)
            if roomId != 0 {
                predicate = NSPredicate(format: "roomId = %lld AND statusRaw = %d", roomId, IGRoomMessageStatus.sending.rawValue)
            }
            
            for message in realm.objects(IGRoomMessage.self).filter(predicate) {
                if message.isInvalidated {
                    break
                }
                count = count + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + count){
                    let room = realm.objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", message.roomId)).first
                    if room != nil && !room!.isInvalidated {
                        IGMessageSender.defaultSender.resend(message: message, to: room!)
                    }
                }
            }

        } catch let error as NSError {
            print("REALM ERROR HAPPENDED: ", error)
        }
    }
    
    func removeMessagesWithAttachmentTask(primaryKeyId: String){
        if let task = getAttachemntTaskWithFilePrimaryKeyId(primaryKeyId: primaryKeyId) {
            if let index = messagesWithAttachmentArray.firstIndex(of: task) {
                messagesWithAttachmentArray.remove(at: index)
            }
        }
    }
    
    func faileMessage(primaryKeyId: String){
        IGFactory.shared.updateMessageStatus(primaryKeyId: primaryKeyId, status: .failed, hasAttachment: false)
    }
    
    func faileFileMessage(uploadTask: IGUploadTask) {
        DispatchQueue.main.async {
            IGUploadManager.sharedManager.cancelUpload(attachment: uploadTask.file, deleteMessage: false)
            IGFactory.shared.updateMessageStatus(primaryKeyId: uploadTask.file.primaryKeyId!, status: .failed, hasAttachment: true)
        }
    }
    
    func deleteFailedMessage(primaryKeyId: String?, hasAttachment: Bool = false) {
        if primaryKeyId == nil {return}
        
        if hasAttachment {
            removeMessagesWithAttachmentTask(primaryKeyId: primaryKeyId!) // do this for file
        } else {
            removeTaskFromPlainMessagesQueue(getPlainTaskWithMessagePrimaryKeyId(primaryKeyId: primaryKeyId!))
        }
        
        IGFactory.shared.deleteMessageWithPrimaryKeyId(primaryKeyId: primaryKeyId, hasAttachment: hasAttachment)
    }
    
    //MARK: Queue Handler
    private func addTaskToPlainMessagesQueue(_ task: IGMessageSenderTask, sendRequest: Bool = true) {
        plainMessagesArray.append(task)
        if sendRequest {
            sendNextPlainRequest()
        }
    }
    
    fileprivate func removeTaskFromPlainMessagesQueue(_ task: IGMessageSenderTask?) {
        if task == nil {return}
        
        if let index = plainMessagesArray.firstIndex(of: task!) {
            plainMessagesArray.remove(at: index)
        }
    }
    
    private func addTaskToMessagesWithAttachmentQueue(_ task: IGMessageSenderTask, sendRequest: Bool = true) {
        messagesWithAttachmentArray.append(task)
        if sendRequest {
        uploadAttahcmentForNextRequest()
        }
    }
    
    private func moveMesageFromAttachmentedQueueToPlainQueue(_ task: IGMessageSenderTask) {
        if let index = messagesWithAttachmentArray.firstIndex(of: task) {
            messagesWithAttachmentArray.remove(at: index)
            addTaskToPlainMessagesQueue(task)
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
    
    private func getAttachemntTaskWithFilePrimaryKeyId(primaryKeyId: String) -> IGMessageSenderTask? {
        for task in messagesWithAttachmentArray {
            if task.message.attachment!.primaryKeyId! == primaryKeyId {
                return task
            }
        }
        return nil
    }
    
    
    //MARK: Send Next
    func sendNextPlainRequest() {
        if let nextMessageTask = plainMessagesArray.first {
            switch nextMessageTask.room.type {
            case .chat:
                IGChatSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.token).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        if let chatSendMessageResponse = protoResponse as? IGPChatSendMessageResponse {
                            
                            if !chatSendMessageResponse.igpResponse.igpID.isEmpty {
                                IGFactory.shared.updateIgpMessagesToDatabase(chatSendMessageResponse.igpRoomMessage, primaryKeyId: nextMessageTask.message.primaryKeyId!, roomId: nextMessageTask.room.id)
                            } else {
                                IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: chatSendMessageResponse.igpRoomMessage)
                            }
                            
                            self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                            self.sendNextPlainRequest()
                        }
                    }
                    
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        if let task = self.plainMessagesArray.first {
                            self.faileMessage(primaryKeyId: task.message.primaryKeyId!)
                        }
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                    
                }).send()
            case .group:
                IGGroupSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.token).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        if let groupSendMessageResponse = protoResponse as? IGPGroupSendMessageResponse {
                            if !groupSendMessageResponse.igpResponse.igpID.isEmpty {
                                IGFactory.shared.updateIgpMessagesToDatabase(groupSendMessageResponse.igpRoomMessage, primaryKeyId: nextMessageTask.message.primaryKeyId!, roomId: nextMessageTask.room.id)
                            } else {
                                IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: groupSendMessageResponse.igpRoomMessage)
                            }
                        }
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        if let task = self.plainMessagesArray.first {
                            self.faileMessage(primaryKeyId: task.message.primaryKeyId!)
                        }
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                    
                }).send()
                break
            case .channel:
                IGChannelSendMessageRequest.Generator.generate(message: nextMessageTask.message, room: nextMessageTask.room, attachmentToken: nextMessageTask.uploadTask?.token).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        if let channelSendMessageResponse = protoResponse as? IGPChannelSendMessageResponse {
                            if !channelSendMessageResponse.igpResponse.igpID.isEmpty {
                                IGFactory.shared.updateIgpMessagesToDatabase(channelSendMessageResponse.igpRoomMessage, primaryKeyId: nextMessageTask.message.primaryKeyId!, roomId: nextMessageTask.room.id)
                            } else {
                                IGFactory.shared.updateSendingMessageStatus(nextMessageTask.message, with: channelSendMessageResponse.igpRoomMessage)
                            }
                        }
                        
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        if let task = self.plainMessagesArray.first {
                            self.faileMessage(primaryKeyId: task.message.primaryKeyId!)
                        }
                        self.removeTaskFromPlainMessagesQueue(nextMessageTask)
                        self.sendNextPlainRequest()
                    }
                }).send()
                break
            }
        }
    }
    
     func uploadAttahcmentForNextRequest() {
        if let nextMessageToUpload = messagesWithAttachmentArray.first {
            if let nextMessageUploadTask = IGUploadManager.sharedManager.upload(file: nextMessageToUpload.message.attachment!, start: {
                self.fileUploadStarted(nextMessageToUpload)
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                self.fileUploadEnded(nextMessageToUpload)
                for task in self.messagesWithAttachmentArray {
                    if task.uploadTask == uploadTask {
                        self.moveMesageFromAttachmentedQueueToPlainQueue(task)
                    }
                }
            }, failure: { 
                //TODO: check what will happen if upload failes.
                self.fileUploadEnded(nextMessageToUpload)
            }) {
                nextMessageToUpload.uploadTask = nextMessageUploadTask
            }
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

    
    private func makeCopyOfMessage(message: IGRoomMessage) -> IGRoomMessage{
        let finalMessage = IGRoomMessage()
        finalMessage.id = message.id
        finalMessage.message = message.message
        finalMessage.type = message.type
        finalMessage.isDeleted = message.isDeleted
        finalMessage.creationTime = message.creationTime
        finalMessage.status = message.status
        finalMessage.temporaryId = message.temporaryId
        finalMessage.primaryKeyId = message.primaryKeyId
        finalMessage.randomId = message.randomId
        finalMessage.authorUser = message.authorUser
        finalMessage.authorHash = message.authorHash
        finalMessage.attachment = message.attachment
        finalMessage.additional = message.additional
        return finalMessage
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










