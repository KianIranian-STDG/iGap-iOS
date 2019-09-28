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
import RealmSwift

class IGHelperGetShareData {

    private static let SUITE_NAME = "group.im.iGap"
    private static let ID = "id"
    private static let TYPE = "type"
    private static let ROOM = "room"
    private static let WEB_DATA = "webData"
    private static let TEXT = "text"
    private static let IMAGE = "image"
    private static let IMAGE_URL = "imageUrl"
    private static let IMAGE_ORIGINAL = "imageOriginal"
    private static let VIDEO = "video"
    private static let VIDEO_DATA = "videoData"
    private static let VIDEO_NAME = "videoName"
    private static let GIF = "gif"
    private static let GIF_DATA = "gifData"
    private static let GIF_NAME = "gifName"
    private static let FILE = "file"
    private static let FILE_DATA = "fileData"
    private static let FILE_NAME = "fileName"
    private static let URL = "url"
    
    private static var userIdArray : [Int64] = []
    private static var addedUserIdArray : [Int64] = []
    
    private static var sendMessageDelay = 0.0
    
    /************************************************************************************************************/
    /********************************************* Get Shared Data **********************************************/
    /************************************************************************************************************/
    
    internal static func manageShareDate(){
        sendMessageDelay = 0.0
        addedUserIdArray = []
        userIdArray = []
        
        if let userDefault = UserDefaults(suiteName: "group.im.iGap") {
            userDefault.addSuite(named: "group.im.iGap")
            
            if let dict = userDefault.value(forKey: TEXT) as? [[String: Any]] { // text
                clearShareData(userDefault: userDefault, key: TEXT)
                
                for info in dict {
                    if let data = info as? NSDictionary {
                        let sharedText = data.value(forKey: TEXT) as! String
                        let type = data.value(forKey: TYPE) as! Int
                        let id = data.value(forKey: ID) as! Int64
                        
                        if type == 4 {
                            chatRoomCreator(userId: id) { (roomId) in
                                sendTextMessage(id: roomId, textMessage: sharedText)
                            }
                        } else {
                            sendTextMessage(id: id, textMessage: sharedText)
                        }
                    }
                }
            }
            
            if let dict = userDefault.value(forKey: WEB_DATA) as? [[String: Any]] { // web data
                clearShareData(userDefault: userDefault, key: WEB_DATA)
                
                for info in dict {
                    if let data = info as? NSDictionary {
                        let sharedText = data.value(forKey: WEB_DATA) as! String
                        let type = data.value(forKey: TYPE) as! Int
                        let id = data.value(forKey: ID) as! Int64
                        if type == 4 {
                            chatRoomCreator(userId: id) { (roomId) in
                                sendTextMessage(id: roomId, textMessage: sharedText)
                            }
                        } else {
                            sendTextMessage(id: id, textMessage: sharedText)
                        }
                    }
                }
            }
            
            if let outData = userDefault.value(forKey: IMAGE) as? Data { // image
                clearShareData(userDefault: userDefault, key: IMAGE)
                
                let dict = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [[String: Any]]
                
                for info in dict! {
                    if let data = info as? NSDictionary {
                        let imageUrl = data.value(forKey: IMAGE_URL) as? URL
                        let originalImage = data.value(forKey: IMAGE_ORIGINAL) as? UIImage
                        
                        if originalImage == nil && imageUrl == nil {
                            break
                        }
                        
                        if originalImage == nil {
                            let imageData = try? Data(contentsOf: imageUrl!)
                            if let image = UIImage(data: imageData!) {
                                let type = data.value(forKey: TYPE) as! Int
                                let id = data.value(forKey: ID) as! Int64
                                
                                if type == 4 {
                                    chatRoomCreator(userId: id) { (roomId) in
                                        sendImageMessage(id: roomId, imageUrl: imageUrl, originalImage: image)
                                    }
                                } else {
                                    sendImageMessage(id: id, imageUrl: imageUrl, originalImage: image)
                                }
                            }
                        } else {
                            let type = data.value(forKey: TYPE) as! Int
                            let id = data.value(forKey: ID) as! Int64
                            if type == 4 {
                                chatRoomCreator(userId: id) { (roomId) in
                                    sendImageMessage(id: roomId, imageUrl: imageUrl, originalImage: originalImage!)
                                }
                            } else {
                                sendImageMessage(id: id, imageUrl: imageUrl, originalImage: originalImage!)
                            }
                        }
                    }
                }
                
            }
            
            if let outData = userDefault.value(forKey: VIDEO) as? Data { // video
                clearShareData(userDefault: userDefault, key: VIDEO)
                
                let dict = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [[String: Any]]
                for info in dict! {
                    if let data = info as? NSDictionary {
                        let videoData = data.value(forKey: VIDEO_DATA) as! Data
                        let videoName = data.value(forKey: VIDEO_NAME) as! String
                        let type = data.value(forKey: TYPE) as! Int
                        let id = data.value(forKey: ID) as! Int64
                        
                        if type == 4 {
                            chatRoomCreator(userId: id) { (roomId) in
                                sendVideoMessage(id: roomId, videoData: videoData, videoName: videoName)
                            }
                        } else {
                            sendVideoMessage(id: id, videoData: videoData, videoName: videoName)
                        }
                    }
                }
            }
            
            if let outData = userDefault.value(forKey: GIF) as? Data { // gif
                clearShareData(userDefault: userDefault, key: GIF)
                
                let dict = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [[String: Any]]
                for info in dict! {
                    if let data = info as? NSDictionary {
                        let gifData = data.value(forKey: GIF_DATA) as! Data
                        let gifName = data.value(forKey: GIF_NAME) as! String
                        let type = data.value(forKey: TYPE) as! Int
                        let id = data.value(forKey: ID) as! Int64
                        
                        if type == 4 {
                            chatRoomCreator(userId: id) { (roomId) in
                                sendGifMessage(id: roomId, gifData: gifData, gifName: gifName)
                            }
                        } else {
                            sendGifMessage(id: id, gifData: gifData, gifName: gifName)
                        }
                    }
                }
            }
            
            if let outData = userDefault.value(forKey: FILE) as? Data { // gif
                clearShareData(userDefault: userDefault, key: FILE)
                
                let dict = NSKeyedUnarchiver.unarchiveObject(with: outData) as? [[String: Any]]
                for info in dict! {
                    if let data = info as? NSDictionary {
                        let fileData = data.value(forKey: FILE_DATA) as! Data
                        let fileName = data.value(forKey: FILE_NAME) as! String
                        let type = data.value(forKey: TYPE) as! Int
                        let id = data.value(forKey: ID) as! Int64
                        
                        if type == 4 {
                            chatRoomCreator(userId: id) { (roomId) in
                                sendFileMessage(id: roomId, fileData: fileData, fileName: fileName)
                            }
                        } else {
                            sendFileMessage(id: id, fileData: fileData, fileName: fileName)
                        }
                    }
                }
            }
        }
    }
    
