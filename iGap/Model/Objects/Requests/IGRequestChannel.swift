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
import SwiftEventBus

class IGChannelCreateRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(name: String, description: String?) -> IGRequestWrapper {
            var channelCreateRequestMessage = IGPChannelCreate()
            channelCreateRequestMessage.igpName = name
            if let description = description {
                channelCreateRequestMessage.igpDescription = description
            }
            return IGRequestWrapper(message: channelCreateRequestMessage, actionID: 400)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelCreateResponse) ->(String) {
            IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_CREATE_CHANNEL)
            return responseProtoMessage.igpInviteLink
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelCreateResponse as IGPChannelCreateResponse:
                _ = self.interpret(response: channelCreateResponse)
            default:
                break
            }
        }
    }
}

class IGChannelAddMemberRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 401
        class func generate(userID: Int64, channel: IGRoom) -> IGRequestWrapper {
            var channelAddMemberRequestMessage = IGPChannelAddMember()
            var channelMemberMessage = IGPChannelAddMember.IGPMember()
            channelMemberMessage.igpUserID = userID
            //let memberBuild = try! channelMemberBuilder.build()
            channelAddMemberRequestMessage.igpRoomID = channel.id
            channelAddMemberRequestMessage.igpMember = channelMemberMessage
            return IGRequestWrapper(message: channelAddMemberRequestMessage, actionID: 401)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelAddMemberResponse) {
            IGRealmMember.putOrUpdate(roomId: responseProtoMessage.igpRoomID, userId: responseProtoMessage.igpUserID, role: responseProtoMessage.igpRole.rawValue)
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let channelAddmemberResponse = responseProtoMessage as? IGPChannelAddMemberResponse {
                self.interpret(response: channelAddmemberResponse)
            }
        }
    }
}

class IGChannelAddAdminRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            var channelAddAdminRequestMessage = IGPChannelAddAdmin()
            channelAddAdminRequestMessage.igpRoomID = roomID
            channelAddAdminRequestMessage.igpMemberID = memberID
            return IGRequestWrapper(message: channelAddAdminRequestMessage, actionID: 402)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelAddAdminResponse) {
            IGRealmMember.updateMemberRole(roomId: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID, role: IGPChannelRoom.IGPRole.admin.rawValue)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let channelAddAdminResponse = responseProtoMessage as? IGPChannelAddAdminResponse {
                interpret(response: channelAddAdminResponse)
            }
        }
    }
}

class IGChannelAddModeratorRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            var channelAddModeratorRequestMessage = IGPChannelAddModerator()
            channelAddModeratorRequestMessage.igpMemberID = memberID
            channelAddModeratorRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelAddModeratorRequestMessage, actionID: 403)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelAddModeratorResponse){
            IGRealmMember.updateMemberRole(roomId: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID, role: IGPChannelRoom.IGPRole.moderator.rawValue)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let channelAddModeratorResponse = responseProtoMessage as? IGPChannelAddModeratorResponse {
                interpret(response: channelAddModeratorResponse)
            }
        }
    }
}

class IGChannelDeleteRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID : Int64) -> IGRequestWrapper {
            var channelDeleteRequestMessage = IGPChannelDelete()
            channelDeleteRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelDeleteRequestMessage, actionID: 404)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelDeleteResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.markAllMessagesAsRead(roomId: igpRoomId)
            IGFactory.shared.setDeleteRoom(roomID: igpRoomId)
            IGFactory.shared.deleteAllMessages(roomId: igpRoomId)
            return igpRoomId
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelDeleteResponse as IGPChannelDeleteResponse:
                let _ = self.interpret(response: channelDeleteResponse)
            default:
                break
            }
        }
    }
}

class IGChannelEditRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomId: Int64 , channelName: String , description: String?) -> IGRequestWrapper {
            var channelEditRequestMessage = IGPChannelEdit()
            channelEditRequestMessage.igpName = channelName
            channelEditRequestMessage.igpRoomID = roomId
            if let description = description {
                channelEditRequestMessage.igpDescription = description
            }
            return IGRequestWrapper(message: channelEditRequestMessage, actionID: 405)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelEditResponse) -> (channelName: String , description : String) {
            let roomID = responseProtoMessage.igpRoomID
            let channelName = responseProtoMessage.igpName
            let channelDescription = responseProtoMessage.igpDescription
            
            IGFactory.shared.editChannelRooms(roomID: roomID, roomName: channelName, roomDescription: channelDescription)
            return (channelName: channelName , description: channelDescription)
        }
         override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelEditResponse as IGPChannelEditResponse:
                let _ = self.interpret(response: channelEditResponse)
            default:
                break
            }

        }
    }
}
class IGChannelKickAdminRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64 , memberId: Int64) -> IGRequestWrapper {
            var channelKickAdminRequestMessage = IGPChannelKickAdmin()
            channelKickAdminRequestMessage.igpRoomID = roomId
            channelKickAdminRequestMessage.igpMemberID = memberId
            return IGRequestWrapper(message: channelKickAdminRequestMessage, actionID: 406)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage:IGPChannelKickAdminResponse) {
            IGRealmMember.updateMemberRole(roomId: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID, role: IGPChannelRoom.IGPRole.member.rawValue)
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let channelKickAdminResoponse = responseProtoMessage as? IGPChannelKickAdminResponse {
                self.interpret(response: channelKickAdminResoponse)
            }
        }
    }
}

class IGChannelKickModeratorRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64 , memberID : Int64) -> IGRequestWrapper {
            var channelKickModeratorRequestMessage = IGPChannelKickModerator()
            channelKickModeratorRequestMessage.igpMemberID = memberID
            channelKickModeratorRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelKickModeratorRequestMessage, actionID: 408)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelKickModeratorResponse) {
            IGRealmMember.updateMemberRole(roomId: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID, role: IGPChannelRoom.IGPRole.member.rawValue)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let channelKickModeratorResoponse = responseProtoMessage as? IGPChannelKickModeratorResponse {
                self.interpret(response: channelKickModeratorResoponse)
            }
        }
    }
}

class IGChannelKickMemberRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate (roomID: Int64 , memberID: Int64) -> IGRequestWrapper {
            var channelKickMemberRequestMessage = IGPChannelKickMember()
            channelKickMemberRequestMessage.igpRoomID = roomID
            channelKickMemberRequestMessage.igpMemberID = memberID
            return IGRequestWrapper(message: channelKickMemberRequestMessage, actionID: 407)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret (response responseProtoMessage:IGPChannelKickMemberResponse) {
            IGRealmMember.removeMember(roomId: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let channelKickMemberResoponse = responseProtoMessage as? IGPChannelKickMemberResponse {
                self.interpret(response: channelKickMemberResoponse)
            }
        }
    }
}

class IGChannelLeftRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate (room: IGRoom) -> IGRequestWrapper {
            var channelLeftRequestMessage = IGPChannelLeft()
            channelLeftRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: channelLeftRequestMessage, actionID: 409)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelLeftResponse) {
            IGFactory.shared.leftRoomInDatabase(roomID: responseProtoMessage.igpRoomID, memberId: responseProtoMessage.igpMemberID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelLeftResoponse as IGPChannelLeftResponse:
                self.interpret(response: channelLeftResoponse)
            default:
                break
            }
        }
    }
}

class IGChannelSendMessageRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(message: IGRoomMessage, room: IGRoom, attachmentToken: String?) -> IGRequestWrapper {
            var channelSendMessageRequestMessage = IGPChannelSendMessage()
            if let text = message.message {
                channelSendMessageRequestMessage.igpMessage = text
            }
            
            channelSendMessageRequestMessage.igpRoomID = room.id
            channelSendMessageRequestMessage.igpMessageType = message.type.toIGP()
            channelSendMessageRequestMessage.igpRandomID = message.randomId
            
            if let attachmentToken = attachmentToken {
                channelSendMessageRequestMessage.igpAttachment = attachmentToken
            } else if let attachmentToken = message.attachment?.token {
                channelSendMessageRequestMessage.igpAttachment = attachmentToken
            }
            
