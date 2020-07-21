//
//  SMConstants.swift
//  PayGear
//
//  Created by a on 4/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import maincore

struct SMConstants {
    
    static let notificationMerchant = "merchant.info.updated"
    static let refreshTableView = "refreshTableview"
    static let notificationBarchart = "merchant.barCHart.updated"
    static let notificationHistoryMerchantUpdate = "merchant.info.updated.History"
    static let notificationRefresh = "Notification.Refresh"
    static let isBackToMain = "isBackToMain"

    
    static let version : String    = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
    static let build : String     = Bundle.main.infoDictionary!["CFBundleVersion"]! as! String
}

struct EventBusManager {
    
    static let GoToTransactions = "GoToTransactions"
    static let GoToCheque = "GoToCheque"
    static let GoToLoans = "GoToLoans"
    static let ShowDropDown = "ShowDropDown"
    static let UpdateData = "UpdateData"
    static let DroppDownPicked = "DroppDownPicked"
    static let initTheme = "initTheme"
    static let stopMusicPlayer = "stopMusicPlayer"
    static let playMusicPlayer = "playMusicPlayer"
    static let updateMediaTimer = "updateMediaTimer"
    static let updateMediaTimerTo = "updateMediaTimerTo"
    static let changePlayState = "changePlayState"
    static let updateBill = "updateBill"
    static let hideTopMusicPlayer = "showMusicTopPlayer"
    static let showTopMusicPlayer = "hideMusicTopPlayer"
    static let sendRoomId = "sendRoomId"
    static let updateMusicPlayerList = "updateMusicPlayerList"
    static let updateBottomPlayerButtonsState = "updateBottomPlayerButtonsState"
    static let updateLabelsData = "updateLabelsData"
    static let messageReceiveGlobal = "messageReceiveGlobal"
    static let lookAndFindForward = "lookAndFindForward"
    static let stopLastButtonState = "stopLastButtonState"
    static let updateBottomPlayerLabelsData = "updateBottomPlayerLabelsData"
    static let updateBillsName = "updateBillsName"
    static let sendForwardReq = "sendForwardReq"
    static let disableMultiSelect = "disableMultiSelect"
    static let updateTypingBubble = "updateTypingBubble"
    static let stickerToolbarClick = "stickerToolbarClick"
    static let stickerCurrentGroupId = "stickerCurrentGroupId"
    static let stickerAdd = "stickerAdd"
    static let discoveryFetchFirstPage = "discoveryFetchFirstPage"
    static let discoveryNearbyClick = "discoveryNearbyClick"
    static let login = "login"
    static let openRoom = "openRoom"
    static let changeDirection = "changeDirection"
    static let updateButtonPlayForDownload = "updateButtonPlayForDownload"
    static let showContactDetail = "showContactDetail"
    static let giftCardTap = "giftCardTap"
    static let giftCardPayment = "giftCardPayment"
    static let giftCardSendMessage = "giftCardSendMessage"
    static let sendCardToCardMessage = "sendCardToCardMessage"
    static let TopUpAddToFavourite = "TopUpAddToFavourite"
    static let InternetPackageAddToFavourite = "InternetPackageAddToFavourite"

}

struct SMMessage {
    
    static func showWithMessage(_ message: String) {
        
        let dialog = MC_message_dialog(title: MCLocalization.string(forKey: "GLOBAL_MESSAGE"), message: message, delegate: UIApplication.shared.delegate?.window??.rootViewController ?? UIViewController())
        let okBtn = MC_ActionDialog.action(withTitle: MCLocalization.string(forKey: IGStringsManager.GlobalOK.rawValue), style: MCMessageDialogActionButton.blue, handler: nil)
        dialog.addAction(okBtn)
        dialog.show()
    }
}

struct SMLog {
	
	static func SMPrint<T>(_ message:T, function: String = #function) {
		#if DEBUG
		if let text = message as? String {
			print("SMPrint:\(function): \(text)")
		}
		#endif
	}
}

