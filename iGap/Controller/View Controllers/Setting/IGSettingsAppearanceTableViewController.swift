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
import SwiftEventBus

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
    
    @IBOutlet weak var lblMessagePreview2 : UILabel!
    @IBOutlet weak var messageStatusPreview2 : UILabel!
    @IBOutlet weak var messageTimePreview2 : UILabel!
    @IBOutlet weak var viewMessagePreview2 : UIView!
    @IBOutlet weak var collectionThemes : UICollectionView!
    @IBOutlet weak var collectionAppIcons : UICollectionView!
    @IBOutlet weak var collectionColorSets : UICollectionView!
    var userDefaults = UserDefaults.standard
    
    var themeTypes = [IGStringsManager.ClassicTheme.rawValue.localized,IGStringsManager.DayTheme.rawValue.localized,IGStringsManager.NightTheme.rawValue.localized]
    var colorSets : [UIColor] = [UIColor(named: "BlueColorSet")!,UIColor(named: "TurquoiseColorSet")!,UIColor(named: "GreenColorSet")!,UIColor(named: "PinkColorSet")!,UIColor(named: "OrangeColorSet")!,UIColor(named: "PurpleColorSet")!,UIColor(named: "RedColorSet")!,UIColor(named: "GoldColorSet")!,UIColor(named: "LightGrayColorSet")!,UIColor(named: "BlackColorSet")!]
    var appIcons : [UIImage] = [UIImage(named: "AppIconOne")!,UIImage(named: "AppIconTwo")!,UIImage(named: "AppIconThree")!,UIImage(named: "AppIconFour")!,UIImage(named: "AppIconFive")!,UIImage(named: "AppIconSix")!]
    var appIconsNames : [String] = ["AppIconOne","AppIconTwo","AppIconThree","AppIconFour","AppIconFive","AppIconSix"]
    var isClassicTheme : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionThemes.delegate = self
        self.collectionThemes.dataSource = self
        self.collectionColorSets.delegate = self
        self.collectionColorSets.dataSource = self
        self.collectionAppIcons.delegate = self
        self.collectionAppIcons.dataSource = self
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
        messageTimePreview2.text = messageTimePreview2.text?.inLocalizedLanguage()
        lblMessagePreview2.textAlignment =  messageTimePreview2.localizedDirection
        selectTheme()
        
    }
    private func changeTheme(themeType: String!) {
        SwiftEventBus.post("ChangeTheme",sender: themeType)
    }
    private func selectTheme() {
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
        switch currentColorSetDark {
        case "IGAPBlue" :
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPTorquoise" :
            let indexPath = IndexPath(item: 1, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPGreen" :
            let indexPath = IndexPath(item: 2, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPPink" :
            let indexPath = IndexPath(item: 3, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPOrange" :
            let indexPath = IndexPath(item: 4, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPPurple" :
            let indexPath = IndexPath(item: 5, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPRed" :
            let indexPath = IndexPath(item: 6, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPGold" :
            let indexPath = IndexPath(item: 7, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPLightGray" :
            let indexPath = IndexPath(item: 8, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPBW" :
            let indexPath = IndexPath(item: 9, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
        default: break
        }
        switch currentColorSetLight {
        case "IGAPBlue" :
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPTorquoise" :
            let indexPath = IndexPath(item: 1, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPGreen" :
            let indexPath = IndexPath(item: 2, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPPink" :
            let indexPath = IndexPath(item: 3, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPOrange" :
            let indexPath = IndexPath(item: 4, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPPurple" :
            let indexPath = IndexPath(item: 5, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPRed" :
            let indexPath = IndexPath(item: 6, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPGold" :
            let indexPath = IndexPath(item: 7, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPLightGray" :
            let indexPath = IndexPath(item: 8, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPBW" :
            let indexPath = IndexPath(item: 9, section: 0)
            self.collectionColorSets.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
        default: break
        }
        switch currentTheme {
            
        case "IGAPClassic" :
            print("CURRENT  IS :","CLASSIC")
            self.isClassicTheme = true
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionThemes.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPDay" :
            print("CURRENT  IS :","DAY")
            self.isClassicTheme = false
            let indexPath = IndexPath(item: 1, section: 0)
            self.collectionThemes.selectItem(at: indexPath, animated: true, scrollPosition: [])
            
            break
        case "IGAPNight" :
            print("CURRENT  IS :","NIGHT")
            self.isClassicTheme = false
            let indexPath = IndexPath(item: 2, section: 0)
            self.collectionThemes.selectItem(at: indexPath, animated: true, scrollPosition: [])
            
            break
            
        default:
            break
        }
    }
    func changeMessagePreview(font : CGFloat!) {
        lblMessagePreview.font = UIFont.igFont(ofSize: font)
        lblMessagePreview2.font = UIFont.igFont(ofSize: font)
    }
    
    func initChangeLang() {
        // MARK: - Section 0
        lblChatBG.text = IGStringsManager.ChatBG.rawValue.localized
        lblMessagePreview.text = IGStringsManager.ChatSample.rawValue.localized
        lblMessagePreview2.text = IGStringsManager.ChatSample2.rawValue.localized
        // MARK: - Section 1
        // MARK: - Section 2
        lblStickers.text = IGStringsManager.Sticker.rawValue.localized
        lblInAppBrowser.text = IGStringsManager.InAppbrowser.rawValue.localized
        
    }
    func initDefaultNav() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.ChatSettings.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    func initView() {
        if self.isRTL {
            lblMinA.font = UIFont.systemFont(ofSize: 20)
            lblMaxA.font = UIFont.systemFont(ofSize: 12)
            viewMessagePreview2.layer.cornerRadius = 15.0
            viewMessagePreview2.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
            
        } else {
            lblMinA.font = UIFont.systemFont(ofSize: 12)
            lblMaxA.font = UIFont.systemFont(ofSize: 20)
            viewMessagePreview2.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
        }
        viewMessagePreview2.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
        
        
        //sample2
        if self.isRTL {
            viewMessagePreview.layer.cornerRadius = 15.0
            viewMessagePreview.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
            
        } else {
            viewMessagePreview.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
        }
        viewMessagePreview.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: true)
        
        
        
        
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
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 {
                //                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "showWallpaperOptionPage", sender: self)
                
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
        default :
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return IGStringsManager.AppIcon.rawValue.localized
        case 2:
            return IGStringsManager.Other.rawValue.localized
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            
        case 1:
            return 50
        case 2:
            return 50
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0 :
            switch indexPath.item {
            case 0 , 1:
                return 44
            case 2 :
                return 224
            case 3 :
                return 108
            case 4 :
                if isClassicTheme {
                    return 0
                } else {
                    return 50
                }
            default:
                return 44
            }
            break
        case 1 :
            return 100
            
        default :
            return 44
            
        }
    }
    
}

/// MARK: - collectionView delegate and datasource
extension IGSettingsAppearanceTableViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionThemes {
            return themeTypes.count
        } else if collectionView == collectionAppIcons {
            return appIcons.count
        } else {
            return colorSets.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionThemes {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGThemeCVCell", for: indexPath) as! IGThemeCVCell
            let current = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            
            cell.lblThemeName.text = themeTypes[indexPath.item]
            
            switch indexPath.item {
            case 0 :
                cell.viewBG.backgroundColor = DefaultColorSet().SettingClassicBG
                cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
                cell.viewReciever.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: true)
                if current == "IGAPClassic" {
                    cell.viewBG.layer.borderColor = UIColor.iGapGreen().cgColor
                } else {
                    cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                    
                }
                
            case 1:
                cell.viewBG.backgroundColor = .white
                cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
                
                cell.viewReciever.backgroundColor = DayColorSetManager.currentColorSet.SettingDayReceiveBubble
                if current == "IGAPDay" {
                    cell.viewBG.layer.borderColor = UIColor.iGapGreen().cgColor
                } else {
                    cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                    
                }
            case 2:
                cell.viewBG.backgroundColor = .black
                cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
                
                cell.viewReciever.backgroundColor = DayColorSetManager.currentColorSet.SettingDayReceiveBubble
                if current == "IGAPNight" {
                    cell.viewBG.layer.borderColor = UIColor.iGapGreen().cgColor
                } else {
                    cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                    
                }
            default :
                cell.viewBG.backgroundColor = ThemeManager.currentTheme.BackGroundColor
                
            }
            return cell
            
        } else if collectionView == collectionAppIcons {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGAppIconsCVCell", for: indexPath) as! IGAppIconsCVCell
            
            cell.imgIcon.image = appIcons[indexPath.item]
            cell.lblbIconName.text = "Name"
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGColorsSetCVCell", for: indexPath) as! IGColorsSetCVCell
            
            let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
            let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"

            cell.viewColorInner.backgroundColor = colorSets[indexPath.item]
            cell.viewColorOuter.backgroundColor = colorSets[indexPath.item]
            cell.viewColorInner.layer.borderColor = colorSets[indexPath.item].cgColor
            
            if currentTheme == "IGAPDay" {

                switch indexPath.item {
                    
                case 0 :
                    
                    switch currentColorSetLight {
                    case "IGAPBlue" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 1 :
                    
                    switch currentColorSetLight {
                    case "IGAPTorquoise" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                    default: break
                        
                    }
                    break
                case 2 :
                    
                    switch currentColorSetLight {
                        
                    case "IGAPGreen" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                        
                    default: break
                    }
                    break
                case 3 :
                    
                    switch currentColorSetLight {
                        
                    case "IGAPPink" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                        
                    default: break
                    }
                    break
                case 4 :
                    
                    switch currentColorSetLight {
                    case "IGAPOrange" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 5 :
                    
                    switch currentColorSetLight {
                        
                    case "IGAPPurple" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                        
                    default: break
                    }
                    break
                case 6 :
                    
                    switch currentColorSetLight {
                        
                    case "IGAPRed" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 7 :
                    
                    switch currentColorSetLight {
                    case "IGAPGold" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                    default: break
                    }
                    break
                case 8 :
                    
                    switch currentColorSetLight {
                    case "IGAPLightGray" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 9 :
                    
                    switch currentColorSetLight {
                    case "IGAPBW" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                    default: break
                    }
                    break
                default: break
                }
            } else if currentTheme == "IGAPDark" {

                switch indexPath.item {
                    
                case 0 :
                    
                    switch currentColorSetDark {
                    case "IGAPBlue" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 1 :
                    
                    switch currentColorSetDark {
                    case "IGAPTorquoise" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                    default: break
                        
                    }
                    break
                case 2 :
                    
                    switch currentColorSetDark {
                        
                    case "IGAPGreen" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                        
                    default: break
                    }
                    break
                case 3 :
                    
                    switch currentColorSetDark {
                        
                    case "IGAPPink" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                        
                    default: break
                    }
                    break
                case 4 :
                    
                    switch currentColorSetDark {
                    case "IGAPOrange" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 5 :
                    
                    switch currentColorSetDark {
                        
                    case "IGAPPurple" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                        
                    default: break
                    }
                    break
                case 6 :
                    
                    switch currentColorSetDark {
                        
                    case "IGAPRed" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 7 :
                    
                    switch currentColorSetDark {
                    case "IGAPGold" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                    default: break
                    }
                    break
                case 8 :
                    
                    switch currentColorSetDark {
                    case "IGAPLightGray" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                        
                    default: break
                    }
                    break
                case 9 :
                    
                    switch currentColorSetDark {
                    case "IGAPBW" :
                        cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                        break
                    default: break
                    }
                    break
                default: break
                }
            } else {
                
            }
            
            
            return cell
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionThemes {
            let cell = collectionView.cellForItem(at: indexPath) as! IGThemeCVCell
            cell.viewBG.layer.borderColor = UIColor.iGapGreen().cgColor
            
            switch indexPath.item {
            case 0 :
                self.tableView.beginUpdates()
                UserDefaults.standard.set("IGAPClassic", forKey: "CurrentTheme")
                print("CURRENT THEME IS :","Classic")
                isClassicTheme = true
                self.tableView.endUpdates()
                
            case 1 :
                self.tableView.beginUpdates()
                UserDefaults.standard.set("IGAPDay", forKey: "CurrentTheme")
                print("CURRENT THEME IS :","Day")
                isClassicTheme = false
                self.tableView.endUpdates()
                
                
            case 2 :
                self.tableView.beginUpdates()
                UserDefaults.standard.set("IGAPNight", forKey: "CurrentTheme")
                print("CURRENT THEME IS :","NIGHT")
                isClassicTheme = false
                self.tableView.endUpdates()
                
            default :
                break
            }
        } else if collectionView == collectionAppIcons {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IGAppIconsCVCell else { return }
            cell.viewColorOuter.layer.borderColor = UIColor.iGapGreen().cgColor
            cell.viewColorOuter.layer.borderWidth = 2
            self.changeIcon(to: appIconsNames[indexPath.item])
            
            
            
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IGColorsSetCVCell else { return }
            cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            
            switch indexPath.item {
            case 0 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPBlue", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPBlue", forKey: "CurrentColorSetDark")
                }
                print("CURRENT COLORSET IS :","BLUE")
                
            case 1 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPTorquoise", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPTorquoise", forKey: "CurrentColorSetDark")
                }
                
                print("CURRENT COLORSET IS :","TORQUOISE")
                
            case 2 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPGreen", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPGreen", forKey: "CurrentColorSetDark")
                }
                
                print("CURRENT COLORSET IS :","GREEN")
                
            case 3 :
                UserDefaults.standard.set("IGAPPink", forKey: "CurrentColorSetDark")
                print("CURRENT COLORSET IS :","PINK")
                
            case 4 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPOrange", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPOrange", forKey: "CurrentColorSetDark")
                }
                
                print("CURRENT COLORSET IS :","ORANGE")
                
            case 5 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPPurple", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPPurple", forKey: "CurrentColorSetDark")
                }
                
                print("CURRENT COLORSET IS :","PURPLE")
                
            case 6 :
                print("CURRENT COLORSET IS :","RED")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPRed", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPRed", forKey: "CurrentColorSetDark")
                }
                
                
            case 7 :
                print("CURRENT COLORSET IS :","GOLD")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPGold", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPGold", forKey: "CurrentColorSetDark")
                }
                
                
            case 8 :
                print("CURRENT COLORSET IS :","LIGHTGRAY")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPLightGray", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPLightGray", forKey: "CurrentColorSetDark")
                }
            case 9 :
                print("CURRENT COLORSET IS :","BW")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPBW", forKey: "CurrentColorSetLight")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPBW", forKey: "CurrentColorSetDark")
                }
                
                
                
            default :
                break
            }
            
        }
        
        
        
    }
    private func changeIcon(to iconName: String) {
        // 1
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        
        // 2
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
            // 3
            if let error = error {
                print("App icon failed to change due to \(error.localizedDescription)")
            } else {
                print("App icon changed successfully")
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionThemes {
            let cell = collectionView.cellForItem(at: indexPath) as! IGThemeCVCell
            cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
            
        } else if collectionView == collectionAppIcons {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IGAppIconsCVCell else { return }
            cell.viewColorOuter.layer.borderWidth = 0
            
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IGColorsSetCVCell else { return }
            
            cell.viewColorInner.layer.borderColor = colorSets[indexPath.item].cgColor
            
        }
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionThemes {
            let itemHeight = 108
            let itemWidth = UIScreen.main.bounds.width / 3
            return CGSize(width: Int(itemWidth), height: itemHeight)
            
            
        } else if collectionView == collectionAppIcons {
            let itemHeight = 80
            let itemWidth = 80
            return CGSize(width: Int(itemWidth), height: itemHeight)
            
            
        } else {
            let itemHeight = 50
            let itemWidth = 50
            return CGSize(width: Int(itemWidth), height: itemHeight)
            
        }
    }
}
