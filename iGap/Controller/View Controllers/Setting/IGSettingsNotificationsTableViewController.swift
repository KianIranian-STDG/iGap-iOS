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

class IGSettingsNotificationsTableViewController: UITableViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var lblPrivateCHats : UILabel!
    @IBOutlet weak var lblGroups : UILabel!
    @IBOutlet weak var lblChannels : UILabel!
    @IBOutlet weak var lblEnabled : UILabel!
    @IBOutlet weak var lblMUtedChats : UILabel!
    @IBOutlet weak var lblCountUnread : UILabel!
    @IBOutlet weak var lblInAppSounds : UILabel!
    @IBOutlet weak var lblInAppVibrate : UILabel!
    @IBOutlet weak var lblInAppPreview : UILabel!
    @IBOutlet weak var lblJoint : UILabel!
    @IBOutlet weak var lblReset : UILabel!
    
    @IBOutlet weak var switchPrivateChats: UISwitch!
    @IBOutlet weak var switchGroups: UISwitch!
    @IBOutlet weak var switchChannels: UISwitch!
    @IBOutlet weak var switchEnabled: UISwitch!
    @IBOutlet weak var switchIncludeMuted: UISwitch!
    @IBOutlet weak var switchCountUnread: UISwitch!
    @IBOutlet weak var switchInAppSounds: UISwitch!
    @IBOutlet weak var switchInAppVibrate: UISwitch!
    @IBOutlet weak var switchInAppPreview: UISwitch!
    @IBOutlet weak var switchJoint: UISwitch!
    var userDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        initChangeStrings()
        initSwitched()
        
    }
    private func initSwitched() {
        //privateChat switch
            switchPrivateChats.isOn = IGGlobal.isSilent
    }
    //MARK: - Actions
    @IBAction func privateChatSwitch(_ sender: UISwitch) {
        IGGlobal.isSilent = !(sender.isOn)
            userDefaults.set(sender.isOn, forKey: "silentPrivateChat")
    }
    
    // MARK: - initializing Navigation Bar with items in it
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "MESSAGE_NOTIFICATIONS".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

    }
    // MARK: - Change Strings Based on App Language
    func initChangeStrings(){
        lblPrivateCHats.text = "SETTING_SOUND_SEND_MESSAGE".localized
        lblGroups.text = "NOTIFI_GROUPS".localized
        lblChannels.text = "NOTIFI_CHANNELS".localized
        lblEnabled.text = "NOTIFI_ENABLED".localized
        lblMUtedChats.text = "NOTIFI_INCLUDE_MUTED_CHATS".localized
        lblCountUnread.text = "NOTIFI_COUNT_UNREAD_MESSAGE".localized
        lblInAppSounds.text = "NOTIFI_IN_APP_SOUNDS".localized
        lblInAppVibrate.text = "NOTIFI_IN_APP_VIBRATE".localized
        lblInAppPreview.text = "NOTIFI_IN_APP_PREVIEW".localized
        lblJoint.text = "NOTIFI_NEW_CONTACTS".localized
        lblReset.text = "NOTIFI_RESET".localized

        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//      return 5
        //Hint: uncomment above line if the settings were available
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0 :
            return 1
        case 1 :
            return 3
        case 2 :
            return 3
        case 3 :
            return 1
        case 4 :
            return 1
        default :
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerView.textLabel!.text = "MESSAGE_NOTIFICATIONS".localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        case 1 :
            containerView.textLabel!.text = "BADGE_COUNTER".localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        case 2 :
            containerView.textLabel!.text = "IN_APP_NOTIFICATIONS".localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        case 3 :
            containerView.textLabel!.text = "EVENTS".localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        case 4 :
            containerView.textLabel!.text = "RESET".localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        default :
            containerView.textLabel!.text = "SETTING_PS_TV_TTL".localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        }
        
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            break
        case 1 :
           break
        case 2 :
           break
        case 3 :
            containerFooterView.textLabel!.text = "NOTIFI_EVENTS_FOOTER".localized
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerFooterView.textLabel?.textAlignment = (containerFooterView.textLabel?.localizedDirection)!
        case 4 :
           break
        default :
            break
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
        case 0 :
            return 50
        case 1 :
            return 50
        case 2 :
            return 50
        case 3 :
            return 50
        case 4 :
            return 50
        default :
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 :
            return "MESSAGE_NOTIFICATIONS".localized
        case 1 :
            return "BADGE_COUNTER".localized
        case 2 :
            return "IN_APP_NOTIFICATIONS".localized
        case 3 :
            return "EVENTS".localized
        case 4 :
            return "RESET".localized
        default :
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0 :
            return ""
        case 1 :
            return ""
        case 2 :
            return ""
        case 3 :
            return "NOTIFI_EVENTS_FOOTER".localized
        case 4 :
            return ""
        default :
            return ""
        }
    }
   
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            switch section {
            case 0 :
                return 0
            case 1 :
                return 0
            case 2 :
                return 0
            case 3 :
                return 50
            case 4 :
                return 0
            default :
                return 0
            }
    }
}
