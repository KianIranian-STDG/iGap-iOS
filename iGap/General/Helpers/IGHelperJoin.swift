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
                    let alert = UIAlertController(title: "iGap", message: "Are you sure want to join \(clinetCheckInvitedlink.igpRoom.igpTitle)?", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.joinRoombyInvitedLink(room:clinetCheckInvitedlink.igpRoom, invitedToken: token)
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.viewController.present(alert, animated: true, completion: nil)
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.viewController.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                IGGlobal.prgHide()
            }
            
        }).send()
    }
    
    
    func joinRoombyInvitedLink(room:IGPRoom, invitedToken: String) {
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
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.viewController.present(alert, animated: true, completion: nil)
                    
                case .clientJoinByInviteLinkForbidden:
                    let alert = UIAlertController(title: "Error", message: "Sorry,this group does not seem to exist.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.viewController.present(alert, animated: true, completion: nil)
                    
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
            beforeString = "before "
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Success", message: "You joined \(beforeString)to \(room.title!)!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            let openNow = UIAlertAction(title: "Open Now", style: .default, handler: { (action) in
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let chatPage = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
                chatPage.room = room
                self.viewController.navigationController!.pushViewController(chatPage, animated: true)
            })
            alert.addAction(okAction)
            alert.addAction(openNow)
            self.viewController.present(alert, animated: true, completion: nil)
        }
    }
}
