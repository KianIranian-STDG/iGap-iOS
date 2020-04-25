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

    static func getInstance() -> IGHelperJoin {
        return IGHelperJoin()
    }
    
    func requestToCheckInvitedLink(invitedLink: String) {
        let strings = invitedLink.split(separator: "/")
        let token: String = String(strings[strings.count-1])
        
        IGGlobal.prgShow()
        IGClinetCheckInviteLinkRequest.Generator.generate(invitedToken: token).success({ (protoResponse) in
            DispatchQueue.main.async {
                IGGlobal.prgHide()
                var bodyString = ""
                if let clinetCheckInvitedlink = protoResponse as? IGPClientCheckInviteLinkResponse {
                    IGClinetCheckInviteLinkRequest.Handler.interpret(response: clinetCheckInvitedlink)
                    bodyString = IGStringsManager.SureToJoin.rawValue.localized + "\n \(clinetCheckInvitedlink.igpRoom.igpTitle)"
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .question, showIconView: true, showDoneButton: true, showCancelButton: true, message: bodyString ,doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized,done: {
                        self.joinRoombyInvitedLink(room:clinetCheckInvitedlink.igpRoom, invitedToken: token)
                    })
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    self.requestToCheckInvitedLink(invitedLink: invitedLink)
                    break
                default:
                    break
                }
                IGGlobal.prgHide()
            }
        }).send()
    }
    
    
    private func joinRoombyInvitedLink(room:IGPRoom, invitedToken: String) {
        IGGlobal.prgShow()
        IGClientJoinByInviteLinkRequest.Generator.generate(invitedToken: invitedToken).success({ [weak self] (protoResponse) in
            if let _ = protoResponse as? IGPClientJoinByInviteLinkResponse {
                IGClientJoinByInviteLinkRequest.Handler.interpret(roomId: room.igpID)
                self?.getRoomInfoAndOpenChat(roomId: room.igpID)
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                    
                case .clientJoinByInviteLinkForbidden:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GroupNotExist.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    
                case .clientJoinByInviteLinkAlreadyJoined:
                    self?.getRoomInfoAndOpenChat(roomId: room.igpID)
                default:
                    break
                }
                
            }
        }).send()
        
    }
    
    private func openChatAfterJoin(room: IGRoom, before:Bool = false){
        
        var beforeString = ""
        if before {
            beforeString = IGStringsManager.Before.rawValue.localized + " "
        }
        
        DispatchQueue.main.async {
                        
            let msg = IGStringsManager.YouJoined.rawValue.localized + " " + beforeString + IGStringsManager.To.rawValue.localized + room.title!
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: msg,doneText: IGStringsManager.OpenNow.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized,done: {

                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let chatPage = storyboard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
                chatPage.room = room
                chatPage.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()?.navigationController?.pushViewController(chatPage, animated: true)
            })
        }
    }
    
    
    public func joinByUsername(username: String, roomId: Int64, completion: (() -> Void)? = nil){
        
        IGGlobal.prgShow()
        IGClientJoinByUsernameRequest.Generator.generate(userName: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let clientJoinbyUsernameResponse as IGPClientJoinByUsernameResponse:
                    IGClientJoinByUsernameRequest.Handler.interpret(response: clientJoinbyUsernameResponse, roomId: roomId)
                    self.getRoomInfo(roomId: roomId, completion: completion)
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
                    let alert = UIAlertController(title: IGStringsManager.GlobalAlerrt.rawValue.localized, message: IGStringsManager.YouCanNotJoin.rawValue.localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                    
                default:
                    break
                }
            }
        }).send()
    }
    
    private func getRoomInfo(roomId: Int64, completion: (() -> Void)? = nil){
        IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                completion?()
            }
        }).error ({ (errorCode, waitTime) in
            self.getRoomInfo(roomId: roomId, completion: completion)
        }).send()
    }
    
    private func getRoomInfoAndOpenChat(roomId: Int64){
        IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ [weak self] (protoResponse) in
            if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // TODO - Use another solution. -> delay is for insuring about save data and fetch latest room info from Realm
                    IGGlobal.prgHide()
                    let predicate = NSPredicate(format: "id = %lld", roomId)
                    if let roomInfo = try! Realm().objects(IGRoom.self).filter(predicate).first {
                        self?.openChatAfterJoin(room: roomInfo)
                    }
                }
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            IGGlobal.prgHide()
            self?.getRoomInfoAndOpenChat(roomId: roomId)
        }).send()
    }
    
}