            if let repliedTo = message.repliedTo {
                channelSendMessageRequestMessage.igpReplyTo = repliedTo.id
            } else if let forward = message.forwardedFrom {
                var forwardedFrom = IGPRoomMessageForwardFrom()
                forwardedFrom.igpRoomID = forward.roomId
                forwardedFrom.igpMessageID = forward.id
                channelSendMessageRequestMessage.igpForwardFrom = forwardedFrom
            }
            
            if let contact = message.contact {
                var igpContact = IGPRoomMessageContact()
                if let firstName = contact.firstName {
                    igpContact.igpFirstName = firstName
                }
                if let lastName = contact.lastName {
                    igpContact.igpLastName = lastName
                }
                
                var phones = [String]()
                for phone in contact.phones {
                    phones.append(phone.innerString)
                }
                igpContact.igpPhone = phones
                
                var emails = [String]()
                for email in contact.emails {
                    emails.append(email.innerString)
                }
                igpContact.igpEmail = emails
                
                channelSendMessageRequestMessage.igpContact = igpContact
            }
            
            if let location = message.location {
                channelSendMessageRequestMessage.igpLocation.igpLat = location.latitude
                channelSendMessageRequestMessage.igpLocation.igpLon = location.longitude
            }
            
            if let additional = message.additional {
                channelSendMessageRequestMessage.igpAdditionalType = additional.dataType
                channelSendMessageRequestMessage.igpAdditionalData = additional.data!
            }
            
            return IGRequestWrapper(message: channelSendMessageRequestMessage, actionID: 410, identity: IGStructMessageIdentity(roomMessage: message))
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelSendMessageResponse, identity: IGStructMessageIdentity? = nil) {
            IGHelperMessage.shared.handleMessageResponse(roomId: responseProtoMessage.igpRoomID, roomMessage: responseProtoMessage.igpRoomMessage, roomType: IGPRoom.IGPType.channel, sender: !responseProtoMessage.igpResponse.igpID.isEmpty, structMessageIdentity: identity)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelSendMessageResponse:
                IGChannelSendMessageRequest.Handler.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChannelAddAvatarRequest: IGRequest {
    class Generator : IGRequest.Generator{
        class func generate (attachment: IGFile, roomId: Int64, completion: @escaping (_ avatar: IGFile) -> Void) -> IGRequestWrapper {
            var channelAddAvatarMessage = IGPChannelAvatarAdd()
            channelAddAvatarMessage.igpRoomID = roomId
            channelAddAvatarMessage.igpAttachment = attachment.token!
            return IGRequestWrapper(message: channelAddAvatarMessage, actionID: 412, identity: (attachment, completion))
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelAvatarAddResponse) {
            IGDatabaseManager.shared.perfrmOnDatabaseThread {
                try! IGDatabaseManager.shared.realm.write {
                    IGRoom.updateAvatar(roomId: responseProtoMessage.igpRoomID, avatar: IGAvatar.putOrUpdate(igpAvatar: responseProtoMessage.igpAvatar, ownerId: responseProtoMessage.igpRoomID))
                }
            }
        }
        override class func handlePush(responseProtoMessage: Message) {
            if let channelAvatarResponse = responseProtoMessage as? IGPChannelAvatarAddResponse {
                self.interpret(response: channelAvatarResponse)
            }
        }
    }
}

class IGChannelAvatarDeleteRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64, avatarId: Int64) -> IGRequestWrapper {
            var channelAvatarDeleteRequestMessage = IGPChannelAvatarDelete()
            channelAvatarDeleteRequestMessage.igpID = avatarId
            channelAvatarDeleteRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: channelAvatarDeleteRequestMessage, actionID: 413)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response: IGPChannelAvatarDeleteResponse) {
            IGAvatar.deleteAvatar(roomId: response.igpRoomID, avatarId: response.igpID)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let response = responseProtoMessage as? IGPChannelAvatarDeleteResponse {
                self.interpret(response: response)
            }
        }
    }
}


class IGChannelAvatarGetListRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var channelAvatarGetListRequestMessage = IGPChannelAvatarGetList()
            channelAvatarGetListRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: channelAvatarGetListRequestMessage, actionID: 414)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPChannelAvatarGetListResponse, roomId: Int64) {
            IGAvatar.addAvatarList(ownerId: roomId, avatars: response.igpAvatar)
        }
    }
}


class IGChannelUpdateDraftRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            var igpChannelUpdateDraftMessage = IGPChannelUpdateDraft()
            igpChannelUpdateDraftMessage.igpDraft = draft.toIGP()
            igpChannelUpdateDraftMessage.igpRoomID = draft.roomId
            return IGRequestWrapper(message: igpChannelUpdateDraftMessage, actionID: 415)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelUpdateDraftResponse) {
            IGFactory.shared.saveDraft(roomId: responseProtoMessage.igpRoomID, igpDraft: responseProtoMessage.igpDraft)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelUpdateDraftResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChannelGetDraftRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class Generator : IGRequest.Generator{
            class func generate(roomId: Int64) -> IGRequestWrapper {
                var igpChannelGetDraftMessage = IGPChannelGetDraft()
                igpChannelGetDraftMessage.igpRoomID = roomId
                return IGRequestWrapper(message: igpChannelGetDraftMessage, actionID: 416)
            }
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelGetDraftResponse, roomId: Int64) {
            IGFactory.shared.saveDraft(roomId: roomId, igpDraft: responseProtoMessage.igpDraft)
        }
    }
}

class IGChannelGetMemberListRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64, offset: Int32, limit: Int32, filterRole: IGMemberRole) -> IGRequestWrapper {
            var channelGetMemberRequestMessage = IGPChannelGetMemberList()
            channelGetMemberRequestMessage.igpRoomID = roomId
            switch filterRole {
            case .all :
                channelGetMemberRequestMessage.igpFilterRole = .all
            case .admin :
                channelGetMemberRequestMessage.igpFilterRole = .admin
            case .member:
                 channelGetMemberRequestMessage.igpFilterRole = .member
            case .moderator:
                 channelGetMemberRequestMessage.igpFilterRole = .moderator
            }
            var  pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            channelGetMemberRequestMessage.igpPagination = pagination
            return IGRequestWrapper(message: channelGetMemberRequestMessage, actionID: 417)
        }
    }
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChannelGetMemberListResponse, roomId: Int64) {
            IGRealmMember.putOrUpdate(roomId: roomId, members: responseProtoMessage.igpMember)
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}


class IGChannelCheckUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomId: Int64, username: String) -> IGRequestWrapper {
            var checkUsername = IGPChannelCheckUsername()
            checkUsername.igpRoomID = roomId
            checkUsername.igpUsername = username
            return IGRequestWrapper(message: checkUsername, actionID: 418)
        }
    }
    
    class Handler : IGRequest.Handler {
        override class func handlePush(responseProtoMessage: Message) {
            
        }
    }
}


class IGChannelUpdateUsernameRequest : IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(userName: String , room: IGRoom) -> IGRequestWrapper {
            var channelUpdateUsernameRequestMessage = IGPChannelUpdateUsername()
            channelUpdateUsernameRequestMessage.igpRoomID = room.id
            channelUpdateUsernameRequestMessage.igpUsername = userName
            return IGRequestWrapper(message: channelUpdateUsernameRequestMessage, actionID: 419)
        }
        
        class func generate(roomId: Int64 , username: String) -> IGRequestWrapper {
            var channelUpdateUsernameRequestMessage = IGPChannelUpdateUsername()
            channelUpdateUsernameRequestMessage.igpRoomID = roomId
            channelUpdateUsernameRequestMessage.igpUsername = username
            return IGRequestWrapper(message: channelUpdateUsernameRequestMessage, actionID: 419)
        }

    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelUpdateUsernameResponse) {
            IGFactory.shared.updateChannelUserName(userName: responseProtoMessage.igpUsername, roomID : responseProtoMessage.igpRoomID)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelUpdateUsernameResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChannelRemoveUsernameRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(roomID: Int64) -> IGRequestWrapper {
            var channelRemoveUsernameRequestMessage = IGPChannelRemoveUsername()
            channelRemoveUsernameRequestMessage.igpRoomID = roomID
            return IGRequestWrapper(message: channelRemoveUsernameRequestMessage, actionID: 420)
        }
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChannelRemoveUsernameResponse) -> Int64 {
            let igpRoomId = responseProtoMessage.igpRoomID
            IGFactory.shared.romoveChannelUserName(igpRoomId)
            return responseProtoMessage.igpRoomID
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelRemoveUserName as IGPChannelRemoveUsernameResponse:
                let _ = self.interpret(response: channelRemoveUserName)
            default:
                break
            }
        }
    }
}

class IGChannelRevokeLinkRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(roomId: Int64 ) -> IGRequestWrapper {
            var channelRevokeLinkRequestMessage = IGPChannelRevokeLink()
            channelRevokeLinkRequestMessage.igpRoomID = roomId
            return IGRequestWrapper(message: channelRevokeLinkRequestMessage, actionID: 421)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelRevokeLinkResponse) ->(roomId: Int64 ,invitedLink: String , invitedToken: String ) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpInvitedLink = responseProtoMessage.igpInviteLink
            let igpInvitedToken = responseProtoMessage.igpInviteToken
            IGFactory.shared.revokePrivateRoomLink(roomId: igpRoomId , invitedLink: igpInvitedLink , invitedToken: igpInvitedToken)
            return (roomId: igpRoomId ,invitedLink: igpInvitedLink , invitedToken: igpInvitedToken )
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelRevokeLink as IGPChannelRevokeLinkResponse:
                let _ = self.interpret(response: channelRevokeLink)
            default:
                break
            }
        }
    }
}

class IGChannelUpdateSignatureRequest : IGRequest {
    class Generator: IGRequest.Generator {
        class func generate (roomId: Int64 , signatureStatus: Bool) -> IGRequestWrapper {
            var channelUpdateSignaturerequestMessage = IGPChannelUpdateSignature()
            channelUpdateSignaturerequestMessage.igpRoomID = roomId
            channelUpdateSignaturerequestMessage.igpSignature = signatureStatus
            return IGRequestWrapper(message: channelUpdateSignaturerequestMessage, actionID: 422)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response responseProtoMessage: IGPChannelUpdateSignatureResponse) -> (roomId: Int64 , signatureStatus: Bool) {
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpSignatureStatus = responseProtoMessage.igpSignature
            IGFactory.shared.updatChannelRoomSignature(igpRoomId, signatureStatus: igpSignatureStatus)
            return (roomId: igpRoomId, signatureStatus: igpSignatureStatus)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let channelUpdateSignature as IGPChannelUpdateSignatureResponse:
                let _ = self.interpret(response: channelUpdateSignature)
            default:
                break
            }
        }
    }
}

class IGChannelGetMessagesStatsRequest: IGRequest {
    
