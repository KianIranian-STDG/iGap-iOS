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
import Fabric
import Crashlytics
import RealmSwift
import FirebaseMessaging
import Firebase
import UserNotifications
import IGProtoBuff
import Intents
import CoreData
import messages
import maincore
import PushKit
import CallKit


@UIApplicationMain
class AppDelegate: App_SocketService, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate , PKPushRegistryDelegate, CXProviderDelegate {
 
    var timer = Timer()

    var window: UIWindow?
    var isNeedToSetNickname : Bool = true
    internal static var userIdRegister: Int64?
    internal static var usernameRegister: String?
    internal static var authorHashRegister: String?
    internal static var isFirstEnterToApp: Bool = true
    internal static var isUpdateAvailable : Bool = false
    internal static var isDeprecatedClient : Bool = false
    internal static var appIsInBackground : Bool = false
    
    // MARK: - Core Data stack
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application.
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let applicationDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let url = applicationDocumentsDirectory.appendingPathComponent("CoreData.sqlite")
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption:true]
            
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            SMLog.SMPrint("Unresolved error \(error)")
            abort()
        }
        
        return coordinator
    }()
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "iGap")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func clearAllFilesFromDirectory() {
        
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPathValue = documentsPath{
                
                let path = documentPathValue.replacingOccurrences(of: "file://", with: "")
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(path)")
                print("all files in cache: \(fileNames)")
                
                for fileName in fileNames {
                    
                    let tempPath = String(format: "%@/%@", path, fileName)
                    
                    //Check for specific file which you don't want to delete. For me .sqlite files
//                    if !tempPath.contains(".sql") {
//                        try fileManager.removeItem(atPath: tempPath)
//                    }
                }
            }
            
        } catch {
            print("Could not clear document directory \(error)")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        isActive = true
        if IGGlobal.isKeyPresentInUserDefaults(key: "textMessagesFontSize")  {
            fontDefaultSize = CGFloat(UserDefaults.standard.float(forKey: "textMessagesFontSize"))
        } else {
            fontDefaultSize = 15.0
        }
        lastLang = SMLangUtil.loadLanguage()
        if SMLangUtil.loadLanguage() == "fa" {
            IGGlobal.languageFileName = "localizationsFa"
        } else {
            IGGlobal.languageFileName = "localizationsEn"
        }
        let stringPath : String! = Bundle.main.path(forResource: IGGlobal.languageFileName, ofType: "json")
        MCLocalization.load(fromJSONFile: stringPath, defaultLanguage: SMLangUtil.loadLanguage())
        MCLocalization.sharedInstance().language = SMLangUtil.loadLanguage()

        if SMLangUtil.loadLanguage() == "fa" {
            UITableView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UITableView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        SMUserManager.clearKeychainOnFirstRun()
        SMUserManager.loadFromKeychain()
        realmConfig()
        Fabric.with([Crashlytics.self])
        _ = IGDatabaseManager.shared
        _ = IGWebSocketManager.sharedManager
        _ = IGFactory.shared
        _ = IGCallEventListener.sharedManager // detect cellular call state
        
        UITabBar.appearance().tintColor = UIColor.white
        
        let tabBarItemApperance = UITabBarItem.appearance()
        tabBarItemApperance.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor):UIColor.red]), for: UIControl.State.normal)
        tabBarItemApperance.setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor):UIColor.white]), for: UIControl.State.selected)

        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")

        pushNotification(application)
        detectBackground()
        IGGlobal.checkRealmFileSize()
        
