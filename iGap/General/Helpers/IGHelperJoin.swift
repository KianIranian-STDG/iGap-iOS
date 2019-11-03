/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift

class IGHelperJoin {

    private var viewController: UIViewController!
    
    private init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func getInstance(viewController: UIViewController) -> IGHelperJoin {
        return IGHelperJoin(viewController)
    }
    
    func requestToCheckInvitedLink(invitedLink: String) {
        let strings = invitedLink.split(separator: "/")
        let token: String = String(strings[strings.count-1])
        
        IGGlobal.prgShow(viewController.view)
        IGClinetCheckInviteLinkRequest.Generator.generate(invitedToken: token).success({ (protoResponse) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                if let clinetCheckInvitedlink = protoResponse as? IGPClientCheckInviteLinkResponse {
                    
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "iGap", showIconView: true, showDoneButton: false, showCancelButton: true, message: "Are you sure want to join \(clinetCheckInvitedlink.igpRoom.igpTitle)?",doneText: "GLOBAL_OK".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew,done: {
                        self.joinRoombyInvitedLink(room:clinetCheckInvitedlink.igpRoom, invitedToken: token)
                    })

                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    
                    break
                default:
                    break
                }
                IGGlobal.prgHide()
            }
            
        }).send()
    }
    
    
    private func joinRoombyInvitedLink(room:IGPRoom, invitedToken: String) {
        IGGlobal.prgShow(viewController.view)
        IGClientJoinByInviteLinkRequest.Generator.generate(invitedToken: invitedToken).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let _ = protoResponse as? IGPClientJoinByInviteLinkResponse {
                    IGFactory.shared.updateRoomParticipant(roomId: room.igpID, isParticipant: true)
                    let predicate = NSPredicate(format: "id = %lld", room.igpID)
                    if let roomInfo = try! Realm().objects(IGRoom.self).filter(predicate).first {
                        self.openChatAfterJoin(room: roomInfo)
                    }
                }
                IGGlobal.prgHide()
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:

                    break
                case .clientJoinByInviteLinkForbidden:
                    
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "GROUP_DOES_NOT_EXIST".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
                    
                case .clientJoinByInviteLinkAlreadyJoined:
                    self.openChatAfterJoin(room: IGRoom(igpRoom: room), before: true)
                default:
                    break
                }
                
            }
        }).send()
        
    }
    
    private func openChatAfterJoin(room: IGRoom, before:Bool = false){
        
        var beforeString = ""
        if before {
            beforeString = "BEFORE".localizedNew + " "
        }
        
        DispatchQueue.main.async {
                        
            let msg = "U_JOINED".localizedNew + " " + beforeString + "TO".localizedNew + room.title!
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: "SUCCESS".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: msg,doneText: "OPEN_NOW".localizedNew, cancelText: "GLOBAL_CLOSE".localizedNew,done: {

                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let chatPage = storyboard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
                chatPage.room = room
                chatPage.hidesBottomBarWhenPushed = true
                self.viewController.navigationController!.pushViewController(chatPage, animated: true)

                
            })
        }
    }
    
    
    public func joinByUsername(username: String, roomId: Int64, completion: (() -> Void)? = nil){
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", roomId)
        if let room = realm.objects(IGRoom.self).filter(predicate).first, room.isParticipant {
            if completion != nil {
                completion!()
            }
            return
        }
        
        IGGlobal.prgShow(viewController.view)
        IGClientJoinByUsernameRequest.Generator.generate(userName: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                switch protoResponse {
                case let clientJoinbyUsernameResponse as IGPClientJoinByUsernameResponse:
                    IGClientJoinByUsernameRequest.Handler.interpret(response: clientJoinbyUsernameResponse, roomId: roomId)
                    if completion != nil {
                        completion!()
                    }
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                case .clinetJoinByUsernameForbidden:
                    let alert = UIAlertController(title: "Error", message: "You don't have permission to join this room", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.viewController.present(alert, animated: true, completion: nil)
                    
                default:
                    break
                }
            }
        }).send()
    }
}
