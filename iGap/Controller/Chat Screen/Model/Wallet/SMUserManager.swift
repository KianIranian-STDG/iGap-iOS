//
//  SMUserManager.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import KeychainSwift
import webservice

class SMUserManager: NSObject {
    
    
    static var token:String?
    static var profilePictureId:String?
    static var mobileNumber:String?
    static var profileCompleteFromServer:Bool?
    static var profileLevelsCompleted:String?
    static var accountType:Int64 = 2
    static var userPass:String?
    static var userBalance : Int64!
    static let imageSource = "https://api.paygeer.ir/files/v3/"
    static var callBackUrl = "https://secure.igap.net/api/wallet/callback/"

    
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
    static func refreshToken(delegate: Any, onSuccess: CallBack? = nil,onFail onFailed: FailedCallBack? = nil) {

        let request = WS_methods(delegate: delegate, failedDialog: false)
        request.addSuccessHandler { (response : Any) in
            onSuccess?(response)
        }
        
        request.addFailedHandler { (response : Any) in
            SMLog.SMPrint("failiure in refresh token")
            onFailed?(response)
        }
        request.refresh_token()
    }
    static func resetUserData() {
        
        SMUserManager.accountId = ""
        SMUserManager.firstName = ""
        SMUserManager.lastName = ""
        SMUserManager.publicKey = ""
        SMUserManager.payToken = ""
        SMUserManager.payGearToken = ""
        SMUserManager.mobileNumber = ""
        SMCard.deleteAllCardsFromDB()
        SMMerchant.deleteAllMerchantsFromDB()
//        SMImage.saveImage(image: UIImage.init(named: "user")! , withName: "profile.png")
        
        UserDefaults.standard.removeObject(forKey: "pin")
        UserDefaults.standard.removeObject(forKey: "isUpdateAvailable")
        UserDefaults.standard.removeObject(forKey: "barcodeTipIsShown")
        UserDefaults.standard.synchronize()
        
        
        //        #import "WS_SecurityManager.h"
        let securityManager = WS_SecurityManager.init()
        securityManager.clear()
        
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
    static var fullName : String {
        if profileDataAvailable() {
            return firstName + " " + lastName
        } else {
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
    static func profileDataAvailable() -> Bool {
        if firstName.isEmpty && lastName.isEmpty {
            return false
        } else {
            return true
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
    
    static func profilePictureAvailable() -> Bool {
        if profilePictureId?.isEmpty ?? true {
            return false
        } else {
            return true
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
    static var isProtected: Bool? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isProtected")
            UserDefaults.standard.synchronize()
        }
        get {
            if UserDefaults.standard.object(forKey: "isProtected") != nil {
                return UserDefaults.standard.bool(forKey: "isProtected")
            }
            return nil
        }
        
    }
    ///////////////////
    
    static func saveDataToKeyChain(){
        
        let keychain = KeychainSwift()
        
        keychain.set(self.mobileNumber ?? "", forKey: "mobile")
        keychain.set((self.token ?? ""), forKey: "token")
        keychain.set(self.profileLevelsCompleted ?? "", forKey: "level")
    }
    static func savePassToKeyChain(){
        
        let keychain = KeychainSwift()
        
        keychain.set(self.userPass ?? "", forKey: "userPass")
    }
    static func loadPassFromKeychain(){
        
        let keychain = KeychainSwift()
        
        self.userPass = keychain.get("userPass")
        
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
    
    static func getUserProfileFromServer(_ onSuccess: SimpleCallBack? = nil,  onFailed: FailedCallBack? = nil) {
        let request = WS_methods(delegate: self, failedDialog: false)
        request.addSuccessHandler { (response : Any) in
            if let jsonResult = response as? Dictionary<String, AnyObject> {
           
                if let id = jsonResult["_id"]{
                    print(id)
                    SMUserManager.accountId = "\(id)"
                }
            }
            onSuccess?()
        }
        request.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
        })
        DispatchQueue.main.async(execute: { () -> Void in
        request.pu_getAccountingInfo(SMUserManager.token)
        })
        
    }
}


