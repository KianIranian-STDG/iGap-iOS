//
//  SMMerchant.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 7/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import CoreData
import webservice
import models

/// Merchant Model; This class provide method to create model by data fetched from server or db
/// Model insert to, delete from or select from db, Also fetch data from server
public class SMMerchant: SMEntity {

	// MARK:- Properties
	/// Core Data model name
	static let ENTITY_NAME = "Merchant"

	/// Defined roles name on application for merchant
	static let roleString : [String]  = [
		///Sore key name
		IGStringsManager.Store.rawValue.localized,
		///No name
		IGStringsManager.Other.rawValue.localized,
		///Driver key name
		IGStringsManager.Driver.rawValue.localized]
	
	
	///Merchant name
	var name: String?
	
	///Type of account
	var accountType:Int64?
	/// Roles of user at this merchant (admin, finance, ...)
	var role:String?
	/// Merchant id
	var id:String?
	/// Path of merchant profile picture
	var profilePicture:String?
	/// Merchant username
	var username: String?
	/// It is application parameter to show paygear user in top of merchants
	var sort: Int16?
	/// Merchant role - It is store or driver or ...
	var businessType: Int?
	
	
	// MARK:- static functions
	
	/// Static Function to load Merchant object from Merchant db value.
	///
	/// - Parameter nsmo: A SNManagedObject fetched from DB
	/// - Returns: A SMMerchant object
	static func loadFromManagedObject(nsmo : NSManagedObject) -> SMMerchant{
		
		let c = SMMerchant()
		
		c.name = nsmo.value(forKey: "name") as? String
		c.accountType = nsmo.value(forKey: "type") as? Int64
		c.role = nsmo.value(forKey: "role") as? String
		c.id = nsmo.value(forKey: "id") as? String
		c.profilePicture = nsmo.value(forKey: "picture") as? String
		c.username = nsmo.value(forKey: "username") as? String
		c.sort = nsmo.value(forKey: "sort") as? Int16
		c.businessType = nsmo.value(forKey: "bType") as? Int
		return c
		
	}
	
	/**
	Static Function to Add An Array of Merchant object to db.
	
	- Parameter nsmo: A list of SMMerchant
	
	- Returns: No Return
	*/
	static func addMerchantsToDB(merchants: [SMMerchant]){
		
		for merchant in merchants {
			let nsmo = NSEntityDescription.insertNewObject(forEntityName: SMMerchant.ENTITY_NAME, into: SMEntity.context)
			nsmo.setValue(merchant.name, forKey: "name")
			nsmo.setValue(merchant.accountType, forKey: "type")
			nsmo.setValue(merchant.role, forKey: "role")
			nsmo.setValue(merchant.id, forKey: "id")
			nsmo.setValue(merchant.profilePicture, forKey: "picture")
			nsmo.setValue(merchant.username, forKey: "username")
			nsmo.setValue(merchant.sort, forKey: "sort")
			nsmo.setValue(merchant.businessType, forKey: "bType")
		}
		SMEntity.commit()
	}
	
	
	/**
	Static Function to Delete All Merchant objects from db.
	
	It used to clear all old date before adding new data to db
	*/
	static func deleteAllMerchantsFromDB(){
		
		let req = NSFetchRequest<NSManagedObject>(entityName: SMMerchant.ENTITY_NAME)
		
		
		do {
			let results = try SMEntity.context.fetch(req)
			
			for r in results{
				
				SMEntity.context.delete(r)
				
			}
			
		} catch {
			SMLog.SMPrint(error)
		}
		
		SMEntity.commit()
		
	}
	
	/**
	Static Function to load Merchant object from db.
	
	- Parameter conditions: an optional parameter to set any conditions to fetch request
	
	- Returns: A list of SMMerchant object
	
	This fetch method is sorted on "sort" column
	the sort value of paygear user is 0, and all other merchants are 1 
	*/
	static func getAllMerchantsFromDB( _ conditions:((NSFetchRequest<NSManagedObject>)->())? = nil) -> [SMMerchant]{
		
		let req = NSFetchRequest<NSManagedObject>(entityName: SMMerchant.ENTITY_NAME)
		
		req.sortDescriptors = [NSSortDescriptor(key: "sort", ascending: true)]
		
		conditions?(req)
		
		do {
			let results = try SMEntity.context.fetch(req)
			
			var resultsArr:[SMMerchant] = []
			
			for res in results{
				
				resultsArr.append(SMMerchant.loadFromManagedObject(nsmo: res))
			}
			
			return resultsArr
		} catch {
			SMLog.SMPrint(error)
			return []
		}
		
	}
	
