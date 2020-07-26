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
import SwiftProtobuf
import IGProtoBuff
import Digger
import Files
import CryptoSwift
import Alamofire
import AVKit
import AVFoundation

typealias DownloadCompleteHandler = ((_ attachment:IGFile)->())?
typealias DownloadFailedHander    = (()->())?
typealias DownloadLocationImage = ((_ locationPath:String)->())?

class IGDownloadManager {
    
    //MARK: Initilizers
    static let sharedManager = IGDownloadManager()
    static let defaultChunkSizeForDownload:Int32 = 102400 //1048576 // 1024x1024
    
    private var downloadQueue:  DispatchQueue
    private var thumbnailQueue: DispatchQueue
    private var writeFile: DispatchQueue
    
    private var thumbnailTasks = [IGDownloadTask]()
    var taskQueueTokenArray : [String] = []
    var dictionaryDownloadTaskMain : [String:IGDownloadTask] = [:]
    var dictionaryDownloadTaskQueue : [String:IGDownloadTask] = [:]
    var dictionaryPauseTask : [String:IGDownloadTask] = [:]
    let DOWNLOAD_LIMIT = 2
    var streamReq : DataStreamRequest!

    
    init() {
        downloadQueue  = DispatchQueue(label: "im.igap.ios.queue.download.attachments")
        thumbnailQueue = DispatchQueue(label: "im.igap.ios.queue.download.thumbnail")
        writeFile = DispatchQueue(label: "im.igap.ios.queue.download.write")
    }
    

    public func getStreamHeader(startRange: Int64? = 0 ,endRange: Int64) -> HTTPHeaders {
        //            if IGApiBase.httpHeaders == nil {
        guard let token = IGAppManager.sharedManager.getAccessToken() else { return ["Authorization": ""] }
        let authorization = "Bearer " + token
        //            let contentType = "application/json"
        let range =  "bytes=\(startRange ?? 0)-\(endRange)"
        
        IGApiBase.httpHeaders = ["Authorization": authorization,"Range": range]
        //            }
        return IGApiBase.httpHeaders
    }
    public func getHeader() -> HTTPHeaders {
        if IGApiBase.httpHeaders == nil {
            guard let token = IGAppManager.sharedManager.getAccessToken() else { return ["Authorization": ""] }
            let authorization = "Bearer " + token
            //            let contentType = "application/json"
            IGApiBase.httpHeaders = ["Authorization": authorization]
        }
        return IGApiBase.httpHeaders
    }
    
    func isDownloading(token: String) -> Bool {
        return (dictionaryDownloadTaskMain[token] != nil || dictionaryDownloadTaskQueue[token] != nil)
    }
    
    func hasDownload() -> Bool {
        return dictionaryDownloadTaskMain.count > 0
    }
    
    func manageDownloadAfterLogin(autoRetry: Bool = false) {
        
        if autoRetry { //*** Auto Retry Downloads ***//
            
            dictionaryPauseTask.removeAll()
            for downloadTask in dictionaryDownloadTaskMain.values {
                dictionaryDownloadTaskMain.removeValue(forKey: downloadTask.file.token!)
                manageDownloadQueue(downloadTask)
            }
            
        } else { //*** Auto Fail Downloads ***//
            
            for downloadTask in dictionaryDownloadTaskMain.values {
                pauseDownload(attachment: downloadTask.file)
            }
            for downloadTask in dictionaryDownloadTaskQueue.values {
                pauseDownload(attachment: downloadTask.file)
            }
            dictionaryPauseTask.removeAll()
            
        }
    }
    
    func download(file: IGFile, previewType: PreviewType, completion:DownloadCompleteHandler, failure:DownloadFailedHander) {
        
        guard let token = file.token else {
            return
        }
        
        if IGDownloadManager.sharedManager.isDownloading(token: token) {
            IGDownloadManager.sharedManager.pauseDownload(attachment: file)
            return
        }
        
        if !IGAppManager.sharedManager.isUserLoggiedIn() { // if isn't login don't start download
            return
        }
        
        let downloadTask = IGDownloadTask(file: file, previewType:previewType, completion:completion, failure:failure)
        
        switch previewType {
        case .originalFile:
            downloadQueue.async {
                self.manageDownloadQueue(downloadTask)
            }
        case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
            thumbnailQueue.async {
                self.addToThumbnailQueue(downloadTask)
            }
        }
    }
    
