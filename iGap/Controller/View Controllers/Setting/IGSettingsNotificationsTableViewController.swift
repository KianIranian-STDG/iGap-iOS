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
        initTheme()
    }
    private func initTheme() {
        self.lblPrivateCHats.textColor = ThemeManager.currentTheme.LabelColor
        self.lblGroups.textColor = ThemeManager.currentTheme.LabelColor
        self.lblChannels.textColor = ThemeManager.currentTheme.LabelColor
        self.lblMUtedChats.textColor = ThemeManager.currentTheme.LabelColor
        self.lblEnabled.textColor = ThemeManager.currentTheme.LabelColor
        self.lblCountUnread.textColor = ThemeManager.currentTheme.LabelColor
        self.lblInAppSounds.textColor = ThemeManager.currentTheme.LabelColor
        self.lblInAppVibrate.textColor = ThemeManager.currentTheme.LabelColor
        self.lblInAppPreview.textColor = ThemeManager.currentTheme.LabelColor
        self.lblJoint.textColor = ThemeManager.currentTheme.LabelColor
        self.lblReset.textColor = ThemeManager.currentTheme.LabelColor

        self.switchPrivateChats.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchGroups.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchChannels.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchEnabled.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchIncludeMuted.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchCountUnread.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchInAppSounds.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchInAppVibrate.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchInAppPreview.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.switchJoint.onTintColor = ThemeManager.currentTheme.SliderTintColor

        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        
        
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
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.MessageNotifications.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

    }
    // MARK: - Change Strings Based on App Language
    func initChangeStrings(){
        lblPrivateCHats.text = IGStringsManager.SendMessageSoundAlert.rawValue.localized
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
        default :
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerView.textLabel!.text = IGStringsManager.MessageNotifications.rawValue.localized
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        default :
            containerView.textLabel!.text = ""
            containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
            containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
        }
        
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        
        switch section {
        default :
            break
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
        default :
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 :
            return IGStringsManager.MessageNotifications.rawValue.localized
        default :
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        default :
            return ""
        }
    }
   
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            switch section {
            default :
                return 0
            }
    }
}
