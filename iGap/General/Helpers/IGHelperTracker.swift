/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import FirebaseAnalytics

class IGHelperTracker {
 
    static let shared = IGHelperTracker()
    
    private static let CATEGORY_SETTING = "iOS Setting@"
    private static let CATEGORY_COMMUNICATION = "iOS Communication@"
    private static let CATEGORY_REGISTRATION = "iOS Registration@"
    private static let CATEGORY_DISCOVERY = "iOS Discovery@"
    
    public let TRACKER_CHANGE_LANGUAGE = CATEGORY_SETTING + "iOS_TRACKER_CHANGE_LANGUAGE"
    
    public let TRACKER_CALL_HISTORY_PAGE = CATEGORY_COMMUNICATION + "iOS_TRACKER_CALL_HISTORY_PAGE"
    public let TRACKER_VOICE_CALL_CONNECTING = CATEGORY_COMMUNICATION + "iOS_TRACKER_VOICE_CALL_CONNECTING"
    public let TRACKER_VOICE_CALL_CONNECTED = CATEGORY_COMMUNICATION + "iOS_TRACKER_VOICE_CALL_CONNECTED"
    public let TRACKER_VIDEO_CALL_CONNECTING = CATEGORY_COMMUNICATION + "iOS_TRACKER_VIDEO_CALL_CONNECTING"
    public let TRACKER_VIDEO_CALL_CONNECTED = CATEGORY_COMMUNICATION + "iOS_TRACKER_VIDEO_CALL_CONNECTED"
    public let TRACKER_CHAT_VIEW = CATEGORY_COMMUNICATION + "iOS_TRACKER_CHAT_VIEW"
    public let TRACKER_GROUP_VIEW = CATEGORY_COMMUNICATION + "iOS_TRACKER_GROUP_VIEW"
    public let TRACKER_CHANNEL_VIEW = CATEGORY_COMMUNICATION + "iOS_TRACKER_CHANNEL_VIEW"
    public let TRACKER_BOT_VIEW = CATEGORY_COMMUNICATION + "iOS_TRACKER_BOT_VIEW"
    public let TRACKER_ROOM_PAGE = CATEGORY_COMMUNICATION + "iOS_TRACKER_ROOM_PAGE"
    public let TRACKER_CREATE_CHANNEL = CATEGORY_COMMUNICATION + "iOS_TRACKER_CREATE_CHANNEL"
    public let TRACKER_CREATE_GROUP = CATEGORY_COMMUNICATION + "iOS_TRACKER_CREATE_GROUP"
    
    public let TRACKER_INSTALL_USER = CATEGORY_REGISTRATION + "iOS_TRACKER_INSTALL_USER"
    public let TRACKER_SUBMIT_NUMBER = CATEGORY_REGISTRATION + "iOS_TRACKER_SUBMIT_NUMBER"
    public let TRACKER_ACTIVATION_CODE = CATEGORY_REGISTRATION + "iOS_TRACKER_ACTIVATION_CODE"
    public let TRACKER_REGISTRATION_USER = CATEGORY_REGISTRATION + "iOS_TRACKER_REGISTRATION_USER"
    public let TRACKER_REGISTRATION_NEW_USER = CATEGORY_REGISTRATION + "iOS_TRACKER_REGISTRATION_NEW_USER"
    
    public let TRACKER_DISCOVERY_PAGE = CATEGORY_DISCOVERY + "iOS_TRACKER_DISCOVERY_PAGE"
    public let TRACKER_WALLET_PAGE = CATEGORY_DISCOVERY + "iOS_TRACKER_WALLET_PAGE"
    public let TRACKER_NEARBY_PAGE = CATEGORY_DISCOVERY + "iOS_TRACKER_NEARBY_PAGE"
    public let TRACKER_FINANCIAL_SERVICES = CATEGORY_DISCOVERY + "iOS_TRACKER_FINANCIAL_SERVICES"
    
    
    public func sendTracker(trackerTag: String) {
        
        var allowSendTracker = true
        
        if trackerTag == TRACKER_INSTALL_USER && !IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyTrackInstallUser) {
            allowSendTracker = false
        } else {
            IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyTrackInstallUser, state: false)
        }
        
        if allowSendTracker {
            let tracker = trackerTag.split(separator: "@")
            let category = String(tracker[0])
            let action = String(tracker[1])
            
            Analytics.logEvent(action, parameters: nil)
            
            if let trackingId = IGGlobal.readStringFromFile(fileName: "trackingId") {
                guard let trackerInstance = GAI.sharedInstance().tracker(withTrackingId: trackingId) else { return }
                trackerInstance.send((GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: nil, value: nil)?.build() as! [AnyHashable : Any]))
            }
        }
    }
}
