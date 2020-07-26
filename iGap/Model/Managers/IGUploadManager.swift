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
import RxSwift

typealias UploadStartCallback    = (()->())?
typealias UploadProgressCallback = ((Progress)->())?
typealias UploadCompleteCallback = ((IGUploadTask)->())?
typealias UploadFailedCallback   = (()->())?

enum UploadDownloadStatus {
    case waiting
    case uploading
    case finished
    case failed
}

class IGUploadManager: StreamManagerDelegate {
    
    var disposeBag = DisposeBag()
    
    static let sharedManager = IGUploadManager()
    fileprivate var uploadQueue: DispatchQueue
    private var pendingUploads = [IGUploadTask]()
    private var currentUploadingTask: IGUploadTask?
    private var canceledUpload = false // for insuring about disable processing state
    
    class func compress(image: UIImage) -> UIImage {
        let scale: CGFloat = 0.5
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    
    //MARK: - Init
    private init() {
        uploadQueue = DispatchQueue(label: "im.igap.ios.queue.upload")
    }
    
    //MARK: - Public methods
    @discardableResult
    func upload(file:IGFile, start:UploadStartCallback, progress:UploadProgressCallback, completion:UploadCompleteCallback, failure:UploadFailedCallback) -> IGUploadTask? {

        let uploadTask = IGUploadTask(file: file, start: start, progress: progress, completion: completion, failure: failure)
        performInUploadQueue {
            self.addToQueue(task: uploadTask)
        }
        
        return uploadTask
    }
    
    func pauseAllUploads(){
        for task in pendingUploads {
            cancelUpload(attachment: task.file, deleteMessage: false)
            IGFactory.shared.updateMessageStatus(primaryKeyId: task.file.cacheID!, status: .failed, hasAttachment: true)
        }
    }
    
    func cancelUpload(attachment: IGFile, deleteMessage: Bool = true) {
        if attachment.cacheID == nil {
            return
        }
        self.canceledUpload = true
        IGRequestManager.sharedManager.cancelRequest(identity: attachment.cacheID!)
        IGMessageSender.defaultSender.removeMessagesWithAttachmentTask(cacheID: attachment.cacheID!)
        removeFromQueueAndStartNext(task: getTaskWithPrimaryKeyId(primaryKeyId: attachment.cacheID!))
        IGAttachmentManager.sharedManager.setStatus(.uploadFailed, for: attachment)
        if deleteMessage {
            IGFactory.shared.deleteMessageWithPrimaryKeyId(primaryKeyId: attachment.cacheID, hasAttachment: true)
        }
    }
    
    //MARK: - Private methods
    private func performInUploadQueue(execute work: @escaping @convention(block) () -> Swift.Void) {
        uploadQueue.async {
            work()
        }
    }
    
    private func addToQueue(task: IGUploadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.uploading, for: task.file)
        pendingUploads.append(task)
        startNextTaskIfPossible()
    }
    
    private func removeFromQueueAndStartNext(task: IGUploadTask?) {
        if task != nil {
            if let index = pendingUploads.firstIndex(of: task!) {
                pendingUploads.remove(at: index)
                performInUploadQueue {
                    self.startNextTaskIfPossible()
                }
            }
        }
    }
    
    private func getTaskWithPrimaryKeyId(primaryKeyId: String) -> IGUploadTask? {
        for task in pendingUploads {
            if task.file.cacheID == primaryKeyId {
                return task
            }
        }
        return nil
    }
    
