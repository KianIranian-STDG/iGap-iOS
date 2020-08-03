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
import SwiftEventBus
import AsyncDisplayKit
import SDWebImage
import SDWebImageWebPCoder

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
    
    var backTask: UIBackgroundTaskIdentifier = .invalid
    var backTaskTimer : Timer!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //checksetting defaults
        userdefaultsManagment()
        
        LocaleManager.setup()
        
        UITableView.appearance().semanticContentAttribute = LocaleManager.semantic
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        SMUserManager.clearKeychainOnFirstRun()
        SMUserManager.loadFromKeychain()
        realmConfig()
        Fabric.with([Crashlytics.self])
        _ = IGDatabaseManager.shared
        _ = IGWebSocketManager.sharedManager
        _ = IGFactory.shared
        _ = IGCallEventListener.sharedManager // detect cellular call state
        IGInitialConfig.sharedConfig.getInitialConfig {}
        
        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        pushNotification(application)
        detectBackground()
        IGGlobal.checkRealmFileSize()
        
        // select initial page if logged in or not
        if IGAppManager.sharedManager.isUserPreviouslyLoggedIn() {
            RootVCSwitcher.updateRootVC(storyBoard: "Main", viewControllerID: "MainTabBar")
        } else {
            logoutAndShowRegisterViewController()
        }
        
        
        //        ShortcutParser.shared.registerShortcuts()
        
        //        let x : [AnyHashable: Any] = ["deepLink": "discovery/3/311"]
        //        DeepLinkManager.shared.handleRemoteNotification(x)
        
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "hasRunBefore") {
            
            // Remove KeyChain Old Data
            let keychain = KeychainSwift()
            keychain.clear()
            
            userDefaults.set(true, forKey: "hasRunBefore")
        }
        
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        DeepLinkManager.shared.handleShortcut(item: shortcutItem)
    }
     
    func realmConfig() {
        let config = Realm.Configuration (
            schemaVersion: 58//HINT: change schemaVersion in 'ShareConfig'
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
        activateBackgroundTask()
        /* change this values for import contact after than contact changed in phone contact */
        IGContactManager.syncedPhoneBookContact = false
        IGContactManager.importedContact = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        AppDelegate.appIsInBackground = false
        deactivateBackGroundTask()
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
        // handle any deeplink
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            self.checkDeepLink()
        } else {
            SwiftEventBus.on(self, name: EventBusManager.login, queue: OperationQueue.current) { [weak self] (result) in
                self?.checkDeepLink()
            }
        }
    }
    
    private func checkDeepLink() {
        SwiftEventBus.unregister(self, name: EventBusManager.login)
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
    
    func deleteToken() {
        let instance = InstanceID.instanceID()
        instance.deleteID { (error) in
            print(error.debugDescription)
        }

    }
    func refreshFCMToken() {
        let instance = InstanceID.instanceID()
        instance.instanceID { (result, error) in
          if let error = error {
            print("Error fetching FCMRemote Instance ID: \(error)")
          } else {
            print("FCMRemote instance ID token: \(String(describing: result?.token))")
          }
        }
        Messaging.messaging().shouldEstablishDirectChannel = true

    }
    
    func pushNotification(_ application: UIApplication) {
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
        voipRegistration()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCMRemote Token: \(fcmToken)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
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
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
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
    
    func logoutAndShowRegisterViewController() {
        UIApplication.shared.unregisterForRemoteNotifications()
        
        IGAppManager.sharedManager.clearDataOnLogout()
        RootVCSwitcher.updateRootVC(storyBoard: "Register", viewControllerID: "IGSplashViewController")
    }
    
    func goToSpash(mainRoot: Bool = false) {
        UIApplication.shared.unregisterForRemoteNotifications()
        
        if mainRoot {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController()
        }
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Register", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGIntroductionViewController")
        vc.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
    }
    
    func showRegistrationSetpProfileInfo() {
        DispatchQueue.main.async {
            let storyboard : UIStoryboard = UIStoryboard(name: "Register", bundle: nil)
            let setNicknameVC = storyboard.instantiateViewController(withIdentifier: "RegistrationStepProfileInfo")
            setNicknameVC.modalPresentationStyle = .fullScreen

            let navigationBar = UINavigationController(rootViewController: setNicknameVC)
            self.window?.rootViewController?.present(navigationBar, animated: true, completion: {
                self.isNeedToSetNickname = false
            })
        }
    }
    
    func showCallPage(userId: Int64 ,userName: String? = nil, isIncommmingCall: Bool = true, sdp: String? = nil, type:IGPSignalingOffer.IGPType = .voiceCalling, mode:String? = nil, showAlert: Bool = true){
        
        if isIncommmingCall || !showAlert {
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let callPage = storyboard.instantiateViewController(withIdentifier: "IGCall") as! IGCall
            //Mark:- show Display Name of caller User if Nil we are not in terminate State
            callPage.callerName = userName ?? IGStringsManager.Unknown.rawValue.localized
            //End
            callPage.userId = userId
            callPage.isIncommingCall = isIncommmingCall
            callPage.callType = type
            callPage.callSdp = sdp
            
            var currentController = self.window?.rootViewController
            if let presentedController = currentController!.presentedViewController {
                currentController = presentedController
            }
            callPage.modalPresentationStyle = .fullScreen
            currentController!.present(callPage, animated: true, completion: nil)
            
        } else {
            if mode != nil {
                if mode == "voiceCall" {
                    self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.voiceCalling, showAlert: false)
                    
                }
                else if mode == "videoCall"{
                    self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.videoCalling, showAlert: false)
                    
                }
                
            } else {
                let callAlert = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
                let voiceCall = UIAlertAction(title: IGStringsManager.VoiceCall.rawValue.localized, style: .default, handler: { (action) in
                    self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.voiceCalling, showAlert: false)
                })
                let videoCall = UIAlertAction(title: IGStringsManager.VideoCall.rawValue.localized, style: .default, handler: { (action) in
                    self.showCallPage(userId: userId, isIncommmingCall: isIncommmingCall, sdp: sdp, type: IGPSignalingOffer.IGPType.videoCalling, showAlert: false)
                })
                let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
                
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
//        let badLoginAC = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//            self.logoutAndShowRegisterViewController()
//        })
//        badLoginAC.addAction(ok)
//        self.window?.rootViewController?.present(badLoginAC, animated: true, completion: nil)
        self.logoutAndShowRegisterViewController() // comment this line if the alert was unhidden

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
        return DeepLinkManager.shared.handleDeeplink(url: url)
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
    
    private func userdefaultsManagment() {
        if (UserDefaults.standard.object(forKey: "silentPrivateChat") != nil) {
            IGGlobal.isSilent = UserDefaults.standard.bool(forKey: "silentPrivateChat")
        }
        if IGGlobal.isKeyPresentInUserDefaults(key: "textMessagesFontSize")  {
            fontDefaultSize = CGFloat(UserDefaults.standard.float(forKey: "textMessagesFontSize"))
        } else {
            fontDefaultSize = 15.0
        }
        manageTheme()
    }
    private func manageColorSet(mode: String = "IGAPClassic") {
        let currentColorSet = UserDefaults.standard.string(forKey: "CurrentColorSet") ?? "IGAPDefaultColor"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
        let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
        if mode == "IGAPClassic" {
            switch currentColorSet {
            default:
                DefaultColorSetManager.currentColorSet = DefaultColorSet()
                SwiftEventBus.post("initTheme")
                break
            }
            
        } else if mode == "IGAPDay" {
            
            switch currentColorSetLight {
            case "IGAPBlue" :
                DayColorSetManager.currentColorSet = BlueColorSet()
                break
            case "IGAPTorquoise" :
                DayColorSetManager.currentColorSet = TorquoiseColorSet()
                break
                
            case "IGAPGreen" :
                DayColorSetManager.currentColorSet = GreenColorSet()
                break
                
            case "IGAPPink" :
                DayColorSetManager.currentColorSet = PinkColorSet()
                break
                
            case "IGAPOrange" :
                DayColorSetManager.currentColorSet = OrangeColorSet()
                break
                
            case "IGAPPurple" :
                DayColorSetManager.currentColorSet = PurpleColorSet()
                break
                
            case "IGAPRed" :
                DayColorSetManager.currentColorSet = RedColorSet()
                break
                
            case "IGAPGold" :
                DayColorSetManager.currentColorSet = GoldColorSet()
                break
                
            case "IGAPLightGray" :
                DayColorSetManager.currentColorSet = LightGrayColorSet()
                break
          case "IGAPBlack" :
                DayColorSetManager.currentColorSet = BWColorSet()
                break
                
            default: break
            }
            SwiftEventBus.post("initTheme")

        } else {
            
            switch currentColorSetDark {
            case "IGAPBlue" :
                NightColorSetManager.currentColorSet = BlueColorSetNight()
                break
            case "IGAPTorquoise" :
                NightColorSetManager.currentColorSet = TorquoiseColorSetNight()
                break
                
            case "IGAPGreen" :
                NightColorSetManager.currentColorSet = GreenColorSetNight()
                break
                
            case "IGAPPink" :
                NightColorSetManager.currentColorSet = PinkColorSetNight()
                break
                
            case "IGAPOrange" :
                NightColorSetManager.currentColorSet = OrangeColorSetNight()
                break
                
            case "IGAPPurple" :
                NightColorSetManager.currentColorSet = PurpleColorSetNight()
                break
                
            case "IGAPRed" :
                NightColorSetManager.currentColorSet = RedColorSetNight()
                break
                
            case "IGAPGold" :
                NightColorSetManager.currentColorSet = GoldColorSetNight()
                break
                
            case "IGAPLightGray" :
                NightColorSetManager.currentColorSet = LightGrayColorSetNight()
                break
            case "IGAPBlack" :
                NightColorSetManager.currentColorSet = BWColorSetNight()
                break
                
            default: break
            }
            SwiftEventBus.post("initTheme")

        }
    }
    private func manageTheme() {
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        
        switch currentTheme {
        case "IGAPClassic" :
            ThemeManager.currentTheme = ClassicTheme()
            manageColorSet(mode: "IGAPClassic")
        case "IGAPDay" :
            ThemeManager.currentTheme = DayTheme()
            manageColorSet(mode: "IGAPDay")
        case "IGAPNight" :
            ThemeManager.currentTheme = NightTheme()
            manageColorSet(mode: "IGAPNight")

        default:
            ThemeManager.currentTheme = ClassicTheme()
            manageColorSet(mode: "IGAPClassic")
        }
        
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


    // MARK: - Keep App Active in background
extension AppDelegate {
    
    
    func activateBackgroundTask() {
        
        backTaskTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(backTaskTimerAction), userInfo: nil, repeats: false)
        
        backTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let sSelf = self else {
                return
            }
            UIApplication.shared.endBackgroundTask(sSelf.backTask)
            sSelf.backTask = .invalid
            return


        })
    }
    
    @objc private func backTaskTimerAction() {
        var i = 0
        i += 1
    }
    
    private func deactivateBackGroundTask() {
        if (backTaskTimer != nil) {
            backTaskTimer.invalidate()
        }
        UIApplication.shared.endBackgroundTask(backTask)
        backTask = .invalid
    }
    
}
