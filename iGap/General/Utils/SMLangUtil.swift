//
//  SMLangUtil.swift
//  PayGear
//
//  Created by a on 4/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import maincore

var lastLang = ""
class SMLangUtil: NSObject {
	
	public enum SMLanguage : String {
//		case Arabic = "ar"
        case Persian = "fa"
        case English = "en"
        case Arabic = "ar"
	}
	
    static var lang = SMLanguage.English.rawValue
	
    
    static func changeLanguage(newLang: SMLanguage) {
        UserDefaults.standard.setValue(newLang.rawValue, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()
        MCLocalization.sharedInstance().language = newLang.rawValue
        lastLang = newLang.rawValue
        Bundle.setLanguage("en")
        lang = newLang.rawValue
    }
    
    
    static func loadLanguage() -> String {
        let targetLang = UserDefaults.standard.object(forKey: "selectedLanguage") as? String
        lang = targetLang ?? SMLanguage.English.rawValue
        Bundle.setLanguage("en")
        setAppleLAnguageTo(lang: "en")
        return lang

    }
    static func changeOrderToPersian() {
        Bundle.setLanguage("fa")
        setAppleLAnguageTo(lang: "fa")

    }
    static func changeOrderToEn() {
        Bundle.setLanguage("en")
        setAppleLAnguageTo(lang: "en")

    }
    static let APPLE_LANGUAGE_KEY = "AppleLanguages"

    static func currentAppleLanguage() -> String{
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
        return current
    }
    static func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang,currentAppleLanguage()], forKey: APPLE_LANGUAGE_KEY)
        userdef.synchronize()
    }
    
    static func changeLblText(tag: Int , parentViewController : String) -> (String){
        
        switch parentViewController {
        case "iGap.IGAccountViewController":
            if tag == 1 {
                return "SETTING_PAGE_ACCOUNT_NIKNAME".localizedNew
            }
            else if tag == 2 {
                return "SETTING_PAGE_ACCOUNT_PHONENUMBER".localizedNew
            }
                
            else if tag == 3 {
                return "SETTING_PAGE_ACCOUNT_USERNAME".localizedNew
            }
                
            else if tag == 4 {
                return "SETTING_PAGE_ACCOUNT_EMAIL".localizedNew
            }
                
            else if tag == 5 {
                return "SETTING_PAGE_ACCOUNT_BIO".localizedNew
            }
                
            else if tag == 6 {
                return "SETTING_PAGE_ACCOUNT_REFERRAL".localizedNew
            }
                
            else if tag == 7 {
                return "SETTING_PAGE_ACCOUNT_D_ACCOUNT".localizedNew
            }
                
            else if tag == 8 {
                return "SETTING_PAGE_ACCOUNT_S_DESTRUCT".localizedNew
            }
                
            else if tag == 9 {
                return "SETTING_PAGE_ACCOUNT_S_DESTRUCT_HINT".localizedNew
            }
                
                
            else if tag == 10 {
                return "SETTING_PAGE_ACCOUNT_LOGOUT".localizedNew
            }
                
            else {
                return "SETTING_PAGE_ACCOUNT_NIKNAME".localizedNew
            }
            
        case "iGap.IGSettingChnageLanguageTableViewController":
            if tag == 1 {
                return "SETTING_CHL_PERSIAN".localizedNew
            }
            else if tag == 2 {
                return "SETTING_CHL_ENGLISH".localizedNew
            }
                
            else if tag == 3 {
                return "SETTING_CHL_ARABIC".localizedNew
            }
            else {
                return "SETTING_CHL_PERSIAN".localizedNew
                
            }
        case "iGap.packetTableViewController":
            if tag == 1 {
                return "TTL_WALLET_BALANCE_USER".localizedNew
            }
            else if tag == 2 {
                return "CURRENCY".localizedNew
            }
            else if tag == 3 {
                return "BTN_CASHOUT_WALLET".localizedNew
            }
            else if tag == 4 {
                return "BTN_CHARGE_WALLET".localizedNew
            }
            else if tag == 5 {
                return "RECOVER_PASS".localizedNew
            }
            else {
                return "TTL_MY_CARDS".localizedNew
            }
            
        default:
            return "".localizedNew
            
        }
        
        
    }
    
}


