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
import SwiftProtobuf
import MBProgressHUD

class IGRegistrationStepQrViewController: BaseViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblHEader : UILabel!
    var expirayDate: Int32 = 0
    var imageData: Data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        IGGlobal.setLanguage()

        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: "LOGIN_USING_QR".localizedNew)
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(forName: IGNotificationPushLoginToken.name, object: nil, queue: .main) { (notificaion) in
            if let userInfo = notificaion.userInfo {
                let userID: Int64 = userInfo["userID"] as! Int64
                let token = userInfo["token"] as! String
                let username = userInfo["username"] as! String
                let authorHash = userInfo["authorHash"] as! String
                
                IGAppManager.sharedManager.save(userID: userID)
                IGAppManager.sharedManager.save(username: username)
                IGAppManager.sharedManager.save(authorHash: authorHash)
                IGAppManager.sharedManager.save(token: token)
                
                IGAppManager.sharedManager.setUserLoginSuccessful()
                
                self.loginUser(token: token)
            }
//            IGGlobal.setLanguage()

        }
        
        NotificationCenter.default.addObserver(forName: IGNotificationPushTwoStepVerification.name, object: nil, queue: .main) { (notificaion) in
            if let userInfo = notificaion.userInfo {
                let userID: Int64 = userInfo["userID"] as! Int64
                let username = userInfo["username"] as! String
                let authorHash = userInfo["authorHash"] as! String
                
                IGAppManager.sharedManager.save(userID: userID)
                IGAppManager.sharedManager.save(username: username)
                IGAppManager.sharedManager.save(authorHash: authorHash)
                
                IGAppManager.sharedManager.setUserLoginSuccessful()
                
                self.performSegue(withIdentifier:"twoStepPassword", sender: nil)
            }
            
        }
//        IGGlobal.setLanguage()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblHEader.text = "SHOW_AND_LOGIN_USING_QR".localizedNew

        getNewQrCode()
//        IGGlobal.setLanguage()

    }
    
    func getNewQrCode() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGQrCodeNewDeviceRequest.Generator.generate().success( { (protoResponse) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
                switch protoResponse {
                case let qrCodeNewDeviceProtoResponse as IGPQrCodeNewDeviceResponse:
                    (self.expirayDate, self.imageData) = IGQrCodeNewDeviceRequest.Handler.interpret(response: qrCodeNewDeviceProtoResponse)
                    self.imageView.image = UIImage(data: self.imageData)
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(exactly: self.expirayDate)! , execute: {
                        self.getNewQrCode()
                    })
                    break
                default:
                    break
                }
            }
//            IGGlobal.setLanguage()

        }).error( { (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
        }).send()
    }
    
    func checkIfShouldUpdateQr() {
        
    }
    
    
    
    fileprivate func loginUser(token: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        IGUserLoginRequest.Generator.generate(token: token).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPUserLoginResponse:
                    IGUserLoginRequest.Handler.intrepret(response: (protoResponse as? IGPUserLoginResponse)!)
                    IGAppManager.sharedManager.setUserLoginSuccessful()
                    IGUserInfoRequest.Generator.generate(userID: IGAppManager.sharedManager.userID()!).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let userInfoResponse as IGPUserInfoResponse:
                                let igpUser = userInfoResponse.igpUser
                                IGFactory.shared.saveRegistredUsers([igpUser])
                                break
                            default:
                                break
                            }
                            hud.hide(animated: true)
                            IGAppManager.sharedManager.setUserLoginSuccessful()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            hud.hide(animated: true)
                            let alertVC = UIAlertController(title: "Error", message: "There was an error logging you in. Try again please.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(ok)
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    }).send()
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            
        }).send()
    }
}
