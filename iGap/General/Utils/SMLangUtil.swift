//
//  SMLangUtil.swift
//  PayGear
//
//  Created by a on 4/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import maincore

//var lastLang = ""
class SMLangUtil: NSObject {
	
	public enum SMLanguage : String {
        case Persian = "fa"
        case English = "en"
        case Arabic = "ar"
	}
    
    static func loadLanguage() -> String {
        return Locale.userPreferred.languageCode ?? "en"
    }
    
    static func changeLblText(tag: Int , parentViewController : String) -> (String){

        switch parentViewController {
        case "iGap.IGAccountViewController":
            if tag == 1 {
                return "SETTING_PAGE_ACCOUNT_NIKNAME".localized
            }
            else if tag == 2 {
                return IGStringsManager.Phone.rawValue.localized
            }

            else if tag == 3 {
                return "SETTING_PAGE_ACCOUNT_USERNAME".localized
            }

            else if tag == 4 {
                return "SETTING_PAGE_ACCOUNT_EMAIL".localized
            }

            else if tag == 5 {
                return IGStringsManager.Bio.rawValue.localized
            }

            else if tag == 6 {
                return "SETTING_PAGE_ACCOUNT_REFERRAL".localized
            }

            else if tag == 7 {
                return IGStringsManager.DeleteAccount.rawValue.localized
            }

            else if tag == 8 {
                return IGStringsManager.SelfDestruct.rawValue.localized
            }

            else if tag == 9 {
                return "SETTING_PAGE_ACCOUNT_S_DESTRUCT_HINT".localized
            }


            else if tag == 10 {
                return IGStringsManager.Logout.rawValue.localized
            }

            else {
                return "SETTING_PAGE_ACCOUNT_NIKNAME".localized
            }

        case "iGap.IGSettingChnageLanguageTableViewController":
            if tag == 1 {
                return "SETTING_CHL_PERSIAN".localized
            }
            else if tag == 2 {
                return "SETTING_CHL_ENGLISH".localized
            }

            else if tag == 3 {
                return "SETTING_CHL_ARABIC".localized
            }
            else {
                return "SETTING_CHL_PERSIAN".localized

            }
        case "iGap.packetTableViewController":
            if tag == 1 {
                return IGStringsManager.UserWalletBalance.rawValue.localized
            }
            else if tag == 2 {
                return IGStringsManager.Currency.rawValue.localized
            }
            else if tag == 3 {
                return IGStringsManager.Cashout.rawValue.localized
            }
            else if tag == 4 {
                return "BTN_CHARGE_WALLET".localized
            }
            else if tag == 5 {
                return "RECOVER_PASS".localized
            }
            else {
                return "TTL_MY_CARDS".localized
            }

        default:
            return "".localized

        }
    }
    
}


