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

class IGSettingPrivacy_SecurityTableViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var lblBlockedUserTitle: UILabel!
    @IBOutlet weak var lblProfilePhotoTitle: UILabel!
    @IBOutlet weak var lblLastSeenTitle: UILabel!
    @IBOutlet weak var lblGroupsTitle: UILabel!
    @IBOutlet weak var lblChannelsTitle: UILabel!
    @IBOutlet weak var lblCallTitle: UILabel!
    @IBOutlet weak var lblActiveSessionsTitle: UILabel!
    @IBOutlet weak var lblTwoStepTitle: UILabel!
    @IBOutlet weak var lblHint: UILabel!

    @IBOutlet weak var AlloLoginSwitch: UISwitch!
    @IBOutlet weak var whoCanSeeProfilePhotoLabel: UILabel!
    @IBOutlet weak var whoCanAddingMeToChannelLabel: UILabel!
    @IBOutlet weak var numberOfBlockedContacts: UILabel!
    @IBOutlet weak var whoCanSeeLastSeenLabel: UILabel!
    @IBOutlet weak var whoCanAddingToGroupLabel: UILabel!
    @IBOutlet weak var whoCanCallMe: UILabel!
    
    
    var selectedIndexPath : IndexPath!
    var hud = MBProgressHUD()
    var blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter("isBlocked == 1" )
    var notificationToken: NotificationToken?
    var notificationToken2: NotificationToken?
    var userPrivacy = try! Realm().objects(IGUserPrivacy.self).filter("primaryKeyId == 1").first
    var allUserPrivacy = try! Realm().objects(IGUserPrivacy.self).filter("primaryKeyId == 1")
    var avatarUserPrivacy : IGPrivacyLevel?
    var lastSeenUserPrivacy: IGPrivacyLevel?
    var groupInviteUserPrivacy: IGPrivacyLevel?
    var channelInviteUserPrivacy: IGPrivacyLevel?
    var callPrivacy: IGPrivacyLevel?
    var twoStepVerification: IGTwoStepVerification?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PS_TTL_PRIVACY".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        fetchBlockedContactsFromServer()
        
        let predicate = NSPredicate(format: "isBlocked == 1")
        blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        numberOfBlockedContacts.text = "\(blockedUsers.count)".inLocalizedLanguage() + "CONTACTS".localized
        
        self.notificationToken = blockedUsers.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_,_,_,_):
                print("updating members tableV")
                self.tableView.reloadData()
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break                
            }
        }
        
        self.notificationToken = allUserPrivacy.observe{ (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_,_,_,_):
                self.showPrivacyInfo()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
        
        showPrivacyInfo()
        requestToGetUserPrivacy()
        initChangeLang()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
        numberOfBlockedContacts.text = "\(blockedUsers.count)" + "CONTACTS".localizedNew
        
        fetchBlockedContactsFromServer()
        showPrivacyInfo()
        initChangeLang()
    }
    func initChangeLang() {
        lblBlockedUserTitle.text = "SETTING_PS_BLOCKED_USERS".localizedNew
        lblProfilePhotoTitle.text = "SETTING_PS_PROFILE_PHOTO".localizedNew
        lblLastSeenTitle.text = "SETTING_PS_LAST_SEEN".localizedNew
        lblGroupsTitle.text = "SETTING_PS_GROUPS".localizedNew
        lblChannelsTitle.text = "SETTING_PS_CHANNELS".localizedNew
        lblCallTitle.text = "SETTING_PS_CALL".localizedNew
        lblGroupsTitle.text = "SETTING_PS_GROUPS".localizedNew
        lblGroupsTitle.text = "SETTING_PS_GROUPS".localizedNew
        lblGroupsTitle.text = "SETTING_PS_GROUPS".localizedNew
        tableView.beginUpdates()
        
        if let containerView = tableView.footerView(forSection: 0) {
            containerView.textLabel!.text = "SETTING_PS_PRIVACY_HINT".localizedNew
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedNewDirection)!
            containerView.sizeToFit()
        }
        if let header = tableView.headerView(forSection: 0) {
            header.textLabel!.text = "SETTING_PS_TTL_PRIVACY".localizedNew
            header.textLabel?.font = UIFont.igFont(ofSize: 15)

            header.sizeToFit()
        }
        if let headerT = tableView.headerView(forSection: 1) {
            headerT.textLabel!.text = "SETTING_PS_TTL_SECURITY".localizedNew
            headerT.textLabel?.font = UIFont.igFont(ofSize: 15)
            headerT.sizeToFit()
        }
        
        tableView.endUpdates()
        lblActiveSessionsTitle.text = "SETTING_PS_ACTIVE_SESSIONS".localizedNew
        lblTwoStepTitle.text = "SETTING_PS_TWO_STEP_VERFI".localizedNew

    }
    
    func showPrivacyInfo(){
        if (userPrivacy == nil || (userPrivacy?.isInvalidated)!) {
            return
        }
        
        setAvatarPrivacy()
        setStatusPrivacy()
        setChannelInvitePrivacy()
        setGroupInvitePrivacy()
        setCallPrivacy()
    }
    
    private func requestToGetUserPrivacy() {
        requestToGetCallPrivacy()
        requestToGetGroupPrivacy()
        requestToGetStatusPrivacy()
        requestToGetAvatarPrivacy()
        requestToGetChannelPrivacy()
    }
    
    private func getUserPrivacy(){
        userPrivacy = try! Realm().objects(IGUserPrivacy.self).filter("primaryKeyId == 1").first
    }
    
    private func setAvatarPrivacy(needUpdate: Bool = false){
        if needUpdate {
            getUserPrivacy()
        }
        if let avatarPrivacy = userPrivacy?.avatar {
            avatarUserPrivacy = avatarPrivacy
            switch  avatarPrivacy{
            case .allowAll:
                whoCanSeeProfilePhotoLabel.text = "EVERYBODY".localizedNew
                break
            case .allowContacts:
                whoCanSeeProfilePhotoLabel.text = "MY_CONTACTS".localizedNew
                break
            case .denyAll:
                whoCanSeeProfilePhotoLabel.text = "NOBODY".localizedNew
                break
            }
        }
    }
    
    private func setStatusPrivacy(needUpdate: Bool = false){
        if needUpdate {
            getUserPrivacy()
        }
        if let userStatePrivacy = userPrivacy?.userStatus {
            lastSeenUserPrivacy = userStatePrivacy
            switch userStatePrivacy {
            case .allowAll:
                whoCanSeeLastSeenLabel.text = "EVERYBODY".localizedNew
                break
            case .allowContacts:
                whoCanSeeLastSeenLabel.text = "MY_CONTACTS".localizedNew
                break
            case .denyAll:
                whoCanSeeLastSeenLabel.text = "NOBODY".localizedNew
                break
            }
        }
    }
    
    private func setChannelInvitePrivacy(needUpdate: Bool = false){
        if needUpdate {
            getUserPrivacy()
        }
        if let channelInvitePrivacy = userPrivacy?.channelInvite {
            channelInviteUserPrivacy = channelInvitePrivacy
            switch channelInvitePrivacy {
                
            case .allowAll:
                whoCanAddingMeToChannelLabel.text = "EVERYBODY".localizedNew
                break
            case .allowContacts:
                whoCanAddingMeToChannelLabel.text = "MY_CONTACTS".localizedNew
                break
            case .denyAll:
                whoCanAddingMeToChannelLabel.text = "NOBODY".localizedNew
                break
            }
        }
    }
    
    private func setGroupInvitePrivacy(needUpdate: Bool = false){
        if needUpdate {
            getUserPrivacy()
        }
        if let groupInvitePrivacy = userPrivacy?.groupInvite {
            groupInviteUserPrivacy = groupInvitePrivacy
            switch groupInvitePrivacy {
            case .allowAll:
                whoCanAddingToGroupLabel.text = "EVERYBODY".localizedNew
                break
            case .allowContacts:
                whoCanAddingToGroupLabel.text = "MY_CONTACTS".localizedNew
                break
            case .denyAll:
                whoCanAddingToGroupLabel.text = "NOBODY".localizedNew
                break
                
            }
        }
    }
    
    private func setCallPrivacy(needUpdate: Bool = false){
        if needUpdate {
            getUserPrivacy()
        }
        if let callPrivacy = userPrivacy?.voiceCalling {
            self.callPrivacy = callPrivacy
            switch callPrivacy {
            case .allowAll:
                whoCanCallMe.text = "EVERYBODY".localizedNew
                break
            case .allowContacts:
                whoCanCallMe.text = "MY_CONTACTS".localizedNew
                break
            case .denyAll:
                whoCanCallMe.text = "NOBODY".localizedNew
                break
            }
        }
    }
    
    private func requestToGetCallPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .voiceCalling).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    let _ = IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .voiceCalling)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.setCallPrivacy(needUpdate: true)
                    }
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.requestToGetCallPrivacy()
                break
            default:
                break
            }
        }).send()
    }
    
    private func requestToGetAvatarPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .avatar).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    let _ = IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .avatar)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.setAvatarPrivacy(needUpdate: true)
                    }
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.requestToGetAvatarPrivacy()
                break
            default:
                break
            }
        }).send()
    }
    
    private func requestToGetStatusPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .userStatus).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    let _ = IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse, privacyType: .userStatus)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.setStatusPrivacy(needUpdate: true)
                    }
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.requestToGetStatusPrivacy()
                break
            default:
                break
            }
        }).send()
    }
    
    private func requestToGetChannelPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .channelInvite).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    let _ = IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse, privacyType: .channelInvite)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.setChannelInvitePrivacy(needUpdate: true)
                    }
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.requestToGetChannelPrivacy()
                break
            default:
                break
            }
        }).send()
    }
    
    private func requestToGetGroupPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .groupInvite).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    let _ = IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .groupInvite)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.setGroupInvitePrivacy(needUpdate: true)
                    }
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.requestToGetGroupPrivacy()
                break
            default:
                break
            }
        }).send()
    }
    
    func fetchBlockedContactsFromServer(){
        IGUserContactsGetBlockedListRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getBlockedListProtoResponse as IGPUserContactsGetBlockedListResponse:
                    IGUserContactsGetBlockedListRequest.Handler.interpret(response: getBlockedListProtoResponse)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 6
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "GoToBlockListPageFromPrivacyAndSecurity", sender: self)
                return
            } else if indexPath.row == 1 {
                if userPrivacy?.avatar == nil {
                    alertWaiting()
                    return
                }
            } else if indexPath.row == 2 {
                if userPrivacy?.userStatus == nil {
                    alertWaiting()
                    return
                }
            } else if indexPath.row == 3 {
                if userPrivacy?.groupInvite == nil {
                    alertWaiting()
                    return
                }
            } else if indexPath.row == 4 {
                if userPrivacy?.channelInvite == nil {
                    alertWaiting()
                    return
                }
            } else if indexPath.row == 4 {
                if userPrivacy?.voiceCalling == nil {
                    alertWaiting()
                    return
                }
            }
            performSegue(withIdentifier: "GoToWhoCanSeeYourPrivacyAndPolicyPage", sender: self)
            
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0 :
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToActiveSessionListPage", sender: self)
            case 1 :
                self.tableView.isUserInteractionEnabled = false
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                IGUserTwoStepVerificationGetPasswordDetailRequest.Generator.generate().success({ (protoResponse) in
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        switch protoResponse {
                        case let getPasswordDetailsResponse as IGPUserTwoStepVerificationGetPasswordDetailResponse:
                            self.twoStepVerification = IGUserTwoStepVerificationGetPasswordDetailRequest.Handler.interpret(response: getPasswordDetailsResponse)
                            self.performSegue(withIdentifier: "ShowTwoStepVerificationPassword", sender: self)
                        default:
                            self.showAlert(title: "GAME_ALERT_TITLE".localizedNew, message: "MSG_BAD_RESPONSE".localizedNew)
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        switch errorCode {
                        case .userTwoStepVerificationGetPasswordDetailsBadPayload:
                            self.showAlert(title: "GAME_ALERT_TITLE".localizedNew, message: "Bad payload")
                        case .userTwoStepVerificationGetPasswordDetailsInternalServerError:
                            self.showAlert(title: "GAME_ALERT_TITLE".localizedNew, message: "Internal Server Error")
                        case .userTwoStepVerificationGetPasswordDetailsForbidden:
                            self.showAlert(title: "GAME_ALERT_TITLE".localizedNew, message: "Forbidden")
                        case .userTwoStepVerificationGetPasswordDetailsNoPassword:
                            self.performSegue(withIdentifier: "GoToTwoStepVerificationPage", sender: self)
                        default:
                            break
                        }
                    }
                }).send()
            case 2 :
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToPassCodeLockSettingsPage", sender: self)
            default:
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "SETTING_PS_PRIVACY_HINT".localizedNew

        }
        else {
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == 0 {
            let containerView = view as! UITableViewHeaderFooterView
            containerView.textLabel!.text = "SETTING_PS_PRIVACY_HINT".localizedNew
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedNewDirection)!
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    private func alertWaiting(){
        let alert = UIAlertController(title: "Please Wait", message: "Please wait for detect your privacy info", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goBackToPrivacyAndSecurityList(seque:UIStoryboardSegue){
        numberOfBlockedContacts.text = "\(blockedUsers.count) ".inLocalizedLanguage() + "USERS".localizedNew
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let whoCanSeeYourPrivacyAndSetting = segue.destination as? IGPrivacyAndSecurityWhoCanSeeTableViewController {
            if selectedIndexPath.section == 0 {
                switch selectedIndexPath.row {
                case 1:
                    whoCanSeeYourPrivacyAndSetting.headerText = "TTL_WHO_CAN_SEE_MY_PROFILE_PHOTO".localizedNew
                    whoCanSeeYourPrivacyAndSetting.mode = "SETTING_PS_PROFILE_PHOTO".localizedNew
                    whoCanSeeYourPrivacyAndSetting.privacyType = .avatar
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = avatarUserPrivacy
                    break
                    
                case 2:
                    whoCanSeeYourPrivacyAndSetting.headerText = "TTL_WHO_CAN_SEE_MY_PLAST_SEEN".localizedNew
                    whoCanSeeYourPrivacyAndSetting.lastSeenFooterText = "MSG_IF_NOT_SHARE_LAST_SEEN".localizedNew
                    whoCanSeeYourPrivacyAndSetting.mode = "SETTING_PS_LAST_SEEN".localizedNew
                    whoCanSeeYourPrivacyAndSetting.privacyType = .userStatus
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = lastSeenUserPrivacy
                    break
                    
                case 3:
                    whoCanSeeYourPrivacyAndSetting.headerText = "TTL_WHO_CAN_ADD_TO_GROUPS".localizedNew
                    whoCanSeeYourPrivacyAndSetting.mode = "TTL_ADDING_ME_TO_GROULS".localizedNew
                    whoCanSeeYourPrivacyAndSetting.privacyType = .groupInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = groupInviteUserPrivacy
                    break
                    
                case 4:
                    whoCanSeeYourPrivacyAndSetting.headerText = "TTL_WHO_CAN_ADD_TO_CHANNNELS".localizedNew
                    whoCanSeeYourPrivacyAndSetting.mode = "TTL_ADDING_ME_TO_CHANNELS".localizedNew
                    whoCanSeeYourPrivacyAndSetting.privacyType = .channelInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = channelInviteUserPrivacy
                    break
                    
                case 5:
                    whoCanSeeYourPrivacyAndSetting.headerText = "TTL_WHO_CAN_CALL".localizedNew
                    whoCanSeeYourPrivacyAndSetting.mode = "SETTING_PS_CALL".localizedNew
                    whoCanSeeYourPrivacyAndSetting.privacyType = .voiceCalling
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = callPrivacy
                    break
                    
                default:
                    break
                }
            }
        } else if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationVerifyPasswordTableViewController {
            destinationVC.twoStepVerification = twoStepVerification
        }
    }
    
}
