//
//  IGSettingsAppearanceTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/28/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SnapKit

class IGSettingsAppearanceTableViewController: UITableViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblInAppBrowser : UILabel!
    @IBOutlet weak var lblEnableAnimation : UILabel!
    @IBOutlet weak var lblStickers : UILabel!
    @IBOutlet weak var lblLightTheme : UILabel!
    @IBOutlet weak var lblDarkTheme : UILabel!
    @IBOutlet weak var lblChatBG : UILabel!
    @IBOutlet weak var oneTo10Slider: TGPDiscreteSlider!
    @IBOutlet weak var switchInAppBrowser: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Change Strings based On Language
        initChangeLang()
        // MARK: - Initialize Default NavigationBar
        initDefaultNav()
        // MARK: - Initialize View
        initView()

        
    }
    func initChangeLang() {
        // MARK: - Section 0
        lblChatBG.text = "CHAT_BG".localizedNew
        // MARK: - Section 1
        lblDarkTheme.text = "DARK_THEME".localizedNew
        lblLightTheme.text = "LIGHT_THEME".localizedNew
        // MARK: - Section 2
        lblEnableAnimation.text = "ENABLE_ANIMATIONS".localizedNew
        lblStickers.text = "STICKERS".localizedNew
        lblInAppBrowser.text = "SETTING_PAGE_IN_APP_BROWSER".localizedNew

    }
    func initDefaultNav() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "NOTIFICATION_SOUNDS".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    func initView() {
        oneTo10Slider.addTarget(self, action: #selector(IGSettingsAppearanceTableViewController.valueChanged(_:event:)), for: .valueChanged)
            if IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
                    switchInAppBrowser.isOn = true
            } else {
                    switchInAppBrowser.isOn = false
            }
    }
    @objc func valueChanged(_ sender: TGPDiscreteSlider, event:UIEvent) {
        print("valueChanged", Double(sender.value))
    }
    @IBAction func switchInAppBrowser(_ sender: Any) {
        IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: switchInAppBrowser.isOn)

    }
    //MARK: - TableView Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 3
        default:
            return 0
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
//                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "showWallpaperOptionPage", sender: self)

            }
        case 1:
            if indexPath.row == 1 {
                
            }
            else {
                
            }
        case 2:
            if indexPath.row == 2 {
                
            }
        default:
            break
        }
    }
    //MARK:- FOOTER CONFIGS
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        
        switch section {
        default :
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        default:
            return 0
        }
    }
    //MARK:-HEADER CONFIGS
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0  :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 1 :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 2 :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
        default :
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "TEXT_SIZE".localizedNew
        case 1:
            return "COLOR_THEME".localizedNew
        case 2:
            return "OTHER".localizedNew
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            return 50
        default:
            return 0
        }
    }
    
}