    // MARK: Upload next
    private func startNextTaskIfPossible() {
        if let task = pendingUploads.first {
            if task.status == .waiting {
                task.file.loadData()
                
                if IGAppManager.sharedManager.UploadDownloadMethod == .Socket {
                    getUploadOptions(for: task)
                }else {
                    initializeStreamUpload(for: task)
                }
            }
        }
    }
    
    
    //Step 1: Get Upload options (initil bytes limit, final bytes limit, max connection)
    private func getUploadOptions(for task: IGUploadTask) {
        
        guard let fileData = task.file.data else {
            return
        }
        
        if task.file.uploadDownloadMethod != RequestMethod.Socket.rawValue {
            if task.file.uploadDownloadMethod == RequestMethod.Rest.rawValue && task.file.token != nil{
                task.file.token = nil
            }
            IGFile.setUploadDownloadMethod(cacheId: task.file.cacheID!, uploadDownloadMethod: .Socket)
        }
        
        DispatchQueue.main.async {
            if let startClousure = task.startCallBack {
                startClousure()
            }
        }
        
        IGFileUploadOptionRequest.Generator.generate(size: Int64((fileData.count)), identity: task.file.cacheID!).successPowerful ({ (protoMessage, requestWrapper) in
            switch protoMessage {
            case let fileUploadOptionReponse as IGPFileUploadOptionResponse:
                task.status = .uploading
                let response = IGFileUploadOptionRequest.Handler.interpret(response: fileUploadOptionReponse)
                task.initialBytesLimit = response.initialBytesLimit
                task.finalBytesLimit = response.finalBytesLimit
                self.initializeUplaod(for: task)
            default:
                break
            }
        }).error({ (errorCode, waitTime) in
            IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    //Step 1-Stream: Initialize Upload
    private func initializeStreamUpload(for task: IGUploadTask, forceRestart: Bool = false) {
        
        if task.file.uploadDownloadMethod != RequestMethod.Socket.rawValue {
            if task.file.uploadDownloadMethod == RequestMethod.NotSet.rawValue {
                IGFile.setUploadDownloadMethod(cacheId: task.file.cacheID!, uploadDownloadMethod: .Rest)
            }
            if task.file.token == nil {
                requestNewUploadToken(for: task)
            } else {
                resumeUpload(for: task)
            }
        } else {
            requestNewUploadToken(for: task)
        }
        
    }
    
    //Step 2-Stream: Request Upload Token
    private func requestNewUploadToken(for task: IGUploadTask) {
        
        IGApiStream.shared.initUpload(name: task.file.name ?? "", size: UInt64(task.file.size)) {[weak self] (response, error) in
            
            guard let sSelf = self else {
                return
            }
            
            if error != nil || response?.token == nil || task.file.cacheID == nil {
                IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
                task.status = .failed
                sSelf.removeFromQueueAndStartNext(task: task)
                DispatchQueue.main.async {
                    if let failureClosure = task.failureCallBack {
                        failureClosure()
                    }
                }
                return
            }
            
            IGFile.updateFileToken(cacheId: task.file.cacheID!, token: (response?.token)!)
            task.file.token = response?.token!
            sSelf.createUploadTask(for: task, token: (response?.token)!)
            
        }
        
    }
    
    //Step 2-Stream-Resume: Resume Upload With Existing Token
    private func resumeUpload(for task: IGUploadTask) {
        
        var retryCount = 0
        
        IGApiStream.shared.uploadResume(token: task.file.token!) {[weak self] (uploadedSize, fileStatus, error) in
            guard let sSelf = self else {
                return
            }
            
            if error != nil {
                IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
                task.status = .failed
                sSelf.removeFromQueueAndStartNext(task: task)
                DispatchQueue.main.async {
                    if let failureClosure = task.failureCallBack {
                        failureClosure()
                    }
                }
                return
            }
            
            if let status = fileStatus {
                if status == .NotFound {
                    sSelf.initializeStreamUpload(for: task, forceRestart: true)
                    return
                }else {
                    
                    if retryCount > 4 {
                        sSelf.initializeStreamUpload(for: task, forceRestart: true)
                        return
                    }
                    
                    sSelf.uploadQueue.asyncAfter(deadline: .now() + 5) {
                        retryCount += 1
                        sSelf.resumeUpload(for: task)
                        return
                    }
                    
                }
            }
            
            sSelf.createUploadTask(for: task, token: task.file.token!, offset: uploadedSize ?? 0)
            
        }
        
    }
    
    //Step 2: Initilize Upload
    private func initializeUplaod(for task: IGUploadTask) {
        let fileData = NSData(data: task.file.data!)
        let initialBytes = fileData.subdata(with: NSMakeRange(0, Int(task.initialBytesLimit!)))
        let finalBytes = fileData.subdata(with: NSMakeRange(Int(task.file.data!.count) - Int(task.finalBytesLimit!), Int(task.finalBytesLimit!)))
        let request = IGFileUploadInitRequest.Generator.generate(initialBytes: initialBytes,
                                                              finalBytes: finalBytes,
                                                              size: Int64(task.file.data!.count),
                                                              hash: (task.file.data?.SHA256())!,
                                                              name: task.file.name!,
                                                              identity: task.file.cacheID!)
        request.successPowerful ({ (protoMessage, requestWrapper) in
            switch protoMessage {
            case let fileUploadInitReponse as IGPFileUploadInitResponse:
                let response = IGFileUploadInitRequest.Handler.interpret(response: fileUploadInitReponse)
                task.file.token = response.token
                task.progress = response.progress
                IGAttachmentManager.sharedManager.setProgress(response.progress / 100.0, for: task.file)
                IGAttachmentManager.sharedManager.setStatus(.uploading, for: task.file)
                if response.progress == 100 {
                    self.canceledUpload = false
                    self.checkStatus(for: task)
                } else {
                    self.uploadAChunk(task: task, offset: response.offset, limit: response.limit)
                }
            default:
                break
            }
        }).error({ (errorCode, waitTime) in
            IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    //Step 3-Stream: Create Upload Task
    private func createUploadTask(for task: IGUploadTask, token: String, offset: UInt64 = 0) {
        
        let manager = StreamManager(uploadTask: task)
        manager.delegate = self
        guard let fileUrl = task.file.localUrl else {
            IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
            return
        }
        manager.createUploadTask(token: token, path: fileUrl, offset: offset)
        var oldProgressValue : Double = 0
        manager.progress.asObservable().subscribe(onNext: { (progress) in
            
            if progress - oldProgressValue < 0.05 && progress < 0.9 {
                return
            }
            oldProgressValue = progress
            
            IGAttachmentManager.sharedManager.setProgress(progress, for: task.file)
            IGAttachmentManager.sharedManager.setStatus(.uploading, for: task.file)
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
    }
    
    //Step 3: Upload a chunk of file (repeat this step until finish)
    private func uploadAChunk(task: IGUploadTask, offset: Int64, limit: Int32) {
        let fileData = NSData(data: task.file.data!)
        let bytes = fileData.subdata(with: NSMakeRange(Int(offset), Int(limit)))
        IGFileUploadRequest.Generator.generate(token: task.file.token ?? "", offset: offset, data: bytes, identity: task.file.cacheID!).successPowerful ({ (protoMessage, requestWrapper) in
            switch protoMessage {
            case let fileUploadReponse as IGPFileUploadResponse:
                let response = IGFileUploadRequest.Handler.interpret(response: fileUploadReponse)
                let progress = response.progress
                if (progress == 100) {
                    IGAttachmentManager.sharedManager.setProgress(99 / 100.0, for: task.file)
                    self.canceledUpload = false
                    self.checkStatus(for: task)
                } else {
                    IGAttachmentManager.sharedManager.setProgress(response.progress / 100.0, for: task.file)
                    //upload another chunk
                    self.uploadAChunk(task: task, offset: response.nextOffset, limit: response.nextLimit)
                }
            default:
                break
            }
        }).error({ (errorCode, waitTime) in
            IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    //Step 4: Check for file state
    private func checkStatus(for task: IGUploadTask) {
        IGFileUploadStatusRequest.Generator.generate(token: task.file.token ?? "", identity: task.file.cacheID!).successPowerful ({ (protoMessage, requestWrapper) in
            
            if self.canceledUpload {
                self.canceledUpload = false
                return
            }
            
            if let statusResponse = protoMessage as? IGPFileUploadStatusResponse {
                switch statusResponse.igpStatus {
                case .uploading:
                    if statusResponse.igpProgress == 100 {
                        //check again after retry delay
                        self.uploadQueue.asyncAfter(deadline: (DispatchTime.now() + Double(statusResponse.igpRecheckDelayMs)/1000.0), execute: {
                            self.checkStatus(for: task)
                        })
                    } else {
                        self.initializeUplaod(for: task)
                    }
                    
                case .processing: //check again after retry delay
                    self.uploadQueue.asyncAfter(deadline: (DispatchTime.now() + Double(statusResponse.igpRecheckDelayMs)/1000.0), execute: {
                        self.checkStatus(for: task)
                    })
                    break
                case .processed:
                    if let fakeCacheId = task.file.cacheID, let token = task.file.token {
                        IGFile.updateFileToken(cacheId: fakeCacheId, token: token)
                    }
                    
                    task.status = .finished
                    self.removeFromQueueAndStartNext(task: task)
                    DispatchQueue.main.async {
                        if let completeClosure = task.successCallBack {
                            completeClosure(task)
                        }
                    }
                    break
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
        }).send()
    }
    
    func uploadStatusDidChange(task: IGUploadTask, status: UploadDownloadStatus) {
        switch status {
        case .failed:
            IGMessageSender.defaultSender.faileFileMessage(uploadTask: task)
            task.status = .failed
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let failureClosure = task.failureCallBack {
                    failureClosure()
                }
            }
            return
        
        case .finished:
//            if let fakeCacheId = task.file.cacheID, let token = task.token {
//                IGFile.updateFileToken(cacheId: fakeCacheId, token: token)
//            }
            task.status = .finished
            self.removeFromQueueAndStartNext(task: task)
            DispatchQueue.main.async {
                if let completeClosure = task.successCallBack {
                    completeClosure(task)
                }
            }
            return
        default:
            break
        }
    }
    
}


class IGUploadTask: NSObject{
    
    var status = UploadDownloadStatus.waiting
    var file:IGFile
    var progress: Double = 0
    var initialBytesLimit : Int32?
    var finalBytesLimit : Int32?
    var fileExtension = String()
    
    var startCallBack   : UploadStartCallback
    var progressCallBack: UploadProgressCallback
    var successCallBack : UploadCompleteCallback
    var failureCallBack : UploadFailedCallback
    fileprivate init(file:IGFile,  start: UploadStartCallback, progress:UploadProgressCallback, completion:UploadCompleteCallback, failure:UploadFailedCallback) {
        self.file = file.detach()
        self.startCallBack    = start
        self.progressCallBack = progress
        self.successCallBack  = completion
        self.failureCallBack  = failure
        super.init()
    }
}

func == (lhs: IGUploadTask, rhs: IGUploadTask) -> Bool {
    if (lhs.file == rhs.file) {
        return true
    }
    return false
}
