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


class IGChannelInfoEditTypeTableViewController: BaseTableViewController ,UITextFieldDelegate {

    @IBOutlet weak var publicChannelCell: UITableViewCell!
    @IBOutlet weak var privateChannelCell: UITableViewCell!
    @IBOutlet weak var channelLinkTextField: UITextField!
    @IBOutlet weak var lblPublic : UILabel!
    @IBOutlet weak var lblPrivate : UILabel!

    var publicIndexPath : IndexPath?
    var privateIndexPath : IndexPath?
    var room: IGRoom?
    var hud = MBProgressHUD()
    
    var userWantsToChangeThisChannelToPublic = false
    var userWantsToChangeThisChannelToPrivate = false
    
    @IBAction func edtTextChange(_ sender: UITextField) {
        if let text = sender.text {
            if text.count >= 5 {
                checkUsername(username: sender.text!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privateIndexPath = IndexPath(row: 1, section: 0)
        publicIndexPath  = IndexPath(row: 0, section: 0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "GLOBAL_DONE".localizedNew, title: "TYPE".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            if self.userWantsToChangeThisChannelToPublic {
                self.changedChannelTypeToPublic()
            } else if self.userWantsToChangeThisChannelToPrivate {
                self.changedChannelTypeToPrivate()
            } else {
                //update user name
                if self.room?.channelRoom?.type == .publicRoom {
                    self.changedChannelTypeToPublic()
                }
            }
        }
        
        if self.room?.channelRoom?.type == .publicRoom {
            tableView.selectRow(at: publicIndexPath, animated: true, scrollPosition: .none)
            let selectedCell = tableView.cellForRow(at: publicIndexPath!)
            selectedCell?.accessoryType = .checkmark
            channelLinkTextField.text = room?.channelRoom?.publicExtra?.username
            
            channelLinkTextField.isUserInteractionEnabled = true
            channelLinkTextField.text = nil
            let channelDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
            channelDefualtName.font = UIFont.systemFont(ofSize: 14)
            channelDefualtName.text = "iGap.net/"
            channelLinkTextField.leftView = channelDefualtName
            channelLinkTextField.leftViewMode = UITextField.ViewMode.always
            channelLinkTextField.placeholder = ""
            channelLinkTextField.delegate = self
            
            if let username = room?.channelRoom?.publicExtra?.username {
                channelLinkTextField.text = username
            }
            
        }
        if self.room?.channelRoom?.type == .privateRoom {
            tableView.selectRow(at: privateIndexPath, animated: true, scrollPosition: .none)
            let selectedCell = tableView.cellForRow(at: privateIndexPath!)
            selectedCell?.accessoryType = .checkmark
            channelLinkTextField.text = room?.channelRoom?.privateExtra?.inviteLink
            channelLinkTextField.isUserInteractionEnabled = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblPublic.text = "PUBLIC".localizedNew
        lblPrivate.text = "PRIVATE".localizedNew
    }
    func checkUsername(username: String){
        IGChannelCheckUsernameRequest.Generator.generate(roomId:room!.id ,username: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let usernameResponse as IGPChannelCheckUsernameResponse :
                    if usernameResponse.igpStatus == IGPChannelCheckUsernameResponse.IGPStatus.available {
                        self.channelLinkTextField.textColor = UIColor.black
                    } else {
                        self.channelLinkTextField.textColor = UIColor.red
                    }
                    break
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
            }
        }).send()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  indexPath.section == 0 {
            if indexPath.row == 0 {
                publicChannelCell.accessoryType = .checkmark
                privateChannelCell.accessoryType = .none
                privateIndexPath = indexPath
                userWantsToChangeThisChannelToPublic = true
                
                channelLinkTextField.isUserInteractionEnabled = true
                channelLinkTextField.text = nil
                let channelDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
                channelDefualtName.font = UIFont.systemFont(ofSize: 14)
                channelDefualtName.text = "iGap.net/"
                channelLinkTextField.leftView = channelDefualtName
                channelLinkTextField.leftViewMode = UITextField.ViewMode.always
                channelLinkTextField.placeholder = ""
                channelLinkTextField.delegate = self
                
                if let username = room?.channelRoom?.publicExtra?.username {
                    channelLinkTextField.text = username
                }
                
            } else if indexPath.row == 1 {
                publicChannelCell.accessoryType = .none
                privateChannelCell.accessoryType = .checkmark
                publicIndexPath = indexPath
                userWantsToChangeThisChannelToPrivate = true
                
                channelLinkTextField.leftView = nil
                if let invitedLink = room?.channelRoom?.privateExtra?.inviteLink {
                    channelLinkTextField.text = invitedLink
                } else {
                    channelLinkTextField.text = "Invite link will be generated ..."
                }
                
                channelLinkTextField.isUserInteractionEnabled = false
                channelLinkTextField.delegate = self
            }
            tableView.reloadData()
        }
    }
    
    func changedChannelTypeToPrivate() {
        if room!.channelRoom!.type == .privateRoom {
            return
        }
        if let roomID = room?.id {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelRemoveUsernameRequest.Generator.generate(roomID: roomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelRemoveUsernameResponse as IGPChannelRemoveUsernameResponse:
                        IGClientGetRoomRequest.Generator.generate(roomId: roomID).success({ (protoResponse) in
                            DispatchQueue.main.async {
                                switch protoResponse {
                                case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                    IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
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
                        
                        _ = IGChannelRemoveUsernameRequest.Handler.interpret(response: channelRemoveUsernameResponse)
                        
                        if self.navigationController is IGNavigationController {
                            _ = self.navigationController?.popViewController(animated: true)
                        }

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
    }
    
    func changedChannelTypeToPublic(){
        if room!.channelRoom!.type == .publicRoom && room?.channelRoom?.publicExtra?.username == channelLinkTextField.text {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        if let channelUserName = channelLinkTextField.text {
            if channelUserName == "" {
                let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_FORM".localizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                self.hud.hide(animated: true)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if channelUserName.count < 5 {
                let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_MINIMUM_LENGH".localizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                self.hud.hide(animated: true)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelUpdateUsernameRequest.Generator.generate(userName:channelUserName ,room: room!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelUpdateUserName as IGPChannelUpdateUsernameResponse :
                        IGChannelUpdateUsernameRequest.Handler.interpret(response: channelUpdateUserName)
                        _ = self.navigationController?.popViewController(animated: true)
                    default:
                        break
                    }
                    self.hud.hide(animated: true)
                }
            }).error ({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    case .channelUpdateUsernameIsInvalid:
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_INVALID_USERNAME".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameHasAlreadyBeenTakenByAnotherUser:
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_TAKEN_USERNAME".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou:
                        let alert = UIAlertController(title: "Error", message: "More than the allowed usernmae have been selected by you", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameForbidden:
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_UPDATE_USERNAME_FORBIDDEN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameLock:
                        let time = waitTime
                        let remainingMiuntes = time!/60
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_CHANGE_USERNAME_AFTER".localizedNew + " \(remainingMiuntes)" + "MINUTE".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true,completion: nil)
                        break
                        
                    default:
                        break
                    }
                    
                    self.hud.hide(animated: true)
                }
                
            }).send()
        }
    }
    
    func channelLinkDidChanged() {
        if let invitedLink = room?.channelRoom?.privateExtra?.inviteLink {
            if tableView.indexPathForSelectedRow == privateIndexPath {
                tableView.reloadData()
                channelLinkTextField.isUserInteractionEnabled = true
                channelLinkTextField.text = nil
                let channelDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
                channelDefualtName.font = UIFont.systemFont(ofSize: 14)
                channelDefualtName.text = "iGap.net/"
                channelLinkTextField.leftView = channelDefualtName
                channelLinkTextField.leftViewMode = UITextField.ViewMode.always
                channelLinkTextField.placeholder = ""
                channelLinkTextField.delegate = self
            }
            if tableView.indexPathForSelectedRow == publicIndexPath {
                channelLinkTextField.leftView = nil
                channelLinkTextField.text = invitedLink
                channelLinkTextField.isUserInteractionEnabled = false
                channelLinkTextField.delegate = self
                tableView.reloadData()
            }
        }
    }
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
////        let containerView = view as! UITableViewHeaderFooterView
////
////        if section == 1 {
////            containerView.textLabel!.text = "CHANNEL_LINK".localizedNew
////
////        }
////        else {
////            containerView.textLabel!.text = "CHANNELTYPE".localizedNew
////
////        }
////        containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
////        containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedNewDirection)!
////        return containerView
////
////
//    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
        
    }


     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
