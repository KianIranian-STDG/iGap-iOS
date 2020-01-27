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
import CryptoSwift
import UIKit
import IGProtoBuff
import Files

public class IGFile: Object {
    enum Status {
        case unknown
        
        case readyToDownload // also for 'downloadFailed' & 'downloadPause' use 'readyToDownload' enum
        case downloading
        
        case uploadFailed
        case uploading
        
        case ready
    }
    
    enum PlayingStatus {
        case notAvaiable
        case readyToPlay
        case playing
        case paused
    }
    
    enum PreviewType: Int {
        case originalFile = 0
        case smallThumbnail
        case largeThumbnail
        case waveformThumbnail
    }
    
    public enum FileType: Int {
        case image = 0
        case gif
        case video
        case audio
        case voice
        case file
        case sticker
        
        static func convertToFileType(messageType: IGRoomMessageType) -> IGFile.FileType {
            switch messageType {
            case .audio, .audioAndText:
                return .audio
                
            case .image, .imageAndText:
                return .image
                
            case .video, .videoAndText:
                return .video
                
            case .voice:
                return .voice
                
            case .gif, .gifAndText:
                return .gif
                
            case .file, .fileAndText:
                return .file
                
            case .sticker:
                return .sticker
                
            default:
                return .image
            }
        }
    }
    
    enum FileTypeBasedOnNameExtension {
        case generic
        case docx
        case exe
        case pdf
        case txt
    }
    
    
    //properties
    @objc dynamic var primaryKeyId:       String?  ///TODO - use from id instead primaryKey (messagId) //if incomming { primaryKeyId = cacheId } else { primaryKeyId = rand}
    @objc dynamic var cacheID:            String?
    @objc dynamic var token:              String?
    @objc dynamic var publicUrl:          String?
    @objc dynamic var fileNameOnDisk:     String?
    @objc dynamic var name:               String?
    @objc dynamic var mime:               String?
    @objc dynamic var localSavePath:      String? // save file path without base directory. don't save absolute path, because application directory after each run will be changed
    @objc dynamic var smallThumbnail:     IGFile?
    @objc dynamic var largeThumbnail:     IGFile?
    @objc dynamic var waveformThumbnail:  IGFile?
    @objc dynamic var size:               Int64                     = -1
    @objc dynamic var width:              Double                    = 0.0
    @objc dynamic var height:             Double                    = 0.0
    @objc dynamic var duration:           Double                    = 0.0
    @objc dynamic var typeRaw:            FileType.RawValue         = FileType.file.rawValue
    @objc dynamic var baseFilePathTypeRaw:BaseFilePathType.RawValue = BaseFilePathType.document.rawValue // use this variable at detect base file directory for fetch 'localPath'
    
    ///TODO - check and remove following files
    var data:           Data?
    var status:         Status                              = .unknown
    var downloadUploadPercent: Double                       = 0.0
    
    var localPath: String? {
        get {
            if let path = self.localSavePath, !path.isEmpty {
                if baseFilePathTypeRaw == BaseFilePathType.document.rawValue {
                    return IGGlobal.APP_DIR + path
                } else if baseFilePathTypeRaw == BaseFilePathType.cache.rawValue {
                    return IGGlobal.CACHE_DIR + path
                } else if baseFilePathTypeRaw == BaseFilePathType.temp.rawValue {
                    return IGGlobal.TEMP_DIR + path
                }
            }
            return nil
        }
    }
    
    var localUrl: URL? {
        get {
            if let path = self.localPath, !path.isEmpty {
                return NSURL(fileURLWithPath: path) as URL?
            }
            return nil
        }
    }
    
    
    var fileTypeBasedOnNameExtension: FileTypeBasedOnNameExtension {
        get {
            if let name = self.name {
                let fileExtension = (name as NSString).lastPathComponent
                switch fileExtension {
                case "docx":
                    return .docx
                case "exe":
                    return .exe
                case "pdf":
                    return .pdf
                case "txt":
                    return .txt
                default:
                    return .generic
                }
            }
            return .generic
        }
    }
    
