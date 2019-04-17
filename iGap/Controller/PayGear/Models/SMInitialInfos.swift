//
//  SMInitialInfos.swift
//  PayGear
//
//  Created by amir soltani on 4/18/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

struct NotificationKeys {
	
	//MARK:- shortcut selection
	static let NKShortcutSelection = "shortcut_selection"
	static let NKShortcutSelectionPage = "shortcut_selection_page"
	
	// MARK:- IPG Success
	static let NKIPGSuccess = "ipg_success"
	
	
}

class SMInitialInfos: NSObject {
    static var AllUpdatedSuccessfully:SimpleCallBack?
    static var AtLeastOneFailedDelegate:SimpleCallBack?
    
    static var updateIsInProgress = false
    static var successfulUpdateCount = 0
    static var failedUpdateCount = 0
    static var totalSyncCount = 5
    
    
    
    static func syncs(){
        if SMUserManager.isLoggedIn {
            
            SMInitialInfos.updateBaseInfoFromServer()
            runUserSyncs()
        }
    }
    
    
    static func runUserSyncs() {
        
        SMUserManager.getUserProfileFromServer()
        SMCard.syncCardsWithServer()
		
    }
    
    
    static func updateBaseInfoFromServer() {
        
        if SMInitialInfos.updateIsInProgress {
            return
        }
        
        SMCard.syncCardsWithServer()
        
        SMUserManager.getUserProfileFromServer({
           
            SMInitialInfos.taskSucceed()
			SMMerchant.getAllMerchantsFromServer(SMUserManager.accountId, { (merchant) in
				SMInitialInfos.taskSucceed()
				return
			}) { (err) in
				SMInitialInfos.taskFailed()
			}
			
			SMIBAN.getAllIBANsFromServer(accountId: SMUserManager.accountId, { (ibans) in
				SMInitialInfos.taskSucceed()
			}, onFailed: { err in
				SMInitialInfos.taskFailed()
			})
			
            return
           
            }, onFailed: { err in
                SMInitialInfos.taskFailed()
        })
        
        
       SMCard.getAllCardsFromServer({ cards in
            
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0{
                        
                        SMInitialInfos.taskSucceed()
                        return
                    }
                }
            }
            
            SMInitialInfos.taskFailed()
            
        }, onFailed: {err in
            
            SMInitialInfos.taskFailed()
        })
        
        
        SMCashout.getAllCardsFromServer({cards in
            SMInitialInfos.taskSucceed()
            
            return
            
        }, onFailed: {err in
             SMInitialInfos.taskFailed()
        })
        
    }
    
    
    static func taskSucceed(){
        
        SMInitialInfos.successfulUpdateCount += 1
        SMInitialInfos.checkUpdateStatus()
    }
    
    static func taskFailed(){
        
        SMInitialInfos.failedUpdateCount += 1
        SMInitialInfos.checkUpdateStatus()
    }
    
    static func checkUpdateStatus(){
        
        if SMInitialInfos.successfulUpdateCount + SMInitialInfos.failedUpdateCount == SMInitialInfos.totalSyncCount{
            
            
            if SMInitialInfos.successfulUpdateCount == SMInitialInfos.totalSyncCount {
                SMInitialInfos.AllUpdatedSuccessfully?()
			}
			else if SMInitialInfos.failedUpdateCount == SMInitialInfos.totalSyncCount {
				
				SMInitialInfos.successfulUpdateCount = 0
				SMInitialInfos.failedUpdateCount = 0
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
					syncs()
				}
            } else {
                SMInitialInfos.AtLeastOneFailedDelegate?()
            }
            
            SMInitialInfos.successfulUpdateCount = 0
            SMInitialInfos.failedUpdateCount = 0
            SMInitialInfos.updateIsInProgress = false
            return
        }
    }
}
