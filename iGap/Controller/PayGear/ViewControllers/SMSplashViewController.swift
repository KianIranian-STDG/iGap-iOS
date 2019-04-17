//
//  SMSplashViewController.swift
//  PayGear
//
//  Created by a on 4/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation
import webservice

class SMSplashViewController: UIViewController {
    override func viewDidLoad() {
        
        if !ConnectionCheck.isConnectedToNetwork() {
            self.navigateToMainVC()
            return
        }
        
        let request = WS_methods(delegate: self, failedDialog: false)
        request.addSuccessHandler { (response : Any) in
            self.navigateToMainVC()
        }
        
        request.addFailedHandler { (response : Any) in
//            self.tokenErrorHandler(response as? [AnyHashable : Any])
            self.navigateToMainVC()
            SMLog.SMPrint("failiure in refresh token")
        }
        
        request.addCancelHandler {
            
        }
        
        request.refresh_token()
//        let x = WS_SecurityManager.init()
//        print(x.getRefreshToken())
    }
    
    private func navigateToMainVC() {
        SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Main.rawValue
        let navigation = SMNavigationController.shared
        navigation.navigationBar.isHidden = false
        navigation.style = .NoStyle
        navigation.setRootViewController(page: .Main)
        SMUserManager.saveDataToKeyChain()
        SMInitialInfos.syncs()
    }
    
//    func tokenErrorHandler(_ Response: [AnyHashable : Any]?) {
//        //--
//        let Message = MCLocalization.string(forKey: "Token_Error")
//        //--Show Dialog
//        showErrorDialog(Message ?? "")
//    }
//
//    func showErrorDialog(_ Message: String) {
//        let Dialog = MC_message_dialog(title: MCLocalization.string(forKey: "GLOBAL_MESSAGE"), message: Message, delegate: SMNavigationController.shared.viewControllers.first)
//        let Ok = MC_ActionDialog.action(withTitle: MCLocalization.string(forKey: "GLOBAL_OK") ?? "", style: MCMessageDialogActionButton.blue) {
//
//        }
//        self.navigateToMainVC()
//        Dialog.addAction(Ok)
//        Dialog.show()
//    }
}
