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
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.ActiveSessions.rawValue.localized)
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
        lblTerminate.text = IGStringsManager.Terminate.rawValue.localized
    }
    func showConfirmDeleteAlertView(){
        let deleteConfirmAlertView = UIAlertController(title: IGStringsManager.SureToTerminateThis.rawValue.localized, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: IGStringsManager.Terminate.rawValue.localized, style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if let thisSession = self.selectedSession {
                if thisSession.isCurrent == false {
                    self.terminateSession()
                }else{
                    self.logOutCurrentSession()
                }
            }
        })
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == IGStringsManager.Terminate.rawValue.localized{
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
                platformSelectedSessionLabel.text = IGStringsManager.Android.rawValue.localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
            case .iOS :
                platformSelectedSessionLabel.text = IGStringsManager.IOS.rawValue.localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_iPhone")
            case .macOS :
                platformSelectedSessionLabel.text = IGStringsManager.MacOs.rawValue.localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Mac")
            case .windows :
                platformSelectedSessionLabel.text = IGStringsManager.Widnows.rawValue.localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Windows")
            case .linux :
                platformSelectedSessionLabel.text = IGStringsManager.Linux.rawValue.localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Linux")
            case .blackberry :
                platformSelectedSessionLabel.text = IGStringsManager.BlackBerry.rawValue.localized
                selectedSessionImageview.image = UIImage(named:"IG_Settings_Active_Sessions_Device_Android")
            default:
                break
            }
            switch thisSession.device! {
            case .mobile:
                SelectedSessionDeviceModelLabel.text = IGStringsManager.Mobile.rawValue.localized
            case .desktop:
                SelectedSessionDeviceModelLabel.text = IGStringsManager.Desktop.rawValue.localized
            case .tablet:
                SelectedSessionDeviceModelLabel.text = IGStringsManager.Tablet.rawValue.localized
            case .unknown:
                SelectedSessionDeviceModelLabel.text = IGStringsManager.Unknown.rawValue.localized
            }        
            appVersionSelectedSessionLabel.text = IGStringsManager.GlobalAppVersion.rawValue.localized + "\(thisSession.appVersion)".inLocalizedLanguage()
            countrySelectedSessionLabel.text = IGStringsManager.Country.rawValue.localized + " \(thisSession.country)"
            let creationDateString = Date(timeIntervalSince1970: TimeInterval(thisSession.createTime)).completeHumanReadableTime()
            createdTimeSelectedSessionLabel.text = IGStringsManager.SessionCreateOn.rawValue.localized + creationDateString
            let lastActiveDateString = Date(timeIntervalSince1970: TimeInterval(thisSession.activeTime)).completeHumanReadableTime().inLocalizedLanguage()
            lastActivationSelectedSessionLabel.text = IGStringsManager.LastActiveAt.rawValue.localized  + lastActiveDateString.inLocalizedLanguage()
            ipSelectedSessionLabel.text = IGStringsManager.IP.rawValue.localized + " \(thisSession.ip)".inLocalizedLanguage()
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
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }

            }).send()
            
        }
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }

    func logOutCurrentSession(){
        IGGlobal.prgShow()
        IGUserSessionLogoutRequest.Generator.genarete().success({ (protoResponse) in
            if let logoutSessionProtoResponse = protoResponse as? IGPUserSessionLogoutResponse {
                IGUserSessionLogoutRequest.Handler.interpret(response: logoutSessionProtoResponse)
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()

            switch errorCode {
            case .timeout:
                break
            default:
                break
            }
            
        }).send()
    }
 }
