/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation
import IGProtoBuff
import SwiftProtobuf

class IGClientConditionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(clientConditionRooms: [IGPClientCondition.IGPRoom]) -> IGRequestWrapper {
            var clientConditionRequestMessage = IGPClientCondition()
            clientConditionRequestMessage.igpRooms = clientConditionRooms
            return IGRequestWrapper(message: clientConditionRequestMessage, actionID: 600)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientConditionResponse) {
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGClientGetRoomListRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(offset: Int32, limit: Int32, identity: String = "") -> IGRequestWrapper {
            var clientGetRoomListRequestMessage = IGPClientGetRoomList()
            var pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            clientGetRoomListRequestMessage.igpPagination = pagination
            return IGRequestWrapper(message: clientGetRoomListRequestMessage, actionID: 601, identity: identity)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomListResponse, removeDeleted: Bool = false) -> Int {
            let igpRooms: Array<IGPRoom> = responseProtoMessage.igpRooms
            IGFactory.shared.saveRoomsToDatabase(igpRooms, ignoreLastMessage: false, removeDeleted: removeDeleted, enableCache: true)
//            IGGlobal.importedRoomMessageDic.removeAll()
//            IGGlobal.importedFileDic.removeAll()
            return igpRooms.count
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGClientGetRoomRequest : IGRequest {
    
    class func sendRequest(roomId: Int64){
        IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
            if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
            }
        }).error ({ (errorCode, waitTime) in
            IGClientGetRoomRequest.sendRequest(roomId: roomId)
        }).send()
    }
    
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var clientGetRoomRequestMessage = IGPClientGetRoom()
            clientGetRoomRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: clientGetRoomRequestMessage, actionID: 602)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomResponse, ignoreLastMessage: Bool = true) {
            let igpRoom = responseProtoMessage.igpRoom
            IGFactory.shared.saveRoomsToDatabase([igpRoom], ignoreLastMessage: ignoreLastMessage)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGClientGetRoomHistoryRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomID: Int64, firstMessageID: Int64?) -> IGRequestWrapper {
            var getRoomHistoryRequestMessage = IGPClientGetRoomHistory()
            getRoomHistoryRequestMessage.igpRoomID = roomID
            if let firstMessageID = firstMessageID {
                getRoomHistoryRequestMessage.igpFirstMessageID = firstMessageID
            } else {
                getRoomHistoryRequestMessage.igpFirstMessageID = Int64(0)
            }
            return IGRequestWrapper(message: getRoomHistoryRequestMessage, actionID: 603)
        }
        
        class func generatePowerful(roomID: Int64, firstMessageID: Int64 = 0, reachMessageId: Int64, limit: Int32, direction: IGPClientGetRoomHistory.IGPDirection,
                                    onMessageReceive: @escaping ((_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection) -> Void)) -> IGRequestWrapper {
            var getRoomHistoryRequestMessage = IGPClientGetRoomHistory()
            getRoomHistoryRequestMessage.igpRoomID = roomID
            getRoomHistoryRequestMessage.igpLimit = limit
            getRoomHistoryRequestMessage.igpDirection = direction
            getRoomHistoryRequestMessage.igpFirstMessageID = firstMessageID
            let identity = IGStructClientGetRoomHistoryIdentity(firstMessageId: firstMessageID, reachMessageId: reachMessageId, onMessageReceive: onMessageReceive)
            return IGRequestWrapper(message: getRoomHistoryRequestMessage, actionID: 603, identity: identity)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPClientGetRoomHistoryResponse, roomId: Int64) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
class IGClientSearchRoomHistoryRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64, offset : Int32 , filter : IGSharedMediaFilter ) -> IGRequestWrapper {
            var clientSearchRoomHistoryRequestMessage = IGPClientSearchRoomHistory()
            clientSearchRoomHistoryRequestMessage.igpRoomID = roomId
            clientSearchRoomHistoryRequestMessage.igpOffset = offset
            switch filter {
            case .audio:
                clientSearchRoomHistoryRequestMessage.igpFilter = .audio
                break
            case .image:
                clientSearchRoomHistoryRequestMessage.igpFilter = .image
                break
            case .file:
                clientSearchRoomHistoryRequestMessage.igpFilter = .file
                break
            case .gif:
                clientSearchRoomHistoryRequestMessage.igpFilter = .gif
                break
            case .url:
                clientSearchRoomHistoryRequestMessage.igpFilter = .url
                break
            case .video:
                clientSearchRoomHistoryRequestMessage.igpFilter = .video
                break
            case .voice:
                clientSearchRoomHistoryRequestMessage.igpFilter = .voice
            }
            return IGRequestWrapper(message: clientSearchRoomHistoryRequestMessage, actionID: 605)
            
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPClientSearchRoomHistoryResponse , roomId: Int64) -> (totlaCount: Int32 , NotDeletedCount: Int32 , messages: [IGPRoomMessage] ) {
            let totalCount = responseProtoMessage.igpTotalCount
            let notDeletedCount = responseProtoMessage.igpNotDeletedCount
            let igpMessages = responseProtoMessage.igpResult
            return (totlaCount: totalCount , NotDeletedCount: notDeletedCount , messages: igpMessages)
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
        
        
    }
}
class IGClientResolveUsernameRequest: IGRequest {
    
    class func fetchRoom(username: String, completed: @escaping (ResponseMessage) -> Void, error: @escaping (IGError, IGErrorWaitTime?) -> Void) {
        IGClientResolveUsernameRequest.Generator.generate(username: username, identity: completed).successPowerful ({ (protoResponse, requestWrapper) in
            
            if let closure = requestWrapper.identity as? ((ResponseMessage) -> Void) {
                closure(protoResponse)
            }
        }).error(error).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate(username: String, identity: Any = "") -> IGRequestWrapper {
            var finalUsername = username
            if username.starts(with: "@") {
                finalUsername = String(username.dropFirst())
            }
            var clientResolveUsernameRequestMessage = IGPClientResolveUsername()
            clientResolveUsernameRequestMessage.igpUsername = finalUsername
            return IGRequestWrapper(message: clientResolveUsernameRequestMessage, actionID: 606, identity: identity)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPClientResolveUsernameResponse) -> (clientResolveUsernametype : IGClientResolveUsernameType , user: IGRegisteredUser? , room: IGRoom?) {
            var igRoom: IGRoom?
            var igUser: IGRegisteredUser?
            let igpclientUsernameType = responseProtoMessage.igpType
            let userClientType : IGClientResolveUsernameType
            switch igpclientUsernameType {
            case .room:
                userClientType = .room
            case .user:
                userClientType = .user
            case .UNRECOGNIZED(_):
                userClientType = .user
            }
            if responseProtoMessage.hasIgpUser {
                igUser = IGRegisteredUser(igpUser: responseProtoMessage.igpUser)
                try! IGDatabaseManager.shared.realm.write {
                    _ = IGRegisteredUser.putOrUpdate(realm: IGDatabaseManager.shared.realm, igpUser: responseProtoMessage.igpUser)
                }
            }
            if responseProtoMessage.hasIgpRoom {
                igRoom = IGRoom(igpRoom: responseProtoMessage.igpRoom)
                IGFactory.shared.saveRoomToDatabase(responseProtoMessage.igpRoom, isParticipant: nil)
            }
            return (clientResolveUsernametype : userClientType , user: igUser , room: igRoom)
        }
    }
}

class IGClinetCheckInviteLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(invitedToken: String) -> IGRequestWrapper {
            var clientCheckInvitedLinkRequest = IGPClientCheckInviteLink()
            clientCheckInvitedLinkRequest.igpInviteToken = invitedToken
            return IGRequestWrapper(message: clientCheckInvitedLinkRequest, actionID: 607)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientCheckInviteLinkResponse) {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    _ = IGRoom.putOrUpdate(responseProtoMessage.igpRoom)
                }
            }
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}



class IGClientJoinByInviteLinkRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(invitedToken: String) -> IGRequestWrapper {
            var clientJoinByInviteLinkMessage = IGPClientJoinByInviteLink()
            clientJoinByInviteLinkMessage.igpInviteToken = invitedToken
            return IGRequestWrapper(message: clientJoinByInviteLinkMessage, actionID: 608)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientJoinByInviteLinkResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientJoinByUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(userName: String, identity: String = "") -> IGRequestWrapper {
            var finalUsername = userName
            if userName.starts(with: "@") {
                finalUsername = String(userName.dropFirst())
            }
            var clientJoinByUsernameRequestMessage = IGPClientJoinByUsername()
            clientJoinByUsernameRequestMessage.igpUsername = finalUsername
            return IGRequestWrapper(message: clientJoinByUsernameRequestMessage, actionID: 609, identity: identity)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientJoinByUsernameResponse, roomId: Int64) {
            IGRoom.setParticipant(roomId: roomId, isParticipant: true)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientSubscribeToRoomRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var clientCountRoomHistoryRequestMessage = IGPClientSubscribeToRoom()
            clientCountRoomHistoryRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: clientCountRoomHistoryRequestMessage, actionID: 610)
            
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientSubscribeToRoomResponse) {
            
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientUnsubscribeFromRoomRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var clientCountRoomHistoryRequestMessage = IGPClientUnsubscribeFromRoom()
            clientCountRoomHistoryRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: clientCountRoomHistoryRequestMessage, actionID: 611)
            
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientUnsubscribeFromRoomResponse) {
            
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientSearchUsernameRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(query: String) -> IGRequestWrapper {
            var searchText = query
            if query.starts(with: "@") {
                searchText = String(searchText.dropFirst())
            }
            var clientSearchUsername = IGPClientSearchUsername()
            clientSearchUsername.igpQuery = searchText
            return IGRequestWrapper(message: clientSearchUsername, actionID: 612, identity: query)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientSearchUsernameResponse) {
            IGFactory.shared.saveSearchUsernameResult(responseProtoMessage.igpResult)
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientCountRoomHistoryRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            var clientCountRoomHistoryRequestMessage = IGPClientCountRoomHistory()
            clientCountRoomHistoryRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: clientCountRoomHistoryRequestMessage, actionID: 613)
            
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientCountRoomHistoryResponse) -> (media: Int32 , image: Int32 , video: Int32 , gif: Int32 , voice: Int32 , file: Int32 , audio: Int32, url: Int32 ) {
            let mediaCount = responseProtoMessage.igpMedia
            let imageCount = responseProtoMessage.igpImage
            let videoCount = responseProtoMessage.igpVideo
            let audioCount = responseProtoMessage.igpAudio
            let voiceCount = responseProtoMessage.igpVoice
            let gifCount = responseProtoMessage.igpGif
            let fileCount = responseProtoMessage.igpFile
            let urlCount = responseProtoMessage.igpURL
            
            return (media: mediaCount , image: imageCount , video: videoCount , gif: gifCount , voice: voiceCount , file: fileCount , audio: audioCount, url: urlCount )
            
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
    
}

class IGClientMuteRoomRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64, roomMute: IGRoom.IGRoomMute) -> IGRequestWrapper {
            var mute: IGPRoomMute = IGPRoomMute.unmute
            if roomMute == IGRoom.IGRoomMute.mute {
                mute = IGPRoomMute.mute
            }
            
            var clientMuteRoom = IGPClientMuteRoom()
            clientMuteRoom.igpRoomID = roomId
            clientMuteRoom.igpRoomMute = mute
            return IGRequestWrapper(message: clientMuteRoom, actionID: 614)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPClientMuteRoomResponse) {
            var muteState: IGRoom.IGRoomMute = IGRoom.IGRoomMute.unmute
            if responseProtoMessage.igpRoomMute == IGPRoomMute.mute {
                muteState = .mute
            }
            IGFactory.shared.muteRoom(roomId: responseProtoMessage.igpRoomID, roomMute: muteState)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let message = responseProtoMessage as? IGPClientMuteRoomResponse {
                self.interpret(response: message)
            }
        }
    }
    
}

class IGClientPinRoomRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64, pin: Bool) -> IGRequestWrapper {
            var clientPin = IGPClientPinRoom()
            clientPin.igpRoomID = roomId
            clientPin.igpPin = pin
            return IGRequestWrapper(message: clientPin, actionID: 615)
            
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientPinRoomResponse)  {
            IGFactory.shared.pinRoom(roomId: responseProtoMessage.igpRoomID, pinId: responseProtoMessage.igpPinID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let messsage = responseProtoMessage as? IGPClientPinRoomResponse {
                self.interpret(response: messsage)
            }
        }
    }
    
}

class IGClientRoomReportRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64, messageId: Int64 = 0 ,reason: IGPClientRoomReport.IGPReason, description: String = "") -> IGRequestWrapper {
            var clientRoomReportResponse = IGPClientRoomReport()
            clientRoomReportResponse.igpRoomID = roomId
            clientRoomReportResponse.igpMessageID = messageId
            clientRoomReportResponse.igpReason = reason
            if reason == IGPClientRoomReport.IGPReason.other {
                clientRoomReportResponse.igpDescription = description
            }
            return IGRequestWrapper(message: clientRoomReportResponse, actionID: 616)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientRoomReportResponse) {
        }
        
        override class func handlePush(responseProtoMessage: Message) {
        }
    }
}

class IGClientRegisterDeviceRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(token: String) -> IGRequestWrapper {
            var clientRegisterDevice = IGPClientRegisterDevice()
            clientRegisterDevice.igpToken = token
            clientRegisterDevice.igpType = IGPClientRegisterDevice.IGPType.ios
            return IGRequestWrapper(message: clientRegisterDevice, actionID: 617)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret( response responseProtoMessage : IGPClientRoomReportResponse) {
        }
        
        override class func handlePush(responseProtoMessage: Message) {
        }
    }
}

class IGClientGetPromoteRequest: IGRequest {
    
    class func fetchPromotedRooms() {
        
        // just fetch promote one time and disable this action after do completely and get response from server
        if !IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyAllowFetchPromote) {
            return
        }
        
        IGClientGetPromoteRequest.Generator.generate().success ({ (responseProtoMessage) in
            if let promoteResponse = responseProtoMessage as? IGPClientGetPromoteResponse {
                IGClientGetPromoteRequest.Handler.interpret(response: promoteResponse)
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.fetchPromotedRooms()
            default:
                break
            }
        }).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPClientGetPromote(), actionID: 618)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientGetPromoteResponse) {
            IGHelperPromote.promoteManager(promoteList: responseProtoMessage.igpPromote)
        }
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientGetFavoriteMenuRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate() -> IGRequestWrapper {
            return IGRequestWrapper(message: IGPClientGetFavoriteMenu(), actionID: 619)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientGetFavoriteMenuResponse) {}
        
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientGetDiscoveryRequest: IGRequest {
    
    class Generator: IGRequest.Generator {
        class func generate(pageId: Int32 = 0) -> IGRequestWrapper {
            var request = IGPClientGetDiscovery()
            request.igpPageID = pageId
            return IGRequestWrapper(message: request, actionID: 620, identity: String(describing: pageId))
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientGetDiscoveryResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

//poll


class IGPClientGetPollRequest: IGRequest {
    class func sendRequest(pageId: Int32){
        IGPClientGetPollRequest.Generator.generate(pageId: pageId).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in }).send()
    }
    class Generator: IGRequest.Generator {
        class func generate(pageId: Int32 = 0) -> IGRequestWrapper {
            var request = IGPClientGetPoll()
            request.igpPollID = pageId
            return IGRequestWrapper(message: request, actionID: 624, identity: String(describing: pageId))
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientGetPollResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGPClientSetPollItemClickRequest: IGRequest {
    
    class func sendRequest(itemId: Int32){
        IGPClientSetPollItemClickRequest.Generator.generate(itemId: itemId).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in }).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate(itemId: Int32) -> IGRequestWrapper {
            var request = IGPClientSetPollItemClick()
            request.igpItemID = itemId
            return IGRequestWrapper(message: request, actionID: 625)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientSetPollItemClickResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


//end
class IGClientSetDiscoveryItemClickRequest: IGRequest {
    
    class func sendRequest(itemId: Int32){
        IGClientSetDiscoveryItemClickRequest.Generator.generate(itemId: itemId).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in }).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate(itemId: Int32) -> IGRequestWrapper {
            var request = IGPClientSetDiscoveryItemClick()
            request.igpItemID = itemId
            return IGRequestWrapper(message: request, actionID: 621)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientSetDiscoveryItemClickResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGClientSetDiscoveryItemAgreemnetRequest: IGRequest {
    
    class func sendRequest(itemId: Int32){
        IGClientSetDiscoveryItemAgreemnetRequest.Generator.generate(itemId: itemId).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in }).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate(itemId: Int32) -> IGRequestWrapper {
            var request = IGPClientSetDiscoveryItemAgreement()
            request.igpItemID = itemId
            return IGRequestWrapper(message: request, actionID: 623)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage : IGPClientSetDiscoveryItemAgreementResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
