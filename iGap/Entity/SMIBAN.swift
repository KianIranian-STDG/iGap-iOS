//
//  SMIBAN.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 7/22/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import CoreData
import webservice

/// SMIban Model; This class provide method to create model by data fetched from server or db
/// Model insert to, delete from or select from db, Also fetch data from server
class SMIBAN: SMEntity {

	// MARK:- Properties
	/// Core Data model name
	static let ENTITY_NAME = "IBAN"
	
	/// Number of iban - it is english characters
	var ibanNumber : String! {
		didSet {
			ibanNumber = ibanNumber.inEnglishNumbers()
		}
	}
	/// It is true when iban is default
	var isDefault : Bool!
	
	
	// MARK:- static functions
	/// Static method to add list of iban to db
	///
	/// - Parameter ibans: An array contains ibans
	static func addIBANsToDB(ibans:[SMIBAN]){
	
		for iban in ibans {
			let nsmo = NSEntityDescription.insertNewObject(forEntityName: SMIBAN.ENTITY_NAME, into: SMEntity.context)
			nsmo.setValue(iban.ibanNumber, forKey: "number")
			nsmo.setValue(iban.isDefault, forKey: "isdefault")
		}
		SMEntity.commit()
	}
	
	
	/// Static Function to load IBAN object from IBAN db value
	///
	/// - Parameter nsmo: a Iban object fetched from db
	/// - Returns: SMIBAN model
	static func loadFromManagedObject(nsmo : NSManagedObject) -> SMIBAN{
		
		let c = SMIBAN()
		c.ibanNumber = nsmo.value(forKey: "number") as? String
		c.isDefault = nsmo.value(forKey: "isdefault") as? Bool
		return c
	}
	
	
	
	/// Static Function to remove all Ibans from DB
	static func deleteAllIBANsFromDB(){
		
		let req = NSFetchRequest<NSManagedObject>(entityName: SMIBAN.ENTITY_NAME)
		do{
			let results = try SMEntity.context.fetch(req)
			
			for r in results{
				
				SMEntity.context.delete(r)
			}
			
		}catch{
//            SMLog.SMPrint(error)
		}
		
		SMEntity.commit()
	}
	
	/// Static Function to fetch all Ibans from DB
	///
	/// - Parameter conditions: an optional parameter to set any conditions to fetch request
	/// - Returns: list of Ibans
	static func getAllIBANsFromDB( _ conditions:((NSFetchRequest<NSManagedObject>)->())? = nil) -> [SMIBAN]{
		
		let req = NSFetchRequest<NSManagedObject>(entityName: SMIBAN.ENTITY_NAME)
		req.sortDescriptors = [NSSortDescriptor(key: "isdefault", ascending: false)]
		conditions?(req)
		
		do{
			let results = try SMEntity.context.fetch(req)
			
			var resultsArr:[SMIBAN] = []
			
			for res in results{
				
				resultsArr.append(SMIBAN.loadFromManagedObject(nsmo: res))
			}
			
			return resultsArr
		}catch{
//            SMLog.SMPrint(error)
			return []
		}
		
	}

	/// Static method to fetch all Iban from server
	///
	/// - Parameters:
	///   - accountId: account id, paygear account id or merchant account id
	///   - onSuccess: optional call back method on successfull response from server
	///   - onFailed: optional call back method on fail response from server
	///
	/// This method remove all ibans from db and insert ibans fetched from server in
	/// success response
	static func getAllIBANsFromServer(accountId: String, _ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
		var serverIBANs = [SMIBAN]()
		let ibanRequest = WS_methods(delegate: self, failedDialog: false)
		ibanRequest.addSuccessHandler { (response : Any) in
			for item in response as! [NSDictionary]{
				let ibanItem = item as? Dictionary<String, AnyObject>
				let iban = SMIBAN()
				iban.ibanNumber = ibanItem?["iban"] as? String
				iban.isDefault = ibanItem?["default"] as? Bool
				serverIBANs.append(iban)
			}
			
			
			if accountId == SMUserManager.accountId {
				SMIBAN.deleteAllIBANsFromDB()
				SMIBAN.addIBANsToDB(ibans: serverIBANs)
			}
			onSuccess?(serverIBANs)
		}
		
		
		
		ibanRequest.addFailedHandler({ (response: Any) in
//            SMLog.SMPrint("faild")
//            SMLoading.hideLoadingPage()
			onFailed?(response)
			
		})
		ibanRequest.pc_listiban(accountId)
		
	}
	
	/// Static method to change default ibans
	/// This method request to server, in success response calls getAllIBANsFromServer(:)
	/// to reload db 
	///
	/// - Parameters:
	///   - accountId: paygear account id
	///   - iban: iban code to change as default
	static func saveIbanAsDefault(accountId: String, iban: String) {
		
		let ibanRequest = WS_methods(delegate: self, failedDialog: false)
		ibanRequest.addSuccessHandler { (response : Any) in
			
			//save it as default
			SMIBAN.getAllIBANsFromServer(accountId: accountId)
		}
		
		
		ibanRequest.addFailedHandler({ (response: Any) in
//            SMLog.SMPrint("faild")
		})
		ibanRequest.pc_setibandefault(accountId, iban: iban)
	}
}