    private static func clearShareData(userDefault: UserDefaults, key: String){
        userDefault.removeObject(forKey: key)
        userDefault.synchronize()
    }
    
    /************************************************************************************************************/
    /************************************************ Send Text *************************************************/
    /************************************************************************************************************/
    
    internal static func sendTextMessage(id: Int64, textMessage: String) {
        guard let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", id)).first else {
            return
        }
        sendMessageDelay = sendMessageDelay + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + sendMessageDelay) {
            let message = IGRoomMessage(body: textMessage)
            message.type = .text
            message.roomId = id
            let detachedMessage = message.detach()
            IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
            IGMessageSender.defaultSender.send(message: message, to: room)
        }
    }
    
    
    /************************************************************************************************************/
    /******************************************* Manage Shared Image ********************************************/
    /************************************************************************************************************/
    
    internal static func sendImageMessage(id: Int64, imageUrl: URL?, originalImage: UIImage){
        guard let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", id)).first else {
            return
        }
        
        sendFileMessage(room: room, attachment: manageImage(imageUrl: imageUrl, originalImage: originalImage))
    }
    
    private static func manageImage(imageUrl: URL?, originalImage: UIImage) -> IGFile {
        
        var filename : String!
        var fileSize : Int!
        
        if imageUrl != nil {
            filename = imageUrl!.lastPathComponent
            fileSize = Int(IGGlobal.getFileSize(path: imageUrl))
        } else {
            filename = "IMAGE_" + IGGlobal.randomString(length: 16)
            fileSize = NSData(data: (originalImage).jpegData(compressionQuality: 1)!).length
        }
        let randomString = IGGlobal.randomString(length: 16) + "_"
        
        var scaledImage = originalImage
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        let fileNameOnDisk = randomString + filename
        
        if (originalImage.size.width) > CGFloat(2000.0) || (originalImage.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: originalImage)
        }
        
        let attachment = IGFile(name: filename)
        attachment.size = fileSize
        attachment.attachedImage = scaledImage
        attachment.fileNameOnDisk = fileNameOnDisk
        attachment.height = Double((scaledImage.size.height))
        attachment.width = Double((scaledImage.size.width))
        attachment.size = (imgData?.count)!
        attachment.data = imgData
        attachment.type = .image
        
        DispatchQueue.main.async {
            self.saveAttachmentToLocalStorage(data: imgData!, fileNameOnDisk: fileNameOnDisk)
        }
        
        return attachment
    }
    
    private static func saveAttachmentToLocalStorage(data: Data, fileNameOnDisk: String) {
        let path = IGFile.path(fileNameOnDisk: fileNameOnDisk)
        FileManager.default.createFile(atPath: path.path, contents: data, attributes: nil)
    }
    
    /************************************************************************************************************/
    /******************************************** Manage Shared Video *******************************************/
    /************************************************************************************************************/
    
    internal static func sendVideoMessage(id: Int64, videoData: Data, videoName: String){
        guard let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", id)).first else {
            return
        }
        
        sendFileMessage(room: room, attachment: manageVideo(videoData: videoData, filename: videoName))
    }
    
    private static func manageVideo(videoData: Data, filename: String) -> IGFile{
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let randomString = IGGlobal.randomString(length: 16) + "_"
        let pathOnDisk = documents + "/" + randomString + filename
        
        let videoUrl : URL = NSURL(fileURLWithPath: pathOnDisk) as URL
        //let fileSize = Int(IGGlobal.getFileSize(path: videoUrl))
        let fileSize = Int(videoData.count)

        // write data to my fileUrl
        try! videoData.write(to: videoUrl)
        
        /*** get thumbnail from video ***/
        let asset = AVURLAsset(url: videoUrl)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = try! imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)
        
        let attachment = IGFile(name: filename)
        attachment.size = fileSize
        attachment.duration = asset.duration.seconds
        attachment.fileNameOnDisk = randomString + filename
        attachment.name = filename
        attachment.attachedImage = uiImage
        attachment.type = .video
        attachment.height = Double(cgImage.height)
        attachment.width = Double(cgImage.width)
        
        let randomStringFinal = IGGlobal.randomString(length: 16) + "_"
        let pathOnDiskFinal = documents + "/" + randomStringFinal + filename
        try! FileManager.default.copyItem(atPath: videoUrl.path, toPath: pathOnDiskFinal)
        
        return attachment
    }
    
    /************************************************************************************************************/
    /******************************************** Manage Shared Gif *******************************************/
    /************************************************************************************************************/
    
    internal static func sendGifMessage(id: Int64, gifData: Data, gifName: String){
        guard let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", id)).first else {
            return
        }
        
        sendFileMessage(room: room, attachment: manageGif(gifData: gifData, filename: gifName))
    }
    
    private static func manageGif(gifData: Data, filename: String) -> IGFile {
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let randomString = IGGlobal.randomString(length: 16) + "_"
        let pathOnDisk = documents + "/" + randomString + filename
        
        let gifUrl : URL = NSURL(fileURLWithPath: pathOnDisk) as URL
        let fileSize = Int(gifData.count)
        
        // write data to my fileUrl
        try! gifData.write(to: gifUrl)
        
        let uiImage = UIImage.gifImageWithURL(gifUrl.absoluteString)
        
        let attachment = IGFile(name: filename)
        attachment.size = fileSize
        attachment.fileNameOnDisk = randomString + filename
        attachment.name = filename
        attachment.attachedImage = uiImage
        attachment.type = .gif
        attachment.height = Double((uiImage?.size.height)!)
        attachment.width = Double((uiImage?.size.width)!)
        
        let randomStringFinal = IGGlobal.randomString(length: 16) + "_"
        let pathOnDiskFinal = documents + "/" + randomStringFinal + filename
        try! FileManager.default.copyItem(atPath: gifUrl.path, toPath: pathOnDiskFinal)
        
        return attachment
    }
    
    /************************************************************************************************************/
    /******************************************** Manage Shared File *******************************************/
    /************************************************************************************************************/
    
    internal static func sendFileMessage(id: Int64, fileData: Data, fileName: String){
        guard let room = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", id)).first else {
            return
        }
        
        sendFileMessage(room: room, attachment: manageFile(fileData: fileData, filename: fileName))
    }
    
    private static func manageFile(fileData: Data, filename: String) -> IGFile {
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let randomString = IGGlobal.randomString(length: 16) + "_"
        let pathOnDisk = documents + "/" + randomString + filename
        
        let fileUrl : URL = NSURL(fileURLWithPath: pathOnDisk) as URL
        let fileSize = Int(fileData.count)
        
        // write data to my fileUrl
        try! fileData.write(to: fileUrl)
        
        let attachment = IGFile(name: filename)
        attachment.size = fileSize
        attachment.fileNameOnDisk = randomString + filename
        attachment.name = filename
        attachment.type = .file
        
        let randomStringFinal = IGGlobal.randomString(length: 16) + "_"
        let pathOnDiskFinal = documents + "/" + randomStringFinal + filename
        try! FileManager.default.copyItem(atPath: fileUrl.path, toPath: pathOnDiskFinal)
        
        return attachment
    }
    
    
    /************************************************************************************************************/
    /********************************************* Send File Message ********************************************/
    /************************************************************************************************************/
    
    private static func sendFileMessage(room: IGRoom, attachment: IGFile){
        sendMessageDelay = sendMessageDelay + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + sendMessageDelay) {
            let messageText = ""
            let message = IGRoomMessage(body: messageText)
            attachment.status = .uploading
            message.attachment = attachment
            IGAttachmentManager.sharedManager.add(attachment: attachment)
            switch attachment.type {
            case .image:
                if messageText == "" {
                    message.type = .image
                } else {
                    message.type = .imageAndText
                }
                break
                
            case .gif:
                message.type = .gif
                break
                
            case .video:
                if messageText == "" {
                    message.type = .video
                } else {
                    message.type = .videoAndText
                }
                break
                
            case .audio:
                if messageText == "" {
                    message.type = .audio
                } else {
                    message.type = .audioAndText
                }
                break
                
            case .voice:
                message.type = .voice
                break
                
            case .file:
                if messageText == "" {
                    message.type = .file
                } else {
                    message.type = .fileAndText
                }
                break
                
            case .sticker:
                message.type = .sticker
                break
            }
            
            message.roomId = room.id
            let detachedMessage = message.detach()
            IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
            IGMessageSender.defaultSender.send(message: message, to: room)
        }
    }
    
    /************************************************************************************************************/
    /******************************************** Set Realm Share Info ******************************************/
    /************************************************************************************************************/
    
    internal static func clearShareInfo(){
        do {
            let realm = try Realm()

            try realm.write {
                realm.delete(realm.objects(IGShareInfo.self))
            }
        } catch {
            print("REALM ERROR HAPPENDED: ", error)
        }
     
        
    }
    
    
    internal static func setRealmShareInfo(igpRoom: IGPRoom, igRoom: IGRoom) -> IGShareInfo? {
        
        /* if room is readOnly don't set data to IGShareInfo, because in this state user can't set message to room */
        if igpRoom.igpReadOnly {
            return nil
        }
        
        var imageData : Data?
        var id : Int64!
        if igpRoom.igpType == .chat {
            
            if let user = igRoom.chatRoom?.peer {
                id = user.id
                if let attachment = user.avatar?.file?.largeThumbnail {
                    if let path : URL = attachment.path() {
                        imageData = try? Data(contentsOf: path)
                    }
                }
            }
            
        } else if igpRoom.igpType == .group {
            
            if let group = igRoom.groupRoom {
                id = group.id
                if let path = igRoom.groupRoom?.avatar?.file?.largeThumbnail?.path() {
                    imageData = try? Data(contentsOf: path)
                }
            }
            
        } else if igpRoom.igpType == .channel {
            
            if let channel = igRoom.channelRoom {
                id = channel.id
                if let attachment = igRoom.channelRoom?.avatar?.file?.largeThumbnail {
                    if let path : URL = attachment.path() {
                        imageData = try? Data(contentsOf: path)
                    }
                }
            }
            
        }
        
        return IGShareInfo(igpRoom: igpRoom, id: id, imageData: imageData)
    }
    
    internal static func setRealmShareInfo(igpUser: IGPRegisteredUser, igUser: IGRegisteredUser) -> IGShareInfo {
        
        var imageData : Data?
        if let path = igUser.avatar?.file?.largeThumbnail?.path() {
            imageData = try? Data(contentsOf: path)
        }
        
        return IGShareInfo(igpUser: igpUser, imageData: imageData)
    }
    
    /************************************************************************************************************/
    /************************************************ Chat Creator **********************************************/
    /************************************************************************************************************/
    
    internal static func chatRoomCreator(userId: Int64, completion: @escaping (Int64)->()){
        if !addedUserIdArray.contains(userId) {
            addedUserIdArray.append(userId)
            userIdArray.append(userId)
        }
        IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                    let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                    let userId = chatGetRoomResponse.igpRoom.igpChatRoomExtra.igpPeer.igpID
                    if userIdArray.contains(userId) {
                        userIdArray.remove(at: userIdArray.firstIndex(of: userId)!)
                        completion(roomId)
                    }
                }
            }
            
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                chatRoomCreator(userId: userId, completion: completion)
            default:
                break
            }
        }).send()
    }
    
    private static func isExistRoom(userId: Int64) -> Bool{
        if let _ = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "chatRoom.peer.id = %lld AND isParticipant == true" ,userId)).first {
            return true
        }
        return false
    }
}