    var type: FileType {
        get {
            if let a = FileType(rawValue: typeRaw) {
                return a
            }
            return .file
        }
        set {
            typeRaw = newValue.rawValue
        }
    }

    override public static func indexedProperties() -> [String] {
        return ["cacheID"]
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["previewType", "type", "attachedImage", "data", "sha256Hash", "status", "playingStatus", "downloadUploadPercent", "fileTypeBasedOnNameExtention"]
    }
    
    convenience init(name: String?) {
        self.init()
        self.name = name
        self.cacheID = IGGlobal.randomString(length: 64)
    }
    
    convenience init(path: URL) {
        self.init()
        self.fileNameOnDisk = path.lastPathComponent
        self.name = path.lastPathComponent
        self.cacheID = IGGlobal.randomString(length: 64)
    }
    
    ///TODO - remove usage of this files
    convenience init(igpFile : IGPFile, type: IGFile.FileType) {
        self.init()
        self.token = igpFile.igpToken
        self.publicUrl = igpFile.igpPublicURL
        self.name = igpFile.igpName
        self.size = igpFile.igpSize
        self.cacheID = igpFile.igpCacheID
        self.type = type
        self.mime = igpFile.igpMime
        self.width = Double(igpFile.igpWidth)
        self.height = Double(igpFile.igpHeight)
        self.duration = igpFile.igpDuration
        
        if igpFile.hasIgpSmallThumbnail {
            let predicate = NSPredicate(format: "cacheID = %@", igpFile.igpSmallThumbnail.igpCacheID)
            let realm = try! Realm()
            if let fileInDb = realm.objects(IGFile.self).filter(predicate).first {
                self.smallThumbnail = fileInDb
            } else {
                self.smallThumbnail = IGFile(igpThumbnail: igpFile.igpSmallThumbnail, token:self.token)
            }
        }
        if igpFile.hasIgpLargeThumbnail {
            let predicate = NSPredicate(format: "cacheID = %@", igpFile.igpLargeThumbnail.igpCacheID)
            let realm = try! Realm()
            if let fileInDb = realm.objects(IGFile.self).filter(predicate).first {
                self.largeThumbnail = fileInDb
            } else {
                self.largeThumbnail = IGFile(igpThumbnail: igpFile.igpLargeThumbnail, token:self.token)
            }
        }
        if igpFile.hasIgpWaveformThumbnail {
            self.waveformThumbnail = IGFile(igpThumbnail: igpFile.igpWaveformThumbnail, token:self.token)
        }
    }
    
    convenience init(igpFile : IGPFile, messageType: IGRoomMessageType) {
        var fileType = IGFile.FileType.file
        
        switch messageType {
        case .audio, .audioAndText:
            fileType = .audio
            break
            
        case .image, .imageAndText:
            fileType = .image
            break
            
        case .video, .videoAndText:
            fileType = .video
            break
            
        case .voice:
            fileType = .voice
            break
            
        case .gif, .gifAndText:
            fileType = .gif
            break
            
        case .file, .fileAndText:
            fileType = .file
            break
            
        case .sticker:
            fileType = .sticker
            break
            
        default:
            break
        }
        
        self.init(igpFile : igpFile, type: fileType)
    }
    
    convenience private init(igpThumbnail: IGPThumbnail, token: String?) {
        self.init()
        self.token = token
        self.size = igpThumbnail.igpSize
        self.width = Double(igpThumbnail.igpWidth)
        self.height = Double(igpThumbnail.igpHeight)
        self.type = .image
        self.cacheID = igpThumbnail.igpCacheID
        self.name = cacheID
    }
    
