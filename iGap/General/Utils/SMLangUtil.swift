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
        case Persian = "fa"
		case English = "en"
		case Base = "Base"
	}
	
    static var lang = SMLanguage.Persian.rawValue
	
    
   
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


