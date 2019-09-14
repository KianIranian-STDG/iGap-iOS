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
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGDeleteAccountConfirmationTableViewController: BaseTableViewController , UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var CodeEntryTextField: UITextField!
    @IBOutlet weak var retrySendingCodeLabel: UILabel!
    var delayBeforeSendingAgaing : Int32? = 60
    let borderName = CALayer()
    let width: CGFloat = 0.5
    var hud = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder()
        self.navigationController?.navigationBar.tintColor = UIColor.organizationalColor()
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            phoneNumberLabel.text = "\(userInDb.phone)"
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "NEXT_BTN".localizedNew, title: "SETTING_PAGE_ACCOUNT_D_ACCOUNT".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

        navigationItem.rightViewContainer?.addAction {
            self.nextButtonClicked()
        }
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateCountDown()
    }
    
    func addBottomBorder(){
        borderName.borderColor = UIColor.organizationalColor().cgColor
        borderName.frame = CGRect(x: 0, y: CodeEntryTextField.frame.size.height - width, width:  CodeEntryTextField.frame.size.width, height: CodeEntryTextField.frame.size.height)
        borderName.borderWidth = width
        CodeEntryTextField.layer.addSublayer(borderName)
        CodeEntryTextField.layer.masksToBounds = true
    }

    func nextButtonClicked(){
        if CodeEntryTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "GAME_ALERT_TITLE".localizedNew, message: "MSG_FILL_DELETE_CODE".localizedNew, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: UIAlertAction.Style.default, handler: nil))
            alert.view.tintColor = UIColor.organizationalColor()
            self.present(alert, animated: true, completion: nil)
        } else {
            //performSegue(withIdentifier: "GoToDeleteReasenPage", sender: self)
            IGUserDeleteRequest.Generator.generate(token: CodeEntryTextField.text! , reasen: IGPUserDelete.IGPReason(rawValue: 0)!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let deleteUserProtoResponse as IGPUserDeleteResponse:
                        self.hud.hide(animated: true)
                        self.dismiss(animated: true, completion: { 
                            IGUserDeleteRequest.Handler.interpret(response: deleteUserProtoResponse)
                        })
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async{
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .userDeleteTokenInvalidCode:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title:"INVALID_CODE".localizedNew, message: "MSG_THE_CODE_INVALID".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default , handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    DispatchQueue.main.async {
                        let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew, preferredStyle: .alert)
                        
                        let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alertC.addAction(cancel)
                        self.hud.hide(animated: true)
                        self.present(alertC, animated: true, completion: nil)
                    }
                    break
                }
            }).send()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    @objc func updateCountDown() {
        self.delayBeforeSendingAgaing! -= 1
        if self.delayBeforeSendingAgaing!>0 {
            let fixedText = "DIDNT_RECIEVE_CODE_WAIT".localizedNew
            let remainingSeconds = self.delayBeforeSendingAgaing!%60
            let remainingMiuntes = self.delayBeforeSendingAgaing!/60
            retrySendingCodeLabel.text = "\(fixedText) \(remainingMiuntes):\(remainingSeconds)"
            self.perform(#selector(IGDeleteAccountConfirmationTableViewController.updateCountDown), with: nil, afterDelay: 1.0)
        } else {
            retrySendingCodeLabel.text = "TAP_RESEND".localizedNew
            let tap = UITapGestureRecognizer(target: self, action: #selector(IGDeleteAccountConfirmationTableViewController.tapFunction))
            retrySendingCodeLabel.isUserInteractionEnabled = true
            retrySendingCodeLabel.addGestureRecognizer(tap)
        }
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        getDeleteToken()
    }
    
    func getDeleteToken(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserGetDeleteTokenRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getDeleteTokenProtoResponse as IGPUserGetDeleteTokenResponse:
                let _ = IGUserGetDeleteTokenRequest.Handler.interpret(response: getDeleteTokenProtoResponse)
                self.hud.hide(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToDeleteReasenPage" {
            let deleteReasonNavigationController = segue.destination as! UINavigationController
            if deleteReasonNavigationController.topViewController is IGDeleteAccountReasonViewController {
                let deleteReasenVC = deleteReasonNavigationController.topViewController as! IGDeleteAccountReasonViewController
                if let deleteCode = CodeEntryTextField.text {
                    deleteReasenVC.token = deleteCode.uppercased()
                    print(deleteCode)
                }
            }
        }
    }
}
