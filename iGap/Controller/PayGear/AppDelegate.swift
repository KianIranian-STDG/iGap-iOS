//
//  AppDelegate.swift
//  PayGear
//
//  Created by Amir on 3/27/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import maincore
import Fabric
import Crashlytics
import messages
//import

protocol ActionDelegate {
	func AppChangeLanguage()
}

@UIApplicationMain
class AppDelegate: App_SocketService, UIApplicationDelegate, App_ActionDelegate, PC_ActionDelegate {

    var window: UIWindow?
	var launchedShortcutItem: UIApplicationShortcutItem?
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        SMLangUtil.loadLanguage()
        UserDefaults.standard.set("ar", forKey: "lang")
        MCLocalization.load(from: core_utils.getResourcesBundle().url(forResource: "strings.json", withExtension: nil), defaultLanguage: "ar")
        MCLocalization.sharedInstance().language = "ar"
        SMUserManager.clearKeychainOnFirstRun()
        SMUserManager.loadFromKeychain()
//        SMInitialInfos.syncs()
        self.setupRootViews()
		UserDefaults.standard.set("", forKey: "deviceToken")
	    UIApplication.shared.statusBarStyle = .default
		UINavigationBar.appearance().tintColor = .white
		if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
			launchedShortcutItem = shortcutItem
		}
        
        // TODO: Move this to where you establish a user session
//        self.logUser()


		database.setup()
        return true
    }
    