    /**
    make file realm info
    - Parameter igpFile: server object for file info
    - Parameter fileType: type of file that converted to the client file type
    - Parameter filePathType: make localPath according to 'filePathType' value
    */
    static func putOrUpdate(igpFile:IGPFile, fileType:IGFile.FileType, filePathType: FilePathType? = nil) -> IGFile {
        
        let predicate = NSPredicate(format: "token = %@", igpFile.igpToken)
        var file: IGFile! = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(predicate).first
        
        if file == nil {
            file = IGFile()
            file.cacheID = igpFile.igpCacheID
            if file.fileNameOnDisk == nil {
                file.downloadUploadPercent = 0.0
                file.status = .readyToDownload
            } else if !(file.isInUploadLevels()){
                file.downloadUploadPercent = 1.0
                file.status = .ready
            }
        }
        
        file.type = fileType
        file.token = igpFile.igpToken
        file.publicUrl = igpFile.igpPublicURL
        file.name = igpFile.igpName
        file.mime = igpFile.igpMime
        file.size = igpFile.igpSize
        file.cacheID = igpFile.igpCacheID
        file.width = Double(igpFile.igpWidth)
        file.height = Double(igpFile.igpHeight)
        file.duration = igpFile.igpDuration
        let path = file.makeLocalPath(filePathType ?? file.convertToFilePathType())
        file.localSavePath = path
        
        if igpFile.hasIgpSmallThumbnail {
            file.smallThumbnail = IGFile.putOrUpdateThumbnail(igpThumbnail: igpFile.igpSmallThumbnail, token:file.token)
        }
        if igpFile.hasIgpLargeThumbnail {
            file.largeThumbnail = IGFile.putOrUpdateThumbnail(igpThumbnail: igpFile.igpLargeThumbnail, token:file.token)
        }
        if igpFile.hasIgpWaveformThumbnail {
            file.waveformThumbnail = IGFile.putOrUpdateThumbnail(igpThumbnail: igpFile.igpWaveformThumbnail, token:file.token)
        }
        
        return file
    }
    
    static func putOrUpdateThumbnail(igpThumbnail: IGPThumbnail, token: String?) -> IGFile {
        
        let predicate = NSPredicate(format: "cacheID = %@", igpThumbnail.igpCacheID)
        var file: IGFile! = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(predicate).first
        if file == nil {
            file = IGFile()
            file.cacheID = igpThumbnail.igpCacheID
        }
        
        file.token = token
        file.size = igpThumbnail.igpSize
        file.width = Double(igpThumbnail.igpWidth)
        file.height = Double(igpThumbnail.igpHeight)
        file.type = .image
        file.cacheID = igpThumbnail.igpCacheID
        file.name = igpThumbnail.igpCacheID
        file.mime = igpThumbnail.igpMime
        file.localSavePath = file.makeLocalPath(.thumb)
        
        return file
    }
    
