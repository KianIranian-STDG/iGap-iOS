/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Crashlytics
import IGProtoBuff
import YPImagePicker

/** Global Class For Manage Avatar States, Like: Upload, Add Avatar, Delete Avatar*/
class IGHelperAvatar {

    static let shared = IGHelperAvatar()
    
    //MARK:- Upload & Add Avatar
    /**
     Pick avatar then upload to server and finally send add avatar request according to type of 'AvatarType'
     - Parameter roomId: if 'type' is not user so don't need to set roomId otherwise set group or channel roomId
     - Parameter type: type of add avatar request for group , channel or user
     - Parameter screens: type of pick image (capture image or choose from gallery)
     - Parameter completion: return final result after than finished upload and add avatar request
     */
    public func pickAndUploadAvatar(roomId: Int64 = 0, type: AvatarType, screens: [YPPickerScreen], completion: @escaping (_ avatar: IGFile)->Void) {
        IGHelperMediaPicker.shared.setScreens(screens).pick { mediaItems in
            if let imageInfo = mediaItems.singlePhoto, mediaItems.count == 1 {
                let avatar = self.makeAvatarFile(photo: imageInfo)
                self.upload(roomId: roomId, type: type, file: avatar, completion: completion)
            }
        }
    }
    
    /**
     Upload avatar according to type of ownerId, and after upload file send add avatar request to server
     - Parameter roomId: if 'type' is not user so don't need to set roomId otherwise set group or channel roomId
     - Parameter type: type of add avatar request for group , channel or user
     - Parameter file: avatar file
     - Parameter completion: return final result after than finished upload
     */
    public func upload(roomId: Int64 = 0, type: AvatarType, file: IGFile, completion: @escaping (_ avatar: IGFile)->Void) {
        IGGlobal.prgShow()
        IGUploadManager.sharedManager.upload(file: file, start: {
            
        }, progress: { (progress) in
            
        }, completion: { (uploadTask) in
            self.add(ownerId: roomId, file: uploadTask.file, type: type, completion: completion)
        }, failure: {
            IGGlobal.prgHide()
        })
    }
    
