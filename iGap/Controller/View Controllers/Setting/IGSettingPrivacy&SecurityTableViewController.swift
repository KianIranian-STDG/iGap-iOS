/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import RealmSwift
import MBProgressHUD
import IGProtoBuff

class IGSettingPrivacy_SecurityTableViewController: UITableViewController, UIGestureRecognizerDelegate {

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
        
        self.tableView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Privacy & Security")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        fetchBlockedContactsFromServer()
        
        let predicate = NSPredicate(format: "isBlocked == 1")
        blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        numberOfBlockedContacts.text = "\(blockedUsers.count) users"
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
        numberOfBlockedContacts.text = "\(blockedUsers.count) Contact "
        
        fetchBlockedContactsFromServer()
        showPrivacyInfo()
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
                whoCanSeeProfilePhotoLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanSeeProfilePhotoLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanSeeProfilePhotoLabel.text = "Nobody"
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
                whoCanSeeLastSeenLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanSeeLastSeenLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanSeeLastSeenLabel.text = "Nobody"
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
                whoCanAddingMeToChannelLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanAddingMeToChannelLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanAddingMeToChannelLabel.text = "Nobody"
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
                whoCanAddingToGroupLabel.text = "Everybody"
                break
            case .allowContacts:
                whoCanAddingToGroupLabel.text = "My Contacts"
                break
            case .denyAll:
                whoCanAddingToGroupLabel.text = "Nobody"
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
                whoCanCallMe.text = "Everybody"
                break
            case .allowContacts:
                whoCanCallMe.text = "My Contacts"
                break
            case .denyAll:
                whoCanCallMe.text = "Nobody"
                break
            }
        }
    }
    
    private func requestToGetCallPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .voiceCalling).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .voiceCalling)
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
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .avatar)
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
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse, privacyType: .userStatus)
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
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse, privacyType: .channelInvite)
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
                    IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .groupInvite)
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
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                            self.showAlert(title: "Alert", message: "Bad response")
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        switch errorCode {
                        case .userTwoStepVerificationGetPasswordDetailsBadPayload:
                            self.showAlert(title: "Alert", message: "Bad payload")
                        case .userTwoStepVerificationGetPasswordDetailsInternalServerError:
                            self.showAlert(title: "Alert", message: "Internal Server Error")
                        case .userTwoStepVerificationGetPasswordDetailsForbidden:
                            self.showAlert(title: "Alert", message: "Forbidden")
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

    private func alertWaiting(){
        let alert = UIAlertController(title: "Please Wait", message: "Please wait for detect your privacy info", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func goBackToPrivacyAndSecurityList(seque:UIStoryboardSegue){
        numberOfBlockedContacts.text = "\(blockedUsers.count) users"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let whoCanSeeYourPrivacyAndSetting = segue.destination as? IGPrivacyAndSecurityWhoCanSeeTableViewController {
            if selectedIndexPath.section == 0 {
                switch selectedIndexPath.row {
                case 1:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can see my Profile Photo"
                    whoCanSeeYourPrivacyAndSetting.mode = "Profile Photo"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .avatar
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = avatarUserPrivacy
                    break
                    
                case 2:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can see my Last Seen"
                    whoCanSeeYourPrivacyAndSetting.lastSeenFooterText = "If you don't share your Last Seen , you won't be able to see people's Last Seen "
                    whoCanSeeYourPrivacyAndSetting.mode = "Last Seen"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .userStatus
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = lastSeenUserPrivacy
                    break
                    
                case 3:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can adding me to Groups"
                    whoCanSeeYourPrivacyAndSetting.mode = "Adding me to Groups"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .groupInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = groupInviteUserPrivacy
                    break
                    
                case 4:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can adding me to Channels"
                    whoCanSeeYourPrivacyAndSetting.mode = "Adding me to Channels"
                    whoCanSeeYourPrivacyAndSetting.privacyType = .channelInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = channelInviteUserPrivacy
                    break
                    
                case 5:
                    whoCanSeeYourPrivacyAndSetting.headerText = "Who can call me"
                    whoCanSeeYourPrivacyAndSetting.mode = "Call me"
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
