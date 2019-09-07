/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGSessionInfo: Object {
    @objc dynamic  private var id: Int     = 1
    @objc dynamic  var loginToken: String?
    @objc dynamic  var username:   String?
    @objc dynamic  var userID:     Int64   = -1
    @objc dynamic  var nickname:   String?
    @objc dynamic  var authorHash: String?
    @objc dynamic  var representer: String?
    @objc dynamic  var accessToken: String?
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    static func getRepresenter() -> String? {
        let realm = try! Realm()
        if let sessionInfo = realm.objects(IGSessionInfo.self).first {
            return sessionInfo.representer
        }
        return nil
    }
}

class IGSession: Object {
    
    @objc dynamic var sessionId:          Int64                 = -1
    @objc dynamic var appID:              Int32                 = -1
    @objc dynamic var appBuildVersion:    Int32                 = -1
    @objc dynamic var createTime:         Int32                 = -1
    @objc dynamic var activeTime:         Int32                 = -1
    @objc dynamic var appName:            String                = ""
    @objc dynamic var country:            String                = ""
    @objc dynamic var appVersion:         String                = ""
    @objc dynamic var ip:                 String                = ""
    @objc dynamic var isCurrent:          Bool                  = false
    var platform:           IGPlatform?
    var device:             IGDevice?
    var language:           IGLanguage?
    
    convenience init(igpSession: IGPUserSessionGetActiveListResponse.IGPSession) {
        self.init()
        self.sessionId = igpSession.igpSessionID
        self.appID = igpSession.igpAppID
        self.appBuildVersion = igpSession.igpAppBuildVersion
        self.createTime = igpSession.igpCreateTime
        self.activeTime = igpSession.igpActiveTime
        self.appName = igpSession.igpAppName
        self.country = igpSession.igpCountry
        self.appVersion = igpSession.igpAppVersion
        self.ip = igpSession.igpIp
        self.isCurrent = igpSession.igpCurrent
        
        switch igpSession.igpPlatform {
        case .android:
            self.platform = .android
        case .blackBerry:
            self.platform = .blackberry
        case .ios:
            self.platform = .iOS
        case .linux:
            self.platform = .linux
        case .macOs:
            self.platform = .macOS
        case .unknownPlatform:
            self.platform = .unknown
        case .windows:
            self.platform = .windows
        case .UNRECOGNIZED(_):
            self.platform = .unknown
        }
        
        switch igpSession.igpDevice {
        case .mobile:
            self.device = .mobile
        case .pc:
            self.device = .desktop
        case .tablet:
            self.device = .tablet
        case .unknownDevice:
            self.device = .unknown
        case .UNRECOGNIZED(_):
            self.device = .unknown
        }
        switch igpSession.igpLanguage {
        case .enUs:
            self.language = .en_us
        case .faIr:
            self.language = .fa_ir
        case .UNRECOGNIZED(_):
            self.language = .en_us
        }
        
    }
}

