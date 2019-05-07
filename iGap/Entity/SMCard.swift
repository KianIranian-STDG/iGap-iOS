//
//  SMCard.swift
//  PayGear
//
//  Created by a on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation
import CoreData
import webservice
import models

protocol HandleDefaultCard {
    func finishDefault(isPaygear : Bool? ,isCard : Bool?)
    func valueChanged(value: Bool)
}
class SMCard : SMEntity{

    static let ENTITY_NAME = "Card"



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

//
//
    var bank : SMBank?
//
//

    static func addCardsToDB(cards:[SMCard]){


        for card in cards{

        let nsmo = NSEntityDescription.insertNewObject(forEntityName: SMCard.ENTITY_NAME, into: SMEntity.context)
            nsmo.setValue(card.token, forKey: "token")
            nsmo.setValue(card.protected, forKey: "protected")
            nsmo.setValue(card.type, forKey: "type")
            nsmo.setValue(card.cashablebalance, forKey: "cashablebalance")
            nsmo.setValue(card.cashin, forKey: "cashin")
            nsmo.setValue(card.cashout, forKey: "cashout")
            nsmo.setValue(card.balance, forKey: "balance")
            nsmo.setValue(card.bankCode, forKey: "bankcode")
            nsmo.setValue(card.cardID, forKey: "cardID")
            nsmo.setValue(card.pan, forKey: "pan")
            nsmo.setValue(card.exp_y, forKey: "exp_y")
            nsmo.setValue(card.exp_m, forKey: "exp_m")
            nsmo.setValue(card.backgroundimage, forKey: "backgroundimage")
            nsmo.setValue(card.isDefault, forKey: "default")

            if card.isDefault == true{
                nsmo.setValue(0, forKey: "order")
            }
            else{
                nsmo.setValue(1, forKey: "order")
            }
       }
        SMEntity.commit()
    }

//
    static func loadFromManagedObject(nsmo : NSManagedObject) -> SMCard{

        let c = SMCard()


        c.balance = nsmo.value(forKey: "balance") as? Int64
        c.bankCode = nsmo.value(forKey: "bankcode") as? Int64
        c.cardID = nsmo.value(forKey: "cardID") as? NSNumber
        c.cashablebalance = nsmo.value(forKey: "cashablebalance") as? Int64
        c.cashin = nsmo.value(forKey: "cashin") as? Bool
        c.cashout = nsmo.value(forKey: "cashout") as? Bool
        c.exp_m = nsmo.value(forKey: "exp_m") as? String
        c.exp_y = nsmo.value(forKey: "exp_y") as? String
        c.pan = nsmo.value(forKey: "pan") as? String
        c.type = nsmo.value(forKey: "type") as? Int64
        c.protected = nsmo.value(forKey: "protected") as? Bool
        c.token = nsmo.value(forKey: "token") as? String
        c.isDefault = nsmo.value(forKey: "default") as? Bool ?? false
        c.backgroundimage = nsmo.value(forKey: "backgroundimage") as? String

        let bank = SMBank()
        bank.setBankInfo(code: c.bankCode ?? 0)
        c.bank = bank
        return c

    }


    // MARK: static functions

