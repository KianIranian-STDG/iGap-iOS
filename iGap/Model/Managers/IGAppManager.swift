/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation
import UIKit
import IGProtoBuff
import SwiftProtobuf
import RealmSwift
import RxSwift
import WebRTC
import FirebaseInstanceID

class IGAppManager: NSObject {
    static let sharedManager = IGAppManager()
    internal static var iceServersStatic: [RTCIceServer] = []
    
    enum ConnectionStatus {
        case waitingForNetwork
        case connecting
        case connected
        case iGap // login state
    }
    
    var realm = try! Realm()
    var connectionStatus: Variable<ConnectionStatus>
    static var connectionStatusStatic: IGAppManager.ConnectionStatus?
    var isUserLoggedIn:   Variable<Bool>
    var isTryingToLoginUser: Bool = false
    var currentMessagesNotificationToekn: NotificationToken?
    
    private var _loginToken: String?
    private var _username: String?
    private var _userID: Int64?
    private var _authorHash: String?
    private var _nickname: String?
    private var _mapEnable: Bool = false
    private var _mplActive: Bool = false
    private var _md5Hex: String?
    private var _walletRegistered: Bool = false
    private var _walletActive: Bool = false
    private var _AccessToken: String!

    public let LOAD_ROOM_LIMIT = 15
    
    private override init() {
        connectionStatus = Variable(.waitingForNetwork)
        isUserLoggedIn   = Variable(false)
        super.init()
    }
    
    public func setNetworkConnectionStatus(_ status: ConnectionStatus) {
        self.connectionStatus.value = status
    }
    
