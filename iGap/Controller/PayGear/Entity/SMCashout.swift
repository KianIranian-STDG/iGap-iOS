//
//  SMCashout.swift
//  PayGear
//
//  Created by a on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation
import CoreData
import webservice
import models


class SMCashout : SMEntity{
    
    static let ENTITY_NAME = "CashoutCard"
    
    
    
    var cardID:NSNumber?
    var pan:String?
    var exp_m:String?
    var exp_y:String?
    var pin2:String?
    var cvv2:String?
    var bankCode:Int64?
    var type:Int64?
    var balance:Int64?
    var cashablebalance:Int64?
    var cashin:Bool?
    var cashout:Bool?
    var protected:Bool?
    var backgroundimage:String?
    var token:String?
    var isDefault:Bool? = false
    
   
    
    var bank : SMBank?
    
    
    
    static func addCardsToDB(cards:[SMCashout]){
        
        
        for card in cards{
        
        let nsmo = NSEntityDescription.insertNewObject(forEntityName: SMCashout.ENTITY_NAME, into: SMEntity.context)
            nsmo.setValue(card.token, forKey: "token")
            nsmo.setValue(card.pan, forKey: "pan")
            nsmo.setValue(card.bankCode, forKey: "bankCode")
       }
        SMEntity.commit()
    }
    
    
    static func loadFromManagedObject(nsmo : NSManagedObject) -> SMCashout{
        
        let c = SMCashout()
        c.pan = nsmo.value(forKey: "pan") as? String
        c.token = nsmo.value(forKey: "token") as? String
        c.bankCode = nsmo.value(forKey: "bankCode") as? Int64
        return c
        
    }
    
    // MARK: static functions
    
    static func deleteAllCardsFromDB(){
        
        let req = NSFetchRequest<NSManagedObject>(entityName: SMCashout.ENTITY_NAME)
        
        
        do{
            let results = try SMEntity.context.fetch(req)
            
            for r in results{
                
                SMEntity.context.delete(r)
                
            }
            
        }catch{
            SMLog.SMPrint(error)
        }
        
        SMEntity.commit()
        
    }
	
    static func getAllCardsFromDB( _ conditions:((NSFetchRequest<NSManagedObject>)->())? = nil) -> [SMCashout]{
        
        let req = NSFetchRequest<NSManagedObject>(entityName: SMCashout.ENTITY_NAME)
        
//        req.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
//
        
        conditions?(req)
        
        do{
            let results = try SMEntity.context.fetch(req)
            
            var resultsArr:[SMCashout] = []
            
            for res in results{
                   resultsArr.append(SMCashout.loadFromManagedObject(nsmo: res))
           }
            
            return resultsArr
        }catch{
            SMLog.SMPrint(error)
            return []
        }
        
    }
    
    static func getAllCardsFromServer(_ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        var serverCards = [SMCashout]()
        let cardRequest = WS_methods(delegate: self, failedDialog: true)
        cardRequest.addSuccessHandler { (response : Any) in
            for item in response as! [NSDictionary]{
                let cardItem = item as? Dictionary<String, AnyObject>
                let card = SMCashout()
                
                card.pan = cardItem?["card_number"] as? String
                card.token = cardItem?["token"] as? String
                card.bankCode = cardItem?["bank_code"] as? Int64
				if card.bankCode != 0 {
                	serverCards.append(card)
				}
            }
            
            
            SMCashout.deleteAllCardsFromDB()
            SMCashout.addCardsToDB(cards:serverCards)
            
            onSuccess?(serverCards)
        }
        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            SMLoading.hideLoadingPage()
            onFailed?(response)
            
        })
        cardRequest.pc_listCashOutcard()
    }
}
