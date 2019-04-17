//
//  SMUserManager.swift
//  PayGear
//
//  Created by amir soltani on 4/15/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//


import UIKit
import KeychainSwift
import webservice

class SMUserManager: NSObject {
	
	
	enum CurrentStep : String {
		case ChooseLanguage = "5"
		case Intro			= "0"
		case Signup			= "1"
		case Login			= "2"
		case SetPass		= "3"
		case Main			= "4"
		case Profile		= "6"
	}
	
	static let imageSource = "https://api.paygeer.ir/files/v3/"

    static var token:String?
    static var profilePictureId:String?
	static var mobileNumber:String?
    static var profileCompleteFromServer:Bool?
    static var profileLevelsCompleted:String?
	static var accountType:Int64 = 2
	
    static func resetUserData() {
        
        SMUserManager.userName = ""
        SMUserManager.accountId = ""
        SMUserManager.proviencId = ""
        SMUserManager.email = ""
        SMUserManager.birthDate = ""
        SMUserManager.firstName = ""
        SMUserManager.lastName = ""
        SMUserManager.publicKey = ""
        SMUserManager.payToken = ""
        SMUserManager.payGearToken = ""
        SMUserManager.mobileNumber = ""
		SMCard.deleteAllCardsFromDB()
		SMMerchant.deleteAllMerchantsFromDB()
		SMImage.saveImage(image: UIImage.init(named: "user")! , withName: "profile.png")
        SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.ChooseLanguage.rawValue
		
		UserDefaults.standard.removeObject(forKey: "pin")
		UserDefaults.standard.removeObject(forKey: "isUpdateAvailable")
		UserDefaults.standard.removeObject(forKey: "barcodeTipIsShown")
		UserDefaults.standard.synchronize()
		
		
//		#import "WS_SecurityManager.h"
		let securityManager = WS_SecurityManager.init()
		securityManager.clear()
		
    }
	