    func downloadSticker(file: IGFile, previewType: PreviewType, completion:DownloadCompleteHandler, failure:DownloadFailedHander) {
        
        if !IGAppManager.sharedManager.isUserLoggiedIn() { // if isn't login don't start download
            return
        }
        
        downloadProto(task: IGDownloadTask(file: file, previewType:previewType, completion:completion, failure:failure))
    }
    
    //MARK: Private methods
    private func manageDownloadQueue(_ task: IGDownloadTask) {
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.downloading, for: task.file)
        
        if dictionaryDownloadTaskMain.count >= DOWNLOAD_LIMIT {
            addToWaitingQueue(task)
        } else {
            dictionaryDownloadTaskMain[task.file.token!] = task
            startNextDownloadTaskIfPossible(token: task.file.token)
        }
    }
    
    private func addToWaitingQueue(_ task: IGDownloadTask){
        taskQueueTokenArray.append(task.file.token!)
        dictionaryDownloadTaskQueue[task.file.token!] = task
    }
    
    private func removeFromWaitingQueue(token: String){
        if let index = taskQueueTokenArray.firstIndex(of: token) {
            taskQueueTokenArray.remove(at: index)
            dictionaryDownloadTaskQueue.removeValue(forKey: token)
        }
    }
    
    private func hasWaitingQueue() -> Bool {
        if dictionaryDownloadTaskQueue.count > 0 && taskQueueTokenArray.count == dictionaryDownloadTaskQueue.count {
            return true
        }
        return false
    }
    
    private func addToThumbnailQueue(_ task: IGDownloadTask) {
        //IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        //IGAttachmentManager.sharedManager.setStatus(.downloading, for: task.file)
        //thumbnailTasks.append(task)
        thumbnailTasks.insert(task, at: 0)
        startNextThumbnailTaskIfPossible()
    }
    
    private func startNextDownloadTaskIfPossible(token: String? = nil) {
        
        if IGAppManager.sharedManager.isUserLoggiedIn(){
            
            if dictionaryDownloadTaskMain.count == 0 && dictionaryDownloadTaskQueue.count == 0 {
                return
            }
            
            var firstTaskInQueue : IGDownloadTask!
            if token != nil , let task = dictionaryDownloadTaskMain[token!] {
                firstTaskInQueue = task
            } else if hasWaitingQueue() {
                
                let key : String! = taskQueueTokenArray[0]
                let value : IGDownloadTask! = dictionaryDownloadTaskQueue[key]
                
                firstTaskInQueue = value
                dictionaryDownloadTaskMain[key] = value
                removeFromWaitingQueue(token: key)
            }
            
            if firstTaskInQueue == nil {
                return
            }
            
            
            if firstTaskInQueue.state == .pending {
                
                if IGAppManager.sharedManager.UploadDownloadMethod == .Rest {
                    
                    var shouldResume : Bool = false
                    let nameOfFile : String = "\(firstTaskInQueue.file.token ?? "")\("." + (firstTaskInQueue.file.name?.getExtension() ?? ""))"
                    if (try? IGFilesManager().findFile(forFileNamed: nameOfFile)) != nil {
                        shouldResume = true
                    } //check if file is downloaded once(this if is usefull in conditions where the app was closed after the download was paused
                    
//                    if (IGGlobal.isFileExist(path: firstTaskInQueue.file.localPath, fileSize: firstTaskInQueue.file.size)) {
//                        shouldResume = false
//                    } else {
//                        shouldResume = true
//
//                    }
                    if ((IGGlobal.isFileExist(path: firstTaskInQueue.file.localPath, fileSize: (firstTaskInQueue.file.size)))) {
                        shouldResume = false
                    } else {
                        shouldResume = true
                    }
                    if dictionaryPauseTask[firstTaskInQueue.file.token!] != nil {
                        shouldResume = true
                    }
                    downloadStream(task: firstTaskInQueue,shouldResum: shouldResume)
                } else { //use old methods for download
                    if firstTaskInQueue.file.publicUrl != nil && !(firstTaskInQueue.file.publicUrl?.isEmpty)! {
                           if dictionaryPauseTask[firstTaskInQueue.file.token!] != nil {
                               dictionaryPauseTask.removeValue(forKey: firstTaskInQueue.file.token!)
                               DiggerManager.shared.startTask(for: firstTaskInQueue.file.publicUrl!)
                           } else {
                               downloadCDN(task: firstTaskInQueue)
                           }
                       } else {
                           downloadProto(task: firstTaskInQueue, offset: IGGlobal.getFileSize(path: firstTaskInQueue.file.localPath))
                       }
                       
                }
            } else if firstTaskInQueue.state == .finished {
                startNextDownloadTaskIfPossible()
            }
        }
    }
    
    private func startNextThumbnailTaskIfPossible() {
        if thumbnailTasks.count > 0 && IGAppManager.sharedManager.isUserLoggiedIn(){
            let firstTaskInQueue = thumbnailTasks[0]
            if firstTaskInQueue.state == .pending {
                
                
                if firstTaskInQueue.file.publicUrl != nil && !(firstTaskInQueue.file.publicUrl?.isEmpty)! {
                    let urlToDownload = firstTaskInQueue.file.publicUrl! + "?selector=\(firstTaskInQueue.type.rawValue)"
                    if dictionaryPauseTask[firstTaskInQueue.file.token!] != nil {
                        dictionaryPauseTask.removeValue(forKey: firstTaskInQueue.file.token!)
                        
//                        let urlToDownload
//                        if firstTaskInQueue.type ==
                        
                        
                        DiggerManager.shared.startTask(for: urlToDownload)
                    } else {
                        downloadCDN(task: firstTaskInQueue, publicURL: urlToDownload)
                    }
                } else {
//                    downloadProto(task: firstTaskInQueue, offset: IGGlobal.getFileSize(path: firstTaskInQueue.file.localPath))
                    downloadProtoThumbnail(task: firstTaskInQueue)
                }
                
                
                
            } else if firstTaskInQueue.state == .finished {
                thumbnailTasks.remove(at: 0)
                startNextThumbnailTaskIfPossible()
            }
        }
    }
    
    func downloadLocation(latitude: Double, longitude: Double, locationObserver: DownloadLocationImage) {
        let locationSize = LocationCell.sizeForLocation()
        let url = "http://maps.google.com/maps/api/staticmap?markers=\(latitude),\(longitude)&zoom=15&size=\(Float(locationSize.width).cleanDecimal)x\(Float(locationSize.height).cleanDecimal)&sensor=true"
        let catPictureURL = URL(string: "\(url).png")!
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: catPictureURL) { (data, response, error) in
            if let e = error {
                print("Error downloading cat picture: \(e)")
            } else {
                if let _ = response as? HTTPURLResponse {
                    if let imageData = data {
                        let fileManager = FileManager.default
                        let content = imageData
                        let locationPath : String! = LocationCell.locationPath(latitude: latitude, longitude: longitude)?.path
                        fileManager.createFile(atPath: locationPath, contents: content, attributes: nil)
                        locationObserver!((LocationCell.locationPath(latitude: latitude, longitude: longitude)?.path)!)
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        downloadPicTask.resume()
    }
    
    private func downloadStream(task downloadTask:IGDownloadTask,shouldResum : Bool = false) {
        if let token = downloadTask.file.token {

            let fileEndRange = downloadTask.file.size
            let url = "https://api.igap.net/file-test/v1.0/download/\(token)"
                
            var firstChunk : Bool = false
            var decipher : (Cryptor & Updatable)?
            let nameOfFile = "\(downloadTask.file.token ?? "")\(downloadTask.file.name ?? "")"
//                let nameOfFile = String("\((downloadTask.file.localSavePath) ?? "")".dropFirst())
            var startRangeOfFile : Int64 = 0
            
                if shouldResum {
                    let currentSize = try? IGFilesManager().findFile(forFileNamed: nameOfFile)
                    let tmpDataSize = ((currentSize?.keys.first!.count))
                    startRangeOfFile = Int64(tmpDataSize ?? 0)
//                    IGFilesManager().findAndRemove(token: downloadTask.file.localSavePath ?? "")
//                    IGFilesManager().findAndRemove(token: downloadTask.file.token ?? "")

                } else {
                    IGFilesManager().findAndRemove(token: downloadTask.file.token ?? "")
                }
                streamReq = AF.streamRequest(url,method: .get,headers: self.getStreamHeader(startRange: startRangeOfFile ,endRange: fileEndRange))
                streamReq.responseStream { stream in
                    switch stream.event {
                    case let .stream(result):
                        switch result {
                        case let .success(data):

                            
                            if !firstChunk {
                                firstChunk = true
                                let keyIV = IGSecurityManager.sharedManager.getIVAndKey(encryptedData: data)
                                decipher = try? AES(key: String(decoding: (keyIV["key"]!), as: UTF8.self), iv: (String(decoding: (keyIV["iv"]!), as: UTF8.self)), padding: .pkcs7).makeDecryptor()
                                
                                let dcvar = try? decipher?.update(withBytes: [UInt8](keyIV["firstchunk"]!))
                                let dataa = NSData(bytes: dcvar, length: dcvar!.count)

                                
                                try? IGFilesManager().save(fileNamed: nameOfFile, data: dataa as Data)
                                
                                
                            } else {
                                let dcvar = try? decipher?.update(withBytes: [UInt8](data))
                                let dataa = NSData(bytes: dcvar, length: dcvar!.count)

                                
                                try? IGFilesManager().save(fileNamed: nameOfFile, data: dataa as Data)
                            }
                            IGAttachmentManager.sharedManager.setStatus(.downloading, for: downloadTask.file)
                            
                            do {
                                let currentFile = try IGFilesManager().findFile(forFileNamed: nameOfFile)
                                let alreadyDownloadBytes = currentFile?.keys.first?.count
                                
                                IGAttachmentManager.sharedManager.setProgress(Double(alreadyDownloadBytes ?? 0) / Double(fileEndRange), for: downloadTask.file)
                                
                            } catch {
                                return
                            }
                            
                        case let .failure(error) :
                            print(error)
                            
                        }
                    case let .complete(completion):
                        if completion.response != nil {
                            let dcvar = try? decipher?.finish()
                            let dataa = NSData(bytes: try? decipher?.finish(), length: dcvar!.count)

                            do {
                                try? IGFilesManager().save(fileNamed: nameOfFile, data: dataa as Data)

                                IGFilesManager().fileManager.createFile(atPath: (downloadTask.file.localPath)!, contents: try? IGFilesManager().findFile(forFileNamed: nameOfFile)?.keys.first, attributes: nil)
                                IGFilesManager().findAndRemove(token: downloadTask.file.token ?? "")

                                IGAttachmentManager.sharedManager.setProgress(1, for: downloadTask.file)
                                IGAttachmentManager.sharedManager.setStatus(.ready, for: downloadTask.file)

                                
                                if let task = self.dictionaryDownloadTaskMain[downloadTask.file.token!] {
                                    self.dictionaryDownloadTaskMain.removeValue(forKey: task.file.token!)
                                }
                                
                                downloadTask.state = .finished
                                if let success = downloadTask.completionHandler {
                                    success(downloadTask.file)
                                }
                                
                                self.startNextDownloadTaskIfPossible()
                                
                            }
                            
                        }
                    }
                }
        }
    }
    private func downloadCDN(task downloadTask:IGDownloadTask, publicURL: String? = nil) {
        var url = downloadTask.file.publicUrl
        if publicURL != nil {
            url = publicURL!
        }
        
        
        if  url != nil && !(url?.isEmpty)! {
            
            Digger.download(url!).progress({ (progresss) in
                
                IGAttachmentManager.sharedManager.setProgress(progresss.fractionCompleted, for: downloadTask.file)
                
            }).completion { (result) in
                
                
                switch result {
                case .success(let url):
                    
                    do {
                        let fileManager = FileManager.default
                        let content = try Data(contentsOf: url)
                        fileManager.createFile(atPath: (downloadTask.file.localPath)!, contents: content, attributes: nil)
                        
                        IGAttachmentManager.sharedManager.setStatus(.ready, for: downloadTask.file)
                        
                        if let task = self.dictionaryDownloadTaskMain[downloadTask.file.token!] {
                            self.dictionaryDownloadTaskMain.removeValue(forKey: task.file.token!)
                        }
                        
                        downloadTask.state = .finished
                        if let success = downloadTask.completionHandler {
                            success(downloadTask.file)
                        }
                        
                        self.startNextDownloadTaskIfPossible()
                        
                    } catch {
                        print("error manage downloaded file")
                    }
                    
                case .failure(let error):
                    print("error download file : \(error)")
                    DiggerCache.cleanDownloadFiles()
                    
                    switch downloadTask.type {
                    case .originalFile:
                        self.startNextDownloadTaskIfPossible()
                    case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                        self.startNextThumbnailTaskIfPossible()
                    }
                }
            }
        }
    }
    
    public func downloadImage(url: URL, completion: @escaping ((_ data :Data) -> Void)) {
        
        Digger.download(url).completion { (result) in
            switch result {
            case .success(let url):
                do {
                    let fileManager = FileManager.default
                    let content = try Data(contentsOf: url)
                    if let path = IGGlobal.makePath(filename: url.lastPathComponent) {
                        fileManager.createFile(atPath: path.path, contents: content, attributes: nil)
                    }
                    completion(content)
                } catch let error {
                    print("error downloadImage : \(error)")
                }
                break
                
            case .failure(let error):
                print("error downloadImage : \(error)")
                break
            }
        }
    }
    
    private func downloadProto(task downloadTask:IGDownloadTask, offset: Int64 = 0) {
        
        downloadTask.state = .downloading
        
        let downloadRequest = IGFileDownloadRequest.Generator.generate(token: downloadTask.file.token!, offset: offset, maxChunkSize: IGDownloadManager.defaultChunkSizeForDownload, type: downloadTask.type, downloadTask: downloadTask)
        downloadRequest.successPowerful { (responseProto, requestWrapper) in

            if let fileDownloadReponse = responseProto as? IGPFileDownloadResponse {
                
                var nextOffsetDownload : Int64 = 0
                if let fileDownloadRequest = requestWrapper.message as? IGPFileDownload {
                    let previousOffset = fileDownloadRequest.igpOffset
                    nextOffsetDownload = previousOffset + Int64(fileDownloadReponse.igpBytes.count)
                }
                
                self.writeFile.async {
                    IGAttachmentManager.sharedManager.appendDataToDisk(attachment: downloadTask.file, data: fileDownloadReponse.igpBytes)
                    
                    if nextOffsetDownload != downloadTask.file.size { // downloading
                        
                        let progress = self.fetchProgress(total: Int64(downloadTask.file.size), complete: nextOffsetDownload)
                        IGAttachmentManager.sharedManager.setProgress(progress, for: downloadTask.file)
                        IGDownloadManager.sharedManager.downloadProto(task: downloadTask, offset: nextOffsetDownload)
                        
                    } else { // finished download
                        
                        IGAttachmentManager.sharedManager.setProgress(1.0, for: downloadTask.file)
                        
                        if let task = self.dictionaryDownloadTaskMain[downloadTask.file.token!] {
                            self.dictionaryDownloadTaskMain.removeValue(forKey: task.file.token!)
                        }
                        
                        downloadTask.state = .finished
                        if let success = downloadTask.completionHandler {
                            success(downloadTask.file)
                        }
                        switch downloadTask.type {
                        case .originalFile:
                            self.startNextDownloadTaskIfPossible()
                        case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                            self.startNextThumbnailTaskIfPossible()
                        }
                    }
                }
            }}.error({ (errorCode, waitTime) in
                IGAttachmentManager.sharedManager.setProgress(0.0, for: downloadTask.file)
                IGAttachmentManager.sharedManager.setStatus(.readyToDownload, for: downloadTask.file)
                switch downloadTask.type {
                case .originalFile:
                    self.startNextDownloadTaskIfPossible()
                case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                    self.startNextThumbnailTaskIfPossible()
                }
            }).send()
    }
    
    private func downloadProtoThumbnail(task downloadTask:IGDownloadTask) {
        
        downloadTask.state = .downloading
        
        IGFileDownloadRequest.Generator.generate(token: downloadTask.file.token!, offset: Int64(downloadTask.file.data?.count ?? 0), maxChunkSize: IGDownloadManager.defaultChunkSizeForDownload,type: downloadTask.type, downloadTask: downloadTask).successPowerful { (responseProto, requestWrapper) in
            DispatchQueue.main.async {
                if let fileDownloadReponse = responseProto as? IGPFileDownloadResponse, let downloadTaskMain = requestWrapper.identity as? IGDownloadTask {
                    let data = IGFileDownloadRequest.Handler.interpret(response: fileDownloadReponse)
                    downloadTaskMain.file.data!.append(data)
                    
                    if Int64(downloadTaskMain.file.data!.count) != downloadTaskMain.file.size {
                        IGDownloadManager.sharedManager.downloadProtoThumbnail(task: downloadTaskMain)
                        
                    } else { /*** finished download ***/
                        if let _ = IGAttachmentManager.sharedManager.saveDataToDisk(attachment: downloadTaskMain.file) {
                            IGAttachmentManager.sharedManager.setStatus(.ready, for: downloadTaskMain.file)
                            downloadTaskMain.state = .finished
                            if let success = downloadTaskMain.completionHandler {
                                success(downloadTaskMain.file)
                            }
                            switch downloadTaskMain.type {
                            case .originalFile:
                                self.startNextDownloadTaskIfPossible()
                            case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                                self.startNextThumbnailTaskIfPossible()
                            }
                        }
                    }
                }
            }
        }.errorPowerful({ (errorCode, waitTime, requestWrapper) in
            if let downloadTaskMain = requestWrapper.identity as? IGDownloadTask {
                IGAttachmentManager.sharedManager.setProgress(0.0, for: downloadTaskMain.file)
                IGAttachmentManager.sharedManager.setStatus(.readyToDownload, for: downloadTaskMain.file)
                switch downloadTaskMain.type {
                case .originalFile:
                    self.startNextDownloadTaskIfPossible()
                case .smallThumbnail, .largeThumbnail, .waveformThumbnail:
                    self.startNextThumbnailTaskIfPossible()
                }
            }
        }).send()
    }
    
    private func fetchProgress(total: Int64, complete: Int64) -> Double{
        let progress = Progress()
        progress.totalUnitCount = total
        progress.completedUnitCount = complete
        return progress.fractionCompleted
    }
    
    func pauseAllDownloads(removePauseListCDN: Bool = false) {
        for downloadTask in dictionaryDownloadTaskMain.values {
            pauseDownload(attachment: downloadTask.file)
        }
        for downloadTask in dictionaryDownloadTaskQueue.values {
            pauseDownload(attachment: downloadTask.file)
        }
        
        /* if internet connection lost remove CDN from pauseDownload list (Because now we have to start download NOT start task)
         * BUT
         * if just socket connection losted don't remove pauseDownload list (Because now we have to start task NOT start download)
         */
        if removePauseListCDN {
            dictionaryPauseTask.removeAll()
        }
    }
    
    func pauseDownload(attachment: IGFile) {
        
        if attachment.token == nil {
            return
        }
        
        var task : IGDownloadTask! = dictionaryDownloadTaskMain[attachment.token!]
        if task != nil {
            
            if IGAppManager.sharedManager.UploadDownloadMethod == .Rest {
                if streamReq != nil {
                    streamReq.suspend()
                    dictionaryPauseTask[attachment.token!] = task // go to pause dictionary
                }
            } else {
                if attachment.publicUrl != nil && !(attachment.publicUrl?.isEmpty)! { // CDN Pause Need
                    
                    DiggerManager.shared.stopTask(for: task.file.publicUrl!)
                    dictionaryPauseTask[attachment.token!] = task // go to pause dictionary
                    
                } else { // Proto Pause Need
                    IGRequestManager.sharedManager.cancelRequest(identity: attachment.token!)
                }
                
            }

            dictionaryDownloadTaskMain.removeValue(forKey: attachment.token!) // remove from main download queue
            
            startNextDownloadTaskIfPossible()
            
        } else {
            task = dictionaryDownloadTaskQueue[attachment.token!]
            if task == nil {
                return
            }
            
            removeFromWaitingQueue(token: attachment.token!)
        }
        
        IGAttachmentManager.sharedManager.setProgress(0.0, for: task.file)
        IGAttachmentManager.sharedManager.setStatus(.readyToDownload, for: task.file)
    }
}


//MARK: - IGDownloadTask
class IGDownloadTask {
    enum State {
        case pending
        case downloading
        case finished
    }
    
    var file: IGFile
    var progress: Double = 0.0
    var completionHandler: DownloadCompleteHandler
    var failureHandler: DownloadFailedHander
    var type: PreviewType
    var state = State.pending
    
    init(file: IGFile, previewType: PreviewType, completion: DownloadCompleteHandler, failure: DownloadFailedHander) {
        self.file = file.detach()
        self.file.data = Data()
        self.completionHandler = completion
        self.failureHandler = failure
        self.type = previewType
    }
}



