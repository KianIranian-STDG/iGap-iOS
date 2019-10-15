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

class IGChatGetRoomRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 200
        class func generate(peerId: Int64, identity: String = "") -> IGRequestWrapper {
            var chatGetRoomRequestMessage = IGPChatGetRoom()
            chatGetRoomRequestMessage.igpPeerID = peerId
            return IGRequestWrapper(message: chatGetRoomRequestMessage, actionID: 200, identity: identity)
        }
    }
    
    class Handler : IGRequest.Handler{
        @discardableResult
        class func interpret(response responseProtoMessage:IGPChatGetRoomResponse) -> Int64 {
            let igpRoom = responseProtoMessage.igpRoom
            IGFactory.shared.saveRoomsToDatabase([igpRoom], ignoreLastMessage: true)
            return igpRoom.igpID
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let chatGetRoomResponse as IGPChatGetRoomResponse:
                self.interpret(response: chatGetRoomResponse)
                break
            default:
                break
            }
        }
    }
}


class IGChatSendMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 201
        
        class func generate(message: IGRoomMessage, room: IGRoom, attachmentToken: String?) -> IGRequestWrapper {
            var sendMessageRequestMessage = IGPChatSendMessage()
            if let text = message.message {
                sendMessageRequestMessage.igpMessage = text
            }
            sendMessageRequestMessage.igpRoomID = room.id
            sendMessageRequestMessage.igpMessageType = message.type.toIGP()
            if let attachmentToken = attachmentToken {
                sendMessageRequestMessage.igpAttachment = attachmentToken
            } else if let attachmentToken = message.attachment?.token {
                sendMessageRequestMessage.igpAttachment = attachmentToken
            }
            
            if let repliedTo = message.repliedTo {
                sendMessageRequestMessage.igpReplyTo = repliedTo.id
            } else if let forward = message.forwardedFrom {
                var forwardedFrom = IGPRoomMessageForwardFrom()
                forwardedFrom.igpRoomID = forward.roomId
                forwardedFrom.igpMessageID = forward.id
                sendMessageRequestMessage.igpForwardFrom = forwardedFrom
                //try! sendMessageRequestMessage.igpForwardFrom = forwardedFrom.build()
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
                sendMessageRequestMessage.igpContact = igpContact
            }
            
            if let location = message.location {
                sendMessageRequestMessage.igpLocation.igpLat = location.latitude
                sendMessageRequestMessage.igpLocation.igpLon = location.longitude
            }
            
            if let additional = message.additional {
                sendMessageRequestMessage.igpAdditionalType = additional.dataType
                sendMessageRequestMessage.igpAdditionalData = additional.data!
            }
            
            return IGRequestWrapper(message: sendMessageRequestMessage, actionID: 201, identity: IGStructMessageIdentity(roomMessage: message))
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response:IGPChatSendMessageResponse, identity: IGStructMessageIdentity? = nil) {
            IGHelperMessage.shared.handleMessageResponse(roomId: response.igpRoomID, roomMessage: response.igpRoomMessage, roomType: IGPRoom.IGPType.chat, sender: !response.igpResponse.igpID.isEmpty, structMessageIdentity: identity)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            if let response = responseProtoMessage as? IGPChatSendMessageResponse {
                IGChatSendMessageRequest.Handler.interpret(response: response, identity: nil)
            }
        }
    }
}




class IGChatUpdateStatusRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 202
        class func generate(roomID: Int64, messageID: Int64, status: IGRoomMessageStatus) -> IGRequestWrapper {
            var updateMessageStatusMessage = IGPChatUpdateStatus()
            updateMessageStatusMessage.igpMessageID = messageID
            updateMessageStatusMessage.igpRoomID = roomID
            switch status {
            case .delivered:
                updateMessageStatusMessage.igpStatus = .delivered
            case .seen:
                updateMessageStatusMessage.igpStatus = .seen
                IGFactory.shared.addOfflineSeen(roomId: roomID, messageId: messageID, status: updateMessageStatusMessage.igpStatus)
            case .sent:
                updateMessageStatusMessage.igpStatus = .sent
            default:
                break
            }
            return IGRequestWrapper(message: updateMessageStatusMessage, actionID: 202)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response:IGPChatUpdateStatusResponse) {
            IGFactory.shared.removeOfflineSeen(roomId: response.igpRoomID, messageId: response.igpMessageID, status: response.igpStatus)
            IGFactory.shared.updateMessageStatus(response.igpMessageID, roomID: response.igpRoomID, status: response.igpStatus, statusVersion: response.igpStatusVersion, updaterAuthorHash: response.igpUpdaterAuthorHash, response: response.igpResponse)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChatUpdateStatusResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChatEditMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 203
        class func generate(message: IGRoomMessage, newText: String, room: IGRoom) -> IGRequestWrapper {
            var editMessageRequestMessage = IGPChatEditMessage()
            editMessageRequestMessage.igpMessageID = message.id
            editMessageRequestMessage.igpMessage = newText
            editMessageRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: editMessageRequestMessage, actionID: 203, identity: message)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:Message) {
            self.handlePush(responseProtoMessage: responseProtoMessage)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChatEditMessageResponse:
                IGFactory.shared.editMessage(response.igpMessageID, roomID: response.igpRoomID, message: response.igpMessage, messageType: response.igpMessageType, messageVersion: response.igpMessageVersion)
            default:
                break
            }
        }
    }
}

class IGChatDeleteMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 204
        class func generate(message: IGRoomMessage, room: IGRoom, both: Bool = false) -> IGRequestWrapper {
            var deleteMessageRequestMessage = IGPChatDeleteMessage()
            deleteMessageRequestMessage.igpMessageID = message.id
            deleteMessageRequestMessage.igpRoomID = room.id
            deleteMessageRequestMessage.igpBoth = both
            return IGRequestWrapper(message: deleteMessageRequestMessage, actionID: 204)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response: IGPChatDeleteMessageResponse) {
            IGFactory.shared.setMessageDeleted(response.igpMessageID, roomID: response.igpRoomID, deleteVersion: response.igpDeleteVersion)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChatDeleteMessageResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}
class IGChatClearMessageRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(room: IGRoom ) -> IGRequestWrapper {
            var clearMessageRequestMessage = IGPGroupClearMessage()
            clearMessageRequestMessage.igpRoomID = room.id
            if let lastMessageID = room.lastMessage?.id {
            clearMessageRequestMessage.igpClearID = lastMessageID
            }
            return IGRequestWrapper(message: clearMessageRequestMessage, actionID: 205)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatClearMessageResponse) {
            let roomId = responseProtoMessage.igpRoomID
            let clearId = responseProtoMessage.igpClearID
            IGFactory.shared.setClearMessageHistory(roomId, clearID: clearId)
            IGFactory.shared.markAllMessagesAsRead(roomId: roomId, clearId: clearId)
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let clearHistoryProtoResponse as IGPChatClearMessageResponse:
                self.interpret(response: clearHistoryProtoResponse)
            default:
                break
            }

        }
    }
}

class IGChatDeleteRequest: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(room: IGRoom) -> IGRequestWrapper {
            var chatDeleteRequestMessage = IGPChatDelete()
            chatDeleteRequestMessage.igpRoomID = room.id
            return IGRequestWrapper(message: chatDeleteRequestMessage, actionID: 206)
        }
        
    }
    class Handler : IGRequest.Handler {
        class func interpret(response responseProtoMessage:IGPChatDeleteResponse) {
            let roomId = responseProtoMessage.igpRoomID
            IGFactory.shared.markAllMessagesAsRead(roomId: roomId)
            IGFactory.shared.setDeleteRoom(roomID : roomId)
            IGFactory.shared.deleteAllMessages(roomId: roomId)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChatDeleteResponse:
                self.interpret(response: response)
                break
            default:
                break
            }
        }
    }
    
}

class IGChatUpdateDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(draft: IGRoomDraft) -> IGRequestWrapper {
            var igpChatUpdateDraftMessage = IGPChatUpdateDraft()
            igpChatUpdateDraftMessage.igpDraft = draft.toIGP()
            igpChatUpdateDraftMessage.igpRoomID = draft.roomId
            return IGRequestWrapper(message: igpChatUpdateDraftMessage, actionID: 207)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatUpdateDraftResponse) {
            IGFactory.shared.saveDraft(roomId: responseProtoMessage.igpRoomID, igpDraft: responseProtoMessage.igpDraft)
        }
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChatUpdateDraftResponse:
                self.interpret(response: response)
            default:
                break
            }
        }
    }
}

class IGChatGetDraftRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64) -> IGRequestWrapper {
            var igpChatGetDraftMessage = IGPChatGetDraft()
            igpChatGetDraftMessage.igpRoomID = roomId
            return IGRequestWrapper(message: igpChatGetDraftMessage, actionID: 208)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatGetDraftResponse, roomId: Int64) {
            IGFactory.shared.saveDraft(roomId: roomId, igpDraft: responseProtoMessage.igpDraft)
        }
    }
}

class IGChatConvertToGroupRequest : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(roomId: Int64, name: String, description: String) -> IGRequestWrapper {
            var igpChatConvertToGroupRequetMessage = IGPChatConvertToGroup()
            igpChatConvertToGroupRequetMessage.igpRoomID = roomId
            igpChatConvertToGroupRequetMessage.igpName = name
            igpChatConvertToGroupRequetMessage.igpDescription = description
            return IGRequestWrapper(message: igpChatConvertToGroupRequetMessage, actionID: 209)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatConvertToGroupResponse) ->(roomId: Int64 , groupName: String , groupDescription: String , groupRole: IGGroupMember.IGRole) {
            var IGRole: IGGroupMember.IGRole
            let igpRoomId = responseProtoMessage.igpRoomID
            let igpGroupName = responseProtoMessage.igpName
            let igpGroupDescription = responseProtoMessage.igpDescription
            let igpGroupRole = responseProtoMessage.igpRole
            switch igpGroupRole {
            case .admin:
                IGRole = .admin
            case .member:
                IGRole = .member
            case .moderator:
                IGRole = .moderator
            case .owner:
                IGRole = .owner           
            case .UNRECOGNIZED(_):
                IGRole = .member
            }
            IGFactory.shared.convertChatToGroup(roomId: igpRoomId, roomName: igpGroupName , roomRole : IGRole , roomDescription: igpGroupDescription )
            return (roomId: igpRoomId , groupName: igpGroupName , groupDescription: igpGroupDescription , groupRole:IGRole)
        }
    
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGChatSetActionRequest : IGRequest {
    class Generator : IGRequest.Generator{
        //action id = 210
        class func generate(room: IGRoom, action: IGClientAction, actionId: Int32) -> IGRequestWrapper {
            var requestMessage = IGPChatSetAction()
            requestMessage.igpRoomID = room.id
            requestMessage.igpAction = action.toIGP()
            requestMessage.igpActionID = actionId
            return IGRequestWrapper(message: requestMessage, actionID: 210)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response responseProtoMessage:IGPChatSetActionResponse) {
            
        }
        
        override class func handlePush(responseProtoMessage: Message) {
            switch responseProtoMessage {
            case let response as IGPChatSetActionResponse:
                let action = IGClientAction.cancel.fromIGP(response.igpAction)
                IGFactory.shared.setActionForRoom(action: action, userId: response.igpUserID, roomId: response.igpRoomID)
                break
            default:
                break
            }
        }
    }
}


