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
import SwiftProtobuf
import RealmSwift
import MBProgressHUD
import IGProtoBuff
class IGReport: UITableViewController , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var txtReportDescription: UITextView!
    var room: IGRoom?
    var messageId: Int64 = 0
    var hud = MBProgressHUD()
    var placeholderLabel : UILabel!
    var myRole : IGPChannelRoom.IGPRole!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.navigationController =  self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        txtReportDescription.delegate = self
        txtReportDescription.isUserInteractionEnabled = true
        navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalDone.rawValue.localized, title: "REPORT".localized)
        navigationItem.rightViewContainer?.addAction {
            if self.txtReportDescription.text.isEmpty {
                let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: "PLEASE_WRITE_UR_REPORT".localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.report(room: self.room!)
            }
        }
        
        placeholderLabel = UILabel()
        
        if messageId != 0 {
            placeholderLabel.text = "MESSAGE_INPUT".localized
        } else {
            if room?.type == .chat {
                placeholderLabel.text = "MESSAGE_INPUT".localized
            } else {
                placeholderLabel.text = "MESSAGE_INPUT".localized
            }
        }
        
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (txtReportDescription.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        txtReportDescription.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (txtReportDescription.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !txtReportDescription.text.isEmpty
        txtReportDescription.tintColor = UIColor.organizationalColor()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func reportRoom(roomId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, messageId: self.messageId, reason: reason, description: self.txtReportDescription.text).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    let alert = UIAlertController(title: "SUCCESS".localized, message: "REPORT_SUCCESS".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { (action) in
                        if self.navigationController is IGNavigationController {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportDescriptionIsInvalid:
                    let alert = UIAlertController(title: "Error", message: "Report description is invalid", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportReportedBefore:
                    let alert = UIAlertController(title: "Error", message: "This Room Reported Before", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportForbidden:
                    let alert = UIAlertController(title: "Error", message: "Room Report Fobidden", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func reportUser(userId: Int64, reason: IGPUserReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGUserReportRequest.Generator.generate(userId: userId, reason: reason, description: self.txtReportDescription.text).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPUserReportResponse:
                    let alert = UIAlertController(title: "SUCCESS".localized, message: "REPORT_SUCCESS".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { (action) in
                        if self.navigationController is IGNavigationController {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userReportDescriptionIsInvalid:
                    let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: "MSG_REPORT_INVALID".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userReportReportedBefore:
                    let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: "MSG_USER_REPORTED_BEFOR".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userReportForbidden:
                    let alert = UIAlertController(title: "Error", message: "User Report Forbidden", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func report(room: IGRoom){
        let roomType = room.type
        
        if roomType == .chat && messageId == 0 {
            reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.other)
        } else {
            reportRoom(roomId: room.id, reason: IGPClientRoomReport.IGPReason.other)
        }
    }
}

extension IGReport: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !txtReportDescription.text.isEmpty
    }
    
}