    static func deleteAllCardsFromDB(){

        let req = NSFetchRequest<NSManagedObject>(entityName: SMCard.ENTITY_NAME)


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


//
    static func deleteAllCashoutsFromDB(){

        let req = NSFetchRequest<NSManagedObject>(entityName: SMCard.ENTITY_NAME)


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

//
//
//
//
//
//
    static func getAllCardsFromDB( _ conditions:((NSFetchRequest<NSManagedObject>)->())? = nil) -> [SMCard]{

        let req = NSFetchRequest<NSManagedObject>(entityName: SMCard.ENTITY_NAME)

        req.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]

        conditions?(req)

        do{
            let results = try SMEntity.context.fetch(req)

            var resultsArr:[SMCard] = []

            for res in results{

                resultsArr.append(SMCard.loadFromManagedObject(nsmo: res))
            }

            return resultsArr
        }catch{
//            SMLog.SMPrint(error)
            return []
        }

    }

//
//
//
//
//    // MARK: static remote functions
//
    static func addNewCardToServer(_ card: SMCard, onSuccess: SimpleCallBack? = nil,  onFailed: FailedCallBack? = nil){

        let cardItem = PC_obj_card()
        cardItem.card_number = card.pan?.inEnglishNumbers()
        cardItem.exp_m = card.exp_m?.inEnglishNumbers()
        cardItem.exp_y = card.exp_y?.inEnglishNumbers()
        cardItem.isDefault = card.isDefault! as NSNumber
        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in
            SMLoading.hideLoadingPage()
            self.syncCardsWithServer(onSuccess: {
                onSuccess?()
            }, onFailedCallBack : {err in
                onFailed?(err)

            })
        }


        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
            SMMessage.showWithMessage(SMCard.testConvert(response))

        })
        cardRequest.pc_addcard(cardItem)
    }


    static func initPayment(amount : Int? ,accountId : String?, from : String? = nil, transportId: String? = nil, orderType: ORDER_TYPE? = .DEFAULT, preOrder: Bool? = false, qrCode: String? = nil, isCredit : Bool = false , onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        let payObj = PC_obj_payinit()
        payObj.amount = amount ?? 0
        payObj.to = accountId
        from != nil ? payObj.from = from : print("isnil")
        payObj.transaction_type = 4
        payObj.credit = isCredit
        if transportId != nil {
            payObj.transportId = transportId
        }
        else {
            payObj.to = accountId
            payObj.transaction_type = 4

            if orderType != .DEFAULT  {
                payObj.order_type = orderType!
            }
            payObj.credit = isCredit
            payObj.pre_order = preOrder!
            payObj.from = from

            if transportId != nil {
                payObj.transportId = transportId
            }
            if qrCode != nil {
                payObj.qrCode = qrCode
            }
        }

        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in

                onSuccess?(response)
        }


        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
            print(testConvert(response))
            
            
            SMMessage.showWithMessage(SMCard.testConvert(response))


        })
        cardRequest.pc_payment_init(payObj)
    }
    static func testConvert(_ something: Any) -> String  {
        guard let dict = something as? [AnyHashable: Any] else {
            print("\(something) couldn't be converted to Dictionary")
            return ""
        }
        print(String(dict.values.description))
        let tmpString : String = String(dict.values.description)
        return tmpString.slice(from: "[", to: "]")!
        

    }
    static func confirmChashout(amount : Int? ,cardNumber : String? ,cardToken : String?, accountId: String?, onSuccess: CallBack? = nil, onFailed: FailedCallBack? = nil){

        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in

            onSuccess?(response)

        }

        cardRequest.addFailedHandler({ (response: Any) in
            
            SMLog.SMPrint("faild")
            onFailed?(response)
            SMMessage.showWithMessage(SMCard.testConvert(response))

            
        })
        cardRequest.pc_cashoutconfirm(cardNumber, cardToken: cardToken, amount: amount!,accountId: accountId ?? SMUserManager.accountId)

    }


    static func chashout(amount : Int? ,cardNumber : String? ,cardToken : String? = "", sourceCardToken: String? ,pin : String?,isFast:Bool, accountId: String? = nil, onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        let cashoutObj = PAY_obj_cashout()
        cashoutObj.amount = amount ?? 0
        if cardNumber != ""{
            if isFast{
                cashoutObj.card_number = cardNumber
            }else{
                cashoutObj.shaba_number = cardNumber
            }

        }
        cashoutObj.pin = pin?.onlyDigitChars().inEnglishNumbers()
        cashoutObj.is_instant = isFast as NSObject
        if cardToken != "" {
        cashoutObj.card_token = cardToken
        }
        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in
            
            SMLoading.hideLoadingPage()
            onSuccess?(response)

        }


        cardRequest.addFailedHandler({ (response: Any) in
//            SMLog.SMPrint("faild")
            onFailed?(response)
            SMLoading.hideLoadingPage()

            SMMessage.showWithMessage(SMCard.testConvert(response))

        })
        cardRequest.pc_cashout(cashoutObj, cardhash: sourceCardToken, accountId: accountId)

    }

    static func payPayment(enc : String? , onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){

        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in

            onSuccess?(response)

        }
        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
            SMMessage.showWithMessage(SMCard.testConvert(response))

        })
        cardRequest.pc_payment(withToken: SMUserManager.payToken , enc: enc)

    }



    static func defaultCardFromServer(_ card: String?,isDefault :String? ,  onSuccess: SimpleCallBack? = nil,  onFailed: FailedCallBack? = nil){

        let token = card
        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in
            SMLoading.hideLoadingPage()
            self.syncCardsWithServer(onSuccess: {
                onSuccess?()
            }, onFailedCallBack : {err in
                onFailed?(err)
            })

        }

        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
            SMMessage.showWithMessage(SMCard.testConvert(response))

        })
        cardRequest.pc_defaultcard(token,isDefault: isDefault)

    }


    static func deleteCardFromServer(_ card: String?, onSuccess: SimpleCallBack? = nil,  onFailed: FailedCallBack? = nil){

        let token = card
        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in
            SMLoading.hideLoadingPage()

            self.syncCardsWithServer(onSuccess: {
                onSuccess?()
            }, onFailedCallBack : {err in
                onFailed?(err)
                

            })

        }


        cardRequest.addFailedHandler({ (response: Any) in
            SMLog.SMPrint("faild")
            onFailed?(response)
            SMMessage.showWithMessage(SMCard.testConvert(response))

        })
        cardRequest.pc_deletecard(token)


    }

    static func syncCardsWithServer(onSuccess: SimpleCallBack? = nil,  onFailedCallBack: FailedCallBack? = nil){

        SMCard.getAllCardsFromServer({ cards in
            let newCards = cards as! [SMCard]
            SMCard.deleteAllCardsFromDB()
            SMCard.addCardsToDB(cards : newCards )
            SMCard.setPin(userCards: newCards)
            onSuccess?()

        }, onFailed: {err in
            onFailedCallBack?(err)
        })

    }

    static func setPin(userCards: [SMCard]){
        for card in userCards {
            if card.type == 1{
                SMUserManager.pin = (card.protected) ?? false
            }
        }
    }
    static func getAllCardsFromServer(_ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){

        var serverCards = [SMCard]()
        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        print(cardRequest)
        cardRequest.addSuccessHandler { (response : Any) in
            SMLoading.hideLoadingPage()

            for item in response as! [NSDictionary]{
                let cardItem = item as? Dictionary<String, AnyObject>
                let card = SMCard()
                card.balance = cardItem?["balance"] as? Int64
                card.pan = cardItem?["card_number"] as? String
                card.token = cardItem?["token"] as? String
                card.protected = cardItem?["protected"] as? Bool
                card.type = cardItem?["type"] as? Int64
                card.cashablebalance = cardItem?["cashable_balance"] as? Int64
                card.cashout = cardItem?["cash_out"] as? Bool
                card.cashin = cardItem?["cash_in"] as? Bool
                card.bankCode = cardItem?["bank_code"] as? Int64
                card.backgroundimage = cardItem?["background_image"] as? String
                card.isDefault = cardItem?["default"] as? Bool ?? false
                let bank = SMBank()
                bank.setBankInfo(code: card.bankCode ?? 0)
                card.bank = bank
                serverCards.append(card)
            }


            SMCard.deleteAllCardsFromDB()
            SMCard.addCardsToDB(cards:serverCards)

            onSuccess?(serverCards)
        }


        
        cardRequest.addFailedHandler({ (response: Any) in
//            SMLog.SMPrint("faild")
            SMLoading.hideLoadingPage()
            onFailed?(response)
            print(response)

        })
        DispatchQueue.main.async(execute: { () -> Void in
        cardRequest.pc_listcard()
        })
    }

    static func getMerchatnCardsFromServer(accountId: String, _ onSuccess: CallBack? = nil,  onFailed: FailedCallBack? = nil){
        let card = SMCard()
        let cardRequest = WS_methods(delegate: self, failedDialog: false)
        cardRequest.addSuccessHandler { (response : Any) in
            for item in response as! [NSDictionary] {
                let cardItem = item as? Dictionary<String, AnyObject>
                if (cardItem?["type"] as? Int64) == 1 {
                card.balance = cardItem?["balance"] as? Int64
                card.pan = cardItem?["card_number"] as? String
                card.token = cardItem?["token"] as? String
                card.protected = cardItem?["protected"] as? Bool
                card.type = cardItem?["type"] as? Int64
                card.cashablebalance = cardItem?["cashable_balance"] as? Int64
                card.cashout = cardItem?["cash_out"] as? Bool
                card.cashin = cardItem?["cash_in"] as? Bool
                card.bankCode = cardItem?["bank_code"] as? Int64
                card.backgroundimage = cardItem?["background_image"] as? String
                card.isDefault = cardItem?["default"] as? Bool ?? false
                let bank = SMBank()
                bank.setBankInfo(code: card.bankCode ?? 0)
                card.bank = bank
                }
            }
            onSuccess?(card)
        }

        cardRequest.addFailedHandler({ (response: Any) in
//            SMLog.SMPrint("faild")
//            SMLoading.hideLoadingPage()
            onFailed?(response)

        })
        cardRequest.pc_listcard(byAccountId: accountId)

    }

    static func updateBaseInfoFromServer() {
        
        
        SMCard.syncCardsWithServer()
        
        SMUserManager.getUserProfileFromServer({
            
//            SMInitialInfos.taskSucceed()
            SMMerchant.getAllMerchantsFromServer(SMUserManager.accountId, { (merchant) in
//                SMInitialInfos.taskSucceed()
                return
            }) { (err) in
//                SMInitialInfos.taskFailed()
            }
            
//            SMIBAN.getAllIBANsFromServer(accountId: SMUserManager.accountId, { (ibans) in
//                SMInitialInfos.taskSucceed()
//            }, onFailed: { err in
//                SMInitialInfos.taskFailed()
//            })
            
            return
            
        }, onFailed: { err in
//            SMInitialInfos.taskFailed()
        })
        
        
        SMCard.getAllCardsFromServer({ cards in
            
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0{
                        
//                        SMInitialInfos.taskSucceed()
                        return
                    }
                }
            }
            
//            SMInitialInfos.taskFailed()
            
        }, onFailed: {err in
            
//            SMInitialInfos.taskFailed()
        })
        
        
        SMCashout.getAllCardsFromServer({cards in
//            SMInitialInfos.taskSucceed()
            
            return
            
        }, onFailed: {err in
//            SMInitialInfos.taskFailed()
        })
        
    }
}