@objcMembers
class SMColor: NSObject {
        
    static let PrimaryColor                 = #colorLiteral(red: 0.1176470588, green: 0.5882352941, blue: 1, alpha: 1)
    static let InactiveField                = #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
    static let TitleTextColor               = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let SignupTitleTextColor         = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let HintTextColor                = #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 1)
    static let HintTranspatentTextColor     = #colorLiteral(red: 0.1294117647, green: 0.5882352941, blue: 0.9529411765, alpha: 0.4)
    static let Silver                       = #colorLiteral(red: 0.6980392157, green: 0.7450980392, blue: 0.768627451, alpha: 1)
    static let lightBlue                    = #colorLiteral(red: 0.8901960784, green: 0.9490196078, blue: 0.9921568627, alpha: 1)
}


public enum SMPages:String {
    case IntroPage              = "intro@IntroPage"
    case IntroContentPage       = "introContentPage@IntroPage"
    case Splash                 = "splash@Splash"
    case Main                   = "main@MainTabBar"
    case Packet                 = "packet@Packet"
    case QR                     = "qr@QR"
    case AddCard                = "addcard@AddCard"
    case ChooseCard             = "choosecard@Packet"
    case PayCard                = "paycard@Packet"
    case PayAmount              = "payamount@Packet"
    case SignupPhonePage        = "signup@Signup"
    case ConfirmPhonePage       = "confirmPhone@Signup"
    case SetPasswordPage        = "setPassword@Signup"
    case RefferalPage           = "refferal@Signup"
    case LoginPage              = "login@Signup"
    case ProfilePage            = "profile@Profile"
    case MyQR                   = "myqr@QR"
    case WithDraw               = "withdraw@WithDraw"
    case Fast                   = "fastwithdraw@WithDraw"
    case TextFieldAlert         = "textalert@Alerts"
    case ConfirmAlert           = "confirmalert@Alerts"
    case UpdateAlert            = "updatealert@Alerts"
    case NormalAlert            = "normalalert@Alerts"
    case SavedCardsAlert        = "savedcards@Alerts"
    case HistoryTable           = "historytable@History"
    case HistoryDetail          = "historydetail@History"
	case ChooseLanguage		    = "language@Setting"
	case Merchant               = "merchant@Packet"
    case Service                = "service@Service"
	case Message 				= "message@Message"
}

struct SMFonts {
    
    static func IranYekanBold(_ size:Float) -> UIFont {
        return UIFont(name: "IRANYekanMobile-Bold", size: CGFloat(size))!
    }
    static func IranYekanLight(_ size:Float) -> UIFont {
        return UIFont(name: "IRANYekanMobile-Light", size: CGFloat(size))!
    }
    static func IranYekanRegular(_ size:Float) -> UIFont {
        return UIFont(name: "IRANYekanMobile", size: CGFloat(size))!
    }
}


struct SMImage {
    static func saveImage(image: UIImage, withName name: String) {
		
		let imageData = NSData(data: image.pngData()!)
		let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
														FileManager.SearchPathDomainMask.userDomainMask, true)
		let docs = paths[0] as NSString
		let name = name
		let fullPath = docs.appendingPathComponent(name)
		_ = imageData.write(toFile: fullPath, atomically: true)
	}
	
	static func getImage(imageName: String) -> UIImage? {
		
		var savedImage: UIImage?
		
		if let imagePath = SMImage.getFilePath(fileName: imageName) {
			savedImage = UIImage(contentsOfFile: imagePath)
		}
		else {
			savedImage = nil
		}
        
		return savedImage
	}
	
	static func getFilePath(fileName: String) -> String? {
		
		let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
		let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
		var filePath: String?
		let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
		if paths.count > 0 {
			let dirPath = paths[0] as NSString
			filePath = dirPath.appendingPathComponent(fileName)
		}
		else {
			filePath = nil
		}
		
		return filePath
	}
}
