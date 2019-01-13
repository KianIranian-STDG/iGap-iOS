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

class IGHelperPreferences {

    //setting preferences
    public static let keyInAppBrowser = "IN_APP_BROWSER"
    
    
    internal static func readBoolean(key: String) -> Bool {
        let preferences = UserDefaults.standard
        let currentLevelKey = key
        if preferences.object(forKey: currentLevelKey) != nil {
            return preferences.bool(forKey: currentLevelKey)
        }
        return false
    }

    internal static func writeBoolean(key: String, state: Bool){
        let preferences = UserDefaults.standard
        preferences.set(state, forKey: key)
        preferences.synchronize()
    }
}
