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

class IGHelperMultiForward {
    
    /**
     * open chat room with room id if exist in realm otherwise
     * get info from server and then open chat
     **/
    
    internal static func openChatRoom(room: IGRoom, viewController: UIViewController){
        if IGRoom.existRoomInLocal(roomId: room.id) != nil {
            DispatchQueue.main.async {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                roomVC.room = room
                roomVC.openChatFromLink = false
                viewController.navigationController!.pushViewController(roomVC, animated: true)
            }
        } else {
            IGClientSubscribeToRoomRequest.Generator.generate(roomId: room.id).success ({ (responseProtoMessage) in
                DispatchQueue.main.async {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                    roomVC.room = room
                    roomVC.openChatFromLink = true
                    viewController.navigationController!.pushViewController(roomVC, animated: true)
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.openChatRoom(room: room, viewController: viewController)
                default:
                    break
                }
            }).send()
        }
    }
    internal static func handleMultiForward(count : Int,selectedIndex : [Int64] = [],messages: [IGRoomMessage]? = [],MultiShareModal: IGMultiForwardModal!,viewController: UIViewController) {
        switch count {
        case 1 :
            
            for id in MultiShareModal.selectedIndex {
                
                if let index = MultiShareModal.FilteredMuliShareContacts.firstIndex(where: { $0.id == id }) {
                    let tmpArray = MultiShareModal.FilteredMuliShareContacts
                    //if was chat with user and not Group or Channel
                    
                    if tmpArray[index].typeRaw == 0 {
                        //if has chat
                        if let roomU = IGRoom.existRoomInLocal(userId: tmpArray[index].id) {
                            
                            //if selected any message to forward
                            if selectedIndex.count > 0 {
                                var countt:Double = 0
                                let forwardCount = selectedIndex.count
                                var messageCount = 0
                                //                                        self.openChat(room: roomU)
                                var tmpMSGG : [IGRoomMessage] = []
                                
                                for element in selectedIndex {
                                    
                                    countt += 0.5
                                    
                                    if let index = messages!.firstIndex(where: { $0.id == element }) {
                                        let message = IGRoomMessage(body: "")
                                        message.type = .text
                                        message.roomId = roomU.id
                                        let detachedMessage = message.detach()
                                        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                                        message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                                        
                                        tmpMSGG.append(message)
                                    }
                                }
                                openChat(room: roomU,messageArray: tmpMSGG, viewController: viewController)
                                
                            } else {
                                return
                            }
                            
                        } else {
                            IGGlobal.prgShow(viewController.view)
                            IGChatGetRoomRequest.Generator.generate(peerId: tmpArray[index].id).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    IGGlobal.prgHide()
                                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                        let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                        let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                        //if selected any message to forward
                                        if selectedIndex.count > 0 {
                                            var count:Double = 0
                                            let forwardCount = selectedIndex.count
                                            var messageCount = 0
                                            //                                                    self.openChat(room: roomU)
                                            
                                            var tmpMSG : [IGRoomMessage] = []
                                            for element in (selectedIndex) {
                                                count = count + 0.5
                                                //DispatchQueue.main.asyncAfter(deadline: .now() + (count + 0.1)) {
                                                
                                                if let index = messages!.firstIndex(where: { $0.id == element }) {
                                                    let message = IGRoomMessage(body: "")
                                                    message.type = .text
                                                    message.roomId = roomU.id
                                                    let detachedMessage = message.detach()
                                                    IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                                                    message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                                                    tmpMSG.append(message)
                                                }
                                                //}
                                            }
                                            openChat(room: roomU,messageArray: tmpMSG, viewController: viewController)
                                            
                                        } else {
                                            return
                                        }
                                    }
                                }
                            }).error({ (errorCode, waitTime) in
                                DispatchQueue.main.async {
                                    IGGlobal.prgHide()
                                    let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                                    let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alertC.addAction(cancel)
                                    viewController.present(alertC, animated: true, completion: nil)
                                }
                            }).send()
                        }
                        
                    } else {
                        if let roomU = IGRoom.existRoomInLocal(roomId: tmpArray[index].id) {
                            
                            //if selected any message to forward
                            if selectedIndex.count > 0 {
                                var countt:Double = 0
                                var tmpMSGGG : [IGRoomMessage] = []
                                
                                for element in selectedIndex {
                                    
                                    countt += 0.5
                                    
                                    if let index = messages!.firstIndex(where: { $0.id == element }) {
                                        let message = IGRoomMessage(body: "")
                                        message.type = .text
                                        message.roomId = roomU.id
                                        let detachedMessage = message.detach()
                                        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                                        message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                                        //DispatchQueue.main.asyncAfter(deadline: .now() + countt + 0.1) {
                                        tmpMSGGG.append(message)
                                        //}
                                    }
                                    
                                }
                                self.openChat(room: roomU,messageArray: tmpMSGGG, viewController: viewController)
                                
                            } else {
                                return
                            }
                            
                        }
                            //if dont have chat with contact
                        else {
                            IGGlobal.prgShow(viewController.view)
                            IGClientGetRoomRequest.Generator.generate(roomId: tmpArray[index].id).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    IGGlobal.prgHide()
                                    if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                        let roomU = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                        //if selected any message to forward
                                        if selectedIndex.count > 0 {
                                            var count:Double = 0
                                            var tmpMSGGGG : [IGRoomMessage] = []
                                            
                                            for element in (selectedIndex) {
                                                count = count + 0.5
                                                //DispatchQueue.main.asyncAfter(deadline: .now() + (count + 0.1)) {
                                                
                                                if let index = messages!.firstIndex(where: { $0.id == element }) {
                                                    let message = IGRoomMessage(body: "")
                                                    message.type = .text
                                                    message.roomId = roomU.id
                                                    let detachedMessage = message.detach()
                                                    IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                                                    message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                                                    tmpMSGGGG.append(message)
                                                }
                                                
                                                //}
                                            }
                                            self.openChat(room: roomU,messageArray: tmpMSGGGG, viewController: viewController)
                                            
                                        }
                                        else {
                                            return
                                        }
                                    }
                                }
                            }).error({ (errorCode, waitTime) in
                                DispatchQueue.main.async {
                                    IGGlobal.prgHide()
                                    let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                                    let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alertC.addAction(cancel)
                                    viewController.present(alertC, animated: true, completion: nil)
                                }
                            }).send()
                        }
                        
                    }
                    
                }
                
            }
            break
        default :
            var emptyMessageArray = [IGRoomMessage?]()
            var emptyRoomArray = [IGRoom?]()
            emptyRoomArray.removeAll()
            emptyMessageArray.removeAll()
            for id in MultiShareModal.selectedIndex {
                if let index = MultiShareModal.FilteredMuliShareContacts.firstIndex(where: { $0.id == id }) {
                    let tmpArray = MultiShareModal.FilteredMuliShareContacts
                    //if has chat
                    if tmpArray[index].typeRaw == 0 {
                        if let roomU = IGRoom.existRoomInLocal(userId: tmpArray[index].id) {
                            
                            emptyRoomArray.append(roomU)
                            
                        }
                            //if dont has chat
                        else {
                            IGGlobal.prgShow(viewController.view)
                            IGChatGetRoomRequest.Generator.generate(peerId: tmpArray[index].id).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    IGGlobal.prgHide()
                                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                        let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                        let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                        
                                        emptyRoomArray.append(roomU)
                                        
                                    }
                                }
                            })
                        }
                        
                    } else {
                        if let roomU = IGRoom.existRoomInLocal(roomId: tmpArray[index].id) {
                            emptyRoomArray.append(roomU)
                            
                        } else { //if dont has chat
                            IGGlobal.prgShow(viewController.view)
                            
                            IGClientGetRoomRequest.Generator.generate(roomId: tmpArray[index].id).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    switch protoResponse {
                                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                        let roomU = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                        emptyRoomArray.append(roomU)
                                    default:
                                        break
                                    }
                                }
                            }).error ({ (errorCode, waitTime) in }).send()
                        }
                    }
                }
            }
            
            var tmpEmptyRoomArray0 = [IGRoom?]()
            tmpEmptyRoomArray0.removeAll()
            
            for element in MultiShareModal.selectedIndex{
                if let index = emptyRoomArray.firstIndex(where: { $0!.chatRoom?.peer?.id == element }) {
                    tmpEmptyRoomArray0.append(emptyRoomArray[index])
                }
            }
            //emptyRoomArray = tmpEmptyRoomArray0
            //Message Handler
            for rm in emptyRoomArray {
                for msg in selectedIndex {
                    
                    if let index = messages!.firstIndex(where: { $0.id == msg }) {
                        let message = IGRoomMessage(body: "")
                        message.type = .text
                        message.roomId = rm!.id
                        message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                        //                                    IGMessageSender.defaultSender.send(message: message, to: rm!)
                        emptyMessageArray.append(message)
                        
                    }
                }
                
            }
            //Remove Duplicates From Rooms Array And MSG Array
            var tmpEmptyMessageArray = [IGRoomMessage?]()
            var tmpEmptyRoomArray = [IGRoom?]()
            tmpEmptyMessageArray.removeAll()
            tmpEmptyRoomArray.removeAll()
            for element in selectedIndex{
                if let index = emptyMessageArray.firstIndex(where: { $0!.forwardedFrom?.id == element }) {
                    tmpEmptyMessageArray.append(emptyMessageArray[index])
                }
            }
            for element in MultiShareModal.selectedIndex{
                if let index = emptyRoomArray.firstIndex(where: { $0!.chatRoom?.peer?.id == element }) {
                    tmpEmptyRoomArray.append(emptyRoomArray[index])
                }
            }
            //emptyRoomArray = tmpEmptyRoomArray
            emptyMessageArray = tmpEmptyMessageArray
            
            //We empty Forward from befor saving becoz it will crash the app if forwardFrom is not Nil
            for msg in emptyMessageArray {
                let tmpMsg = msg?.forwardedFrom
                msg?.forwardedFrom = nil
                let detachedMessage = msg!.detach()
                IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                msg?.forwardedFrom = tmpMsg
                
            }
            for room in emptyRoomArray{
                for msg in emptyMessageArray {
                    IGMessageSender.defaultSender.send(message: msg!, to: room!, sendRequest: false)
                    
                }
            }
            IGMessageSender.defaultSender.sendNextPlainRequest()
            
        }
    }
    
    
    internal static func openChat(room : IGRoom,messageArray : [IGRoomMessage] = [],viewController: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
        roomVC.room = room
        
        roomVC.tmpMSGArray = messageArray
        //        IGFactory.shared.updateRoomLastMessageIfPossible(roomID: room.id)
        
        viewController.navigationController!.pushViewController(roomVC, animated: true)
    }
}
