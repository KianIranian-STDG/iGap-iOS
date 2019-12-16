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

class IGSettingPrivacy_SecurityTableViewController: BaseTableViewController {
    
    @IBOutlet weak var lblBlockedUserTitle: UILabel!
    @IBOutlet weak var lblProfilePhotoTitle: UILabel!
    @IBOutlet weak var lblLastSeenTitle: UILabel!
    @IBOutlet weak var lblGroupsTitle: UILabel!
    @IBOutlet weak var lblChannelsTitle: UILabel!
    @IBOutlet weak var lblCallTitle: UILabel!
    @IBOutlet weak var lblVideoCallTitle: UILabel!
    @IBOutlet weak var lblActiveSessionsTitle: UILabel!
    @IBOutlet weak var lblTwoStepTitle: UILabel!
    @IBOutlet weak var lblHint: UILabel!
    
    @IBOutlet  var arrayLabels: [UILabel]!
    @IBOutlet weak var whoCanSeeProfilePhotoLabel: UILabel!
    @IBOutlet weak var whoCanAddingMeToChannelLabel: UILabel!
    @IBOutlet weak var numberOfBlockedContacts: UILabel!
    @IBOutlet weak var whoCanSeeLastSeenLabel: UILabel!
    @IBOutlet weak var whoCanAddingToGroupLabel: UILabel!
    @IBOutlet weak var whoCanCallMe: UILabel!
    @IBOutlet weak var whoCanVideoCallMe: UILabel!
    @IBOutlet weak var lblIfAway : UILabel!
    @IBOutlet weak var lblDeleteAllCloud : UILabel!
    @IBOutlet weak var lblDeleteSyncedContacts : UILabel!
    @IBOutlet weak var lblClearPayments : UILabel!
    @IBOutlet weak var lblSyncContacts : UILabel!
    @IBOutlet weak var lblSecretChatLink : UILabel!
    @IBOutlet weak var selfDestructionLabel : UILabel!
    @IBOutlet weak var lblPasscode : UILabel!
    
    private func initTheme() {
        self.lblBlockedUserTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblLastSeenTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblProfilePhotoTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblGroupsTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblChannelsTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblCallTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblVideoCallTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblActiveSessionsTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.lblTwoStepTitle.textColor = ThemeManager.currentTheme.LabelColor
        self.whoCanSeeProfilePhotoLabel.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.whoCanAddingMeToChannelLabel.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.numberOfBlockedContacts.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.whoCanSeeLastSeenLabel.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.whoCanAddingToGroupLabel.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.whoCanCallMe.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.whoCanVideoCallMe.textColor = ThemeManager.currentTheme.LabelGrayColor
        self.lblIfAway.textColor = ThemeManager.currentTheme.LabelColor
        self.selfDestructionLabel.textColor = ThemeManager.currentTheme.LabelColor
        self.lblSecretChatLink.textColor = ThemeManager.currentTheme.LabelColor
        self.lblClearPayments.textColor = ThemeManager.currentTheme.LabelColor
        self.lblSyncContacts.textColor = ThemeManager.currentTheme.LabelColor
        self.lblDeleteSyncedContacts.textColor = ThemeManager.currentTheme.LabelColor
        self.lblDeleteAllCloud.textColor = ThemeManager.currentTheme.LabelColor
        self.lblPasscode.textColor = ThemeManager.currentTheme.LabelColor

    }
    
    
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
    var currentUser: IGRegisteredUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initChangeLang()
        
        showAccountDetail()
        
        //        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.PrivacyPolicy.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        fetchBlockedContactsFromServer()
        
