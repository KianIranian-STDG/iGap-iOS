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
import MBProgressHUD
import IGProtoBuff

class IGSettingPrivacyAndSecurityActiveSessionMoreDetailsTableViewController: BaseTableViewController {
    
    @IBOutlet weak var lblTerminate: IGLabel!
    var selectedSession: IGSession?
    @IBOutlet weak var platformSelectedSessionLabel: UILabel!
    @IBOutlet weak var appVersionSelectedSessionLabel: UILabel!
    @IBOutlet weak var countrySelectedSessionLabel: UILabel!
    @IBOutlet weak var createdTimeSelectedSessionLabel: UILabel!
    @IBOutlet weak var lastActivationSelectedSessionLabel: UILabel!
    @IBOutlet weak var ipSelectedSessionLabel: UILabel!
    @IBOutlet weak var SessionInfoCell: UITableViewCell!
    @IBOutlet weak var SelectedSessionDeviceModelLabel: UILabel!
    @IBOutlet weak var selectedSessionImageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SessionInfoCell.selectionStyle = UITableViewCell.SelectionStyle.none
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PS_ACTIVE_SESSIONS".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        showContentCell()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            showConfirmDeleteAlertView()
                }
   }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblTerminate.text = "TERMINATE".localized
    }
    func showConfirmDeleteAlertView(){
        let deleteConfirmAlertView = UIAlertController(title: "SETTING_PS_AS_SURE_TO_TERMINATE_THIS".localized, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "TERMINATE".localized, style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if let thisSession = self.selectedSession {
                if thisSession.isCurrent == false {
                    self.terminateSession()
                }else{
                    self.logOutCurrentSession()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localized, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == "TERMINATE".localized{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteConfirmAlertView, animated: true, completion: nil)
    }
    func showContentCell(){
        if let thisSession = selectedSession {
            switch thisSession.platform! {
            case .android :
                platformSelectedSessionLabel.text = "PLATFORM_ANDROID".localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
            case .iOS :
                platformSelectedSessionLabel.text = "PLATFORM_IOS".localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_iPhone")
            case .macOS :
                platformSelectedSessionLabel.text = "PLATFORM_MACOS".localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Mac")
            case .windows :
                platformSelectedSessionLabel.text = "PLATFORM_WINDOWS".localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Windows")
            case .linux :
                platformSelectedSessionLabel.text = "PLATFORM_LINUX".localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Linux")
            case .blackberry :
                platformSelectedSessionLabel.text = "PLATFORM_BLACKBERRY".localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
            default:
                break
            }
            switch thisSession.device! {
            case .mobile:
                SelectedSessionDeviceModelLabel.text = "MOBILE".localized
            case .desktop:
                SelectedSessionDeviceModelLabel.text = "DESKTOP".localized
            case .tablet:
                SelectedSessionDeviceModelLabel.text = "TABLET".localized
            case .unknown:
                SelectedSessionDeviceModelLabel.text = "UNKNOWN".localized
            }        
            appVersionSelectedSessionLabel.text = "APP_VERSION".localized + "\(thisSession.appVersion)".inLocalizedLanguage()
            countrySelectedSessionLabel.text = "COUNTRY".localized + " \(thisSession.country)"
            let creationDateString = Date(timeIntervalSince1970: TimeInterval(thisSession.createTime)).completeHumanReadableTime()
            createdTimeSelectedSessionLabel.text = "SESSION_INITIATED_AT".localized + creationDateString
            let lastActiveDateString = Date(timeIntervalSince1970: TimeInterval(thisSession.activeTime)).completeHumanReadableTime().inLocalizedLanguage()
            lastActivationSelectedSessionLabel.text = "LAST_ACTIVE_AT".localized  + lastActiveDateString.inLocalizedLanguage()
            ipSelectedSessionLabel.text = "IP".localized + " \(thisSession.ip)".inLocalizedLanguage()
        }
    }
    
    func terminateSession() {
        IGGlobal.prgShow()
        if let thisSession = selectedSession {
            IGUserSessionTerminateRequest.Generator.generate(sessionId: thisSession.sessionId).success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let terminateSessionProtoResponse as IGPUserSessionTerminateResponse:
                        IGUserSessionTerminateRequest.Handler.interpret(response: terminateSessionProtoResponse)
                        if self.navigationController is IGNavigationController {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        IGGlobal.prgHide()
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        IGGlobal.prgHide()
                        let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }

            }).send()
            
        }
    }
    
    func logOutCurrentSession(){
        IGGlobal.prgShow()
        IGUserSessionLogoutRequest.Generator.genarete().success({ (protoResponse) in
            if let logoutSessionProtoResponse = protoResponse as? IGPUserSessionLogoutResponse {
                IGUserSessionLogoutRequest.Handler.interpret(response: logoutSessionProtoResponse)
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
 }
