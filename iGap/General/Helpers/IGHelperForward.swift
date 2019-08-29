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

class IGHelperForward {
    
    
    internal static func handleMultiForward(selectedIndex: [Int64] = [], messages: [IGRoomMessage]? = [], forwardModal: IGMultiForwardModal!, viewController: UIViewController) {
        switch selectedIndex.count {
        case 1 :
            
            for selectedItem in forwardModal.selectedItems {
                
                    if selectedItem.typeRaw == IGRoom.IGType.chat {
                        if let roomU = IGRoom.existRoomInLocal(userId: selectedItem.id) {
                            if selectedIndex.count > 0 {
                                var tmpMSGG : [IGRoomMessage] = []
                                for element in selectedIndex {
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
                            IGChatGetRoomRequest.Generator.generate(peerId: selectedItem.id).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    IGGlobal.prgHide()
                                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                        let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                        let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                        //if selected any message to forward
                                        if selectedIndex.count > 0 {
                                            var count:Double = 0
                                            
                                            var tmpMSG : [IGRoomMessage] = []
                                            for element in (selectedIndex) {
                                                count = count + 0.5
                                                if let index = messages!.firstIndex(where: { $0.id == element }) {
                                                    let message = IGRoomMessage(body: "")
                                                    message.type = .text
                                                    message.roomId = roomU.id
                                                    let detachedMessage = message.detach()
                                                    IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                                                    message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                                                    tmpMSG.append(message)
                                                }
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
                        if let roomU = IGRoom.existRoomInLocal(roomId: selectedItem.id) {
                            
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
                                        tmpMSGGG.append(message)
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
                            IGClientGetRoomRequest.Generator.generate(roomId: selectedItem.id).success({ (protoResponse) in
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
                                                if let index = messages!.firstIndex(where: { $0.id == element }) {
                                                    let message = IGRoomMessage(body: "")
                                                    message.type = .text
                                                    message.roomId = roomU.id
                                                    let detachedMessage = message.detach()
                                                    IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                                                    message.forwardedFrom = messages![index] // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                                                    tmpMSGGGG.append(message)
                                                }
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
            break
        default :
            var emptyMessageArray = [IGRoomMessage?]()
            var emptyRoomArray = [IGRoom?]()
            emptyRoomArray.removeAll()
            emptyMessageArray.removeAll()
            for selectedItem in forwardModal.selectedItems {
                    if selectedItem.typeRaw == IGRoom.IGType.chat {
                        if let roomU = IGRoom.existRoomInLocal(userId: selectedItem.id) {
                            emptyRoomArray.append(roomU)
                        } else {
                            IGGlobal.prgShow(viewController.view)
                            IGChatGetRoomRequest.Generator.generate(peerId: selectedItem.id).success({ (protoResponse) in
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
                        if let roomU = IGRoom.existRoomInLocal(roomId: selectedItem.id) {
                            emptyRoomArray.append(roomU)
                            
                        } else { //if dont has chat
                            IGGlobal.prgShow(viewController.view)
                            
                            IGClientGetRoomRequest.Generator.generate(roomId: selectedItem.id).success({ (protoResponse) in
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
            
            var tmpEmptyRoomArray0 = [IGRoom?]()
            tmpEmptyRoomArray0.removeAll()
            
            for selectedItem in forwardModal.selectedItems {
                if let index = emptyRoomArray.firstIndex(where: { $0!.chatRoom?.peer?.id == selectedItem.id }) {
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
            for selectedItem in forwardModal.selectedItems {
                if let index = emptyRoomArray.firstIndex(where: { $0!.chatRoom?.peer?.id == selectedItem.id }) {
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
        viewController.navigationController!.pushViewController(roomVC, animated: true)
    }
}
