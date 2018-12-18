/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import Fabric
import Crashlytics
import RealmSwift
import FirebaseMessaging
import Firebase
import UserNotifications
import IGProtoBuff

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var isNeedToSetNickname : Bool = true
    internal static let showPrint = false
    internal static var userIdRegister: Int64?
    internal static var usernameRegister: String?
    internal static var authorHashRegister: String?
    internal static var isFirstEnterToApp: Bool = true
    internal static var isUpdateAvailable : Bool = false
    internal static var isDeprecatedClient : Bool = false
    internal static var appIsInBackground : Bool = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        let config = Realm.Configuration(schemaVersion: try! schemaVersionAtURL(Realm.Configuration.defaultConfiguration.fileURL!) + 1)
//        Realm.Configuration.defaultConfiguration = config
//        
//        _ = try! Realm()
        
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.im.iGap")!
            .appendingPathComponent("default.realm")
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
            if FileManager.default.fileExists(atPath: defaultRealmPath.path) {
                do {
                    try FileManager.default.copyItem(atPath: defaultRealmPath.path, toPath: fileURL.path)
                } catch let error as NSError {
                    print("error occurred, here are the details:\n \(error)")
                }
            }
        }
        
        let config = Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: 21,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                } else if (oldSchemaVersion < 2) {
                    //Logout users. due to the missing of authorHash
                } else if (oldSchemaVersion < 3) {
                    //version 0.0.5 build 290
                } else if (oldSchemaVersion < 4) {
                    //version 0.0.6 build 291
                } else if (oldSchemaVersion < 5) {
                    //version 0.0.7 build 292
                } else if (oldSchemaVersion < 6) {
                    //version 0.0.8 build 293
                } else if (oldSchemaVersion < 7) { //version 0.1.0 : 7
                    //version 0.0.11
                } else if (oldSchemaVersion < 8) {
                    //version 0.1.5 build 449
                } else if (oldSchemaVersion < 9) {
                    //version 0.2.0 build 452
                } else if (oldSchemaVersion < 10) {
                    //version 0.3.0 build 453
                } else if (oldSchemaVersion < 11) {
                    //version 0.3.1 build 454
                } else if (oldSchemaVersion < 12) {
                    //version 0.3.2 build 455
                } else if (oldSchemaVersion < 13) {
                    //version 0.4.6 build 461
                } else if (oldSchemaVersion < 14) {
                    //version 0.4.7 build 462
                } else if (oldSchemaVersion < 15) {
                    //version 0.4.8 build 463
                } else if (oldSchemaVersion < 16) {
                    //version 0.6.0 build 467
                } else if (oldSchemaVersion < 17) {
                    //version 0.6.5 build 472
                } else if (oldSchemaVersion < 18) {
                    //version 0.6.7 build 474
                } else if (oldSchemaVersion < 19) {
                    //version 0.6.9 build 476 add priority in IGRoom
                } else if (oldSchemaVersion < 20) {
                    //version 0.7.1 build 478 add IGShareInfo
                } else if (oldSchemaVersion < 21) {
                    //version 0.7.2 build 479 add isPromote Option
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        
        Fabric.with([Crashlytics.self])
        _ = IGDatabaseManager.shared
        _ = IGWebSocketManager.sharedManager
        _ = IGFactory.shared
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.sound.rawValue | UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue), categories: nil ))
        
        UITabBar.appearance().tintColor = UIColor.white
        //UITabBar.appearance().barTintColor = UIColor(red: 0.0, green: 176.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        
        let tabBarItemApperance = UITabBarItem.appearance()
        tabBarItemApperance.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.red], for: UIControlState.normal)
        tabBarItemApperance.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white], for: UIControlState.selected)
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")

        pushNotification(application)
        detectBackground()
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AppDelegate.appIsInBackground = true
        IGAppManager.sharedManager.setUserUpdateStatus(status: .exactly)
        
        /* change this values for import contact after than contact changed in phone contact */
        IGContactManager.syncedPhoneBookContact = false
        IGContactManager.importedContact = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AppDelegate.appIsInBackground = false
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            IGHelperGetShareData.manageShareDate()
            IGAppManager.sharedManager.setUserUpdateStatus(status: .online)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if !IGAppManager.sharedManager.isUserPreviouslyLoggedIn() {
            logoutAndShowRegisterViewController()
        } 
    }

    func applicationWillTerminate(_ application: UIApplication) {
    
    }
    
    /******************* Notificaton Start *******************/
    
    func pushNotification(_ application: UIApplication){
        FirebaseApp.configure()
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if #available(iOS 10.0, *) { // For iOS 10 display notification (sent via APNS)
            /**
             * execute following code in "IGRecentsTableViewController" and don't execute here,
             * for avoid from show permission alert in start of app when user not registered yet
             **/
            //UNUserNotificationCenter.current().delegate = self
            //let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .carPlay]
            //UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let roomId = userInfo["roomId"] as? String {
            let unreadCount = IGRoom.updateUnreadCount(roomId: Int64(roomId)!)
            application.applicationIconBadgeNumber = unreadCount
        }
    }
    /******************* Notificaton End *******************/
    
    private func detectBackground() {
        
        if IGWallpaperPreview.chatSolidColor == nil {
            if let wallpaper = try! Realm().objects(IGRealmWallpaper.self).first {
                if let color = wallpaper.selectedColor {
                    IGWallpaperPreview.chatSolidColor = color
                    return
                }
            }
        }
        
        if IGWallpaperPreview.chatWallpaper == nil {
            if let wallpaper = try! Realm().objects(IGRealmWallpaper.self).first {
                IGWallpaperPreview.chatWallpaper = wallpaper.selectedFile
            }
        }
    }
    
    
    func logoutAndShowRegisterViewController(mainRoot: Bool = false) {
        if mainRoot {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
        }
        
        IGAppManager.sharedManager.clearDataOnLogout()
        let storyboard : UIStoryboard = UIStoryboard(name: "Register", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGSplashNavigationController")
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    func showRegistrationSetpProfileInfo() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Register", bundle: nil)
        let setNicknameVC = storyboard.instantiateViewController(withIdentifier: "RegistrationStepProfileInfo")
        let navigationBar = UINavigationController(rootViewController: setNicknameVC)
        self.window?.rootViewController?.present(navigationBar, animated: true, completion: {
            self.isNeedToSetNickname = false
        })
    }
    
    func showCallPage(userId: Int64 , isIncommmingCall: Bool = true, sdp: String? = nil, type:IGPSignalingOffer.IGPType = .voiceCalling, showAlert: Bool = true){
        
        if isIncommmingCall || !showAlert {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let callPage = storyboard.instantiateViewController(withIdentifier: "IGCall") as! IGCall
            callPage.userId = userId
            callPage.isIncommingCall = isIncommmingCall
            callPage.callType = type
            callPage.callSdp = sdp
            
            var currentController = self.window?.rootViewController
            if let presentedController = currentController!.presentedViewController {
                currentController = presentedController
            }
            currentController!.present(callPage, animated: true, completion: nil)
            
        } else {
            let callAlert = UIAlertController(title: nil, message: "Select the type of call", preferredStyle: IGGlobal.detectAlertStyle())
            let voiceCall = UIAlertAction(title: "Voice Call", style: .default, handler: { (action) in
                self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.voiceCalling, showAlert: false)
            })
            let videoCall = UIAlertAction(title: "Video Call", style: .default, handler: { (action) in
                self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.videoCalling, showAlert: false)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            callAlert.addAction(voiceCall)
            callAlert.addAction(videoCall)
            callAlert.addAction(cancel)
            
            self.window?.rootViewController?.present(callAlert, animated: true, completion: nil)
        }
    }
    
    func showCallQualityPage(rateId: Int64){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let callQualityPage = storyboard.instantiateViewController(withIdentifier: "IGCallQualityShowing") as! IGCallQuality
        callQualityPage.rateId = rateId
        self.window?.rootViewController?.present(callQualityPage, animated: true, completion: nil)
    }
    
    func showLoginFaieldAlert(title: String = "Login Failed", message: String = "There was a problem logging you in. Please login again") {
        let badLoginAC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.logoutAndShowRegisterViewController()
        })
        badLoginAC.addAction(ok)
        self.window?.rootViewController?.present(badLoginAC, animated: true, completion: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let statusBarRect = UIApplication.shared.statusBarFrame
        guard let touchPoint = event?.allTouches?.first?.location(in: self.window) else { return }
        
        if statusBarRect.contains(touchPoint) {
            NotificationCenter.default.post(IGNotificationStatusBarTapped)
        }
    }
}