    class func sendRequest(roomId: Int64 , messageIdList: [Int64]){
        IGChannelGetMessagesStatsRequest.Generator.generate(roomId: roomId, messageIdList: messageIdList).successPowerful({ (protoResponse, requestWrapper) in
            if let response = protoResponse as? IGPChannelGetMessagesStatsResponse, let roomId = requestWrapper.identity as? Int64 {
                IGRealmChannelExtra.updateStatus(roomId: roomId, igpChannelMessageStats: response.igpStats)
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                sendRequest(roomId: roomId, messageIdList: messageIdList)
            default:
                break
            }
        }).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate (roomId: Int64 , messageIdList: [Int64]) -> IGRequestWrapper {
            var request = IGPChannelGetMessagesStats()
            request.igpRoomID = roomId
            request.igpMessageID = messageIdList
            return IGRequestWrapper(message: request, actionID: 423, identity: roomId)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelGetMessagesStatsResponse) {
            
        }
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGChannelAddMessageReactionRequest: IGRequest {
    
    class func sendRequest(roomId: Int64 , messageId: Int64, reaction: IGPRoomMessageReaction){
        IGChannelAddMessageReactionRequest.Generator.generate(roomId: roomId, messageId: messageId, reaction: reaction, identity: "identity").successPowerful ({ (protoResponse, requestWrapper) in
            if let response = protoResponse as? IGPChannelAddMessageReactionResponse, let request = requestWrapper.message as? IGPChannelAddMessageReaction {
                IGRealmChannelExtra.addReaction(messageId: messageId, igpChannelAddMessageReactionResponse: response, reaction: request.igpReaction)
                SwiftEventBus.postToMainThread("\(IGGlobal.eventBusChatKey)\(request.igpRoomID)", sender: (action: ChatMessageAction.updateStatus, messageId: messageId))
            }
        }).error ({ (errorCode, waitTime) in }).send()
    }
    
    class Generator: IGRequest.Generator {
        class func generate (roomId: Int64 , messageId: Int64, reaction: IGPRoomMessageReaction, identity: String) -> IGRequestWrapper {
            var request = IGPChannelAddMessageReaction()
            request.igpRoomID = roomId
            request.igpMessageID = messageId
            request.igpReaction = reaction
            return IGRequestWrapper(message: request, actionID: 424, identity: identity)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelGetMessagesStatsResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGChannelEditMessageRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(message: IGRoomMessage, newText: String, room: IGRoom) -> IGRequestWrapper {
            var channelEditMessageRequestMessage = IGPChannelEditMessage()
            channelEditMessageRequestMessage.igpMessageID = message.id
            channelEditMessageRequestMessage.igpMessage = newText
            channelEditMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: channelEditMessageRequestMessage, actionID: 425)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelEditMessageResponse) {
            IGFactory.shared.editMessage(response.igpMessageID, roomID: response.igpRoomID, message: response.igpMessage, messageType: response.igpMessageType, messageVersion: response.igpMessageVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelEditMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}


class IGChannelDeleteMessageRequest: IGRequest {
    class Generator: IGRequest.Generator {
        class func generate(message: IGRoomMessage, room: IGRoom) -> IGRequestWrapper {
            var channelDeleteMessageRequestMessage = IGPChannelDeleteMessage()
            channelDeleteMessageRequestMessage.igpMessageID = message.id
            channelDeleteMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: channelDeleteMessageRequestMessage, actionID: 411)
        }
    }
    class Handler: IGRequest.Handler {
        class func interpret(response: IGPChannelDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageID, roomID: response.igpRoomID, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChannelDeleteMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChannelUpdateReactionStatusRequest : IGRequest {
    
    class func sendRequest(roomId: Int64, reactionStatus: Bool){
        IGChannelUpdateReactionStatusRequest.Generator.generate(roomId: roomId, reactionStatus: reactionStatus).success ({ (protoResponse) in
            SMLoading.hideLoadingPage()
            if let response = protoResponse as? IGPChannelUpdateReactionStatusResponse {
                IGChannelUpdateReactionStatusRequest.Handler.interpret(response: response)
            }
        }).error ({ (errorCode, waitTime) in
            SMLoading.hideLoadingPage()
        }).send()
    }
    
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64, reactionStatus: Bool) -> IGRequestWrapper {
            var channelUpdateReactionStatus = IGPChannelUpdateReactionStatus()
            channelUpdateReactionStatus.igpRoomID = roomId
            channelUpdateReactionStatus.igpReactionStatus = reactionStatus
            return IGRequestWrapper(message: channelUpdateReactionStatus, actionID: 426)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPChannelUpdateReactionStatusResponse) {
           IGChannelRoom.updateReactionStatus(roomId: response.igpRoomID, reactionStatus: response.igpReactionStatus)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let channelUpdateReactionStatus = responseProtoMessage as? IGPChannelUpdateReactionStatusResponse {
                self.interpret(response: channelUpdateReactionStatus)
            }
        }
    }
}

class IGChannelPinMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64, messageId: Int64 = 0) -> IGRequestWrapper {
            var channelPinMessage = IGPChannelPinMessage()
            channelPinMessage.igpRoomID = roomId
            channelPinMessage.igpMessageID = messageId
            return IGRequestWrapper(message: channelPinMessage, actionID: 427)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPChannelPinMessageResponse) {
            IGFactory.shared.roomPinMessage(roomId: response.igpRoomID, messageId: response.igpPinnedMessage.igpMessageID)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let channelPinMessage = responseProtoMessage as? IGPChannelPinMessageResponse {
                self.interpret(response: channelPinMessage)
            }
        }
    }
}


