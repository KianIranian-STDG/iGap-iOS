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

class IGSettingChnageLanguageTableViewController: BaseTableViewController {
    
    @IBOutlet weak var lblPersianLang: UILabel!
    @IBOutlet weak var lblEnglishLang: UILabel!
    @IBOutlet weak var lblArabicLang: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_CHANGE_LANGUAGE".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        initChangeLanguage()
    }
    
    func initChangeLanguage() {
        lblPersianLang.text = SMLangUtil.changeLblText(tag: lblPersianLang.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblEnglishLang.text = SMLangUtil.changeLblText(tag: lblEnglishLang.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblArabicLang.text = SMLangUtil.changeLblText(tag: lblArabicLang.tag, parentViewController: NSStringFromClass(self.classForCoder))
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0 :
            if lastLang != "fa" {
                SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Persian)
                UITableView.appearance().semanticContentAttribute = .forceRightToLeft
                
                resetApp()
            }
            break
            
        case 1:
            if lastLang != "en" {
                SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.English)
                UITableView.appearance().semanticContentAttribute = .forceLeftToRight
                resetApp()
            }
            break
            
        case 2:
            if lastLang != "ar" {
                SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Persian)
                resetApp()
            }
            break
            
        default :
            break
        }
    }
    
    func resetApp() {
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_CHANGE_LANGUAGE)
        if SMLangUtil.loadLanguage() == "fa" {
            UITableView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UITableView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        var window : UIWindow!
        currentTabIndex = TabBarTab.Recent.rawValue
        let apDelegate = UIApplication.shared.delegate as! AppDelegate
        if let appWindow = apDelegate.window {
            window = appWindow
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible() //make window visible
        
//        UIApplication.shared.windows[0].rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    }
}
