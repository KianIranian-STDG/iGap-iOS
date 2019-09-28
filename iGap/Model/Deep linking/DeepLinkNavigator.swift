//
//  DeepLinkNavigator.swift
//  iGap
//
//  Created by MacBook Pro on 6/25/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import IGProtoBuff

class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    private init() {}
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .chatRoom(.roomId(Id: let roomID, messageId: let messageID)):
            if let room = IGRoom.existRoomInLocal(roomId: roomID) {
                self.openRoom(room: room, messageId: messageID)
            } else {
                IGClientGetRoomRequest.Generator.generate(roomId: roomID).success({ (protoResponse) in
                    if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                        
                        self.openRoom(room: IGRoom(igpRoom: clientGetRoomResponse.igpRoom), messageId: messageID)
                    }
                }).error ({ (errorCode, waitTime) in
                    switch errorCode {
                    case .timeout: break
                        
                    default:
                        break
                    }
                }).send()
            }
            break
            
        case .chatRoom(.userName(username: let username, messageId: let messageID)):
            self.redirectToChat(userName: username, messageID: messageID)
            break
            
//        case .chatRoom(username: let username, messageId: let messageID):
//            self.redirectToChat(userName: username, messageID: messageID)
            
        case .payment(message: let message, status: let st, orderId: let id):
            self.showPaymentView(message: message, status: st, orderId: id)
            break
            
        case .discovery(let pathes):
            self.showDiscovery(pathes: pathes)
            break
            
        case .contact:
            self.selectTabBarIndex(tab: TabBarTab.Contact) { (tabBar) in
            }
            break
            
        case .profile:
            self.selectTabBarIndex(tab: TabBarTab.Profile) { (tabBar) in
            }
            break
            
        case .call:
            self.selectTabBarIndex(tab: TabBarTab.Call) { (tabBar) in
            }
            break
            
        case .favouriteChannel(let token):
            self.redirectToFavouriteChannel(token: token)
            break
            
        }
    }
    
    private func selectTabBarIndex(tab: TabBarTab, completion: @escaping (IGTabBarController?) -> ()) {
        UIApplication.topViewController()!.navigationController!.popToRootViewController(animated: true) {
            guard let tabBarController = UIApplication.topTabBarController() as? IGTabBarController else {
                completion(nil)
                return
            }
            tabBarController.selectedIndex = tab.rawValue
            tabBarController.tabBarController(tabBarController, didSelect: tabBarController.selectedViewController!)
            completion(tabBarController)
        }
    }
    
    private func showPaymentView(message: String, status: PaymentStatus, orderId: String) {
        let paymentView = IGPaymentView.sharedInstance
        IGGlobal.prgShow(paymentView.contentView)
        IGApiPayment.shared.orderStatus(orderId: orderId) { (isSuccess, paymentStatus) in
            IGGlobal.prgHide()
            if isSuccess {
                guard let paymentStatus = paymentStatus else {
                    IGHelperAlert.shared.showErrorAlert()
                    return
                }
                if paymentView.payToken != nil {
                    paymentView.reloadPaymentResult(status: status, message: message, RRN: "\(paymentStatus.info?.rrn ?? 0)")
                } else {
                    // get data
                    paymentView.showPaymentResult(on: UIApplication.shared.keyWindow!, paymentStatusData: paymentStatus, message: message)
                }
                
            } else {
                paymentView.hideView()
                IGHelperAlert.shared.showErrorAlert()
            }
        }
    }
    
    private func showDiscovery(pathes: [String]) {
        self.selectTabBarIndex(tab: TabBarTab.Dashboard) { (tabBar) in
            guard let selectedVC = tabBar?.selectedViewController as? IGDashboardViewController else {
                return
            }
            if pathes.count != 0 {
                selectedVC.deepLinkDiscoveryIds = pathes
                selectedVC.getDiscoveryList()
            }
        }
//        tabBarController.selectTabBar(tabBar: tabBarController.tabBar, didSelect: TabBarTab.Dashboard)
    }
    
    private func redirectToFavouriteChannel(token: String?) {
        self.selectTabBarIndex(tab: TabBarTab.Dashboard) { (tabBar) in
            let favouriteChannelDashboard = IGFavouriteChannelsDashboardTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            favouriteChannelDashboard.deepLinkToken = token
            UIApplication.topViewController()!.navigationController!.pushViewController(favouriteChannelDashboard, animated: true)
        }
    }
    
    private func redirectToChat(userName: String?, messageID: Int64?) {
        
        guard let username = userName else {
            return
        }
        UIApplication.topViewController()!.navigationController!.popToRootViewController(animated: false)
        
        IGHelperChatOpener.checkUsername(viewController: UIApplication.topViewController()!, username: username, completed: { (user, room, usernameType) in
            
            switch usernameType {
            case .user:
//                IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: usernameType, user: user, room: room)
                IGHelperChatOpener.createChat(viewController: UIApplication.topViewController()!, userId: (user?.id)!)
            case .room:
                self.openRoom(room: room, messageId: messageID)
                
            case .UNRECOGNIZED(_):
                break
            }
            
        }) { (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
            default:
                break
            }
        }
        
        return
    }
    
    private func openRoom(room: IGRoom?, messageId: Int64?) {
        guard let messageId = messageId else {
            IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: .room, user: nil, room: room)
            return
        }
        guard let igRoom = room else {
            return
        }
        
        if IGRoomMessage.existMessage(messageId: messageId) {
            let chatPage = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            chatPage.room = igRoom
            chatPage.deepLinkMessageId = messageId
            UIApplication.topViewController()!.navigationController!.pushViewController(chatPage, animated: true)
            UIApplication.topViewController()?.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            IGGlobal.prgShow()
            IGClientGetRoomHistoryRequest.Generator.generatePowerful(roomID: igRoom.id, firstMessageID: messageId, reachMessageId: 0, limit: 1, direction: .up, onMessageReceive: { (messages, direction) in
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                }
                
            }).successPowerful({ (responseProto, requestWrapper) in
                DispatchQueue.main.async {
                    
                    IGGlobal.prgHide()
                    
                    if let roomHistoryRequest = requestWrapper.message as? IGPClientGetRoomHistory {
                        if let roomHistoryResponse = responseProto as? IGPClientGetRoomHistoryResponse {
                            IGRoomMessage.managePutOrUpdate(roomId: roomHistoryRequest.igpRoomID, messages: roomHistoryResponse.igpMessage, options: IGStructMessageOption(isEnableCache: true))
                        }
                    }
                    
//                   IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: usernameType, user: user, room: room)
                    
                    
                    let chatPage = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    chatPage.room = room
                    chatPage.deepLinkMessageId = messageId
                    UIApplication.topViewController()!.navigationController!.pushViewController(chatPage, animated: true)
                    UIApplication.topViewController()?.navigationController?.setNavigationBarHidden(false, animated: true)
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: .room, user: nil, room: room)
                }
                
//            switch errorCode {
//            case .timeout:
//                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(okAction)
//                UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
//            default:
//                break
//            }
                
            }).send()
        }
        
    }
    
    private var alertController = UIAlertController()
    private func displayAlert(title: String) {
        alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            if vc.presentedViewController != nil {
                alertController.dismiss(animated: false, completion: {
                    vc.present(self.alertController, animated: true, completion: nil)
                })
            } else {
                vc.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
