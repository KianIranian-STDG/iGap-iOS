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
                return IGStringsManager.ChargeWallet.rawValue.localized
            }
            else if tag == 5 {
                return IGStringsManager.ForgetPassword.rawValue.localized
            }
            else {
                return IGStringsManager.MyCards.rawValue.localized
            }

        default:
            return ""

        }
    }
    
}


