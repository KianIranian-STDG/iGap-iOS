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
    //1
    @IBOutlet weak var lblMinA : UILabel!
    @IBOutlet weak var lblMaxA : UILabel!
    @IBOutlet weak var lblMessagePreview : UILabel!
    @IBOutlet weak var messageStatusPreview : UILabel!
    @IBOutlet weak var messageTimePreview : UILabel!
    @IBOutlet weak var viewMessagePreview : UIView!
    @IBOutlet weak var ViewMainBG : UIView!
    @IBOutlet weak var IMGMainBG : UIImageView!
    //2
    @IBOutlet weak var lblMessagePreview2 : UILabel!
    @IBOutlet weak var messageStatusPreview2 : UILabel!
    @IBOutlet weak var messageTimePreview2 : UILabel!
    @IBOutlet weak var viewMessagePreview2 : UIView!

    //3
    @IBOutlet weak var sliderPreview3: TGPDiscreteSlider!
    @IBOutlet weak var messageStatusPreview3 : UILabel!
    @IBOutlet weak var messageTimePreview3 : UILabel!
    @IBOutlet weak var messageTimePlayPreview3 : UILabel!
    @IBOutlet weak var viewMessagePreview3 : UIView!
    @IBOutlet weak var btnPlayPreview3 : UIButton!

    @IBOutlet weak var collectionThemes : UICollectionView!
    @IBOutlet weak var collectionAppIcons : UICollectionView!
    @IBOutlet weak var collectionColorSets : UICollectionView!
    var indexPathTheme : IndexPath = IndexPath(item: 0, section: 0)
    var indexPathAppIcon : IndexPath = IndexPath(item : 0, section: 0)
    var indexPathDark : IndexPath = IndexPath(item : 0, section: 0)
    var indexPathLight : IndexPath = IndexPath(item : 0, section: 0)
    var userDefaults = UserDefaults.standard
    
    var themeTypes = [IGStringsManager.ClassicTheme.rawValue.localized,IGStringsManager.DayTheme.rawValue.localized,IGStringsManager.NightTheme.rawValue.localized]
    var bgArray : [UIColor] = [DefaultColorSet().SettingClassicBG,UIColor.white,UIColor.black]

    var colorSets : [UIColor] = [UIColor(named: "BlueColorSet")!,UIColor(named: "TurquoiseColorSet")!,UIColor(named: "GreenColorSet")!,UIColor(named: "PinkColorSet")!,UIColor(named: "OrangeColorSet")!,UIColor(named: "PurpleColorSet")!,UIColor(named: "RedColorSet")!,UIColor(named: "GoldColorSet")!,UIColor(named: "LightGrayColorSet")!]
    var appIcons : [UIImage] = [UIImage(named: "AppIconOne")!,UIImage(named: "AppIconTwo")!,UIImage(named: "AppIconThree")!,UIImage(named: "AppIconFour")!,UIImage(named: "AppIconFive")!,UIImage(named: "AppIconSix")!,UIImage(named: "AppIconSeven")!]
    var appIconsNames : [String] = ["AppIconOne","AppIconTwo","AppIconThree","AppIconFour","AppIconFive","AppIconSix","AppIconSeven"]
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
        self.oneTo10Slider.semanticContentAttribute = .forceLeftToRight
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
        oneTo10Slider.thumbTintColor = ThemeManager.currentTheme.SliderTintColor
        
        changeMessagePreview(font: fontDefaultSize)
        
        messageTimePreview.text = messageTimePreview.text?.inLocalizedLanguage()
        lblMessagePreview.textAlignment =  messageTimePreview.localizedDirection
        messageTimePreview2.text = messageTimePreview2.text?.inLocalizedLanguage()
        lblMessagePreview2.textAlignment =  messageTimePreview2.localizedDirection
        selectTheme()
        self.btnPlayPreview3.setTitleColor(ThemeManager.currentTheme.MessageTextReceiverColor, for: .normal)
        self.sliderPreview3.tintColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.sliderPreview3.thumbTintColor = ThemeManager.currentTheme.MessageTextReceiverColor