    static func updateFileToken(fileNameOnDisk: String, token: String){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            let predicate = NSPredicate(format: "fileNameOnDisk = %@", fileNameOnDisk)
            if let file = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(predicate).first {
                try! IGDatabaseManager.shared.realm.write {
                    file.token = token
                }
            }
        }
    }
    
    //detach from current realm
    func detach() -> IGFile {
        let detachedFile = IGFile(value: self)
        
        if let smallThumbnail = self.smallThumbnail {
            let detachedThumbnail = smallThumbnail.detach()
            detachedFile.smallThumbnail = detachedThumbnail
        }
        if let largeThumbnail = self.largeThumbnail {
            let detachedThumbnail = largeThumbnail.detach()
            detachedFile.largeThumbnail = detachedThumbnail
        }
        if let waveformThumbnail = self.waveformThumbnail {
            let detachedThumbnail = waveformThumbnail.detach()
            detachedFile.waveformThumbnail = detachedThumbnail
        }
        
        return detachedFile
    }
    
    public func loadData() {
        if let path = self.localPath, !path.isEmpty {
            let nsurl = NSURL(fileURLWithPath: path)
            if let url = nsurl as URL? {
                try? self.data = Data(contentsOf: url)
            }
        }
    }
    
    public func sizeToString() -> String {
        return IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: self.size)
    }
    
    func makeLocalPath(_ type: FilePathType) -> String {
        
        var filePath = ""
        let filename = self.name ?? ""
        
        switch type {
        case .thumb:
            self.baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.THUMB_DIR + "/" + filename + ".jpg"
            break
        case .image:
            self.baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.IMAGE_DIR + "/" + filename
            break
        case .video:
            self.baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.VIDEO_DIR + "/" + filename
            break
        case .gif:
            self.baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.GIF_DIR + "/" + filename
            break
        case .audio:
            self.baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.AUDIO_DIR + "/" + filename
            break
        case .voice:
            self.baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.VOICE_DIR + "/" + filename
            break
        case .file:
            self.baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.FILE_DIR + "/" + filename
            break
        case .avatar:
            self.baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.AVATAR_DIR + "/" + filename
            break
        case .sticker:
            self.baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.STICKER_DIR + "/" + filename
            break
        case .background:
            self.baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.BACKGROUND_DIR + "/" + filename
            break
        case .temp:
            self.baseFilePathTypeRaw = BaseFilePathType.temp.rawValue
            filePath = IGGlobal.TEMP_DIR + "/" + filename
            break
        default:
            self.baseFilePathTypeRaw = BaseFilePathType.temp.rawValue
            filePath = IGGlobal.TEMP_DIR + "/" + filename
            break
        }
        
        return filePath
    }
    
    class func path(fileNameOnDisk: String) -> URL {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return NSURL(fileURLWithPath: documents).appendingPathComponent(fileNameOnDisk)!
    }
    
    public func isInUploadLevels() -> Bool {
        return self.status == .uploading || self.status == .uploading || self.status == .uploadFailed
    }
    
    public static func getFileType(messageType: IGRoomMessageType) -> IGFile.FileType {
        var fileType = IGFile.FileType.file
        
        switch messageType {
        case .audio, .audioAndText:
            fileType = .audio
            break
            
        case .image, .imageAndText:
            fileType = .image
            break
            
        case .video, .videoAndText:
            fileType = .video
            break
            
        case .voice:
            fileType = .voice
            break
            
        case .gif, .gifAndText:
            fileType = .gif
            break
            
        case .file, .fileAndText:
            fileType = .file
            break
            
        case .sticker:
            fileType = .sticker
            break
            
        default:
            break
        }
        return fileType
    }
    
    func convertToFilePathType() -> FilePathType {
        switch self.type {
        case .image:
            return .image
        case .gif:
            return .gif
        case .video:
            return .video
        case .audio:
            return .audio
        case .voice:
            return .voice
        case .file:
            return .file
        case .sticker:
            return .sticker
        }
    }
    
    internal static func convertFileTypeToString(fileType: IGFile.FileType) -> String{
        if fileType == .image {
            return IGStringsManager.ImageMessage.rawValue.localized
        } else if fileType == .video {
            return IGStringsManager.VideoMessage.rawValue.localized
        } else if fileType == .gif {
            return IGStringsManager.GifMessage.rawValue.localized
        } else if fileType == .audio {
            return IGStringsManager.AudioMessage.rawValue.localized
        } else if fileType == .file {
            return IGStringsManager.FileMessage.rawValue.localized
        } else if fileType == .voice {
            return IGStringsManager.VoiceMessage.rawValue.localized
        } else if fileType == .sticker {
            return IGStringsManager.StickerMessage.rawValue.localized
        }
        return ""
    }
}


//func == (lhs: IGFile, rhs: IGFile) -> Bool {
//    if lhs === rhs {
//        return true
//    }
//    if lhs.cacheID == rhs.cacheID {
//        return true
//    }
//    if (lhs.sha256Hash != nil) && (rhs.sha256Hash != nil) && (lhs.sha256Hash == rhs.sha256Hash) {
//        return true
//    }
//    return false
//}