	/**
	Static Function to convert current user model to merchant model.
	
	- Parameter : void
	
	- Returns: A SMMerchant object
	
	As wen need to show current user in list of merchants, the current user must
	to be converted to merchant model; this method do it.
	*/
	static func getMerchatnTypeOfCurrentUser()-> SMMerchant {
		
		let merchant = SMMerchant()
		merchant.id = SMUserManager.accountId
		merchant.name = SMUserManager.fullName
		merchant.role = IGStringsManager.Personal.rawValue.localized
		merchant.sort = 0
		merchant.profilePicture = SMUserManager.profilePictureId
		merchant.accountType = 2
		return merchant
	}
	
	
	/// Static Function to get All merchant of user from server
	///
	/// - Parameters:
	///   - accountId: this is account id of paygear user
	///   - onSuccess: callback function when fetched data successfully
	///   - onFailed: callback function when API request return failed
	///
	/// This function removes all merchants from db and inserts all fetched merchant
	
	static func getAllMerchantsFromServer(_ accountId: String, _ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
		print(accountId)
		var serverMerchants = [SMMerchant]()
		let cardRequest = WS_methods(delegate: self, failedDialog: false)
		cardRequest.addSuccessHandler { (response : Any) in
			serverMerchants.append(getMerchatnTypeOfCurrentUser())

            // index 0 is for wallet user account because it is the first in sort
            var index: Int16 = 1
            for merchantItem in (response as! NSDictionary)["merchants"]! as! [NSDictionary] {
//				let merchantItem = ((item as? Dictionary<String, AnyObject>)?["account"] as? Dictionary<String, AnyObject>)
				
                let merchant = SMMerchant()
                
                merchant.sort = index
                index += 1
                
                if let name = merchantItem["name"] {
                    merchant.name = (name as? String)!
                }
                if let username = merchantItem["username"] {
                    merchant.username = (username as? String)!
                }
                if let type = merchantItem["account_type"] {
                    merchant.accountType = (type as? Int64)!
                }
                if let id = merchantItem["_id"]  {
                    merchant.id = (id as? String)!
                }
                if let bType = merchantItem["business_type"] {
                    merchant.businessType = (bType as? Int)!
                }
				let imageName = "\(merchant.id!).png"
				SMImage.saveImage(image: UIImage.init(named: "oval")! , withName: imageName)

					if let picture = merchantItem["profile_picture"] {
					merchant.profilePicture = (picture as? String)!
					let urlString = "\(SMUserManager.imageSource)\( picture as! String)"
					NSObject.downloadImageFrom(url: URL(string: urlString)!, closure: { (image) in
						SMImage.saveImage(image: image! , withName: imageName)
					})
				}
					if let users = merchantItem["users"] {
					for user in (users as? [NSDictionary])! {
						
						if (user["user_id"] as? String)! == accountId {
							if let role = user["role"] {
								if merchant.role == nil || (merchant.role != nil && merchant.role != "admin") {
									merchant.role = (role as? String)!
								}
							}
						}
					}
				}
				if merchant.role != nil && (merchant.role == "finance" || merchant.role == "admin") {
					serverMerchants.append(merchant)
				}
			}
			
			SMMerchant.deleteAllMerchantsFromDB()
			SMMerchant.addMerchantsToDB(merchants:serverMerchants)

            NotificationCenter.default.post(name: Notification.Name(SMConstants.notificationMerchant), object: nil)
			onSuccess?(serverMerchants)
		}
		
		
		cardRequest.addFailedHandler({ (response: Any) in
			SMLog.SMPrint("faild")
            SMLoading.hideLoadingPage()
			onFailed?(response)
			
		})
		cardRequest.cl_getMerchants(accountId)
		
	}
}

extension NSObject {
    
    static func downloadImageFrom(url: URL, closure: @escaping (_ image: UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {return}
            closure(image)
            }.resume()
        
    }
}
