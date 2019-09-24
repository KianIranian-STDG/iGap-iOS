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
            
        case .messages(.root):
            displayAlert(title: "Messages Root")
            
        case .messages(.details(id: let id)):
            displayAlert(title: "Messages Details \(id)")
            
        case .chatRoom(username: let username, messageId: let messageID):
            self.redirectToChat(userName: username, messageID: messageID)
            
        case .payment(message: let message, status: let st, orderId: let id):
            self.showPaymentView(message: message, status: st, orderId: id)
            
        case .discovery(let pathes):
            self.showDiscovery(pathes: pathes)
            
        case .contact:
            self.selectTabBarIndex(tab: TabBarTab.Contact)
            
        case .profile:
            self.selectTabBarIndex(tab: TabBarTab.Profile)
            
        case .call:
            self.selectTabBarIndex(tab: TabBarTab.Call)
            
        case .favouriteChannel(let token):
            self.redirectToFavouriteChannel(token: token)
            
        }
    }
    
    @discardableResult
    private func selectTabBarIndex(tab: TabBarTab) -> UIViewController? {
        UIApplication.topViewController()!.navigationController!.popToRootViewController(animated: true)
        guard let tabBarController = UIApplication.topTabBarController() as? IGTabBarController else {
            return nil
        }
        tabBarController.selectedIndex = tab.rawValue
        tabBarController.tabBarController(tabBarController, didSelect: tabBarController.selectedViewController!)
        
        return tabBarController.selectedViewController
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
        guard let selectedVC = self.selectTabBarIndex(tab: TabBarTab.Dashboard) as? IGDashboardViewController else {
            return
        }
        if pathes.count != 0 {
            selectedVC.deepLinkDiscoveryIds = pathes
            selectedVC.getDiscoveryList()
        }
//        tabBarController.selectTabBar(tabBar: tabBarController.tabBar, didSelect: TabBarTab.Dashboard)
    }
    
    private func redirectToFavouriteChannel(token: String?) {
        self.selectTabBarIndex(tab: TabBarTab.Dashboard)
        
        let favouriteChannelDashboard = IGFavouriteChannelsDashboardTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        favouriteChannelDashboard.deepLinkToken = token
        UIApplication.topViewController()!.navigationController!.pushViewController(favouriteChannelDashboard, animated: true)
    }
    
    private func redirectToChat(userName: String?, messageID: Int64?) {
        
        guard let username = userName else {
            return
        }
        UIApplication.topViewController()!.navigationController!.popToRootViewController(animated: true)
        
        IGHelperChatOpener.checkUsername(viewController: UIApplication.topViewController()!, username: username, completed: { (user, room, usernameType) in
            
            switch usernameType {
            case .user:
//                IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: usernameType, user: user, room: room)
                IGHelperChatOpener.createChat(viewController: UIApplication.topViewController()!, userId: (user?.id)!)
            case .room:
                guard let messageId = messageID else {
                    IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: usernameType, user: user, room: room)
                    return
                }
                guard let igRoom = room else {
                    return
                }
                IGGlobal.prgShow()
                IGClientGetRoomHistoryRequest.Generator.generatePowerful(roomID: igRoom.id, firstMessageID: messageId, reachMessageId: 0, limit: 1, direction: .up, onMessageReceive: { (messages, direction) in
                    
                    IGGlobal.prgHide()
                    IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: usernameType, user: user, room: room)
                    
                }).successPowerful({ (responseProto, requestWrapper) in
                    DispatchQueue.main.async {
                        IGGlobal.prgHide()
//                    let identity = requestWrapper.identity as! IGStructClientGetRoomHistoryIdentity
//                    let reachMessageIdRequest: Int64! = identity.reachMessageId
                        
                        if let roomHistoryRequest = requestWrapper.message as? IGPClientGetRoomHistory {
                            if let roomHistoryResponse = responseProto as? IGPClientGetRoomHistoryResponse {
                                IGRoomMessage.managePutOrUpdate(roomId: roomHistoryRequest.igpRoomID, messages: roomHistoryResponse.igpMessage, options: IGStructMessageOption(isEnableCache: true))
                            }
                        }
                        
//                        IGHelperChatOpener.manageOpenChatOrProfile(viewController: UIApplication.topViewController()!, usernameType: usernameType, user: user, room: room)
                        
                        
                        let chatPage = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                        chatPage.room = room
                        chatPage.deepLinkMessageId = messageID
                        UIApplication.topViewController()!.navigationController!.pushViewController(chatPage, animated: true)
                        UIApplication.topViewController()?.navigationController?.setNavigationBarHidden(false, animated: true)
                    }
                }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                }).send()
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
