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
import Foundation
import IGProtoBuff

class IGRealmAuthorRoom: Object {
    
    @objc dynamic var roomId: Int64 = -1 // userId is exist into the 'IGRegisteredUser' but somtimes client doesn't have userInfo so has to separately save userId
    @objc dynamic var roomInfo: IGRoom!
    
    
    var room: IGRoom? {
        get {
            if self.roomInfo != nil {
                return self.roomInfo
            }
            
            if let roomInfo = IGRoom.getRoomInfo(roomId: self.roomId) {
                return roomInfo
            }
            return nil
        }
    }
    
    convenience init(_ room: IGProtoBuff.IGPRoomMessage.IGPAuthor.IGPRoom) {
        self.init()
        
        self.roomId = room.igpRoomID
        
//        if let userInfo = IGRegisteredUser.getUserInfo(id: author.igpUserID) {
//            self.userInfo = userInfo
//            if userInfo.cacheID != author.igpCacheID {
//                IGUserInfoRequest.sendRequest(userId: author.igpUserID)
//            }
//        } else {
//            IGUserInfoRequest.sendRequest(userId: author.igpUserID)
//        }
        
        
        if let roomInfo = IGRoom.getRoomInfo(roomId: room.igpRoomID) {
            self.roomInfo = roomInfo
        }else {
            IGClientGetRoomRequest.sendRequestAvoidDuplicate(roomId: roomId, success: nil)
//            getRoomInfo(roomId: roomId)
        }
        
        
        
        
    }
    
//    func getRoomInfo(roomId: Int64, completion: (() -> Void)? = nil){
//        IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
//            IGGlobal.prgHide()
//            if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
//                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
//                completion?()
//            }
//        }).error ({ (errorCode, waitTime) in
//            self.getRoomInfo(roomId: roomId, completion: completion)
//        }).send()
//    }
    
    public static func putOrUpdate(roomId: Int64, roomInfo: IGPRoom) {
        
        let room = IGRoom.putOrUpdate(roomInfo)
        
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                
                let predicate = NSPredicate(format: "roomId = %@", roomId)
                var authorRoom = IGDatabaseManager.shared.realm.objects(IGRealmAuthorRoom.self).filter(predicate).first
                
                if authorRoom == nil {
                    authorRoom = IGRealmAuthorRoom()
                    authorRoom?.roomId = roomId
                }
                
                authorRoom?.roomInfo = room
                IGDatabaseManager.shared.realm.add(authorRoom!, update: .modified)
                
            }
        }
    }
    
    
    func detach() -> IGRealmAuthorRoom {
        let authorRoom = IGRealmAuthorRoom(value: self)
        if let roomInfo = authorRoom.roomInfo {
            authorRoom.roomInfo = roomInfo.detach(copyMessage: false)
        }
        return authorRoom
    }
    
}