        let predicate = NSPredicate(format: "isBlocked == 1")
        blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        //        numberOfBlockedContacts.text = "\(blockedUsers.count)".inLocalizedLanguage() + IGStringsManager.Contacts.rawValue.localized
        numberOfBlockedContacts.isHidden = true
        if currentUser.selfRemove == -1 {
            getSelfRemove()
        }
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
        initTheme()
    }
    
    
    func getSelfRemove() {
        IGUserProfileGetSelfRemoveRequest.Generator.generate().success({ (protoResponse) in
            switch protoResponse {
            case let response as IGPUserProfileGetSelfRemoveResponse:
                IGUserProfileGetSelfRemoveRequest.Handler.interpret(response: response)
            default:
                break
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                break
            default:
                break
            }
            
        }).send()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
        //        numberOfBlockedContacts.text = "\(blockedUsers.count)" + IGStringsManager.Contacts.rawValue.localized
        fetchBlockedContactsFromServer()
        showPrivacyInfo()
        initChangeLang()
    }
    
    //MARK: Account details
    func showAccountDetail(){
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        currentUser = realm.objects(IGRegisteredUser.self).filter(predicate).first!
        self.updateUI()
        notificationToken = currentUser.observe({ (changes: ObjectChange) in
            switch changes {
            case .change(_):
                self.updateUI()
            default:
                break
            }
            
        })
    }
    
    func updateUI() {
        print(self.currentUser.selfRemove)
        
        DispatchQueue.main.async {
            print("self.currentUser.selfRemove",self.currentUser.selfRemove)
            
            if self.currentUser.selfRemove == -1 {
                self.selfDestructionLabel.text = ""
            } else if self.currentUser.selfRemove == 12 {
                self.selfDestructionLabel.text = "1 " + IGStringsManager.Year.rawValue.localized
            } else if self.currentUser.selfRemove == 1 {
                self.selfDestructionLabel.text = "\(self.currentUser.selfRemove)" + IGStringsManager.Month.rawValue.localized
            } else {
                self.selfDestructionLabel.text = "\(self.currentUser.selfRemove)" + IGStringsManager.Month.rawValue.localized
            }
        }
    }
    func initChangeLang() {
        lblBlockedUserTitle.text = IGStringsManager.ListOfBlockedUsers.rawValue.localized
        lblProfilePhotoTitle.text = IGStringsManager.ProfilePhoto.rawValue.localized
        lblLastSeenTitle.text = IGStringsManager.LastSeen.rawValue.localized
        lblGroupsTitle.text = IGStringsManager.Groups.rawValue.localized
        lblChannelsTitle.text = IGStringsManager.Channels.rawValue.localized
        lblCallTitle.text = IGStringsManager.VoiceCall.rawValue.localized
        lblVideoCallTitle.text = IGStringsManager.VideoCall.rawValue.localized
        lblGroupsTitle.text = IGStringsManager.Groups.rawValue.localized
        lblGroupsTitle.text = IGStringsManager.Groups.rawValue.localized
        lblGroupsTitle.text = IGStringsManager.Groups.rawValue.localized
        lblActiveSessionsTitle.text = IGStringsManager.ActiveSessions.rawValue.localized
        lblTwoStepTitle.text = IGStringsManager.TwoSteps.rawValue.localized
        lblIfAway.text = IGStringsManager.IfAwayFor.rawValue.localized
        
        
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
        setVideoCallPrivacy()
    }
    
    private func requestToGetUserPrivacy() {
        requestToGetCallPrivacy()
        requestToGetVideoCallPrivacy()
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
                whoCanSeeProfilePhotoLabel.text = IGStringsManager.Everbody.rawValue.localized
                break
            case .allowContacts:
                whoCanSeeProfilePhotoLabel.text = IGStringsManager.MyContacts.rawValue.localized
                break
            case .denyAll:
                whoCanSeeProfilePhotoLabel.text = IGStringsManager.Nobody.rawValue.localized
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
                whoCanSeeLastSeenLabel.text = IGStringsManager.Everbody.rawValue.localized
                break
            case .allowContacts:
                whoCanSeeLastSeenLabel.text = IGStringsManager.MyContacts.rawValue.localized
                break
            case .denyAll:
                whoCanSeeLastSeenLabel.text = IGStringsManager.Nobody.rawValue.localized
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
                whoCanAddingMeToChannelLabel.text = IGStringsManager.Everbody.rawValue.localized
                break
            case .allowContacts:
                whoCanAddingMeToChannelLabel.text = IGStringsManager.MyContacts.rawValue.localized
                break
            case .denyAll:
                whoCanAddingMeToChannelLabel.text = IGStringsManager.Nobody.rawValue.localized
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
                whoCanAddingToGroupLabel.text = IGStringsManager.Everbody.rawValue.localized
                break
            case .allowContacts:
                whoCanAddingToGroupLabel.text = IGStringsManager.MyContacts.rawValue.localized
                break
            case .denyAll:
                whoCanAddingToGroupLabel.text = IGStringsManager.Nobody.rawValue.localized
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
                whoCanCallMe.text = IGStringsManager.Everbody.rawValue.localized
                break
            case .allowContacts:
                whoCanCallMe.text = IGStringsManager.MyContacts.rawValue.localized
                break
            case .denyAll:
                whoCanCallMe.text = IGStringsManager.Nobody.rawValue.localized
                break
            }
        }
    }
    
    private func setVideoCallPrivacy(needUpdate: Bool = false){
        if needUpdate {
            getUserPrivacy()
        }
        if let callPrivacy = userPrivacy?.videoCalling {
            self.callPrivacy = callPrivacy
            switch callPrivacy {
            case .allowAll:
                whoCanVideoCallMe.text = IGStringsManager.Everbody.rawValue.localized
                break
            case .allowContacts:
                whoCanVideoCallMe.text = IGStringsManager.MyContacts.rawValue.localized
                break
            case .denyAll:
                whoCanVideoCallMe.text = IGStringsManager.Nobody.rawValue.localized
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
    
    private func requestToGetVideoCallPrivacy() {
        IGUserPrivacyGetRuleRequest.Generator.generate(privacyType: .videoCalling).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userPrivacyGetRuleResponse as IGPUserPrivacyGetRuleResponse:
                    let _ = IGUserPrivacyGetRuleRequest.Handler.interpret(response: userPrivacyGetRuleResponse , privacyType: .videoCalling)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        self.setVideoCallPrivacy(needUpdate: true)
                    }
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.requestToGetVideoCallPrivacy()
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
                break
            default:
                break
            }
            
        }).send()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        case 1:
            return 2
        case 2:
            return 1
        case 3:
            return 0
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
            } else if indexPath.row == 5 {
                if userPrivacy?.voiceCalling == nil {
                    alertWaiting()
                    return
                }
            } else if indexPath.row == 6 {
                if userPrivacy?.videoCalling == nil {
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

                            break

                        }
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        switch errorCode {
                        case .userTwoStepVerificationGetPasswordDetailsBadPayload:

                            break
                        case .userTwoStepVerificationGetPasswordDetailsInternalServerError:
                            break

                        case .userTwoStepVerificationGetPasswordDetailsForbidden:
                            break

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
        } else if indexPath.section == 2 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToSelfDestructionTimePage", sender: self)
            
        } else if indexPath.section == 3 {
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedDirection
        
        switch section {
        case 3 :
            containerFooterView.textLabel!.text = IGStringsManager.SelfDestructFooter.rawValue.localized
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerFooterView.sizeToFit()
        case 4 :
            break
            
        default :
            break
            
        }
        
        
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerHeaderView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerHeaderView.textLabel!.text = IGStringsManager.PrivacyPolicy.rawValue.localized
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 1 :
            containerHeaderView.textLabel!.text = IGStringsManager.Security.rawValue.localized
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 2 :
            containerHeaderView.textLabel!.text = IGStringsManager.SelfDestruct.rawValue.localized
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 3 :
            break
        default :
            break
            
        }
        containerHeaderView.textLabel?.textAlignment = containerHeaderView.textLabel!.localizedDirection
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return IGStringsManager.PrivacyPolicy.rawValue.localized
        case 1:
            return IGStringsManager.Security.rawValue.localized
        case 2:
            return IGStringsManager.SelfDestruct.rawValue.localized
        case 3:
            return ""
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return ""
        case 1:
            return ""
        case 2:
            return ""
        case 3:
            return IGStringsManager.SelfDestructFooter.rawValue.localized
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 10
        case 1:
            return 10
        case 2:
            return 10
        case 3:
            return 80
        default:
            return 10
        }
    }
    
    
    
    private func alertWaiting(){
    }
    
    @IBAction func goBackToPrivacyAndSecurityList(seque:UIStoryboardSegue){
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let whoCanSeeYourPrivacyAndSetting = segue.destination as? IGPrivacyAndSecurityWhoCanSeeTableViewController {
            if selectedIndexPath.section == 0 {
                switch selectedIndexPath.row {
                case 1:
                    whoCanSeeYourPrivacyAndSetting.headerText = ""
                    whoCanSeeYourPrivacyAndSetting.mode = IGStringsManager.ProfilePhotoCheck.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.privacyType = .avatar
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = avatarUserPrivacy
                    break
                    
                case 2:
                    whoCanSeeYourPrivacyAndSetting.headerText = ""
                    whoCanSeeYourPrivacyAndSetting.lastSeenFooterText = ""
                    whoCanSeeYourPrivacyAndSetting.mode = IGStringsManager.LastSeenCheckBy.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.privacyType = .userStatus
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = lastSeenUserPrivacy
                    break
                    
                case 3:
                    whoCanSeeYourPrivacyAndSetting.headerText = IGStringsManager.WhoCanInviteToGroups.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.mode = IGStringsManager.WhoCanInviteToGroups.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.privacyType = .groupInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = groupInviteUserPrivacy
                    break
                    
                case 4:
                    whoCanSeeYourPrivacyAndSetting.headerText = IGStringsManager.WhoCanInviteToChannel.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.mode = IGStringsManager.WhoCanInviteToChannel.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.privacyType = .channelInvite
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = channelInviteUserPrivacy
                    break
                    
                case 5:
                    whoCanSeeYourPrivacyAndSetting.headerText = IGStringsManager.WhoCanVoiceCall.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.mode = IGStringsManager.CALL.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.privacyType = .voiceCalling
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = callPrivacy
                    break
                case 6:
                    whoCanSeeYourPrivacyAndSetting.headerText = IGStringsManager.WhoCanVoiceCall.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.mode = IGStringsManager.CALL.rawValue.localized
                    whoCanSeeYourPrivacyAndSetting.privacyType = .videoCalling
                    whoCanSeeYourPrivacyAndSetting.privacyLevel = callPrivacy
                    break
                    
                default:
                    break
                }
            }
        } else if let destinationVC = segue.destination as? IGSettingPrivacyAndSecurityTwoStepVerificationVerifyPasswordTableViewController {
            destinationVC.twoStepVerification = twoStepVerification
        }
        else if let selfDestructionVC = segue.destination as? IGSettingHaveCheckmarkOntheLeftTableViewController {
            selfDestructionVC.items = [1, 3, 6, 12]
            selfDestructionVC.mode = "Self-Destruction"
            selfDestructionVC.modeT = IGStringsManager.SelfDestruct.rawValue.localized
            
        }
    }
    
}
