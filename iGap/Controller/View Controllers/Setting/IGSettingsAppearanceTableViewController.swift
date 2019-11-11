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
import SnapKit

class IGSettingsAppearanceTableViewController: BaseTableViewController {
    
    @IBOutlet weak var lblInAppBrowser : UILabel!
    @IBOutlet weak var lblStickers : UILabel!
    @IBOutlet weak var lblLightTheme : UILabel!
    @IBOutlet weak var lblDarkTheme : UILabel!
    @IBOutlet weak var lblChatBG : UILabel!
    @IBOutlet weak var oneTo10Slider: TGPDiscreteSlider!
    @IBOutlet weak var switchInAppBrowser: UISwitch!

    @IBOutlet weak var lblMinA : UILabel!
    @IBOutlet weak var lblMaxA : UILabel!
    @IBOutlet weak var lblMessagePreview : UILabel!
    @IBOutlet weak var messageStatusPreview : UILabel!
    @IBOutlet weak var messageTimePreview : UILabel!
    @IBOutlet weak var viewMessagePreview : UIView!
    var userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.semanticContentAttribute = self.semantic
        // MARK: - Change Strings based On Language
        initChangeLang()
        // MARK: - Initialize Default NavigationBar
        initDefaultNav()
        // MARK: - Initialize View
        initView()
        if IGGlobal.isKeyPresentInUserDefaults(key: "textMessagesFontSize")  {
            fontDefaultSize = CGFloat(UserDefaults.standard.float(forKey: "textMessagesFontSize"))
        } else {
            fontDefaultSize = 15.0
        }
        oneTo10Slider.value = fontDefaultSize

        changeMessagePreview(font: fontDefaultSize)

        messageTimePreview.text = messageTimePreview.text?.inLocalizedLanguage()
        lblMessagePreview.textAlignment =  messageTimePreview.localizedDirection
        
    }
    
    func changeMessagePreview(font : CGFloat!) {
        lblMessagePreview.font = UIFont.igFont(ofSize: font)
    }
    
    func initChangeLang() {
        // MARK: - Section 0
        lblChatBG.text = "CHAT_BG".localized
        lblMessagePreview.text = "CHAT_PREVIEW_SAMPLE".localized
        // MARK: - Section 1
        lblDarkTheme.text = "DARK_THEME".localized
        lblLightTheme.text = "LIGHT_THEME".localized
        // MARK: - Section 2
//        lblEnableAnimation.text = "ENABLE_ANIMATIONS".localized
        lblStickers.text = "STICKERS".localized
        lblInAppBrowser.text = "SETTING_PAGE_IN_APP_BROWSER".localized

    }
    func initDefaultNav() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "CHAT_SETTINGS".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    func initView() {
        if self.isRTL {
            lblMinA.font = UIFont.systemFont(ofSize: 20)
            lblMaxA.font = UIFont.systemFont(ofSize: 12)
            viewMessagePreview.layer.cornerRadius = 15.0
            viewMessagePreview.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)

        } else {
            lblMinA.font = UIFont.systemFont(ofSize: 12)
            lblMaxA.font = UIFont.systemFont(ofSize: 20)
            viewMessagePreview.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
        }
        viewMessagePreview.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
        oneTo10Slider.addTarget(self, action: #selector(IGSettingsAppearanceTableViewController.valueChanged(_:event:)), for: .valueChanged)
            if IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
                    switchInAppBrowser.isOn = true
            } else {
                    switchInAppBrowser.isOn = false
            }
    }
    @objc func valueChanged(_ sender: TGPDiscreteSlider, event:UIEvent) {
        print("valueChanged", Double(sender.value))
        UserDefaults.standard.set(sender.value, forKey: "textMessagesFontSize")

        changeMessagePreview(font: sender.value)
    }
    @IBAction func switchInAppBrowser(_ sender: Any) {
        IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: switchInAppBrowser.isOn)

    }
    //MARK: - TableView Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if #available(iOS 13.0, *) {
            return 3
        } else {
            return 3
            // Fallback on earlier versions
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if #available(iOS 13.0, *) {
            switch section {
              case 0:
                  return 3
              case 1:
//                  return 2
                  return 0
              case 2:
                  return 2
              default:
                  return 0
              }
        } else {
            switch section {
              case 0:
                  return 3
              case 1:
                  return 0
              case 2:
                  return 2
              default:
                  return 0
              }
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
                IGGlobal.themeMode = 0
                userDefaults.set(0, forKey: "themeMode")

            }
            else {
                IGGlobal.themeMode = 1
                userDefaults.set(1, forKey: "themeMode")

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
        case 0:
            return 20
        default:
            return 0
        }
    }
    
    //MARK:-HEADER CONFIGS
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedDirection
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
            return "TEXT_SIZE".localized
        case 1:
            if #available(iOS 13.0, *) {
               // return "COLOR_THEME".localized
                return ""

            } else {
                return ""

            }
        case 2:
            return "OTHER".localized
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            if #available(iOS 13.0, *) {

            //return 50
                return 0

            } else {
                return 0
            }
        case 3:
            return 50
        default:
            return 0
        }
    }
    
}
