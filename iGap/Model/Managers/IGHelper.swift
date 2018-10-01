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

class IGHelper {
    
    internal static let shareLinkPrefixGroup = "Open this link to join my iGap Group"
    internal static let shareLinkPrefixChannel = "Open this link to join my iGap Channel"
    
    internal static func shareText(message: String, viewController: UIViewController){
        let textToShare = [message]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    
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
    
    
    /**
     * use this method for open profile from search username page(IGLookAndFind)
     * and when user clicked on forwarded message view
     **/
    
    internal static func openUserProfile(user: IGRegisteredUser , room: IGRoom? = nil, viewController: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "IGRegistredUserInfoTableViewController") as! IGRegistredUserInfoTableViewController
        destinationVC.user = user
        destinationVC.previousRoomId = 0
        destinationVC.room = room
        viewController.navigationController!.pushViewController(destinationVC, animated: true)
    }
}
