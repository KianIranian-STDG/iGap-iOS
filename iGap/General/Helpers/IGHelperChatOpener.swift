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

class IGHelperChatOpener {
    
    /**
     * open chat room with room id if exist in realm otherwise
     * get info from server and then open chat
     **/
    
    internal static func openChatRoom(room: IGRoom, viewController: UIViewController){
        if IGRoom.existRoomInLocal(roomId: room.id) != nil {
            DispatchQueue.main.async {
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let roomVC = storyboard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
                roomVC.room = room
                roomVC.openChatFromLink = false
                viewController.navigationController!.pushViewController(roomVC, animated: true)
            }
        } else {
            IGClientSubscribeToRoomRequest.Generator.generate(roomId: room.id).success ({ (responseProtoMessage) in
                DispatchQueue.main.async {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let roomVC = storyboard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
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
    
    
    
    /**
     * open user profile
     **/
    internal static func openUserProfile(user: IGRegisteredUser , room: IGRoom? = nil, roomType: String = "CHAT", viewController: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "IGProfileUserViewController") as! IGProfileUserViewController
        destinationVC.user = user
        destinationVC.previousRoomId = 0
        destinationVC.room = room
        destinationVC.roomType = roomType
        viewController.navigationController!.pushViewController(destinationVC, animated: true)
        viewController.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    /**
     * open room(group/channel)
     **/
    internal static func openRoom(room: IGRoom, viewController: UIViewController){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
        messagesVc.room = room
        UIApplication.topViewController()?.navigationController?.pushViewController(messagesVc, animated:false)
        UIApplication.topViewController()?.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     * resolve username info and return room
     **/
    internal static func checkUsername(viewController: UIViewController, username: String, completed: @escaping ((IGRegisteredUser?, IGRoom?, IGPClientSearchUsernameResponse.IGPResult.IGPType) -> Void), error: @escaping (IGError, IGErrorWaitTime?) -> Void) {
        IGGlobal.prgShow(viewController.view)
        IGClientResolveUsernameRequest.fetchRoom(username: username, completed: { (protoResponse) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                
                if let clientResolvedUsernameResponse = protoResponse as? IGPClientResolveUsernameResponse {
                    let clientResponse = IGClientResolveUsernameRequest.Handler.interpret(response: clientResolvedUsernameResponse)
                    
                    var usernameType : IGPClientSearchUsernameResponse.IGPResult.IGPType = .room
                    if clientResponse.clientResolveUsernametype == .user {
                        usernameType = .user
                    }
                    
                    completed(clientResponse.user, clientResponse.room, usernameType)
                }
            }
        }) { (errorCode, waitTime) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                error(errorCode, waitTime)
            }
        }
    }
    
    
    /**
     * resolve username info and open chat or profile with received data
     **/
    internal static func checkUsernameAndOpenRoom(viewController: UIViewController, username: String, joinToRoom: Bool = false) {
        IGGlobal.prgShow(viewController.view)
        IGClientResolveUsernameRequest.fetchRoom(username: username, completed: { (protoResponse) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                
                if let clientResolvedUsernameResponse = protoResponse as? IGPClientResolveUsernameResponse {
                    let clientResponse = IGClientResolveUsernameRequest.Handler.interpret(response: clientResolvedUsernameResponse)
                    
                    var usernameType : IGPClientSearchUsernameResponse.IGPResult.IGPType = .room
                    if clientResponse.clientResolveUsernametype == .user {
                        usernameType = .user
                    }
                    if joinToRoom {
                        IGHelperJoin.getInstance(viewController: viewController).joinByUsername(username: username, roomId: (clientResponse.room?.id)!, completion: {
                            let predicate = NSPredicate(format: "id = %lld", (clientResponse.room?.id)!)
                            if let room = try! Realm().objects(IGRoom.self).filter(predicate).first {
                                IGHelperChatOpener.manageOpenChatOrProfile(viewController: viewController, usernameType: usernameType, user: nil, room: room)
                            }
                        })
                    } else {
                        IGHelperChatOpener.manageOpenChatOrProfile(viewController: viewController, usernameType: usernameType, user: clientResponse.user, room: clientResponse.room)
                    }
                }
            }
        }) { (errorCode, waitTime) in
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
        }
    }
    
    
    
    /**
     * open chat room if username is for room or bot otherwise open user profile
     * also if "isForwardEnable" is true directly open chat for send forward message
     **/
    internal static func manageOpenChatOrProfile(viewController: UIViewController, usernameType: IGPClientSearchUsernameResponse.IGPResult.IGPType, user: IGRegisteredUser?, room: IGRoom?, roomType: String? = "CHAT") {
        switch usernameType {
        case .user:
            if user == nil || (user?.isInvalidated)! {return}
            if (user!.isBot || IGGlobal.isForwardEnable()) {
                IGHelperChatOpener.createChat(viewController: viewController, userId: (user?.id)!)
            } else {
                IGHelperChatOpener.openUserProfile(user: user! , room: nil, roomType: roomType!, viewController: viewController)
            }
            break
        case .room:
            if room == nil || (room?.isInvalidated)! {return}
            IGHelperChatOpener.openRoom(room: room!, viewController: viewController)
            break
        default:
            break
        }
    }
    
    
    /**
     * create chat with contact and then open chat room
     **/
    internal static func createChat(viewController: UIViewController, userId: Int64) {
        if let room = IGRoom.existRoomInLocal(userId: userId) {
            openRoom(room: room, viewController: viewController)
        } else {
            IGGlobal.prgShow(viewController.view)
            IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                        let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        let room = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                        openRoom(room: room, viewController: viewController)
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