	static func changeAccount(_ merchant: SMMerchant) {
		
		SMUserManager.userName = merchant.username ?? ""
		SMUserManager.accountId = merchant.id!
//		SMUserManager.proviencId = ""
//		SMUserManager.email = ""
//		SMUserManager.birthDate = ""
		SMUserManager.firstName = merchant.name!
		SMUserManager.accountType = merchant.accountType!
//		SMUserManager.lastName = ""
//		SMUserManager.publicKey = ""
//		SMUserManager.payToken = ""
//		SMUserManager.payGearToken = ""
//		SMUserManager.mobileNumber = ""
		
	}
    static var userName: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userName")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "userName") != nil {
                return UserDefaults.standard.string(forKey: "userName")!
            }
            return ""
        }
    }
    
    
    static var accountId: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "accountId")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "accountId") != nil {
                return UserDefaults.standard.string(forKey: "accountId")!
            }
            return ""
        }
        
    }
	
	static var proviencId: String {
		
		set {
			UserDefaults.standard.setValue(newValue, forKey: "proviencId")
			UserDefaults.standard.synchronize()
		}
		get {
			if UserDefaults.standard.object(forKey: "proviencId") != nil {
				return UserDefaults.standard.string(forKey: "proviencId")!
			}
			return ""
		}
	}
    
	static var email:String {
		
		set {
			UserDefaults.standard.setValue(newValue, forKey: "email")
			UserDefaults.standard.synchronize()
		}
		get {
			if UserDefaults.standard.object(forKey: "email") != nil {
				return UserDefaults.standard.string(forKey: "email")!
			}
			return ""
		}
	}

	static var birthDate:String {
		
		set {
			UserDefaults.standard.setValue(newValue, forKey: "birthDate")
			UserDefaults.standard.synchronize()
		}
		get {
			if UserDefaults.standard.object(forKey: "birthDate") != nil {
				return UserDefaults.standard.string(forKey: "birthDate")!
			}
			return ""
		}
	}
    
    static var firstName: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "firstName")
        }
        get {
            if UserDefaults.standard.object(forKey: "firstName") != nil {
                return UserDefaults.standard.string(forKey: "firstName")!
            }
            return ""
        }
    
}

    static var lastName: String {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "lastName")
        }
        get {
            if UserDefaults.standard.object(forKey: "lastName") != nil {
                return UserDefaults.standard.string(forKey: "lastName")!
            }
            return ""
        }
    }
    
    
    
    static var defaultCardId: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "defaultCardId")
        }
        get {
            if UserDefaults.standard.object(forKey: "defaultCardId") != nil {
                return UserDefaults.standard.string(forKey: "defaultCardId")
            }
            return nil
        }
    }
    
    
    
    static var publicKey: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "publicKey")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "publicKey") != nil {
                return UserDefaults.standard.string(forKey: "publicKey")
            }
            return nil
        }
    }
    
    
    static var payToken: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "payToken")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "payToken") != nil {
                return UserDefaults.standard.string(forKey: "payToken")
            }
            return nil
        }
    }
    
    
    static var payGearToken: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "payGearToken")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "payGearToken") != nil {
                return UserDefaults.standard.string(forKey: "payGearToken")
            }
            return nil
        }
    }
    
    
    
    static var pin: Bool? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "pin")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "pin") != nil {
                return UserDefaults.standard.bool(forKey: "pin")
				
            }
            return nil
        }
    }
    
    
    
    static var isUpdateAvailable: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isUpdateAvailable")
        }
        get {
            if UserDefaults.standard.object(forKey: "isUpdateAvailable") != nil {
                return UserDefaults.standard.bool(forKey: "isUpdateAvailable")
            }
			
            return true
        }
    }
    
    
    static var isHamyanGreenIconHidden: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isHamyanGreenIconHidden")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "isHamyanGreenIconHidden") != nil {
                return UserDefaults.standard.bool(forKey: "isHamyanGreenIconHidden")
            }
            return true
        }
    }
    
    static var isFirstDonationsList: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isFirstDonationList")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "isFirstDonationList") != nil {
                return UserDefaults.standard.bool(forKey: "isFirstDonationList")
            }
            return true
        }
    }
    
    static var hasNewMessage: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "hasNewMessage")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "hasNewMessage") != nil {
                return UserDefaults.standard.bool(forKey: "hasNewMessage")
            }
            return false
        }
    }
    
    static var isFirstMessagesList: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isFirstMessageList")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "isFirstMessageList") != nil {
                return UserDefaults.standard.bool(forKey: "isFirstMessageList")
            }
            return true
        }
    }
    
    
    static var isTouchIdAllowed : Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isTouchIdAllowed")
        }
        get {
            if UserDefaults.standard.object(forKey: "isTouchIdAllowed") != nil {
                return UserDefaults.standard.bool(forKey: "isTouchIdAllowed")
            }
            return true
        }
    }
    
    
    static var isSoundAllowed : Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isSoundAllowed")
        }
        get {
            if UserDefaults.standard.object(forKey: "isSoundAllowed") != nil {
                return UserDefaults.standard.bool(forKey: "isSoundAllowed")
            }
            return true
        }
    }
    
    
    static var barcodeTipIsShown: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "barcodeTipIsShown")
        }
        get {
            if UserDefaults.standard.object(forKey: "barcodeTipIsShown") != nil {
                return UserDefaults.standard.bool(forKey: "barcodeTipIsShown")
            }
            return false
        }
    }
    
    static var isLoggedIn : Bool {
        return (token != nil) || (token == "")
    }
    
    static var fullName : String {
        if profileDataAvailable() {
            return firstName + " " + lastName
        } else {
            return ""
        }
    }
    
    static func profileDataAvailable() -> Bool {
        if firstName.isEmpty && lastName.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    static func profilePictureAvailable() -> Bool {
        if profilePictureId?.isEmpty ?? true {
            return false
        } else {
            return true
        }
    }
    
    static func refreshToken(delegate: Any, onSuccess: CallBack? = nil,onFail onFailed: FailedCallBack? = nil) {
        if !isLoggedIn { return }
        let request = WS_methods(delegate: delegate, failedDialog: true)
        request.addSuccessHandler { (response : Any) in
            onSuccess?(response)
        }
        
        request.addFailedHandler { (response : Any) in
            SMLog.SMPrint("failiure in refresh token")
            onFailed?(response)
        }
        request.refresh_token()
    }
    
    static func getUserProfileFromServer(_ onSuccess: SimpleCallBack? = nil,  onFailed: FailedCallBack? = nil) {
        let request = WS_methods(delegate: self, failedDialog: true)
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
                if let userName = jsonResult["username"]{
                    SMUserManager.userName = "@\(userName)"
                }
				if let name = jsonResult["name"] {
					SMUserManager.firstName = "\(name)"
				}
				if let profileImageURL = jsonResult["profile_picture"] {
					SMUserManager.profilePictureId = "\(imageSource)\((profileImageURL as! String).filter { !" \\ \n \" \t\r".contains($0) })"
					NSObject.downloadImageFrom(url: URL(string: profilePictureId!)!, closure: { (image) in
						SMImage.saveImage(image: image! , withName: "profile.png")
					})
				}
				
				if let proviencId  = jsonResult["province_id"] {
					SMUserManager.proviencId = "\(proviencId)"
				}
				
				if let email = jsonResult["email"] {
					SMUserManager.email =  "\(email)"
				}
				
				if let birthDate = jsonResult["birth_date"] {
					SMUserManager.birthDate = "\(birthDate)"
				}

                if let id = jsonResult["_id"]{
                    SMUserManager.accountId = "\(id)"
                }
            }
            onSuccess?()
        }
        request.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
        })
        request.pu_getAccountingInfo(SMUserManager.token)
        
        
    }
    
    
    static func getUserProfileOffline() -> UIImage?{
        return UIImage(contentsOfFile: SMUserManager.getAvatarPath())
    }
    
    static func saveUserProfileOffline(image:UIImage?){
        
        if image == nil{
            return
        }
        
        
        let url = URL(fileURLWithPath: SMUserManager.getAvatarPath())
        
        do{
            // Save image.
            try image!.pngData()?.write(to: url, options: .atomic)
        }catch{
            
        }
        
    }
    
    static func deleteUserProfile(){
        
        do {
            try FileManager.default.removeItem(atPath: SMUserManager.getAvatarPath())
        } catch let error as NSError {
            SMLog.SMPrint("Error: \(error.domain)")
        }
        
    }
    
    
    static func getAvatarPath() -> String{
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let filePath = "\(paths[0])/avatar.png"
        
        return filePath
    }
    
    ///////////////////
    
    static func saveDataToKeyChain(){
        
        let keychain = KeychainSwift()
        
        keychain.set(self.mobileNumber ?? "", forKey: "mobile")
        keychain.set((self.token ?? ""), forKey: "token")
        keychain.set(self.profileLevelsCompleted ?? "", forKey: "level")
    }
    
    static func loadFromKeychain(){
        
        let keychain = KeychainSwift()
        
        self.mobileNumber = keychain.get("mobile")
        self.token = keychain.get("token")
        self.profileLevelsCompleted = keychain.get("level")
        
    }
    
    static func clearKeychainOnFirstRun(){
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasRunBefore") == false {
            
            self.logout()
            
            // update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize()
            
            return
        }
        
    }
    static func logout(){
        
        SMUserManager.resetUserData()
        self.mobileNumber = nil
        self.token = nil
		
        let keychain = KeychainSwift()
        keychain.delete("token")
        keychain.delete("level")
        SMUserManager.saveDataToKeyChain()
    }

}
