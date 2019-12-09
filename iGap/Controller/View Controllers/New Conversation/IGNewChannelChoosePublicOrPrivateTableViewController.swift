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
        tableView.sectionIndexBackgroundColor = ThemeManager.currentTheme.LabelColor
        tableView.contentInset = UIEdgeInsets.init(top: -1.0, left: 0, bottom: 0, right: 0)
        
        privateChannelCell.selectionStyle = UITableViewCell.SelectionStyle.none
        publicChannelCell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        initView()
        setNavigation()
    }
    private func initView() {
        lblPublicChannel.text = IGStringsManager.PublicChannel.rawValue.localized
        lblPrivateChannel.text = IGStringsManager.PrivateChannel.rawValue.localized
        lblPublicChannelDesc.text = IGStringsManager.PublicChannelDesc.rawValue.localized
        lblPrivateChannelDesc.text = IGStringsManager.PrivateChannelDesc.rawValue.localized
        lblChannelLink.text = IGStringsManager.ChannelLink.rawValue.localized

        
        lblPublicChannel.font = UIFont.igFont(ofSize: 17,weight: .bold)
        lblChannelLink.font = UIFont.igFont(ofSize: 17,weight: .bold)
        lblPrivateChannel.font = UIFont.igFont(ofSize: 17,weight: .bold)
        lblPublicChannelDesc.font = UIFont.igFont(ofSize: 13)
        lblPrivateChannelDesc.font = UIFont.igFont(ofSize: 13)
        lblFooter.font = UIFont.igFont(ofSize: 12)
        lblFooter.textAlignment = lblFooter.localizedDirection
        lblPrivateChannel.textAlignment = lblPrivateChannel.localizedDirection
        lblPublicChannel.textAlignment = lblPublicChannel.localizedDirection
        lblPrivateChannelDesc.textAlignment = lblPrivateChannelDesc.localizedDirection
        lblPublicChannelDesc.textAlignment = lblPublicChannelDesc.localizedDirection
        lblChannelLink.textAlignment = lblChannelLink.localizedDirection
    }
    
    private func setNavigation(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalNext.rawValue.localized, title: IGStringsManager.NewChannel.rawValue.localized)

        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.hidesBackButton = true
        navigationItem.rightViewContainer?.addAction {
            if self.radioButtonController?.selectedButton() == self.publicChannelButton {
                self.convertChannelToPublic()
            } else {
                let profile = IGMemberAddOrUpdateState.instantiateFromAppStroryboard(appStoryboard: .Profile)
                profile.room = IGRoom(igpRoom: self.igpRoom!)
                profile.mode = "CreateChannel"
                profile.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(profile, animated: true)
            }
        }
    }
    
    func convertChannelToPublic() {
        if let channelUserName = channelLinkTextField.text {
            if channelUserName == "" {
                let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalCheckFields.rawValue.localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                alert.addAction(okAction)
                self.hud.hide(animated: true)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if channelUserName.count < 5 {
                let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalMinimumLetters.rawValue.localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
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
                        let profile = IGMemberAddOrUpdateState.instantiateFromAppStroryboard(appStoryboard: .Profile)
                        profile.room = IGRoom(igpRoom: self.igpRoom!)
                        profile.mode = "CreateChannel"
                        profile.hidesBottomBarWhenPushed = true
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
                        break
                    case .channelUpdateUsernameIsInvalid:
                        IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.InvalidUserName.rawValue.localized, cancelText: IGStringsManager.GlobalOK.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameHasAlreadyBeenTakenByAnotherUser:
                        
                        IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AlreadyTakenUserName.rawValue.localized, cancelText: IGStringsManager.GlobalOK.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou:
                        IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "More than the allowed usernmae have been selected by you", cancelText: IGStringsManager.GlobalOK.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameForbidden:
                        IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.MSGUpdateUserNameForbidden.rawValue.localized, cancelText: IGStringsManager.GlobalOK.rawValue.localized)

                        
                        break
                        
                    case .channelUpdateUsernameLock:
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
                        self.channelLinkTextField.textColor = ThemeManager.currentTheme.LabelColor
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

                    break
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
            lblFooter.text = IGStringsManager.NewChannelPrivateFooterHint.rawValue.localized

            channelLinkTextField.delegate = self
            tableView.reloadData()
            
        } else if radioButtonController?.selectedButton() == privateChannel {
            channelLinkTextField.leftView = nil
            channelLinkTextField.text = invitedLink
            channelLinkTextField.textColor = ThemeManager.currentTheme.LabelColor
            channelLinkTextField.isUserInteractionEnabled = false
            lblFooter.text = IGStringsManager.NewChannelPrivateFooterHint.rawValue.localized

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
        let destinationVC = segue.destination as! IGMemberAddOrUpdateState
        destinationVC.room = IGRoom(igpRoom: self.igpRoom!)
        destinationVC.mode = "CreateChannel"
    }

}
