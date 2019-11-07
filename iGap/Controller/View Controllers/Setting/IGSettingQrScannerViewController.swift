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
    var QRHolder:UIImageView!
    var previewView: UIView!
    var scanner: MTBBarcodeScanner?
    var scannerPageType: BarcodeScanner = .Verify
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigation()
        makeView()
        loadScanner()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
        QRHolder = UIImageView()
        mainView.addSubview(previewView)
        mainView.addSubview(QRHolder)
        previewView.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.left.equalTo(mainView.snp.left)
            make.right.equalTo(mainView.snp.right)
        }
        QRHolder.snp.makeConstraints { (make) in
            make.center.equalTo(mainView.snp.center)
            make.height.equalTo(215)
            make.width.equalTo(215)
        }
        if SMLangUtil.loadLanguage() == "fa" {
            if scannerPageType == .BillBarcode {
                QRHolder.contentMode = .scaleAspectFit
                QRHolder.image = UIImage(named: "scan_Holder_BARCODE_FA")
            } else {
                QRHolder.image = UIImage(named: "scan_Holder_FA")
            }
        }
        else {
            if scannerPageType == .BillBarcode {
                QRHolder.contentMode = .scaleAspectFit
                QRHolder.image = UIImage(named: "scan_Holder_BARCODE_EN")
            } else {
                QRHolder.image = UIImage(named: "scan_Holder_EN")
            }
        }

        scanner = MTBBarcodeScanner(previewView: previewView)
    }
    
    private func loadScanner(){
        MTBBarcodeScanner.requestCameraPermission(success: { success in
            if success {
                do {
                    print("SCANNING")
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
        } else {
            manageBillBarcode(code)
        }
    }
    
    private func manageBillBarcode(_ code: String) {
        print("BARCODE SCANEED",code)
        self.navigationController!.popViewController(animated: true)

        let billDataVC = IGElecBillDetailPageTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
        billDataVC.billNumber = String(code.prefix(13))
        billDataVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(billDataVC, animated:true)

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
                        
                        
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: alertTitle, showIconView: true, showDoneButton: false, showCancelButton: true, message: alertMessage, cancelText: "GLOBAL_CLOSE".localizedNew , cancel:  {
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        })

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
                
                switch response.igpState {
                case true :
                    
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: true ,showCancelButton: false, message: response.igpMessage, doneText: "GLOBAL_OK".localizedNew,done: {
                        self.navigationController!.popViewController(animated: true)
                        })
                    break
                default :
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: true ,showCancelButton: false, message: response.igpMessage, doneText: "GLOBAL_OK".localizedNew,done: {
                        self.navigationController!.popViewController(animated: true)
                        })

                    
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .userIVandSetActivityBadPayload:

                
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: true ,showCancelButton: false, message: "MSG_THE_CODE_INVALID".localizedNew, doneText: "GLOBAL_OK".localizedNew,done: {
                    self.navigationController!.popViewController(animated: true)
                })
                break
            default:

                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: true, showCancelButton: false, message: "UNSSUCCESS_OTP".localizedNew, doneText: "GLOBAL_OK".localizedNew,done: {
                    self.navigationController!.popViewController(animated: true)
                })

                break
            }
        }).send()
    }
}
