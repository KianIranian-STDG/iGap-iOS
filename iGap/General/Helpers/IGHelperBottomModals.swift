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
import UIKit
import SwiftEventBus


class IGHelperBottomModals {
    let window = UIApplication.shared.keyWindow
    static let shared = IGHelperBottomModals()

    private var actionSubmit: (() -> Void)?
    private init() {}
    
    func showBottomPanThreeInput(view: UIViewController? = nil,mode: String! = "NEWS_COMMENTS",articleID : String? = nil) {//}-> UIView {
             var alertView = view
             if alertView == nil {
                 alertView = UIApplication.topViewController()
             }
             let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
             let vc = storyboard.instantiateViewController(withIdentifier: "IGThreeInputTVController") as! IGThreeInputTVController
             vc.mode = mode
             if articleID != nil {
                 vc.articleID = articleID!
             }
        UIApplication.topViewController()!.presentPanModal(vc)
     //        return UIView()
         }
    func showBlockCard(view: UIViewController? = nil,mode: String! = "BLOCK_CARD") {//}-> UIView {
             var alertView = view
             if alertView == nil {
                 alertView = UIApplication.topViewController()
             }
             let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
             let vc = storyboard.instantiateViewController(withIdentifier: "IGFourInputTVController") as! IGFourInputTVController
             vc.mode = mode

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.topViewController()!.presentPanModal(vc)
        }
     //        return UIView()
         }
    
    //MARK: - MultiForward Modal
    func showMultiForwardModal(view: UIViewController? = nil,messages: [IGRoomMessage] = [],isFromCloud: Bool = false, isGiftSticker: Bool = false, giftId: String? = nil) {//}-> UIView {
        var alertView = view
        if alertView == nil {
            alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGMultiForwardModalViewController") as! IGMultiForwardModalViewController
        vc.isFromCloud = isFromCloud
        vc.isGiftSticker = isGiftSticker
        vc.giftId = giftId
        vc.selectedMessages = messages
        alertView!.presentPanModal(vc)
    }
    //MARK: -  Modal
    
    func showStickerPackModal(view: UIViewController? = nil) {//}-> UIView {
            var alertView = view
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "IGLiveStickerPackViewController") as! IGLiveStickerPackViewController

        
        
            alertView!.presentPanModal(vc)
    //        return UIView()
        }
}