    public func setUserUpdateStatus(status: IGRegisteredUser.IGLastSeenStatus) {
            IGUserUpdateStatusRequest.Generator.generate(userStatus: status).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let userUpdateStatus as IGPUserUpdateStatusResponse:
                        IGUserUpdateStatusRequest.Handler.interpret(response: userUpdateStatus)
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                    
                default:
                    break
                }
            }).send()
        
    }

    public func clearDataOnLogout() {
        IGDatabaseManager.shared.emptyQueue()
        IGRequestManager.sharedManager.userDidLogout()
        IGHelperPreferences.shared.removeAllPreferences()
        try! realm.write {
            realm.deleteAll()
            
            let room = realm.objects(IGFile.self)
            let room1 = realm.objects(IGUserPrivacy.self)
            let room2 = realm.objects(IGAvatar.self)
            let room4 = realm.objects(IGRoom.self)
            let room5 = realm.objects(IGChatRoom.self)
            let room6 = realm.objects(IGGroupRoom.self)
            let room7 = realm.objects(IGChannelRoom.self)
            let room8 = realm.objects(IGRoomDraft.self)
            let room9 = realm.objects(IGRoomMessage.self)
            let room10 = realm.objects(IGRoomMessageLocation.self)
            let room11 = realm.objects(IGRoomMessageLog.self)
            let room12 = realm.objects(IGRoomMessageContact.self)
            let room13 = realm.objects(IGSignaling.self)
            let room14 = realm.objects(IGSessionInfo.self)
            let room16 = realm.objects(IGRegisteredUser.self)
            let room17 = realm.objects(IGContact.self)
            let room20 = realm.objects(IGRealmClientSearchUsername.self)
            
            realm.delete(room)
            realm.delete(room1)
            realm.delete(room2)
            realm.delete(room4)
            realm.delete(room5)
            realm.delete(room6)
            realm.delete(room7)
            realm.delete(room8)
            realm.delete(room9)
            realm.delete(room10)
            realm.delete(room11)
            realm.delete(room12)
            realm.delete(room13)
            realm.delete(room14)
            realm.delete(room16)
            realm.delete(room17)
            realm.delete(room20)
        }
        _loginToken = nil
        _username = nil
        _userID = nil
        _authorHash = nil
        _nickname = nil
        _mapEnable = false
    }
    
    public func isUserPreviouslyLoggedIn() -> Bool {
        if let sessionInfo = realm.objects(IGSessionInfo.self).first {
            if sessionInfo.loginToken != nil {
                fillUserInfo(sessionInfo: sessionInfo)
                return true
            }
        }
        return false
    }
    
    private func fillUserInfo(sessionInfo: IGSessionInfo? = nil){
        
        var info : IGSessionInfo?
        if sessionInfo == nil {
            let realm = try! Realm()
            info = realm.objects(IGSessionInfo.self).first
        } else {
            info = sessionInfo
        }
        
        if info != nil {
            _loginToken = info?.loginToken
            _username = info?.username
            _userID = info?.userID
            _nickname = info?.nickname
            _authorHash = info?.authorHash
        }
    }
    
    /**
     * reset app value after than connection lost
     **/
    public func resetApp(){
        IGDownloadManager.sharedManager.pauseAllDownloads()
        IGUploadManager.sharedManager.pauseAllUploads()
        IGContactManager.importedContact = false // for allow user that import contact list after than logged in again
        IGRecentsTableViewController.needGetInfo = true
        IGDashboardViewController.needGetFirstPage = true
        
        if let delegate = RTCClient.getInstance()?.callStateDelegate {
            delegate.onStateChange(state: RTCClientConnectionState.Unavailable)
        }
    }
    
    public func setUserLoginSuccessful() {
        isUserLoggedIn.value = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName), object: nil)
    }
    
    public func getSignalingConfiguration(force:Bool = false){
        let realm = try! Realm()
        let signalingConfig = realm.objects(IGSignaling.self).first
        if signalingConfig == nil || force {
            IGSignalingGetConfigurationRequest.Generator.generate().success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let configurationResponse as IGPSignalingGetConfigurationResponse:
                        IGSignalingGetConfigurationRequest.Handler.interpret(response: configurationResponse)
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self.getSignalingConfiguration()
                    break
                default:
                    break
                }
            }).send()
        }
    }
    
    public func isUserLoggiedIn() -> Bool {
        return isUserLoggedIn.value
    }
    
    public func save(token: String?) {
        _loginToken = token
        
        if _username == nil || _username == "" {
            _username = AppDelegate.usernameRegister
        }
        
        if _userID == nil || _userID == 0 {
            _userID = AppDelegate.userIdRegister
        }
        
        if _authorHash == nil || _authorHash == "" {
            _authorHash = AppDelegate.authorHashRegister
        }
        
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.loginToken = token
                sessionInto.username = _username
                sessionInto.userID = _userID!
                sessionInto.authorHash = _authorHash
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.loginToken = token
            sessionInto.username = _username
            sessionInto.userID = _userID!
            sessionInto.authorHash = _authorHash
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(username: String?) {
        AppDelegate.usernameRegister = username
        _username = username
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.username = username
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.username = username
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(userID: Int64?) {
        AppDelegate.userIdRegister = userID
        _userID = userID
        var userId: Int64 = -1
        if userID != nil {
            userId = userID!
        }
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.userID = userId
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.userID = userId
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(authorHash: String?) {
        AppDelegate.authorHashRegister = authorHash
        _authorHash = authorHash
        if let sessionInto = realm.objects(IGSessionInfo.self).first {
            try! realm.write {
                sessionInto.authorHash = authorHash
            }
        } else {
            let sessionInto = IGSessionInfo()
            sessionInto.authorHash = authorHash
            try! realm.write {
                realm.add(sessionInto, update: true)
            }
        }
    }
    
    public func save(nickname: String) {
        _nickname = nickname
    }
    
    public func loginToken() -> String? {
        return _loginToken
    }
    
    public func getAccessToken() -> String? {
        if let session = IGDatabaseManager.shared.realm.objects(IGSessionInfo.self).first {
            return session.accessToken
        } else {
            return nil
        }
    }
    
    public func username() -> String? {
        return _username
    }
    
    public func userID() -> Int64? {
        return _userID
    }
    
    public func authorHash() -> String? {
        return _authorHash
    }
    
    public func nickname() -> String? {
        return _nickname
    }
    
    public func mapEnable() -> Bool {
        return _mapEnable
    }
    
    public func setMapEnable(enable: Bool) {
        _mapEnable = enable
    }
    
    public func mplActive() -> Bool {
        return _mplActive
    }
    public func md5Hex() -> String {
        return _md5Hex!
    }
    
    public func setWalletRegistered(enable: Bool) {
        _walletRegistered = enable
    }
    public func walletRegistered() -> Bool {
        return _walletRegistered
    }
    
    public func setMplActive(enable: Bool) {
        _mplActive = enable
    }
    public func setMd5Hex(md5Hex: String) {
        _md5Hex = md5Hex
    }
    
    public func walletActive() -> Bool {
        return _walletActive
    }
    
    public func setWalletActive(enable: Bool) {
        _walletActive = enable
    }
    
    public func setAccessToken(accessToken: String) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                if let session = IGDatabaseManager.shared.realm.objects(IGSessionInfo.self).first {
                    session.accessToken = accessToken
                }
            }
        }
    }
    
    public func login() {
        if !self.isTryingToLoginUser {
            self.isTryingToLoginUser = true
            
            if _loginToken == nil {
                fillUserInfo()
            }
            
            if _loginToken != nil {
                IGUserLoginRequest.Generator.generate(token: _loginToken!).success({ (responseProto) in
                    DispatchQueue.main.async {
                        self.isTryingToLoginUser = false
                        switch responseProto {
                        case _ as IGPUserLoginResponse:
                            self.setUserLoginSuccessful()
                            IGUserLoginRequest.Handler.intrepret(response: (responseProto as? IGPUserLoginResponse)!)
                            self.setUserUpdateStatus(status: .online)
                            self.getSignalingConfiguration(force: true)
                            self.getGeoRegisterStatus()
                            break
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    self.isTryingToLoginUser = false
                    switch errorCode {
                    case .userLoginFailed, .userLoginFailedOne, .userLoginFailedTwo, .userLoginFailedThree, .userLoginFaieldUserIsBlocked:
                        DispatchQueue.main.async {
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.showLoginFaieldAlert(title: "Login Failed")
                        }
                    default:
                        break
                    }
                }).send()
            } else {
                DispatchQueue.main.async {
                    // no token or no author hash
                    self.isTryingToLoginUser = false
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    UIApplication.shared.unregisterForRemoteNotifications()
//                    IGAppManager.sharedManager.clearDataOnLogout()
//                    let registerVC = IGSplashScreenViewController.instantiateFromAppStroryboard(appStoryboard: .Register)
//                    UIApplication.topViewController()?.navigationController!.pushViewController(registerVC, animated:true)

//                    appDelegate.showLoginFaieldAlert(title: "Login Failed" , message: "User info not exist")
                }
            }
            
        }
        
    }
    
    public func getGeoRegisterStatus(){
        IGGeoGetRegisterStatus.Generator.generate().success({ (responseProto) in
            DispatchQueue.main.async {
                if let geoStatus = responseProto as? IGPGeoGetRegisterStatusResponse {
                    self._mapEnable = geoStatus.igpEnable
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getGeoRegisterStatus()
            default:
                break
            }
        }).send()
    }
    
}