//        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        
    }
    private func changeTheme(theme: String!) {
        //        SwiftEventBus.post("ChangeTheme",sender: themeType)
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
        
        switch theme {
        case "IGAPClassic" :
            ThemeManager.currentTheme = ClassicTheme()
            initTheme(currentTheme: theme)
            
        case "IGAPDay" :
            ThemeManager.currentTheme = DayTheme()
            initTheme(currentTheme: theme, currentColorSet: currentColorSetLight)
            
        case "IGAPNight" :
            ThemeManager.currentTheme = NightTheme()
            initTheme(currentTheme: theme, currentColorSet: currentColorSetDark)
            
        default: break
        }
    }
    private func selectTheme() {
        let currentAppIcon = UserDefaults.standard.integer(forKey: "CurrentAppIcon") ?? 6
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
        print("CURRENT COLOR SET FOR DARK",currentColorSetDark,"\n","CURRENT INDEX DARK IS",indexPathDark)
        print("CURRENT COLOR SET FOR LIGHT",currentColorSetLight,"\n","CURRENT INDEX LIGHT IS",indexPathLight)
        switch currentColorSetLight {
        case "IGAPBlue" :
            indexPathLight = IndexPath(item: 0, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
        case "IGAPTorquoise" :
            indexPathLight = IndexPath(item: 1, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPGreen" :
            indexPathLight = IndexPath(item: 2, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPPink" :
            indexPathLight = IndexPath(item: 3, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPOrange" :
            indexPathLight = IndexPath(item: 4, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPPurple" :
            indexPathLight = IndexPath(item: 5, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPRed" :
            indexPathLight = IndexPath(item: 6, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPGold" :
            indexPathLight = IndexPath(item: 7, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPLightGray" :
            indexPathLight = IndexPath(item: 8, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
            
        case "IGAPBW" :
            indexPathLight = IndexPath(item: 9, section: 0)
            self.collectionColorSets.selectItem(at: indexPathLight, animated: true, scrollPosition: [])
            
        default : break
            
        }
        switch currentColorSetDark {
        case "IGAPBlue" :
            indexPathDark = IndexPath(item: 0, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPTorquoise" :
            indexPathDark = IndexPath(item: 1, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPGreen" :
            indexPathDark = IndexPath(item: 2, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPPink" :
            indexPathDark = IndexPath(item: 3, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPOrange" :
            indexPathDark = IndexPath(item: 4, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPPurple" :
            indexPathDark = IndexPath(item: 5, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPRed" :
            indexPathDark = IndexPath(item: 6, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPGold" :
            indexPathDark = IndexPath(item: 7, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPLightGray" :
            indexPathDark = IndexPath(item: 8, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        case "IGAPBW" :
            indexPathDark = IndexPath(item: 9, section: 0)
            self.collectionColorSets.selectItem(at: indexPathDark, animated: true, scrollPosition: [])
            
        default : break
            
        }
        switch currentAppIcon {
        case 0 :
            indexPathAppIcon = IndexPath(item: 0, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
            
            
        case 1 :
            indexPathAppIcon = IndexPath(item: 1, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
            
            
        case 2 :
            indexPathAppIcon = IndexPath(item: 2, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
            
            
        case 3 :
            indexPathAppIcon = IndexPath(item: 3, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
            
            
        case 4 :
            indexPathAppIcon = IndexPath(item: 4, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
            
            
        case 5 :
            indexPathAppIcon = IndexPath(item: 5, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
            
            
        case 6 :
            indexPathAppIcon = IndexPath(item: 6, section: 0)
            self.collectionColorSets.selectItem(at: indexPathAppIcon, animated: true, scrollPosition: [])
        default : break
            
        }
        print("CURRENT COLOR SET FOR DARK2",currentColorSetDark,"\n","CURRENT INDEX DARK IS",indexPathDark)
        print("CURRENT COLOR SET FOR LIGHT2",currentColorSetLight,"\n","CURRENT INDEX LIGHT IS",indexPathLight)
        
        switch currentTheme {
            
        case "IGAPClassic" :
            print("CURRENT  IS :","CLASSIC")
            self.isClassicTheme = true
            indexPathTheme = IndexPath(item: 0, section: 0)
            self.collectionThemes.selectItem(at: indexPathTheme, animated: true, scrollPosition: [])
            ThemeManager.currentTheme = ClassicTheme()
//            IMGMainBG.alpha = 1.0
            ViewMainBG.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
            break
            
        case "IGAPDay" :
            print("CURRENT  IS :","DAY")
            self.isClassicTheme = false
            indexPathTheme = IndexPath(item: 1, section: 0)
            self.collectionThemes.selectItem(at: indexPathTheme, animated: true, scrollPosition: [])
            ThemeManager.currentTheme = DayTheme()
//            IMGMainBG.alpha = 0.0
            ViewMainBG.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

            
            break
        case "IGAPNight" :
            print("CURRENT  IS :","NIGHT")
            self.isClassicTheme = false
            indexPathTheme = IndexPath(item: 2, section: 0)
            self.collectionThemes.selectItem(at: indexPathTheme, animated: true, scrollPosition: [])
            ThemeManager.currentTheme = NightTheme()
//            IMGMainBG.alpha = 0.0
            ViewMainBG.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

            
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
            lblMinA.font = UIFont.systemFont(ofSize: 12)
            lblMaxA.font = UIFont.systemFont(ofSize: 20)
            viewMessagePreview2.layer.cornerRadius = 15.0
            viewMessagePreview2.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)

            
        } else {
            lblMinA.font = UIFont.systemFont(ofSize: 20)
            lblMaxA.font = UIFont.systemFont(ofSize: 12)
            viewMessagePreview2.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
        }
        self.viewMessagePreview2.backgroundColor = ThemeManager.currentTheme.SendMessageBubleBGColor

        
        //sample2
        if self.isRTL {
            viewMessagePreview.layer.cornerRadius = 15.0
            viewMessagePreview3.layer.cornerRadius = 15.0
            viewMessagePreview.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
            viewMessagePreview3.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)

        } else {
            viewMessagePreview.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
            viewMessagePreview3.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 15.0)
        }
        viewMessagePreview.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: true)
        viewMessagePreview3.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: true)

        
        
        
        oneTo10Slider.addTarget(self, action: #selector(IGSettingsAppearanceTableViewController.valueChanged(_:event:)), for: .valueChanged)
        if IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
            switchInAppBrowser.isOn = true
        } else {
            switchInAppBrowser.isOn = false
        }
        initThemeView()
        
    }
    private func initThemeView() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.lblMaxA.textColor = ThemeManager.currentTheme.LabelColor
        self.lblMinA.textColor = ThemeManager.currentTheme.LabelColor
        self.lblChatBG.textColor = ThemeManager.currentTheme.LabelColor
        self.lblInAppBrowser.textColor = ThemeManager.currentTheme.LabelColor
        self.lblStickers.textColor = ThemeManager.currentTheme.LabelColor
        self.switchInAppBrowser.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.lblMessagePreview2.textColor = ThemeManager.currentTheme.LabelColor
        self.messageTimePreview2.textColor = ThemeManager.currentTheme.LabelColor
        self.messageStatusPreview2.textColor = ThemeManager.currentTheme.LabelColor
        self.messageTimePreview3.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageStatusPreview3.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageTimePlayPreview3.textColor = ThemeManager.currentTheme.MessageTextReceiverColor

        self.lblMessagePreview.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageStatusPreview.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageTimePreview.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.IMGMainBG.image = ThemeManager.currentTheme.ChatBG


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
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

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
        case 1,2  :
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
                return 327
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
    
    private func initTheme(currentTheme : String = "IGAPClassic", currentColorSet: String = "IGAPBlue") {
        
        self.tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
        self.lblMaxA.textColor = ThemeManager.currentTheme.LabelColor
        self.lblMinA.textColor = ThemeManager.currentTheme.LabelColor
        self.oneTo10Slider.tintColor = ThemeManager.currentTheme.SliderTintColor
        self.btnPlayPreview3.setTitleColor(ThemeManager.currentTheme.MessageTextReceiverColor, for: .normal)
        self.sliderPreview3.tintColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.oneTo10Slider.thumbTintColor = ThemeManager.currentTheme.SliderTintColor
        self.sliderPreview3.thumbTintColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.viewMessagePreview.backgroundColor = ThemeManager.currentTheme.ReceiveMessageBubleBGColor
        self.viewMessagePreview3.backgroundColor = ThemeManager.currentTheme.ReceiveMessageBubleBGColor
        self.viewMessagePreview2.backgroundColor = ThemeManager.currentTheme.SendMessageBubleBGColor
        self.lblMessagePreview.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageTimePlayPreview3.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageTimePreview.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageTimePreview3.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.lblMessagePreview2.textColor = ThemeManager.currentTheme.LabelColor
        self.messageTimePreview2.textColor = ThemeManager.currentTheme.LabelColor
        self.messageStatusPreview2.textColor = ThemeManager.currentTheme.LabelColor
        self.messageStatusPreview.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.messageStatusPreview3.textColor = ThemeManager.currentTheme.MessageTextReceiverColor
        self.switchInAppBrowser.onTintColor = ThemeManager.currentTheme.SliderTintColor
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.collectionThemes.reloadData()
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        initThemeView()
        self.tableView.reloadData()
        SwiftEventBus.post("initTheme", sender: "IGAPClassic")
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
            cell.viewBG.backgroundColor = bgArray[indexPath.item]
            cell.lblThemeName.textColor = ThemeManager.currentTheme.LabelColor

            switch indexPath.item {
            case indexPathTheme.item :
                cell.viewBG.layer.borderWidth = 2.0
                cell.viewReciever.backgroundColor = ThemeManager.currentTheme.SettingDayReceiveBubble
                cell.viewBG.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor

            default :
                cell.viewBG.layer.borderWidth = 2.0
                cell.viewReciever.backgroundColor = DefaultColorSet().SettingDayReceiveBubble
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor

            }

            return cell
            
        } else if collectionView == collectionAppIcons {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGAppIconsCVCell", for: indexPath) as! IGAppIconsCVCell
            
            cell.imgIcon.image = appIcons[indexPath.item]
            cell.viewColorOuter.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor

            switch indexPath.item {
            case indexPathAppIcon.item :
                cell.viewColorOuter.layer.borderWidth = 2
                
            default :
                cell.viewColorOuter.layer.borderWidth = 0
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGColorsSetCVCell", for: indexPath) as! IGColorsSetCVCell
            
            let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
            let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            
            cell.viewColorInner.backgroundColor = colorSets[indexPath.item]
            cell.viewColorOuter.backgroundColor = colorSets[indexPath.item]
            
            if currentTheme == "IGAPDay" {
                switch indexPath.item {
                case indexPathLight.item :
                    cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                default:
                    cell.viewColorInner.layer.borderColor = colorSets[indexPath.item].cgColor
                }
                
            } else if currentTheme == "IGAPNight" {
                switch indexPath.item {
                case indexPathDark.item :
                    cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
                default:
                    cell.viewColorInner.layer.borderColor = colorSets[indexPath.item].cgColor
                }
                
            }
            
            
            
            return cell
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionThemes {
            let cell = collectionView.cellForItem(at: indexPath) as! IGThemeCVCell
//            cell.viewBG.layer.borderColor = UIColor.iGapGreen().cgColor
            let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
            let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
            
            switch indexPath.item {
            case 0 :
                self.tableView.beginUpdates()
                UserDefaults.standard.set("IGAPClassic", forKey: "CurrentTheme")
                print("CURRENT THEME IS :","Classic")
                isClassicTheme = true
                self.collectionColorSets.reloadData()
                self.tableView.endUpdates()
                ThemeManager.currentTheme = ClassicTheme()
                initTheme(currentTheme: "IGAPClassic", currentColorSet: "IGAPDefaultColor")
//                IMGMainBG.alpha = 1.0
                ViewMainBG.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

                
            case 1 :
                self.tableView.beginUpdates()
                UserDefaults.standard.set("IGAPDay", forKey: "CurrentTheme")
                print("CURRENT THEME IS :","Day")
                isClassicTheme = false
                self.collectionColorSets.reloadData()
                self.tableView.endUpdates()
                ThemeManager.currentTheme = DayTheme()
                initTheme(currentTheme: "IGAPDay", currentColorSet: currentColorSetLight)
//                IMGMainBG.alpha = 0.0
                ViewMainBG.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

                
                
                
            case 2 :
                self.tableView.beginUpdates()
                UserDefaults.standard.set("IGAPNight", forKey: "CurrentTheme")
                print("CURRENT THEME IS :","NIGHT")
                isClassicTheme = false
                self.collectionColorSets.reloadData()
                self.tableView.endUpdates()
                ThemeManager.currentTheme = NightTheme()
                initTheme(currentTheme: "IGAPNight", currentColorSet: currentColorSetDark)
//                IMGMainBG.alpha = 0.0
                ViewMainBG.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

                
            default :
                break
            }
            cell.viewBG.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
            cell.viewBG.layer.borderWidth = 2
            indexPathTheme = IndexPath(item: indexPath.item, section: 0)
            collectionView.reloadData()


            //            self.selectTheme()
        } else if collectionView == collectionAppIcons {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IGAppIconsCVCell else { return }
            cell.viewColorOuter.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor
            cell.viewColorOuter.layer.borderWidth = 2
            self.changeIcon(to: appIconsNames[indexPath.item])
            UserDefaults.standard.set(indexPath.item, forKey: "CurrentAppIcon")
            indexPathAppIcon = IndexPath(item: indexPath.item, section: 0)
            collectionView.reloadData()
            
            
            
            
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? IGColorsSetCVCell else { return }
            cell.viewColorInner.layer.borderColor = UIColor.white.cgColor
            let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
            
            
            switch indexPath.item {
            case 0 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPBlue", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 0, section: 0)
                    DayColorSetManager.currentColorSet = BlueColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPBlue")
                    
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPBlue", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 0, section: 0)
                    NightColorSetManager.currentColorSet = BlueColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPBlue")
                    
                    
                }
                print("CURRENT COLORSET IS :","BLUE")
                
            case 1 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPTorquoise", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 1, section: 0)
                    DayColorSetManager.currentColorSet = TorquoiseColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPTorquoise")
                    
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPTorquoise", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 1, section: 0)
                    NightColorSetManager.currentColorSet = TorquoiseColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPTorquoise")
                    
                }
                
                print("CURRENT COLORSET IS :","TORQUOISE")
                
            case 2 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPGreen", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 2, section: 0)
                    DayColorSetManager.currentColorSet = GreenColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPGreen")
                    
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPGreen", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 2, section: 0)
                    NightColorSetManager.currentColorSet = GreenColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPGreen")
                    
                }
                
                print("CURRENT COLORSET IS :","GREEN")
                
            case 3 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPPink", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 3, section: 0)
                    DayColorSetManager.currentColorSet = PinkColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPPink")
                    
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPPink", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 3, section: 0)
                    NightColorSetManager.currentColorSet = PinkColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPPink")
                    
                }
                
                print("CURRENT COLORSET IS :","PINK")
                
                
            case 4 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPOrange", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 4, section: 0)
                    DayColorSetManager.currentColorSet = OrangeColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPOrange")
                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPOrange", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 4, section: 0)
                    NightColorSetManager.currentColorSet = OrangeColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPOrange")
                    
                }
                
                print("CURRENT COLORSET IS :","ORANGE")
                
            case 5 :
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPPurple", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 5, section: 0)
                    DayColorSetManager.currentColorSet = PurpleColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPPurple")

                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPPurple", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 5, section: 0)
                    NightColorSetManager.currentColorSet = PurpleColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPPurple")

                }
                
                print("CURRENT COLORSET IS :","PURPLE")
                
            case 6 :
                print("CURRENT COLORSET IS :","RED")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPRed", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 6, section: 0)
                    DayColorSetManager.currentColorSet = RedColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPRed")

                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPRed", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 6, section: 0)
                    NightColorSetManager.currentColorSet = RedColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPRed")

                }
                
                
            case 7 :
                print("CURRENT COLORSET IS :","GOLD")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPGold", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 7, section: 0)
                    DayColorSetManager.currentColorSet = GoldColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPGold")

                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPGold", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 7, section: 0)
                    NightColorSetManager.currentColorSet = GoldColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPGold")

                }
                
                
            case 8 :
                print("CURRENT COLORSET IS :","LIGHTGRAY")
                if currentTheme == "IGAPDay" {
                    UserDefaults.standard.set("IGAPLightGray", forKey: "CurrentColorSetLight")
                    indexPathLight = IndexPath(item: 8, section: 0)
                    DayColorSetManager.currentColorSet = LightGrayColorSet()
                    ThemeManager.currentTheme = DayTheme()
                    initTheme(currentTheme: "IGAPDay", currentColorSet: "IGAPLightGray")

                    
                } else if currentTheme == "IGAPNight" {
                    UserDefaults.standard.set("IGAPLightGray", forKey: "CurrentColorSetDark")
                    indexPathDark = IndexPath(item: 8, section: 0)
                    NightColorSetManager.currentColorSet = LightGrayColorSetNight()
                    ThemeManager.currentTheme = NightTheme()
                    initTheme(currentTheme: "IGAPNight", currentColorSet: "IGAPLightGray")

                }
                
                
            default :
                break
            }
            print("||||||||||||",indexPathLight.item,"||||||||||||")
            print("||||||||||||",indexPathDark.item,"||||||||||||")
            collectionView.reloadData()
        }
        
        
        
    }
    private func changeIcon(to iconName: String) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
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
            cell.viewBG.layer.borderWidth = 0

            
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
            let itemHeight = 107
            let itemWidth = UIScreen.main.bounds.width / 3
            return CGSize(width: Int(itemWidth), height: itemHeight)
            
            
        } else if collectionView == collectionAppIcons {
            let itemHeight = 99
            let itemWidth = 99
            return CGSize(width: Int(itemWidth), height: itemHeight)
            
            
        } else {
            let itemHeight = 49
            let itemWidth = 49
            return CGSize(width: Int(itemWidth), height: itemHeight)
            
        }
    }
}
