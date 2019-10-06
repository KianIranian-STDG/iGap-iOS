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
import IGProtoBuff
import MBProgressHUD

class IGNewChannelChoosePublicOrPrivateTableViewController: BaseTableViewController, UITextFieldDelegate, SSRadioButtonControllerDelegate {
    fileprivate let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var publicChannelButton: SSRadioButton!
    @IBOutlet weak var privateChannel: SSRadioButton!
    @IBOutlet weak var channelLinkTextField: UITextField!
    var radioButtonController: SSRadioButtonsController?
    @IBOutlet weak var privateChannelCell: UITableViewCell!
    @IBOutlet weak var publicChannelCell: UITableViewCell!
    @IBOutlet weak var channelNameEntryCell: UITableViewCell!
    @IBOutlet weak var lblPrivateChannel: UILabel!
    @IBOutlet weak var lblChannelLink: UILabel!
    @IBOutlet weak var lblPrivateChannelDesc: UILabel!
    @IBOutlet weak var lblPublicChannel: UILabel!
    @IBOutlet weak var lblPublicChannelDesc: UILabel!
    @IBOutlet weak var lblFooter: UILabel!
    var invitedLink: String?
    var igpRoom : IGPRoom!
    var hud = MBProgressHUD()
    
    @IBAction func edtTextChange(_ sender: UITextField) {
        if let text = sender.text {
            if text.count >= 5 {
                checkUsername(username: sender.text!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioButtonController = SSRadioButtonsController(buttons: publicChannelButton, privateChannel)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        
        radioButtonController?.pressed(privateChannel)
        
        channelLinkTextField.delegate = self
        channelLinkTextField.text = invitedLink
        channelLinkTextField.isUserInteractionEnabled = false
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.sectionIndexBackgroundColor = UIColor(named: themeColor.labelColor.rawValue)
        tableView.contentInset = UIEdgeInsets.init(top: -1.0, left: 0, bottom: 0, right: 0)
        
        privateChannelCell.selectionStyle = UITableViewCell.SelectionStyle.none
        publicChannelCell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        initView()
        setNavigation()
    }
    private func initView() {
        lblPublicChannel.text = "MSG_NEW_CHANNEL_PUBLIC_CHANNEL_TITLE".localizedNew
        lblPrivateChannel.text = "MSG_NEW_CHANNEL_PRIVATE_CHANNEL_TITLE".localizedNew
        lblPublicChannelDesc.text = "MSG_NEW_CHANNEL_PUBLIC_CHANNEL_DESC".localizedNew
        lblPrivateChannelDesc.text = "MSG_NEW_CHANNEL_PRIVATE_CHANNEL_DESC".localizedNew
        lblChannelLink.text = "NEW_CHANNEL_LINK".localizedNew

        
        lblPublicChannel.font = UIFont.igFont(ofSize: 17,weight: .bold)
        lblChannelLink.font = UIFont.igFont(ofSize: 17,weight: .bold)
        lblPrivateChannel.font = UIFont.igFont(ofSize: 17,weight: .bold)
        lblPublicChannelDesc.font = UIFont.igFont(ofSize: 13)
        lblPrivateChannelDesc.font = UIFont.igFont(ofSize: 13)
        lblFooter.font = UIFont.igFont(ofSize: 12)
        lblFooter.textAlignment = lblFooter.localizedNewDirection
        lblPrivateChannel.textAlignment = lblPrivateChannel.localizedNewDirection
        lblPublicChannel.textAlignment = lblPublicChannel.localizedNewDirection
        lblPrivateChannelDesc.textAlignment = lblPrivateChannelDesc.localizedNewDirection
        lblPublicChannelDesc.textAlignment = lblPublicChannelDesc.localizedNewDirection
        lblChannelLink.textAlignment = lblChannelLink.localizedNewDirection
    }
    
    private func setNavigation(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "NEXT_BTN".localizedNew, title: "NEW_CHANNEL".localizedNew)

        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.hidesBackButton = true
        navigationItem.rightViewContainer?.addAction {
            if self.radioButtonController?.selectedButton() == self.publicChannelButton {
                self.convertChannelToPublic()
            } else {
                //self.performSegue(withIdentifier: "GoToChooseMemberFromContactPage", sender: self)
                let profile = IGChooseMemberFromContactToCreateChannelViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                profile.igpRoom = self.igpRoom
                profile.mode = "CreateChannel"
                self.navigationController!.pushViewController(profile, animated: true)
            }
        }
    }
    
    func convertChannelToPublic() {
        if let channelUserName = channelLinkTextField.text {
            if channelUserName == "" {
                let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "CHECK_ALL_FIELDS".localizedNew, preferredStyle: .alert)
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
            IGChannelUpdateUsernameRequest.Generator.generate(roomId:igpRoom.igpID ,username:channelUserName).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case is IGPChannelUpdateUsernameResponse :
                        //self.performSegue(withIdentifier: "GoToChooseMemberFromContactPage", sender: self)
                        let profile = IGChooseMemberFromContactToCreateChannelViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                        profile.igpRoom = self.igpRoom
                        profile.mode = "CreateChannel"
                        self.navigationController!.pushViewController(profile, animated: true)
                        break
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
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "More than the allowed usernmae have been selected by you", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
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
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_CHANGE_USERNAME_AFTER".localizedNew +  "\(remainingMiuntes)".inLocalizedLanguage() + "MINUTE".localizedNew, preferredStyle: .alert)
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
    
    func checkUsername(username: String){
        IGChannelCheckUsernameRequest.Generator.generate(roomId:igpRoom.igpID ,username: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let usernameResponse as IGPChannelCheckUsernameResponse :
                    if usernameResponse.igpStatus == IGPChannelCheckUsernameResponse.IGPStatus.available {
                        self.channelLinkTextField.textColor = UIColor(named: themeColor.labelColor.rawValue)
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
    
    func didSelectButton(_ aButton: UIButton?) {
        if radioButtonController?.selectedButton() == publicChannelButton {
            channelLinkTextField.isUserInteractionEnabled = true
            channelLinkTextField.text = nil
            let channelDefualtName = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
            channelDefualtName.font = UIFont.systemFont(ofSize: 14)
            channelDefualtName.text = "iGap.net/"
            channelLinkTextField.leftView = channelDefualtName
            channelLinkTextField.leftViewMode = UITextField.ViewMode.always
            channelLinkTextField.placeholder = "yourlink"
            lblFooter.text = "MSG_CHANNEL_SHARE_FOOTER".localizedNew

            channelLinkTextField.delegate = self
            tableView.reloadData()
            
        } else if radioButtonController?.selectedButton() == privateChannel {
            channelLinkTextField.leftView = nil
            channelLinkTextField.text = invitedLink
            channelLinkTextField.textColor = UIColor(named: themeColor.labelColor.rawValue)
            channelLinkTextField.isUserInteractionEnabled = false
            lblFooter.text = "MSG_CHANNEL_SHARE_JOIN".localizedNew

            channelLinkTextField.delegate = self
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 2
        case 1:
            numberOfRows = 2
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                radioButtonController?.pressed(publicChannelButton)
            } else {
                radioButtonController?.pressed(privateChannel)
            }
            didSelectButton(radioButtonController?.selectedButton())
        }
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerText : String = ""
        if section == 0 {
            headerText = ""
            
        }
        if section == 1{
            headerText = "   "
        }
        return headerText
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHieght : CGFloat = 0
        if section == 0 {
            headerHieght = CGFloat.leastNonzeroMagnitude
        }
        if section == 1 {
            headerHieght = 0
        }
        return headerHieght
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! IGChooseMemberFromContactToCreateChannelViewController
        destinationVC.igpRoom = igpRoom
        destinationVC.mode = "CreateChannel"
    }

}