    /**
     Send add request avatar and set avatar file for user, group or channel
     - Parameter ownerId: if 'type' is not user so don't need to set ownerId otherwise set group or channel roomId
     - Parameter type: type of add avatar request for group , channel or user
     - Parameter completion: return final result after than finished add avatar
     */
    public func add(ownerId: Int64, file: IGFile, type: AvatarType, completion: @escaping (_ avatar: IGFile) -> Void) {
        if type == .user {
            IGUserAvatarAddRequest.Generator.generate(attachment: file, completion: completion).successPowerful({ (protoResponse, requestWrapper) in
                if let identity = requestWrapper.identity as? (file: IGFile, completion: (_ avatar: IGFile) -> Void) {
                    if let avatarAddResponse = protoResponse as? IGPUserAvatarAddResponse {
                        IGUserAvatarAddRequest.Handler.interpret(response: avatarAddResponse)
                        identity.completion(identity.file)
                    }
                }
                IGGlobal.prgHide()
            }).error({ (error, waitTime) in
                IGGlobal.prgHide()
            }).send()
            
        } else if type == .group {
            IGGroupAvatarAddRequest.Generator.generate(attachment: file, roomId: ownerId, completion: completion).successPowerful({ (protoResponse, requestWrapper) in
                if let identity = requestWrapper.identity as? (file: IGFile, completion: (_ avatar: IGFile) -> Void) {
                    if let avatarAddResponse = protoResponse as? IGPGroupAvatarAddResponse {
                        IGGroupAvatarAddRequest.Handler.interpret(response: avatarAddResponse)
                        identity.completion(identity.file)
                    }
                }
                IGGlobal.prgHide()
            }).error({ (error, waitTime) in
                IGGlobal.prgHide()
            }).send()
            
        } else if type == .channel {
            IGChannelAddAvatarRequest.Generator.generate(attachment: file, roomId: ownerId, completion: completion).successPowerful({ (protoResponse, requestWrapper) in
                if let identity = requestWrapper.identity as? (file: IGFile, completion: (_ avatar: IGFile) -> Void) {
                    if let avatarAddResponse = protoResponse as? IGPChannelAvatarAddResponse {
                        IGChannelAddAvatarRequest.Handler.interpret(response: avatarAddResponse)
                        identity.completion(identity.file)
                    }
                }
                IGGlobal.prgHide()
            }).error({ (error, waitTime) in
                IGGlobal.prgHide()
            }).send()
        }
    }
    
    
    /**
    get list of avatars for user, group or channel
    - Parameter ownerId: if 'type' is not user so don't need to set ownerId otherwise set group or channel roomId
    - Parameter type: type of add avatar request for group , channel or user
    - Parameter completion: return final result after than finished add avatar
    */
    public func getList(ownerId: Int64, type: AvatarType){
        if type == .user {
            IGUserAvatarGetListRequest.Generator.generate(userId: ownerId).success({ (protoResponse) in
                if let UserAvatarGetListoResponse  = protoResponse as? IGPUserAvatarGetListResponse {
                    IGUserAvatarGetListRequest.Handler.interpret(response: UserAvatarGetListoResponse, userId: ownerId)
                }
            }).error ({ (errorCode, waitTime) in
                self.getList(ownerId: ownerId, type: type)
            }).send()
        } else if type == .group {
            IGGroupAvatarGetListRequest.Generator.generate(roomId: ownerId).successPowerful({ (protoResponse, requestWrapper) in
                if let requestGetAvatarList = requestWrapper.message as? IGPGroupAvatarGetList ,let groupAvatarGetListResponse = protoResponse as? IGPGroupAvatarGetListResponse {
                    IGGroupAvatarGetListRequest.Handler.interpret(response: groupAvatarGetListResponse, roomId: requestGetAvatarList.igpRoomID)
                }
            }).error ({ (errorCode, waitTime) in
                self.getList(ownerId: ownerId, type: type)
            }).send()
        } else if type == .channel {
            IGChannelAvatarGetListRequest.Generator.generate(roomId: ownerId).successPowerful({ (protoResponse, requestWrapper) in
                if let requestGetAvatarList = requestWrapper.message as? IGPChannelAvatarGetList ,let channelAvatarGetListResponse = protoResponse as? IGPChannelAvatarGetListResponse {
                    IGChannelAvatarGetListRequest.Handler.interpret(response: channelAvatarGetListResponse, roomId: requestGetAvatarList.igpRoomID)
                }
            }).error ({ (errorCode, waitTime) in
                self.getList(ownerId: ownerId, type: type)
            }).send()
        }
    }
    
    
    //MARK:- Delete Avatar
    /**
     Delete avatar according to avatarId and also roomId if 'type' is not user
     - Parameter roomId: if 'type' is not user so don't need to set roomId otherwise set group or channel roomId
     - Parameter avatarId: avatarId for remove from user or group or channel
     - Parameter type: type of add avatar request for group , channel or user
     - Parameter completion: return final result after than finished add avatar
     */
    public func delete(roomId: Int64 = 0, avatarId: Int64, type: AvatarType, completion: @escaping () -> Void) {
        IGGlobal.prgShow()
        if type == .user {
            IGUserAvatarDeleteRequest.Generator.generate(avatarId: avatarId).success({ (protoResponse) in
                if let userAvatarDeleteResponse = protoResponse as? IGPUserAvatarDeleteResponse {
                    IGUserAvatarDeleteRequest.Handler.interpret(response: userAvatarDeleteResponse)
                }
                completion()
                IGGlobal.prgHide()
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
            }).send()
            
        } else if type == .group {
            IGGroupAvatarDeleteRequest.Generator.generate(roomId: roomId, avatarId: avatarId).success({ (protoResponse) in
                if let groupAvatarDeleteResponse = protoResponse as? IGPGroupAvatarDeleteResponse {
                    IGGroupAvatarDeleteRequest.Handler.interpret(response: groupAvatarDeleteResponse)
                }
                completion()
                IGGlobal.prgHide()
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
            }).send()
            
        } else if type == .channel {
            IGChannelAvatarDeleteRequest.Generator.generate(roomId: roomId, avatarId: avatarId).success({ (protoResponse) in
                if let channelAvatarDeleteResponse = protoResponse as? IGPChannelAvatarDeleteResponse {
                    IGChannelAvatarDeleteRequest.Handler.interpret(response: channelAvatarDeleteResponse)
                }
                completion()
                IGGlobal.prgHide()
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
            }).send()
        }
    }
    
    
    
    //MARK:- Make Avatar File
    /**
     make 'IGFile' from 'YPMediaPhoto'
     */
    public func makeAvatarFile(photo: YPMediaPhoto) -> IGFile {
        var image = photo.modifiedImage ?? photo.originalImage
        if (image.size.width) > CGFloat(2000.0) || (image.size.height) >= CGFloat(2000) {
            image = IGUploadManager.compress(image: image)
        }
        let imgData = image.jpegData(compressionQuality: 0.7)
        
        let avatar = IGFile.makeFileInfo(name: IGGlobal.randomString(length: 10),
                                         size: Int64(imgData?.count ?? 0),
                                         type: .image,
                                         width: Double(image.size.width),
                                         height: Double(image.size.height),
                                         filePathType: .avatar)
        
        return avatar
    }
}
