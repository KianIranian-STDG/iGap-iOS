//
//  DeepLinkNavigator.swift
//  iGap
//
//  Created by MacBook Pro on 6/25/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class DeeplinkNavigator {
    static let shared = DeeplinkNavigator()
    private init() { }
    
    func proceedToDeeplink(_ type: DeeplinkType) {
        switch type {
        case .dashboard:
            displayAlert(title: "Activity")
        case .messages(.root):
            displayAlert(title: "Messages Root")
        case .messages(.details(id: let id)):
            displayAlert(title: "Messages Details \(id)")
        case .chatRoom(room: let room):
            displayAlert(title: "chat room id: \(room.id)")
        case .request(id: let id):
            displayAlert(title: "Request Details \(id)")
        case .payment(message: let message, status: let st, orderId: let id):
            IGGlobal.prgShow(UIApplication.shared.keyWindow!)
            let paymentView = IGPaymentView.sharedInstance
            IGApiPayment.shared.orderStatus(orderId: id) { (isSuccess, paymentStatus) in
                IGGlobal.prgHide()
                if isSuccess {
                    guard let paymentStatus = paymentStatus else {
                        IGHelperAlert.shared.showErrorAlert()
                        return
                    }
                    if paymentView.payToken != nil {
                        paymentView.reloadPaymentResult(status: st, message: message, RRN: "\(paymentStatus.info?.rrn ?? 0)")
                    } else {
                        // get data
                        paymentView.showPaymentResult(on: UIApplication.shared.keyWindow!, paymentStatusData: paymentStatus, message: message)
                    }
                    
                }
            }
            
            
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
