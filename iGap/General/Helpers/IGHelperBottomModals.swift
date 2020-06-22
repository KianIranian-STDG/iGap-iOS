/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift
import UIKit
import SwiftEventBus


class IGHelperBottomModals {
    let window = UIApplication.shared.keyWindow
    static let shared = IGHelperBottomModals()

    private var actionSubmit: (() -> Void)?
    private init() {}
    func showWalletTransferModal(view: UIViewController? = nil,mode: String! = "WALLET_TRANSFER",articleID : String? = nil) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGWalletTransferModal") as! IGWalletTransferModal
        vc.mode = mode
        UIApplication.topViewController()!.presentPanModal(vc)
    }
    func showCardToCardModal(view: UIViewController? = nil,mode: String! = "CARDTOCARD",articleID : String? = nil) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGCardToCardModal") as! IGCardToCardModal
        vc.mode = mode
    
        
        UIApplication.topViewController()!.presentPanModal(vc)
    }
    func showBuyGiftStickerModal(view: UIViewController? = nil,token : String, amount :String,mode : String = "BUY_STICKER") {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGCheckGiftStickerModal") as! IGCheckGiftStickerModal
        vc.token = token
        vc.amount = amount
        if mode == "SEND_STICKER" {
            vc.mode = mode

        }
        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showGiftStickerModal(view: UIViewController? = nil,token : String, amount :String,mode : String = "BUY_STICKER",giftcard : IGStructGiftCardSticker) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGCheckGiftStickerModal") as! IGCheckGiftStickerModal
        vc.token = token
        vc.amount = amount
        if mode == "SEND_STICKER" {
            vc.mode = mode
            vc.giftcard = giftcard

        }
        UIApplication.topViewController()!.presentPanModal(vc)

    }

    func showNationalIDModal(view: UIViewController? = nil,mode : String = "NATIONAL_ID_Buy") {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGNationalIDModal") as! IGNationalIDModal
        if mode != "NATIONAL_ID_Buy" {
            vc.mode = mode
        }
        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func checkNationalIDModal(view: UIViewController? = nil,mode : String = "NATIONAL_ID_Buy",giftcard : IGStructGiftCardSticker) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGNationalIDModal") as! IGNationalIDModal
        if mode != "NATIONAL_ID_Buy" {
            vc.mode = mode
            vc.giftcard = giftcard

        }
        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showGiftPayInfoModal(view: UIViewController? = nil,giftCardInfo : IGStructGiftCardInfo) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGGIftPayInfoModal") as! IGGIftPayInfoModal

        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showChatMoneyTransactionsModal(view: UIViewController? = nil,roomID : Int64) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGChatPageMoneyModal") as! IGChatPageMoneyModal
        if roomID != nil {
            vc.roomID = roomID
        }
        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showBottomPanThreeInput(view: UIViewController? = nil,mode: String! = "NEWS_COMMENTS",articleID : String? = nil) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGThreeInputTVController") as! IGThreeInputTVController
        vc.mode = mode
        if articleID != nil {
         vc.articleID = articleID!
        }
        UIApplication.topViewController()!.presentPanModal(vc)
    }
    func showBlockCard(view: UIViewController? = nil,mode: String! = "BLOCK_CARD") {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGFourInputTVController") as! IGFourInputTVController
        vc.mode = mode

        UIApplication.topViewController()?.presentPanModal(vc)
        
    }
    func showPayLoan(view: UIViewController? = nil,mode: String! = "PAY_LOAN",loanNumber : String? = nil,amountToPay: String,Account: String? = nil) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGMBPayLoanTVController") as! IGMBPayLoanTVController
        vc.mode = mode
        if loanNumber != nil {
            vc.selectedLoan = loanNumber!
            vc.payAmount = amountToPay
            vc.payAccount = Account!
        }
        UIApplication.topViewController()?.presentPanModal(vc)
        
    }
    func showShebaModal(view: UIViewController? = nil,mode: String! = "SHEBA_CARD",data : String? = nil) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGOneLabelTVController") as! IGOneLabelTVController
        vc.mode = mode

        if data != nil {
        vc.ShebaNumber = data!
        }
        
        UIApplication.topViewController()?.presentPanModal(vc)
    }
    func showFourButtonModal(view: UIViewController? = nil,mode: String! = "SETTINGS") {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGFourButtonsTVController") as! IGFourButtonsTVController
        vc.mode = mode
        
        UIApplication.topViewController()?.presentPanModal(vc)
    }
    
    //MARK: - MultiForward Modal
    func showMultiForwardModal(view: UIViewController? = nil,messages: [IGRoomMessage] = [],isFromCloud: Bool = false, isGiftSticker: Bool = false, giftId: String? = nil) {//}-> UIView {
        var alertView = view
        if alertView == nil {
            alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGMultiForwardModalViewController") as! IGMultiForwardModalViewController
        vc.isFromCloud = isFromCloud
        vc.isGiftSticker = isGiftSticker
        vc.giftId = giftId
        vc.selectedMessages = messages
        alertView!.presentPanModal(vc)
    }
    //MARK: -  Modal
    
    func showStickerPackModal(view: UIViewController? = nil) {//}-> UIView {
            var alertView = view
            if alertView == nil {
                alertView = UIApplication.topViewController()
            }
            let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "IGLiveStickerPackViewController") as! IGLiveStickerPackViewController

        
        
            alertView!.presentPanModal(vc)
    //        return UIView()
        }
    func showChargeList(view: UIViewController? = nil,chargeList: [String]) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }

        let vc = IGPSChargeListTVC()
        vc.delegate = IGPSTopUpMainVC()

        vc.chargeList = chargeList
        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showChargeType(view: UIViewController? = nil,chargeTypes: [String],selectedOperator : IGSelectedOperator) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }

        let vc = IGPSChargeTypesTVC()
        vc.chargeTypes = chargeTypes
        vc.selectedOperator = selectedOperator
        UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showDataModal(view: UIViewController? = nil,categories : [IGPSInternetCategory],isTraffic : Bool = false ) {
        
            var alertView = view
            if alertView == nil {
             alertView = UIApplication.topViewController()
            }

            let vc = IGPSDataArrayVC()
            vc.items = categories
            vc.isTraffic = isTraffic
            UIApplication.topViewController()!.presentPanModal(vc)

    }
    func showBillTypes(view: UIViewController? = nil,types : [String]) {
        
            var alertView = view
            if alertView == nil {
             alertView = UIApplication.topViewController()
            }

            let vc = IGPSBillTypesVC()
            vc.types = types
            UIApplication.topViewController()!.presentPanModal(vc)

    }

    
    func showEditBillName(view: UIViewController? = nil,mode: String! = "EDIT_BILL",billType : IGBillType = .Elec, bill : parentBillModel, billIndex : Int? = nil) {
        var alertView = view
        if alertView == nil {
         alertView = UIApplication.topViewController()
        }
        let storyboard : UIStoryboard = UIStoryboard(name: "BottomModal", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IGWalletTransferModal") as! IGWalletTransferModal
        vc.mode = mode
        vc.billType = billType
        vc.bill = bill
        if billIndex != nil {
            vc.index = billIndex
        }
        UIApplication.topViewController()!.presentPanModal(vc)
    }

    
}
