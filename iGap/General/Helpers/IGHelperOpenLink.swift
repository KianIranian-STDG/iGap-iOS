/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

/* detect should be open link in internal browser or external browser */
class IGHelperOpenLink {

    static let ignoreLinks = ["facebook.com","twitter.com","instagram.com","pinterest.com","tumblr.com","telegram.org","flickr.com","500px.com","behance.net","t.me"]
    
    static func openLink(urlString: String, navigationController: UINavigationController){
        
        if !IGHelperPreferences.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
            UIApplication.shared.openURL(URL(string: urlString)!)
        } else {
            for ignoreLink in ignoreLinks {
                if urlString.contains(ignoreLink) {
                    UIApplication.shared.openURL(URL(string: urlString)!)
                    return
                }
            }
            navigationController.pushViewController(SwiftWebVC(urlString: urlString), animated: true)
        }
    }
}
