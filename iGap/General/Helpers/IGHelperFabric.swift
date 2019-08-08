/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Crashlytics

class IGHelperFabric {

    static let shared = IGHelperFabric()
    
    public func sendNonFatal(domain: String, code: Int = 1){
        Crashlytics.sharedInstance().recordError(NSError(domain: domain, code: code, userInfo: nil))
        //Crashlytics.sharedInstance().recordCustomExceptionName("Error Test", reason: nil, frameArray: [])
    }
}
