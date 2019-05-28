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
import SnapKit
import MBProgressHUD
import SwiftProtobuf
import IGProtoBuff

class IGSettingQrScannerViewController: UIViewController , UIGestureRecognizerDelegate{

    @IBOutlet var mainView: UIView!
    var previewView: UIView!
    var scanner: MTBBarcodeScanner?
    var scannerPageType: BarcodeScanner = .Verify
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigation()
        makeView()
        loadScanner()
    }
    
    private func initNavigation(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_QRCODE_SCANNER".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func makeView(){
        previewView = UIView(frame: mainView.bounds)
        mainView.addSubview(previewView)
        previewView.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.left.equalTo(mainView.snp.left)
            make.right.equalTo(mainView.snp.right)
        }
        scanner = MTBBarcodeScanner(previewView: previewView)
    }
    
    private func loadScanner(){
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    try self.scanner?.startScanning(resultBlock: { codes in
                        if let codes = codes {
                            for code in codes {
                                if let stringValue = code.stringValue {
                                    self.manageResponse(stringValue)
                                    self.scanner?.stopScanning()
                                    return
                                }
                            }
                        }
                    })
                } catch {
                    NSLog("Unable to start scanning")
                }
            } else {
                // no access to camera
            }
        })
    }

    private func manageResponse(_ code: String){
        if scannerPageType == .Verify {
            resolveScannedQrCode(code)
        } else if scannerPageType == .IVandScore {
            setActivity(plancode: code)
        }
    }
    
    
    private func resolveScannedQrCode(_ code: String) {
        if code.contains("igap://") {
            
        } else {
            //try signing in other device
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .indeterminate
            IGUserVerifyNewDeviceRequest.Generator.generate(token: code).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let userVerifyNewDeviceProtoResponse as IGPUserVerifyNewDeviceResponse:
                        let newDeviceResponse = IGUserVerifyNewDeviceRequest.Handler.interpret(response: userVerifyNewDeviceProtoResponse)
                        let alertTitle = "New Device Login"
                        let alertMessage = "App Name: \(newDeviceResponse.appName)\nBuild Version: \(newDeviceResponse.buildVersion)\nApp Version: \(newDeviceResponse.appVersion)\nPlatform: \(newDeviceResponse.platform)\nPlatform Version: \(newDeviceResponse.platformVersion)\nDevice: \(newDeviceResponse.device)\nDevice Name: \(newDeviceResponse.devicename)"
                        self.showAlert(title: alertTitle, message: alertMessage, action: {
                            self.dismiss(animated: true, completion: nil)
                        }, completion: nil)
                    default:
                        break
                    }
                }
            }).error({ (error, waitTime) in
                
            }).send()
        }
    }
    
    private func setActivity(plancode: String){
        IGUserIVandSetActivityRequest.Generator.generate(plancode: plancode).success({ (protoResponse) in
            if let response = protoResponse as? IGPUserIVandSetActivityResponse {
                IGHelperAlert.shared.showSuccessAlert(message: response.igpMessage, success: response.igpState, done: { () -> Void in
                    self.navigationController!.popViewController(animated: true)
                })
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .userIVandSetActivityBadPayload:
                IGHelperAlert.shared.showAlert(view: self, message: "The entered code is invalid!", done: { () -> Void in
                    self.navigationController!.popViewController(animated: true)
                })
                break
            default:
                IGHelperAlert.shared.showSuccessAlert(message: "an error occurred for set new activity!\n please try again later!", success: false, done: { () -> Void in
                    self.navigationController!.popViewController(animated: true)
                })
                break
            }
        }).send()
    }
}
