//
//  SMLangUtil.swift
//  PayGear
//
//  Created by a on 4/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit


class SMLangUtil: NSObject {
	
	public enum SMLanguage : String {
//		case Arabic = "ar"
//		case Persian = "fa"
		case English = "en"
		case Base = "Base"
	}
	
    static var lang = SMLanguage.Base.rawValue
	
    
    static func changeLanguage(newLang:String) {
        UserDefaults.standard.setValue(newLang, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(newLang)
        lang = newLang
    }
    
    
    static func loadLanguage() {
        let targetLang = UserDefaults.standard.object(forKey: "selectedLanguage") as? String
		lang = targetLang ?? SMLanguage.Base.rawValue
        Bundle.setLanguage(lang)
		setAppleLAnguageTo(lang: lang)
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
	
}