//    func logUser() {
//        // TODO: Use the current user's information
//        // You can call any combination of these three methods
//        Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
//        Crashlytics.sharedInstance().setUserIdentifier("12345")
//        Crashlytics.sharedInstance().setUserName("Test User")
//    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       SMLog.SMPrint("recieved")
        if url.relativeString.contains("success"){
            let dataDict:[String: String] = ["order_id":  String(url.absoluteString.split(separator: "=")[1])]
            NotificationCenter.default.post(name: Notification.Name("ipg_success"), object: nil, userInfo:dataDict)
          SMMainTabBarController.packetTabNavigationController.popToRootViewController(animated: true)
          
        }
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        SMInitialInfos.syncs()
		NotificationCenter.default.post(name: Notification.Name("barcode"), object: nil)
        
        SMUserManager.refreshToken(delegate: self, onSuccess: { (response) in

        }, onFail: { (response) in
            NSLog("%@", "FailedHandler")
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		guard let shortcut = launchedShortcutItem else { return }
		
//		handleShortcut(shortcut)
		openDialog(shortcut.type)
		launchedShortcutItem = nil
    }
    
    
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if !SMUserManager.isLoggedIn || SMUserManager.profileLevelsCompleted != "4"{
            return
        }
        
        self.openDialog(shortcutItem.type)
        
        
    }
    
    
    /// Handle shortcut menu
    ///
    /// - Parameter button: button which rout to this action
    func openDialog(_ button:String){
		
        switch button {
        case "com.paygear.wallet.pay":
			NotificationCenter.default.post(name: Notification.Name(NotificationKeys.NKShortcutSelection), object: nil,userInfo : ["tab" : 0, "page" : 0])
        case "com.paygear.wallet.withdraw":
			NotificationCenter.default.post(name: Notification.Name(NotificationKeys.NKShortcutSelection), object: nil,userInfo : ["tab" : 0, "page" : 1])
        case "com.paygear.qr.scan":
			NotificationCenter.default.post(name: Notification.Name(NotificationKeys.NKShortcutSelection), object: nil,userInfo : ["tab" : 1, "page" : 0])
        case "com.paygear.qr.myQr":
			NotificationCenter.default.post(name: Notification.Name(NotificationKeys.NKShortcutSelection), object: nil,userInfo : ["tab" : 0,  "page" : 2])
            
        default:
            return
        }
    }
	
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        
    }
	
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

	// MARK: Handle Push notification
	func registerForPushNotifications(_ application : UIApplication) {
		
		if #available(iOS 10.0, *) {
			let center = UNUserNotificationCenter.current()
			center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
				// Enable or disable features based on authorization.
			}
			application.registerForRemoteNotifications()
			
		} else {
			// Fallback on earlier versions
		}
		
	}
	
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		
		let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
		UserDefaults.standard.set(deviceTokenString, forKey: "deviceToken")
		
		SMLog.SMPrint(deviceTokenString)
	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		
		SMLog.SMPrint("i am not available in simulator \(error)")
		UserDefaults.standard.set("", forKey: "deviceToken")
		
	}
	
    // MARK: - Core Data stack
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        let path = Bundle.main.path(forResource: "PayGear", ofType: "momd")!
        return NSManagedObjectModel(contentsOf: URL(string: path)!)!
        
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
    
    

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PayGear")
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

    // MARK: - Core Data Saving support
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
	
	func appChangeLanguage() {
		
		let navigation = SMNavigationController.shared
		navigation.setRootViewController(page: .Main)
	}
	
	/// Called from webservice pod to handle some errors
	func app_SwitchLogin() {
		
			SMUserManager.logout()
			//              show signup page
			let navigation = SMNavigationController.shared
			if (navigation.visibleViewController?.isKind(of: SMSignupViewController.self))! ||
				(navigation.visibleViewController?.isKind(of: SMLanguageViewController.self))! {
				return
			}
			navigation.style = .SMSignupStyle
			navigation.setRootViewController(page: .SignupPhonePage)

	}
	
	func setupRootViews(){
		
		self.window = UIWindow(frame: UIScreen.main.bounds)		
		let navigation = SMNavigationController.shared
		
		if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.ChooseLanguage.rawValue {
			navigation.style = .SMMainPageStyle
			navigation.setRootViewController(page: .ChooseLanguage)
		} else if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.Intro.rawValue {
			navigation.style = .NoStyle
			navigation.setRootViewController(page: .IntroPage)
		} else if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.Signup.rawValue {
			navigation.style = .NoStyle
			navigation.setRootViewController(page: .SignupPhonePage)
		} else if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.Login.rawValue {
			navigation.setRootViewController(page: .LoginPage)
		} else if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.SetPass.rawValue {
			navigation.setRootViewController(page: .SetPasswordPage)
		} else if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.Profile.rawValue {
			navigation.style = .NoStyle
			navigation.setRootViewController(page: .RefferalPage)
		} else {
            navigation.style = .NoStyle
            navigation.navigationBar.isHidden = true
			navigation.setRootViewController(page: .Splash)
		}
		
		self.window?.rootViewController = navigation
		self.window?.makeKeyAndVisible()
	}
	

	
	// MARK: - Message Action pod to handle payment from message
	/// Response to Request money from other user; when one of contact send request, if user select the payment
	/// this method calls
	func pc_OpenPayment(to Receiver: PU_obj_account!, thread_id ThreadId: String!) {

		if let vc = ((SMNavigationController.shared.viewControllers[0] as! SMMainTabBarController).viewControllers![2] as! SMNavigationController).viewControllers.first {
			
			let messageVC = vc as! SMMessageViewController
			
			messageVC.showPopupToSelectPaymentType(to: Receiver)
		}
	}
	/// Show receipt of payment ( It calles from message lists)
	func pc_OpenHistory(withTarget Target: UINavigationController!, orderid OrderId: String!) {
		
		if let vc = ((SMNavigationController.shared.viewControllers[0] as! SMMainTabBarController).viewControllers![2] as! SMNavigationController).viewControllers.first {
			
			let messageVC = vc as! SMMessageViewController
			
			messageVC.showReceipt(byOrderId: OrderId)
		}
	}
	
	/// When user select money action from message this method goes to be called
	func pc_OpenC2BSheet(withTarget Target: Any!, info Info: PAY_obj_paysheet!, istiny: Bool) {
		
		if let vc = ((SMNavigationController.shared.viewControllers[0] as! SMMainTabBarController).viewControllers![2] as! SMNavigationController).viewControllers.first {
			
			let messageVC = vc as! SMMessageViewController
			
			messageVC.confirmPaymentRequest(withTarget: Target, info: Info, istiny: istiny)
		}
	}
	

}