//        ShortcutParser.shared.registerShortcuts()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        DeepLinkManager.shared.handleShortcut(item: shortcutItem)
    }

    func realmConfig() {
        let config = Realm.Configuration (
            // Share
            // fileURL: fileURL,
            
            schemaVersion: 38,//HINT: change schemaVersion in 'ShareConfig'
            
            /**
             * Set the block which will be called automatically when opening a Realm with a schema version lower than the one set above
             **/
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 37) {
                    // Nothing to do!
                    
                }
                
        }
        )
        Realm.Configuration.defaultConfiguration = config
        compactRealm()
        _ = try! Realm()
    }
    
    func compactRealm() {
        do {
            let defaultURL = Realm.Configuration.defaultConfiguration.fileURL!
            let defaultParentURL = defaultURL.deletingLastPathComponent()
            let compactedURL = defaultParentURL.appendingPathComponent("default-compact.realm")
            try autoreleasepool {
                let realm = try! Realm()
                try realm.writeCopy(toFile: compactedURL)
            }
            try FileManager.default.removeItem(at: defaultURL)
            try FileManager.default.moveItem(at: compactedURL, to: defaultURL)
        } catch let error {
            print(error)
        }
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
    
    func callRefreshToken() {
        SMUserManager.refreshToken(delegate: self, onSuccess: { (response) in
        }, onFail: { (response) in
            NSLog("%@", "FailedHandler")
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if !IGAppManager.sharedManager.isUserPreviouslyLoggedIn() {
            logoutAndShowRegisterViewController()
        } else {
            // handle any deeplink
            
            if IGAppManager.sharedManager.isUserLoggiedIn() {
                self.checkDeepLink()
            } else {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.checkDeepLink),
                                                       name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                       object: nil)
            }
        }
    }
    
    @objc private func checkDeepLink() {
        DeepLinkManager.shared.checkDeepLink()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
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
        self.voipRegistration()

    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
        voipRegistration()
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        if let roomId = userInfo["roomId"] as? String {
            let unreadCount = IGRoom.updateUnreadCount(roomId: Int64(roomId)!)
            application.applicationIconBadgeNumber = unreadCount
        }
        
        print(userInfo)
        
        
        switch UIApplication.shared.applicationState {
        case .active:
            //app is currently active, can update badges count here
            break
        case .inactive:
            //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            DeepLinkManager.shared.handleRemoteNotification(userInfo)
            break
        case .background:
            //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            break
        default:
            break
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
        UIApplication.shared.unregisterForRemoteNotifications()
        
        if mainRoot {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
        }
        
        IGAppManager.sharedManager.clearDataOnLogout()
        let storyboard : UIStoryboard = UIStoryboard(name: "Register", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGSplashNavigationController")
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    func goToSpash(mainRoot: Bool = false) {
        UIApplication.shared.unregisterForRemoteNotifications()
        
        if mainRoot {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
        }
        
//        IGAppManager.sharedManager.clearDataOnLogout()
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
    
    func showCallPage(userId: Int64 ,userName: String? = nil, isIncommmingCall: Bool = true, sdp: String? = nil, type:IGPSignalingOffer.IGPType = .voiceCalling, mode:String? = nil, showAlert: Bool = true){
        
        if isIncommmingCall || !showAlert {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let callPage = storyboard.instantiateViewController(withIdentifier: "IGCall") as! IGCall
            //Mark:- show Display Name of caller User if Nil we are not in terminate State
            callPage.callerName = userName ?? "UNKNOWN".localizedNew
            //End
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
            if mode != nil {
                if mode == "voiceCall" {
                    self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.voiceCalling, showAlert: false)
                    
                }
                else if mode == "videoCall"{
                    self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.videoCalling, showAlert: false)
                    
                }
                
            }
            else {
            let callAlert = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
            let voiceCall = UIAlertAction(title: "VOICE_CALL".localizedNew, style: .default, handler: { (action) in
                self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.voiceCalling, showAlert: false)
            })
            let videoCall = UIAlertAction(title: "VIDEO_CALL".localizedNew, style: .default, handler: { (action) in
                self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.videoCalling, showAlert: false)
            })
            let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
            
            callAlert.addAction(voiceCall)
            callAlert.addAction(videoCall)
            callAlert.addAction(cancel)
            
            self.window?.rootViewController?.present(callAlert, animated: true, completion: nil)
        }
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
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: (#selector(IGCall.canRotate)))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        // Only allow portrait (standard behaviour)
        return .portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if #available(iOS 10.0, *) {
            if let interaction = userActivity.interaction {
                var personHandle: INPersonHandle?
                if let startVideoCallIntent = interaction.intent as? INStartVideoCallIntent {
                    personHandle = startVideoCallIntent.contacts?[0].personHandle
                } else if let startAudioCallIntent = interaction.intent as? INStartAudioCallIntent {
                    personHandle = startAudioCallIntent.contacts?[0].personHandle
                }
                CallManager.waitingPhoneCall = personHandle?.value
                CallManager.nativeCallManager()
            }
        }
        return true
    }

    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /*****************************************************************************************************/
    /***************************************** Deep Link Handler *****************************************/
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
//        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        let host = urlComponents?.host ?? ""
//        
//        if host == "resolve" {
//            let sb = UIStoryboard(name: "Main", bundle: .main)
//            let secretVC = sb.instantiateViewController(withIdentifier: "IGMessageViewController") as? IGMessageViewController
//            let messageID : String?
//            let RoomID : String?
//            let _ : String?
//            RoomID = urlComponents?.queryItems?.first?.value
//            messageID = urlComponents?.queryItems?.last?.value
//            let strAsNSString = messageID! as NSString
//            _ = strAsNSString.longLongValue
//            let predicate = NSPredicate(format: "channelRoom.publicExtra.username = %@", RoomID!)
//            if let room = try! Realm().objects(IGRoom.self).filter(predicate).first {
//                secretVC!.room = room
//                window?.rootViewController = secretVC
//            }
//        }
        print(url)
        return DeepLinkManager.shared.handleDeeplink(url: url)
        
//        return false
    }
    
    /******************************************************************************************************/
    /********************************************** Push Kit **********************************************/
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {}
    
    func providerDidReset(_ provider: CXProvider) {}
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        let payloadDict = payload.dictionaryPayload["data"]! as! Dictionary<String, Any>
        let name = payloadDict["name"]! as Any
        let userId = payloadDict["userID"]! as Any
        
        showCallPage(userId: userId as! Int64 , userName: (name as! String))
    }
    
    func voipRegistration () {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
