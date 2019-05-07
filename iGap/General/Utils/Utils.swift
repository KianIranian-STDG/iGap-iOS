//
//  Utils.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/8/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
//import PopupDialog
//import SwiftEventBus
import Alamofire
import KeychainSwift

/// Show Alert Dialog
///
/// - Parameters:
///   - title: title
///   - Desc: description
///   - onView: parent view
///   - delegate: click delegates
/*
func showAlert(title: String, desc: String ,onView: UIViewController,completion: (()-> Void)? = nil){
    let popup = PopupDialog(title: title, message: desc)
    let vc = popup.viewController as! PopupDialogDefaultViewController
    
    // Set dialog properties
    vc.messageFont = UIFont(name: AppFontName, size: 14)!
    vc.titleFont = UIFont(name: AppFontName, size: 17)!
    
    let btnDone = CancelButton(title: "تایید") {
        completion!()
    }
    btnDone.setDefaultFont()
    popup.addButton(btnDone)
    // Present dialog
    onView.present(popup, animated: true, completion: nil)
    
}
func showAlertInfo(title: String, desc: String ,onView: UIViewController,completion: (()-> Void)? = nil){
    let popup = PopupDialog(title: title, message: desc)
    let vc = popup.viewController as! PopupDialogDefaultViewController
    
    // Set dialog properties
    vc.messageFont = UIFont(name: AppFontName, size: 14)!
    vc.titleFont = UIFont(name: AppFontName, size: 17)!
    
    let btnDone = CancelButton(title: "تایید") {
        completion!()
    }
    btnDone.setDefaultFont()
    popup.addButton(btnDone)
    // Present dialog
    onView.present(popup, animated: true, completion: nil)
    
}

/// show confrim dialog with two button
///
/// - Parameters:
///   - title: title
///   - desc: description
///   - onView: parent vc
///   - completion: completion method
func showConfrimAlert(title: String, desc: String ,onView: UIViewController,completion: ((Bool)-> ())? = nil){
    let popup = PopupDialog(title: title, message: desc, gestureDismissal: false)
    let vc = popup.viewController as! PopupDialogDefaultViewController
    
    // Set dialog properties
    vc.messageFont = UIFont(name: AppFontName, size: 14)!
    vc.titleFont = UIFont(name: AppFontName, size: 17)!
    popup.buttonAlignment = .horizontal
    let btnYes = DefaultButton(title: "بله") {
        completion!(true)
    }
    let btnNo = CancelButton(title: "خیر") {
        completion!(false)
    }
    
    btnYes.setDefaultFont()
    btnNo.setDefaultFont()
    popup.addButtons([btnNo,btnYes])
    // Present dialog
    onView.present(popup, animated: true, completion: nil)
    
}


func showActivityInd(onView : UIViewController,completion: ( () -> Void)? = nil) -> PopupDialog {
    let pbVC = MGProgress(nibName: "MGProgress", bundle: nil)
    let popup = PopupDialog(viewController: pbVC, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false)
    
    let btnCancel = DefaultButton(title: "Cancel".localized, height: 60) {
        print("canceled")
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
            
            
        }
        
    }
    btnCancel.setDefaultFont()
    popup.addButton(btnCancel)
    
    SwiftEventBus.onMainThread(onView.self, name: TimeOut, handler: {_ in
        
        //        popup.dismiss()
        //        DispatchQueue.main.async {
        //            if onView.className == "AccountBalanceViewController" ||
        //                onView.className == "BillActionSubViewControllerAccountByCountViewController" ||
        //                onView.className == "BuyChargeViewController" ||
        //                onView.className == "ChargeDetailsTableViewController" {
        //                onView.navigationController?.popViewController(animated: true)
        //            }
        //        }
        
        
    })
    
    
    //    onView.present(popup, animated: true, completion: nil)
    
    return popup
}
func showCustomActivityInd(onView : UIViewController,completion: ( () -> Void)? = nil) -> PopupDialog {
    let pbVC = MGProgress(nibName: "MGProgress", bundle: nil)
    let popup = PopupDialog(viewController: pbVC, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: false)
    
    let btnCancel = DefaultButton(title: "Cancel".localized, height: 60) {
        print("canceled")
        
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
            
            
        }
        
    }
    btnCancel.setDefaultFont()
    popup.addButton(btnCancel)
    
    SwiftEventBus.onMainThread(onView.self, name: TimeOut, handler: {_ in
        
        //        popup.dismiss()
        //        DispatchQueue.main.async {
        //            if onView.className == "AccountBalanceViewController" ||
        //                onView.className == "BillActionSubViewControllerAccountByCountViewController" ||
        //                onView.className == "BuyChargeViewController" ||
        //                onView.className == "ChargeDetailsTableViewController" {
        //                onView.navigationController?.popViewController(animated: true)
        //            }
        //        }
        
        
    })
    
    
    //    onView.present(popup, animated: true, completion: nil)
    
    return popup
}

enum ServiceType {
    case Account
    case Card
}
enum EasyPayType {
    case Variz
    case Daryaft
}
enum ServiceInnerType {
    case DestiSepah
    case Other
    case Mine
}
enum ChargeType {
    case Direct
    case Normal
}
enum PayBillType {
    case PayBill
    case PayOrganizations
    case PayBillPhone
    case CheckBill
}
var tmpAccountCard: String!
var SumOfAccounts: Int64 = 0
var SumOfCards: Int64 = 0
/// Service Call Mode! Card or Account
var SERVICE_TYPE:ServiceType!
var EASYPAY_TYPE:EasyPayType!
var TRANSFER_TYPE:TransferType!
var ACTION_TYPE:ActionType!
var HINT_TYPE:HintType!
var OPERATOR_TYPE:OperatorType!
var TABBAR_ITEM:TabbarItem!
var NOLOGIN_ACTION_TYPE:NoLoginActionType!
var SERVICE_INNER_TYPE:ServiceInnerType!
var CHARGE_TYPE:ChargeType!
var PAY_BILL_TYPE:PayBillType!


/// enum for bill type
///
/// - BillTypeAB: ab
/// - BillTypeBARGH: bargh
/// - BillTypeGAZ: gaaz
/// - BillTypeTELEPHONE: tell
/// - BillTypeMOBILE: mobile
/// - BillTypeSHARDARI: shahrdari
/// - BillTypeSHAHRDARI2: shahrdari2
/// - BillTypeMALIAT: maliat
/// - BillTypeUD: ud
enum BillType:Int64 {
    case BillTypeAB = 1
    case BillTypeBARGH
    case BillTypeGAZ
    case BillTypeTELEPHONE
    case BillTypeMOBILE
    case BillTypeSHARDARI
    case BillTypeSHAHRDARI2
    case BillTypeMALIAT
    case BillTypeUD
}


/// to select account statement
///

enum BillMode {
    case count
    case date
    case billNum
    case special
}
enum OperatorType {
    case HAMRAHAVAL
    case RIGHTEL
    case IRANCELL
}
enum TabbarItem {
    case TANZIMAT
    case INFO
    case AMALIATHA
    case KHADAMAT
}
enum ActionType {
    case Transfer
    case VarizVajh
    case SoratHesab
    case KhadamatSeporde
    case KhadamatCard
    case Pay
    case BuyCharge
    case Gozareshat
    case GetIban
    case easyPay
    case CheckBill
}
enum HintType {
    case USERNAME
    case PASS
    case TRANSFERPASS
}
enum NoLoginActionType {
    case CardToCard
    case Mojodi
    case Masdoodi
    case PardakhtQabz
    case EstelamQabz
    case KharidCharj
    case EstelamCharj
    case GetIbanOther
    case Call1557
    case Ebank
    case easyPay
}
enum TransferType {
    case AccountToAccount
    case AccountToCard
    case Satna
    case Paya
    case CardToCard
}
var BILL_TYPE_GOZARESHAT: billTypeGozareshat!

enum billTypeGozareshat{
    case Qabz
    case Sharj
}

/// password changes mode
///
/// - User: for change NickName
/// - Password: for change Login password
/// - ConfirmPassword: for change Confirm password
enum PasswordChangeMode {
    
    case User
    case Password
    case ConfirmPassword
    
}


enum DestinationType {
    
    case SepahAccount
    case OtherBankAccount
    case SepahCard
    case OtherBankCard
}

var Destination_Type: DestinationType!


enum ReportMode {
    case User
    case Account
    case Card
}
var REPORT_MODE: ReportMode!

enum ConfirmType: String {
    case STATIC_PIN
    case OTP
    case SMS
    case SOFT_OTP
}

var CONFIRM_TYPE = ConfirmType.STATIC_PIN
var SERVICE_CONFIRM_TYPE = ConfirmType.STATIC_PIN
 */
public class Utils {
    /*
    class func setFontSize() -> CGFloat {
        if isKeyPresentInUserDefaults(key: "FontSize") {
            let defSize = UserDefaults.standard.integer(forKey: "FontSize")
            var size:CGFloat!
            switch defSize {
            case 0 :
                size = 19
            case 1 :
                size = 17
            case 2 :
                size = 14
            case 3 :
                size = 12
            default:
                size = 14
            }
            return CGFloat(size)
        }
        return 14
    }
    
    
    class func getVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "no version info"
        }
        return version
    }
    
    
    class func getOsVersion() -> String {
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion
    }
    */
    class func getAccessToken() -> String {
        let keychain = KeychainSwift()
        
        let accessToken = "bearer" + keychain.get("accesstoken")!
        return accessToken
    }
}
