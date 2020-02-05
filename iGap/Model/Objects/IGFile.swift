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
import Files

public class IGFile: Object {
    
    //@objc dynamic var id: Int64 = -1; Note: add 'id' if need at the future
    @objc dynamic var cacheID:            String?
    @objc dynamic var token:              String?
    @objc dynamic var publicUrl:          String?
    @objc dynamic var name:               String?
    @objc dynamic var mime:               String?
    @objc dynamic var localSavePath:      String? /** save file path without base directory. don't save absolute path, because application directory after each run will be changed **/
    @objc dynamic var smallThumbnail:     IGFile?
    @objc dynamic var largeThumbnail:     IGFile?
    @objc dynamic var waveformThumbnail:  IGFile?
    @objc dynamic var size:               Int64                     = -1
    @objc dynamic var width:              Double                    = 0.0
    @objc dynamic var height:             Double                    = 0.0
    @objc dynamic var duration:           Double                    = 0.0
    @objc dynamic var typeRaw:            FileType.RawValue         = FileType.file.rawValue
    @objc dynamic var baseFilePathTypeRaw:BaseFilePathType.RawValue = BaseFilePathType.document.rawValue // use this variable at detect base file directory for fetch 'localPath'
    
    var data:                  Data?
    var status:                Status                              = .unknown
    var downloadUploadPercent: Double                              = 0.0
    
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
        return ["previewType", "type", "data", "status", "downloadUploadPercent", "fileTypeBasedOnNameExtention"]
    }
    
    /** make default file info **/
    static func makeFileInfo(name: String, size: Int64, type: FileType, width: Double = 0, height: Double = 0, duration: Double = 0, filePathType: FilePathType? = nil) -> IGFile {
        let attachment = IGFile()
        attachment.name = name
        attachment.cacheID = IGGlobal.randomString(length: 64)
        attachment.size = size
        attachment.type = type
        attachment.width = width
        attachment.height = height
        attachment.duration = duration
        attachment.localSavePath = attachment.makeLocalPath(filePathType ?? attachment.convertToFilePathType())
        return attachment
    }
    
    /**
    make file realm info
    - Parameter igpFile: server object for file info
    - Parameter fileType: type of file that converted to the client file type
    - Parameter filePathType: make localPath according to 'filePathType' value
    - Parameter unmanagedObjects: ignore fetch file from realm if set value true. Hint: if use "unmanagedObjects" with true value, localPath will be lost
    */
    static func putOrUpdate(igpFile: IGPFile, fileType: FileType, filePathType: FilePathType? = nil, unmanagedObjects: Bool = false) -> IGFile {
        
        var file: IGFile!
        
        if unmanagedObjects {
            file = IGFile()
            if let fileFind = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "token = %@", igpFile.igpToken)).first {
                file.localSavePath = fileFind.localSavePath
            }
        } else {
           file = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "token = %@", igpFile.igpToken)).first
            if file == nil {
                file = IGFile()
            }
        }
        
        file.cacheID = igpFile.igpCacheID
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
        
        if file.localSavePath == nil { /*** when file upload from current user this value is not nil so will be update with new data ****/
            file.localSavePath = file.makeLocalPath(filePathType ?? file.convertToFilePathType())
        }
        
        if igpFile.hasIgpSmallThumbnail {
            file.smallThumbnail = IGFile.putOrUpdateThumbnail(igpThumbnail: igpFile.igpSmallThumbnail, token:file.token, unmanagedObjects: unmanagedObjects)
        }
        if igpFile.hasIgpLargeThumbnail {
            file.largeThumbnail = IGFile.putOrUpdateThumbnail(igpThumbnail: igpFile.igpLargeThumbnail, token:file.token, unmanagedObjects: unmanagedObjects)
        }
        if igpFile.hasIgpWaveformThumbnail {
            file.waveformThumbnail = IGFile.putOrUpdateThumbnail(igpThumbnail: igpFile.igpWaveformThumbnail, token:file.token, unmanagedObjects: unmanagedObjects)
        }
        
        return file
    }
    
    static func putOrUpdateThumbnail(igpThumbnail: IGPThumbnail, token: String?, unmanagedObjects: Bool = false) -> IGFile {
        
        var file: IGFile!
        
        if unmanagedObjects {
            file = IGFile()
        } else {
            file = IGDatabaseManager.shared.realm.objects(IGFile.self).filter(NSPredicate(format: "cacheID = %@", igpThumbnail.igpCacheID)).first
            if file == nil {
                file = IGFile()
            }
        }
        
        file.cacheID = igpThumbnail.igpCacheID
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
    
    static func updateFileToken(cacheId: String, token: String){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            let predicate = NSPredicate(format: "cacheID = %@", cacheId)
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
        let filename = (self.cacheID ?? IGGlobal.randomString(length: 10)) + ("." + (self.name?.getExtension() ?? ""))
        
        switch type {
        case .thumb:
            self.baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.THUMB_DIR + "/" + filename + "jpg"
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
        return self.status == .uploading || self.status == .uploadFailed
    }
    
    internal static func getFileType(messageType: IGRoomMessageType) -> FileType {
        var fileType = FileType.file
        
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
    
    internal static func convertFileTypeToString(fileType: FileType) -> String{
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
