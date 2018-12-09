/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import IGProtoBuff

class IGHelperChatOpener {
    
    /**
     * open chat room with room id if exist in realm otherwise
     * get info from server and then open chat
     **/
    
    internal static func openChatRoom(room: IGRoom, viewController: UIViewController){
        if IGRoom.existRoomInLocal(roomId: room.id) {
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
    
    
    /* open user profile */
    
    internal static func openUserProfile(user: IGRegisteredUser , room: IGRoom? = nil, viewController: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "IGRegistredUserInfoTableViewController") as! IGRegistredUserInfoTableViewController
        destinationVC.user = user
        destinationVC.previousRoomId = 0
        destinationVC.room = room
        viewController.navigationController!.pushViewController(destinationVC, animated: true)
        viewController.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     * resolve username info and open chat or profile with received data
     **/
 
    internal static func checkUsernameAndOpenPage(viewController: UIViewController, username: String){
        IGGlobal.prgShow(viewController.view)
        IGClientResolveUsernameRequest.Generator.generate(username: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                
                if let clientResolvedUsernameResponse = protoResponse as? IGPClientResolveUsernameResponse {
                    let clientResponse = IGClientResolveUsernameRequest.Handler.interpret(response: clientResolvedUsernameResponse)
                    
                    var usernameType : IGPClientSearchUsernameResponse.IGPResult.IGPType = .room
                    if clientResponse.clientResolveUsernametype == .user {
                        usernameType = .user
                    }
                    IGHelperChatOpener.manageOpenChatOrProfile(viewController: viewController, usernameType: usernameType, user: clientResponse.user, room: clientResponse.room)
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    viewController.present(alert, animated: true, completion: nil)
                default:
                    break
                }
            }
        }).send()
    }
    
    /**
     * open chat room if username is for room or bot otherwise open user profile
     **/
    internal static func manageOpenChatOrProfile(viewController: UIViewController, usernameType: IGPClientSearchUsernameResponse.IGPResult.IGPType, user: IGRegisteredUser?, room: IGRoom?, openChatFromLink: Bool = false){
        switch usernameType {
        case .user:
            if (user!.isBot) {
                IGHelperChatOpener.createChat(viewController: viewController, selectedUser: user!)
            } else {
                IGHelperChatOpener.openUserProfile(user: user! , room: nil, viewController: viewController)
            }
            break
        case .room:
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
            messagesVc.room = room
            messagesVc.openChatFromLink = openChatFromLink
            viewController.navigationController!.pushViewController(messagesVc, animated:false)
            viewController.navigationController?.setNavigationBarHidden(false, animated: true)
            break
        default:
            break
        }
    }
    
    
    /**
     * create chat with contact and then open chat room
     **/
    
    internal static func createChat(viewController: UIViewController, selectedUser: IGRegisteredUser) {
        IGGlobal.prgShow(viewController.view)
        IGChatGetRoomRequest.Generator.generate(peerId: selectedUser.id).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let chatGetRoomResponse as IGPChatGetRoomResponse:
                    let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                    
                    IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                let room = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                                roomVC.room = room
                                viewController.navigationController!.pushViewController(roomVC, animated: true)
                            default:
                                break
                            }
                            IGGlobal.prgHide()
                        }
                    }).error ({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            switch errorCode {
                            case .timeout:
                                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                viewController.present(alert, animated: true, completion: nil)
                            default:
                                break
                            }
                            IGGlobal.prgHide()
                        }
                    }).send()
                    
                    IGGlobal.prgHide()
                    break
                default:
                    break
                }
            }
            
        }).error({ (errorCode, waitTime) in
            IGGlobal.prgHide()
            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertC.addAction(cancel)
            viewController.present(alertC, animated: true, completion: nil)
        }).send()
    }
}
