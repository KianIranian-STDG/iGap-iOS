/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import SwiftProtobuf
import MBProgressHUD
import Foundation
import SwiftyRSA
import SDWebImage
import RxSwift
import maincore
import IGProtoBuff
import RealmSwift
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import Lottie
import Photos
import Files

var fontDefaultSize: CGFloat = 15.0

let kIGChnageLanguageNotificationName = "im.igap.ios.change.language"
let kIGGoDissmissLangNotificationName = "im.igap.ios.dismiss.lang"
let kIGNotificationNameDidCreateARoomAtProfile = "im.igap.ios.room.created.from.profile"
let kIGNoticationForPushUserExpire = "im.igap.ios.user.expire"
let kIGNoticationDismissWalletPay = "im.igap.ios.dismiss.wallet.pay"

let IGNotificationStatusBarTapped         = Notification(name: Notification.Name(rawValue: "im.igap.statusbarTapped"))
let IGNotificationPushLoginToken          = Notification(name: Notification.Name(rawValue: "im.igap.ios.user.push.token"))
let IGNotificationPushTwoStepVerification = Notification(name: Notification.Name(rawValue: "im.igap.ios.user.push.two.step"))


let orangeGradientLocation = [0.0, 1.0]

enum themeMode : Int {
    case night = 0
    case day = 1
    case classic = 2
    case any = 3
}
enum songMainState : Int {
    case ended = 0
    case playing = 1
    case paused = 2

}
enum messageMainTopViewState : Int {
    case withPin = 0
    case withTopPlayer = 1
    case withBoth = 2
    case none = 3
}

class IGGlobal {
    
    /***** Base of Directories *****/
    static let APP_DIR = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/iGap"
    static let CACHE_DIR = APP_DIR//NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/iGap" /*don't use cache directory for avoid from remove files automatically by OS*/

    /***** Document Base *****/
    static let IMAGE_DIR = "/images"
    static let VIDEO_DIR = "/videos"
    static let AUDIO_DIR = "/audios"
    static let VOICE_DIR = "/voices"
    static let GIF_DIR = "/gifs"
    static let FILE_DIR = "/files"
    /***** Cache Base *****/
    static let THUMB_DIR = "/thumb"
    static let BACKGROUND_DIR = "/backgrounds"
    static let AVATAR_DIR = "/avatars"
    static let STICKER_DIR = "/stickers"
    /***** Temporary Base *****/
    static let TEMP_DIR = "/temp"
    //static let TEMP_DIR = Folder.temporary.path + "/iGap"
    
    
    static var imgDic : [String: IGImageView] = [:]
    static var shouldMultiSelect : Bool = false
    static var clickedAudioCellIndexPath : IndexPath = [0,0]
    static var currentMusic : IGFile!
    static var isPaused : Bool = false
    static var isVoice : Bool = false
    static var songState : songMainState = songMainState(rawValue: 0)!
    static var messageViewState : messageMainTopViewState = messageMainTopViewState(rawValue: 3)!
    static var shouldShowTopBarPlayer : Bool = false
    static var isAlreadyOpen : Bool = false
    static var hasTexted : Bool = false
    static var isFromSearchPage : Bool = false
    static var isInChatPage : Bool = true
    static var isSilent : Bool = false
    static var topBarSongTime : Float = 0
    static var topBarSongName : String = ""
    static var topBarSongSinger : String = ""
    static var themeMode : themeMode.RawValue = 2
    static var isPopView : Bool = false
    static var dispoasDic: [Int64:Disposable] = [:]
    static var dispoasDicString: [String:Disposable] = [:]
    static var carpinoAgreement : Bool = false
    static var barSpace : Int = 50
    static var chartIGPPollFields: [IGPPollField]! = []
    static var pageIDChartUpdate: Int32 = 0
    static var languageFileName: String = "localizationsFa"
    static var importedRoomMessageDic: [Int64:IGRoomMessage] = [:]
    static var rewriteRoomInfo: [IGPRoom] = []
    static var shouldShowChart : Bool = false
    static var hideBarChart : Bool = true
    static var latestTime: Int64 = 0
    static var sendTone: AVAudioPlayer?
    static var safeAreaInsets: CGFloat = 0
    static let eventBusChatKey = "CHAT"
    static let eventBusObject = NSObject()
    static var stickerPreviewSectionIndex: Int = -1
    static var stickerCurrentGroupId: String? = nil // when current sticker page type is 'StickerPageType.MAIN' set this value for keep index and show current state of sticker tab after close add sticker list page
    static var stickerImageDic: [String:UIImageView] = [:]
    static var stickerAnimationDic: [String:AnimationView] = [:]
    
    static var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (UIApplication.shared.statusBarFrame.height ) +
                (44)
        } else {
            return UIApplication.shared.statusBarFrame.size.height +
                (44)
        }
    }

    static var timeDic: [Int:Time] = [:]
    struct Time {
        var lastMillis: Int64 = 0
        var total: Int = 0
        var count: Int = 0
    }
    internal static func isCloud(room: IGRoom) -> Bool {
        if !room.isInvalidated, room.chatRoom?.peer?.id == IGAppManager.sharedManager.userID() {
            return true
        }
        return false
    }
    internal static  func playSound(isInChat: Bool = false,isSilent: Bool = false,isSendMessage: Bool! = false) {
        var url = Bundle.main.url(forResource: "igap_send_message_sound", withExtension: "mp3")
        
        if isSendMessage {
            url = Bundle.main.url(forResource: "igap_send_message_sound", withExtension: "mp3")
        } else {
            url = Bundle.main.url(forResource: "igap_receive_message_sound", withExtension: "mp3")
        }
        
        if let soundURL = url {
            var soundID : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
    internal static func getTime(group: Int = 0, _ string: String = "", start: Bool = false) {
        
        if start {
            if IGGlobal.timeDic[group] == nil {
                IGGlobal.timeDic[group] = Time()
            }
            IGGlobal.timeDic[group]!.lastMillis = IGGlobal.getCurrentMillis()
            return
        }
        
        if IGGlobal.timeDic[group] == nil {
            IGGlobal.timeDic[group] = Time()
            IGGlobal.timeDic[group]!.lastMillis = IGGlobal.getCurrentMillis()
        }
        
        let currentTime = IGGlobal.getCurrentMillis()
        let differenceTime = currentTime - IGGlobal.timeDic[group]!.lastMillis
        if string.isEmpty {
            print("TTT || group: \(group)  **  time: \(differenceTime)")
        } else {
            print("TTT || group: \(group)  **  key \(String(describing: string))  **  time: \(differenceTime)")
        }
        
        IGGlobal.timeDic[group]!.count = IGGlobal.timeDic[group]!.count + 1
        IGGlobal.timeDic[group]!.total = IGGlobal.timeDic[group]!.total + Int(differenceTime)
        let average = IGGlobal.timeDic[group]!.total / IGGlobal.timeDic[group]!.count
        print("TTT || AVgroup: \(group)  **  average: \(average)")
        
        IGGlobal.timeDic[group]?.lastMillis = currentTime
    }
    
    internal static func getThread(_ string: String? = nil){
        print("TTT || ", string ?? "" ,Thread.current.isMainThread)
    }
    
    internal static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    internal static func validaatePhoneNUmber(phone : Int64!) -> String {
        let str = String(phone)
        if str.starts(with: "98") {
            let tmp = str.dropFirst(2)
            return "0" + tmp
        } else if str.starts(with: "09") {
            return str
        } else {
            return str
        }
    }
    /////SET LANGUAGE//////
    
//    internal static func setLanguage() {
//        if  lastLang == Language.persian.rawValue  {
//            SMLangUtil.changeLanguage(newLang: .Persian)
//            Language.language = Language.persian
//
//        } else if lastLang == Language.arabic.rawValue {
//            SMLangUtil.changeLanguage(newLang: .Persian)
//            Language.language = Language.arabic
//
//        } else {
//            SMLangUtil.changeLanguage(newLang: .English)
//            Language.language = Language.english
//        }
//    }
    
    /**********************************************/
    /****************** Progress ******************/
    private static var progressHUD = MBProgressHUD()
    
    internal static func prgShow(_ view: UIView? = nil){
        DispatchQueue.main.async {
            var prgView = view
            if prgView == nil {
                prgView = UIApplication.topViewController()?.view
            }
            if prgView != nil, let superView = prgView?.superview {
                IGGlobal.progressHUD = MBProgressHUD.showAdded(to: superView, animated: true)
                IGGlobal.progressHUD.mode = .indeterminate
            }
        }
    }
    
    internal static func prgHide() {
        DispatchQueue.main.async {
            IGGlobal.progressHUD.hide(animated: true)
        }
    }
    
    /**********************************************/
    /******************** HASH ********************/

    internal static func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    /**********************************************/
    /******************** File ********************/
    
    internal static func makePath(filename: String?) -> URL? {
        if filename != nil {
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return NSURL(fileURLWithPath: documents).appendingPathComponent(filename!)
        }
        return nil
    }
    internal static func checkRealmFileSize() {
        if let realmPath = Realm.Configuration.defaultConfiguration.fileURL?.relativePath {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath:realmPath)
                if let fileSize = attributes[FileAttributeKey.size] as? Double {
                    
                    print("REALM SIZE IN BYTE :",fileSize)
                }
            }
            catch (let error) {
                print("FileManager Error: \(error)")
            }
        }
    }
    /*
     * check file exist in path or no. also if 'fileSize' is set to the input of the method,
     * size of file that exist in path and 'fileSize' which is set, will be compared.
     * finally if there are two equal values,the output is true otherwise the output will be false.
     */
    internal static func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    internal static func isFileExist(path: String?, fileSize: Int64 = -1) -> Bool {
        if path != nil && FileManager.default.fileExists(atPath: path!) {
            if fileSize == -1 || fileSize == Int64(FileManager.default.contents(atPath: path!)?.count ?? 0) {
                return true
            }
        }
        return false
    }
    
    internal static func isFileExist(path: URL?, fileSize: Int64 = -1) -> Bool {
        if path != nil {
            return isFileExist(path: path?.path, fileSize: fileSize)
        }
        return false
    }
    
    internal static func removeFile(path: String?) {
        do {
            if path != nil {
                try FileManager.default.removeItem(atPath: path!)
            }
        } catch {
            print("file not removed")
        }
    }
    
    internal static func removeFile(path: URL?) {
        do {
            if path != nil {
                try FileManager.default.removeItem(at: path!)
            }
        } catch {
            print("file not removed")
        }
    }
    
    internal static func getFileSize(path: URL?) -> Int64 {
        if path == nil {
            return 0
        }
        
        return getFileSize(path: path?.path)
    }
    
    internal static func getFileSize(path: String?) -> Int64{
        if path == nil || !isFileExist(path: path) {
            return 0
        }
        
        return Int64(FileManager.default.contents(atPath: (path)!)!.count)
    }
    internal static func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
    /******************** File ********************/
    /**********************************************/
    
    internal static func getVisibleRoomId() -> Int64? {
        for chat in IGRecentsTableViewController.visibleChat {
            if chat.value == true {
                return chat.key
            }
        }
        return nil
    }
    
    internal static func isForwardEnable() -> Bool {
        return IGMessageViewController.selectedMessageToForwardToThisRoom != nil
    }
    
    /**
     * Hint: this method before return file value will be replaced "\n" with "".
     * this action is because of an extra line in file text. if exist another
     * solution so can remove this replce from code
     */
    internal static func readStringFromFile(fileName: String) -> String? {
        let path = Bundle.main.path(forResource: fileName, ofType: "txt")
        let fileValue = try! NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue) as String
        let finalValue = fileValue.replace("\n", withString: "")
        return finalValue
    }
    
    //MARK: RegEx
    public class func matches(for regex: String, in text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.count > 0
        } catch {
            return false
        }
    }
    
    //MARK: Random String
    public class func randomString(length : Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(UInt32(letters.count)))
            randomString.append(letters[rand])
        }
        return randomString
    }
    
    public class func randomId() -> Int64 {
        return Int64(arc4random()) + (Int64(arc4random()) << 18)
    }
    
    public class func fakeMessageId() -> Int64 {
        return getCurrentMillis() + 100000000000000000 // 100000000000000000 is a fake random id for set this fake id bigger than main messageId
    }
    
    /* if device is iPad return "alert" style otherwise will be returned "actionSheet" style */
    public class func detectAlertStyle() -> UIAlertController.Style{
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .actionSheet
        }
        return .alert
    }
    
    public class func hasBigScreen() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return false
        }
        
        return true
    }
    
    public func gradientImage(withColours colours: [UIColor], location: [Double], view: UIView) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = location as [NSNumber]
        gradient.cornerRadius = view.layer.cornerRadius
        return UIImage.image(from: gradient) ?? UIImage()
    }
    
    public class func fetchUIScreen() -> CGRect {
        return UIScreen.main.bounds
    }
    
    public class func fetchBottomSafeArea() -> CGFloat {
        if safeAreaInsets != 0 {
            return safeAreaInsets
        }
        if #available(iOS 11.0, *) {
            safeAreaInsets = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        }
        return safeAreaInsets
    }
    
    public class func getCurrentMillis()->Int64{
        return  Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    internal static func dataFromFile(_ filename: String) -> Data? {
        @objc class TestClass: NSObject { }
        
        let bundle = Bundle(for: TestClass.self)
        if let path = bundle.path(forResource: filename, ofType: "json") {
            return (try? Data(contentsOf: URL(fileURLWithPath: path)))
        }
        return nil
    }
}

extension UIViewController {
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiateFromAppStroryboard(appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
}

extension UICollectionView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.igFont(ofSize: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        DispatchQueue.main.async {
            self.backgroundView = nil
        }
    }
}
extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}
extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = ThemeManager.currentTheme.LabelColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.igFont(ofSize: 20)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

//MARK: -


extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    public class func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //iGap Theme
    class func iGapMainColor() -> UIColor {
        return iGapDarkGreenColor()
    }
    
    class func iGapBlue() -> UIColor {
        return UIColor(red: 30/255.0, green: 136/255.0, blue: 229/255.0, alpha: 1.0)
    }
    
    class func iGapBars() -> UIColor { // navigation bar color
        return iGapDarkGreenColor()
    }
    
    class func iGapBarsInfo() -> UIColor { // text & icons color on navigation bar
        return UIColor(red:255.0/255.0, green:255.0/255.0, blue:255.0/255.0, alpha:1.0)
    }
    
    class func dialogueBoxOutgoing() -> UIColor {
        return ThemeManager.currentTheme.SendMessageBubleBGColor
    }
    class func helperWindowViewColor() -> UIColor {
        return ThemeManager.currentTheme.ModalViewBackgroundColor
    }
    class func helperWindowViewBorderColor() -> UIColor {
        return ThemeManager.currentTheme.LabelGrayColor
    }
    
    class func dialogueBoxIncomming() -> UIColor {
        return UIColor(red: 229/255.0, green: 225/255.0, blue: 220/255.0, alpha: 0.9)
    }
    
    class func forwardBoxIncomming() -> UIColor {
        return #colorLiteral(red: 0.6156862745, green: 0.7803921569, blue: 0.337254902, alpha: 0.3)
    }
    class func tabbarBGColor() -> UIColor {
        return ThemeManager.currentTheme.TabBarColor
    }
    
    class func forwardBoxOutgoign() -> UIColor {
        return #colorLiteral(red: 0.6156862745, green: 0.7803921569, blue: 0.337254902, alpha: 0.3)
    }
    class func iGapDarkGreenColor() -> UIColor { // navigation bar color
        return #colorLiteral(red: 0.2549019608, green: 0.6941176471, blue: 0.1254901961, alpha: 1)
    }
    class func iGapLightGreenColor() -> UIColor { // navigation bar color
        return #colorLiteral(red: 0.7254901961, green: 0.8862745098, blue: 0.2666666667, alpha: 1)
    }
    class func iGapDarkYellow() -> UIColor {
        return UIColor(red: 209/255.0, green: 179/255.0, blue: 31/255.0, alpha: 0.9)
    }
    class func iGapPurple() -> UIColor {
        return UIColor(red: 167/255.0, green: 70/255.0, blue: 141/255.0, alpha: 0.9)
    }

    class func iGapSubmitButtons() -> UIColor { // navigation bar color
        return UIColor(red:87/255.0, green:186/255.0, blue:38/255.0, alpha:1.0)
    }
    class func forwardBoxTitleIncomming() -> UIColor {
        return messageText()
    }
    
    class func forwardBoxTitleOutgoign() -> UIColor {
        return messageText()
    }
    
    class func replyBoxIncomming() -> UIColor {
        return UIColor(red:157/255.0, green:199/255.0, blue:86/255.0, alpha:0.3)
    }
    
    class func replyBoxOutgoing() -> UIColor {
        return UIColor(red:157/255.0, green:199/255.0, blue:86/255.0, alpha:0.3)
    }
    
    class func replyBoxTitleIncomming() -> UIColor {
        return messageText()
    }
    
    class func replyBoxTitleOutgoign() -> UIColor {
        return messageText()
    }
    
    class func replyBoxMessageIncomming() -> UIColor {
        return messageText()
    }
    
    class func replyBoxMessageOutgoign() -> UIColor {
        return messageText()
    }
    
    class func messageText() -> UIColor {
        return ThemeManager.currentTheme.LabelColor
    }
    
    class func dialogueBoxInfo() -> UIColor { // filename, contact, ...
        return UIColor.messageText()
    }
    
    class func logBackground() -> UIColor { // filename, contact, ...
        return ThemeManager.currentTheme.MessageLogCellBGColor
    }
    
    class func unreadBackground() -> UIColor { // filename, contact, ...
        return ThemeManager.currentTheme.MessageUnreadCellBGColor
    }
    
    class func pinnedChats() -> UIColor {
        return UIColor(red:157/255.0, green:199/255.0, blue:86/255.0, alpha:0.2)
    }
    
    class func chatListMessageType() -> UIColor {
        return UIColor(red:157/255.0, green:199/255.0, blue:86/255.0, alpha:1.0)
    }
    
    class func unreadLable() -> UIColor {
        return UIColor(red:224/255.0, green:83/255.0, blue:83/255.0, alpha:1.0)
    }
    
    class func iGapLink() -> UIColor {
        return UIColor(red:123/255.0, green:165/255.0, blue:52/255.0, alpha:1.0)
    }
    
    class func sticker() -> UIColor {
        return ThemeManager.currentTheme.TableViewBackgroundColor
    }
    
    class func stickerToolbar() -> UIColor {
        return ThemeManager.currentTheme.ModalViewBackgroundColor
    }
    
    class func stickerToolbarSelected() -> UIColor {
        return UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.0)
    }
    
    class func statusBackgroundLayout() -> UIColor {
        return UIColor(red: 0/255.0, green: 24/255.0, blue: 25/255.0, alpha: 0.2)
    }
    
    class func iGapRed() -> UIColor {
        return failedColor()
    }
    
    class func iGapGreen() -> UIColor {
        return iGapMainColor()
    }
    class func iGapYellow() -> UIColor {
        return UIColor(red: 244/255.0, green: 212/255.0, blue: 66/255.0, alpha: 0.9)
    }
    class func iGapGold() -> UIColor {
        return UIColor(red: 212/255.0, green: 175/255.0, blue: 55/255.0, alpha: 0.9)
    }
    class func iGapTableViewBackground() -> UIColor {
        return #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
    }
    class func iGapSkyBlue() -> UIColor {
        return UIColor(red: 66/255.0, green: 212/255.0, blue: 244/255.0, alpha: 0.9)
    }
    
    class func iGapPink() -> UIColor {
        return UIColor(named: "IGTopupCellColor")!
    }
    
    class func iGapTopupCellPurple() -> UIColor {
        return UIColor(named: "IGBillCellColor")!
    }
    
    class func iGapGray() -> UIColor {
        return #colorLiteral(red: 0.4078431373, green: 0.4078431373, blue: 0.4078431373, alpha: 0.9)
    }
    class func iGapDarkGray() -> UIColor {
        return ThemeManager.currentTheme.LabelGrayColor
    }
    
    class func failedColor() -> UIColor {
        return #colorLiteral(red: 0.9490196078, green: 0.1960784314, blue: 0.1882352941, alpha: 1)
    }
    
    class func seenColor() -> UIColor {
        return UIColor(red:68/255.0, green:181/255.0, blue:31/255.0, alpha:1.0)
    }
    
    //MARK: MGSwipeTableCell
    class func swipeDarkBlue() -> UIColor {
        return UIColor(red:42/255.0, green:61/255.0, blue:61/255.0, alpha:1.0)
    }
    
    class func swipeBlueGray() -> UIColor {
        return UIColor(red:93/255.0, green:111/255.0, blue:111/255.0, alpha:1.0)
    }
    
    class func swipeGray() -> UIColor {
        return UIColor(red: 104/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1.0)
    }
    
    class func swipeRed() -> UIColor {
        return UIColor(red:224/255.0, green:83/255.0, blue:83/255.0, alpha:1.0)
    }
    
    class func tabbarUnselectedColor() -> UIColor {
        return UIColor(red: 224/255.0, green: 220/255.0, blue: 215/255.0, alpha: 0.9)
    }
    
    class func tabbarTextUnselectedColor() -> UIColor {
        return UIColor(red: 249/255.0, green: 245/255.0, blue: 240/255.0, alpha: 0.9)
    }
    
    //MARK: General Colors
    class func organizationalColor() -> UIColor { // iGap Color
        
        return iGapDarkGreenColor()
    }
    
    class func customKeyboardButton() -> UIColor {
        return UIColor(red:125/255.0, green:125/255.0, blue:125/255.0, alpha:1.0)
    }
    
    //MARK: General Colors
    class func doctorBotPinColor() -> UIColor {
        return UIColor(red:0/255.0, green:176.0/255.0, blue:191.0/255.0, alpha:0.2)
    }
    
    class func organizationalColorLight() -> UIColor {
        return UIColor(red:180.0/255.0, green:255.0/255.0, blue:255.0/255.0, alpha:1.0)
    }
    
    class func returnToCall() -> UIColor {
        return UIColor(red:254.0/255.0, green:193.0/255.0, blue:7.0/255.0, alpha:1.0)
    }
    
    class func callRatingView() -> UIColor {
        return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
    }
    
    class func iGapColor() -> UIColor {
        return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
    }
    
    //MARK: Call State Colors
    class func callStatusColor(status: Int) -> UIColor {
        
        switch status {
            
        case 0: //MISSED
            return UIColor(red: 242.0/255.0, green: 49.0/255.0, blue: 49.0/255.0, alpha: 1.0)
            
        case 1: //CANCELED
            return UIColor(red: 0.0/255.0, green: 176/255.0, blue: 191.0/255.0, alpha: 1.0)
            
        case 2: //INCOMING
            return UIColor(red: 63.0/255.0, green: 81.0/255.0, blue: 181.0/255.0, alpha: 1.0)
            
        case 3: //OUTGOING
            return UIColor(red: 0.0/255.0, green: 176/255.0, blue: 191.0/255.0, alpha: 1.0)
            
        default:
            return UIColor(red: 0.0/255.0, green: 176/255.0, blue: 191.0/255.0, alpha: 1.0)
        }
        
    }
    
    class func senderNameColor() -> UIColor {
        return UIColor(red: 0.0/255.0, green: 188.0/255.0, blue: 202.0/255.0, alpha: 1.0)
    }
    
    class func senderNameColorDark() -> UIColor {
        return UIColor(red: 0.0/255.0, green: 100.0/255.0, blue: 120.0/255.0, alpha: 1.0)
    }
    
    class func chatBubbleBackground(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return  ThemeManager.currentTheme.ReceiveMessageBubleBGColor
        } else {
            return UIColor.dialogueBoxOutgoing()
        }
    }
    
    class func chatBubbleBorderColor() -> UIColor {
        return UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0)
    }
    
    class func chatBubbleTextColor(isIncommingMessage: Bool) -> UIColor {
        return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    }
    
    //MARK: MessageCVCell Time
    class func chatTimeTextColor() -> UIColor {
        return ThemeManager.currentTheme.LabelColor
    }
    
    //MARK: MessageCVCell Forward
    class func chatForwardedFromViewBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.forwardBoxIncomming()
        } else {
            return UIColor.forwardBoxOutgoign()
        }
    }
    
    class func chatForwardedFromUsernameLabelColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.forwardBoxTitleIncomming()
        } else {
            return UIColor.forwardBoxTitleOutgoign()
        }
    }
    
    class func chatForwardedFromMediaContainerViewBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatForwardedFromBodyContainerViewBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        } else {
            return UIColor(red: 44.0/255.0, green: 170/255.0, blue: 163.0/255.0, alpha: 1.0)
        }
    }
    
    class func chatForwardedFromBodyLabelTextColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.chatBubbleTextColor(isIncommingMessage: isIncommingMessage)
        } else {
            return UIColor(red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        }
    }
    
    
    //MARK: MessageCVCell Reply
    class func chatReplyToBackgroundColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.replyBoxIncomming()
        } else {
            return UIColor.replyBoxOutgoing()
        }
    }
    
    class func chatReplyToIndicatorViewColor(isIncommingMessage: Bool) -> UIColor {
        return ThemeManager.currentTheme.ReceiveMessageBubleBGColor
        /*
        if isIncommingMessage {
            return UIColor.replyBoxTitleIncomming()
        } else {
            return UIColor.replyBoxTitleOutgoign()
        }
        */
    }
    
    class func chatForwardToIndicatorViewColor(isIncommingMessage: Bool) -> UIColor {
        return ThemeManager.currentTheme.ReceiveMessageBubleBGColor
    }
    
    class func chatReplyToUsernameLabelTextColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return ThemeManager.currentTheme.LabelColor
        } else {
            return UIColor.replyBoxTitleOutgoign()
        }
    }
    
    class func chatReplyToMessageBodyLabelTextColor(isIncommingMessage: Bool) -> UIColor {
        if isIncommingMessage {
            return UIColor.replyBoxMessageIncomming()
        } else {
            return UIColor.replyBoxMessageOutgoign()
        }
    }
}

//MARK: -
extension Date {
    func convertToHumanReadable(onlyTimeIfToday: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        
        let calendar = NSCalendar.current
        if onlyTimeIfToday && !calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "MMM, dd"
            return self.localizedDate()
        }
        dateFormatter.dateFormat = "HH:mm"
        let hour = calendar.component(Calendar.Component.hour, from: self)
        let min = calendar.component(Calendar.Component.minute, from: self)
        return "\(String(format: "%02d", hour)):\(String(format: "%02d", min))".inLocalizedLanguage()
    }
    
    func completeHumanReadableTime(showHour: Bool = false) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY - HH:mm"
        let dateString = self.localizedDate(showHour: showHour)
        return dateString.inLocalizedLanguage()
    }
    func completeOnlyDate(showHour: Bool = false) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "YYYY-mm-dd"
        let dateString = self.localizedDate(showHour: showHour)
        return dateString.inLocalizedLanguage()
    }
    func CustomeCompleteHumanReadableTime(showHour: Bool = false) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = self.localizedDate(showHour: showHour)
        return dateString.inLocalizedLanguage()
    }

    func completeHumanReadableTimeWithSec(showHour: Bool = false) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY - HH:mm:ss"
        let dateString = self.localizedDate(showHour: showHour)
        return dateString.inLocalizedLanguage()
    }
    
    func humanReadableForLastSeen() -> String {
        let differenctToNow = Date().timeIntervalSince1970 - self.timeIntervalSince1970
        if differenctToNow < 10 {
            return IGStringsManager.NavLastSeenRecently.rawValue.localized
        } else if differenctToNow < 120 {
            return IGStringsManager.InAminute.rawValue.localized
        } else if differenctToNow < 3600 {
            let minutes = Int(differenctToNow / 60)
            return "\(minutes)".inLocalizedLanguage() + " " + IGStringsManager.MinuteAgo.rawValue.localized
        } else if differenctToNow < 3600 * 2 {
            return IGStringsManager.AnHourAgo.rawValue.localized
        } else if differenctToNow < 3600 * 24 {
            let hours = Int(differenctToNow / 3600)
            return "\(hours)".inLocalizedLanguage() + " " + IGStringsManager.HoursAgo.rawValue.localized
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateString = self.localizedDate()
        dateFormatter.dateFormat = "h:mm a"
        let timeString = dateFormatter.string(from: self)
        return dateString.inLocalizedLanguage() + IGStringsManager.At.rawValue.localized + timeString.inLocalizedLanguage()
        
    }
}


extension Double {
    public func fetchPercent() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return (formatter.string(from: self as NSNumber) ?? "0").replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
}

//MARK: -

extension UIPanGestureRecognizer {
    
    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
        static let Left = PanGestureDirection(rawValue: 1 << 2)
        static let Right = PanGestureDirection(rawValue: 1 << 3)
    }
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return xDirection.union(yDirection)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
//MARK: -
extension Data {
    func SHA256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
}
//MARK: -
extension UIViewController {
    func setTabbarHidden(_ hide: Bool, animated: Bool) {
        if (self.isTabbarHidden() == hide ){
            return
        }
        // get a frame calculation ready
        let height = self.tabBarController?.tabBar.frame.size.height
        let offsetY = hide ? height! : -(height!)
        
        // zero duration means no animation
        let duration = animated ? 0.3 : 0.0
        
        UIView.animate(withDuration: duration, animations: {
            let frame = self.tabBarController?.tabBar.frame;
            self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY)
        }, completion: {completed in
            
        })
    }
    
    func isTabbarHidden() -> Bool {
        return (self.tabBarController?.tabBar.frame.origin.y)! >= self.view.frame.maxY
    }
    
    func showAlert(title: String, message: String, action: (()->())? = nil, completion: (() -> Swift.Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default) { (alertAction) in
            if let action = action {
                action()
            }
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: completion)
    }
}

//MARK: -
extension NSCache {
    @objc subscript (key: AnyObject) -> AnyObject? {
        get {
            return (self as! NSCache<AnyObject,AnyObject>).object(forKey: key)
        }
        set {
            if let value: AnyObject = newValue {
                (self as! NSCache<AnyObject,AnyObject>).setObject(value, forKey: key)
            } else {
                (self as! NSCache<AnyObject,AnyObject>).removeObject(forKey: key)
            }
        }
    }
}

var imagesMap = Dictionary<String, UIImageView>()
var liveStickerMap = Dictionary<String, AnimationView>()
extension UIImage {
    
  func tintedWithLinearGradientColors(colorsArr: [CGColor]) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
      guard let context = UIGraphicsGetCurrentContext() else {
          return UIImage()
      }
      context.translateBy(x: 0, y: self.size.height)
      context.scaleBy(x: 1, y: -1)

      context.setBlendMode(.normal)
      let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)

      // Create gradient
      let colors = colorsArr as CFArray
      let space = CGColorSpaceCreateDeviceRGB()
      let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)

      // Apply gradient
      context.clip(to: rect, mask: self.cgImage!)
      context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.size.height), options: .drawsAfterEndLocation)
      let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return gradientImage!
  }

}
extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }

}
//MARK: -
extension UIView {
    
    
    // Using CAMediaTimingFunction
    func shake(duration: TimeInterval = 0.5, values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        // Swift 4.2 and above
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        // Swift 4.1 and below
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        
        animation.duration = duration // You can set fix duration
        animation.values = values  // You can set fix values here also
        self.layer.add(animation, forKey: "shake")
    }
    
    
    // Using SpringWithDamping
    func shake(duration: TimeInterval = 0.5, xValue: CGFloat = 12, yValue: CGFloat = 0) {
        self.transform = CGAffineTransform(translationX: xValue, y: yValue)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
    
    // Using CABasicAnimation
    func shake(duration: TimeInterval = 0.05, shakeCount: Float = 6, xValue: CGFloat = 12, yValue: CGFloat = 0){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = shakeCount
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - xValue, y: self.center.y - yValue))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + xValue, y: self.center.y - yValue))
        self.layer.add(animation, forKey: "shake")
    }
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }

    
}
extension AnimationView {
    func setLiveSticker(for attachment:IGFile) {
        do {
            if let path = attachment.localPath, IGGlobal.isFileExist(path: path) {
                let animation = Animation.filepath(path, animationCache: LRUAnimationCache.sharedCache)
                self.animation = animation
                self.contentMode = .scaleAspectFit
                self.backgroundBehavior = .pauseAndRestore
                
                self.play(fromProgress: 0, toProgress: 1, loopMode: LottieLoopMode.loop, completion: { (finished) in
                    if finished {
                        self.play(fromProgress: 0, toProgress: 1, loopMode: LottieLoopMode.loop)
                    }
                })
                
            } else {
                throw NSError(domain: "error set live sticker", code: 1234, userInfo: nil)
            }
        } catch {
            liveStickerMap[attachment.token!] = self
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                DispatchQueue.main.async {
                    if let animation = liveStickerMap[attachment.token!] {
                        liveStickerMap.removeValue(forKey: attachment.token!)
                        animation.setLiveSticker(for: attachment)
                    }
                }
            }, failure: {})
        }
    }
}
extension UIImageView {
    
    /** show file preview and download thumbnail or main file if needed
     - Parameter showMain: if set true main file will be downloaded automatically
     - Parameter forceShowMain: if set true check size for show main file will be ignored and will be shown main file if has big size (for example appropriate for IGMediaPagerCell)
     */
    func setThumbnail(for attachment:IGFile, showMain: Bool = false, forceShowMain: Bool = false) {
        if !(attachment.isInvalidated) {
            if attachment.type == .voice {
                self.image = UIImage(named:"IG_Message_Cell_Voice")
            } else if attachment.type == .file {
                let filename: NSString = attachment.name! as NSString
                let fileExtension = filename.pathExtension
                
                if fileExtension != "" {
                    if fileExtension == "doc" {
                        self.image = UIImage(named:"IG_Message_Cell_File_Doc")
                        
                    } else if fileExtension == "exe" {
                        self.image = UIImage(named:"IG_Message_Cell_File_Exe")
                        
                    } else if fileExtension == "pdf" {
                        self.image = UIImage(named:"IG_Message_Cell_File_Pdf")
                        
                    } else if fileExtension == "txt" {
                        self.image = UIImage(named:"IG_Message_Cell_File_Txt")
                        
                    } else {
                        self.image = UIImage(named:"IG_Message_Cell_File_Generic")
                    }
                    //self.image = UIImage(named:"IG_Message_Cell_File")
                    
                } else {
                    self.image = UIImage(named:"IG_Message_Cell_File_Generic")
                }
                
            } else if attachment.type == .audio {
                self.image = UIImage(named:"IG_Message_Cell_Player_Default_Cover")
            } else {
                let MAX_IMAGE_SIZE = 256 // max size for show main image at view
                
                /* when fileNameOnDisk is added into the attachment just check file existance without check file size
                 * because file size after upload is different with file size before upload
                 * Hint: mabye change this kind of check for file existance change later
                 */
                let fileSizeKB = attachment.size/1024
                var mainFileExist = false // show main image if has small size otherwise show large thumbnail, also for video show large thumnail always because video doesn't have original image
                if attachment.type == .image {
                    /* for big images show largeThumbnail if exist, even main file was downloaded before.
                     * currently check size for 256 KB
                     */
                    
                    mainFileExist = IGGlobal.isFileExist(path: attachment.localPath, fileSize: attachment.size)
                }
                
                if (fileSizeKB < MAX_IMAGE_SIZE || forceShowMain) && mainFileExist {
                    self.sd_setImage(with: attachment.localUrl, completed: nil)
                } else if attachment.smallThumbnail != nil || attachment.largeThumbnail != nil {
                    
                    var fileType: PreviewType = .smallThumbnail
                    var finalFile: IGFile = attachment.smallThumbnail!
                    if showMain {
                        fileType = .originalFile
                        finalFile = attachment
                    } else if mainFileExist || attachment.type != .image { // show large thumbnail for downloaded file if has big size || for another types that is not image (like: video, gif)
                        fileType = .largeThumbnail
                        finalFile = attachment.largeThumbnail!
                    }
                    
                    do {
                        var image: UIImage?
                        let path = finalFile.localUrl
                        if IGGlobal.isFileExist(path: path) {
                            image = UIImage(contentsOfFile: path!.path)
                        }
                        
                        if image != nil {
                            self.sd_setImage(with: path, completed: nil)
                        } else {
                            if mainFileExist { // if main file is exist show that before download thumbnail (do this for avoid from show small thumbnail after than downloaded file)
                                self.sd_setImage(with: attachment.localUrl, completed: nil)
                            }
                            throw NSError(domain: "image not exist", code: 1234, userInfo: nil)
                        }
                    } catch {
                        imagesMap[finalFile.token!] = self
                        IGDownloadManager.sharedManager.download(file: finalFile, previewType: fileType, completion: { (attachment) -> Void in
                            DispatchQueue.main.async {
                                if let image = imagesMap[attachment.token!] {
                                    imagesMap.removeValue(forKey: attachment.token!)
                                    image.sd_setImage(with: attachment.localUrl, completed: nil)
                                }
                            }
                        }, failure: {})
                    }
                } else {
                    switch attachment.type {
                    case .image:
                        if IGGlobal.isFileExist(path: attachment.localPath, fileSize: attachment.size) {
                            self.sd_setImage(with: attachment.localUrl, completed: nil)
                        } else {
                            self.image = nil
                        }
                        break
                    case .gif:
                        break
                    case .video:
                        break
                    case .audio:
                        self.image = UIImage(named:"IG_Message_Cell_Player_Default_Cover")
                        break
                    default:
                        break
                    }
                }
            }
        }
        else {
            print("ATTACHMENT IS INVALIDATED")
        }
    }

    func setSticker(for attachment:IGFile) {

        do {
            if let url = attachment.localUrl {
                if IGGlobal.isFileExist(path: url) {
                    self.sd_setImage(with: url, completed: nil)
                } else {
                    throw NSError(domain: "sticker not exist", code: 1234, userInfo: nil)
                }
            }
        } catch {
            imagesMap[attachment.token!] = self
            IGDownloadManager.sharedManager.downloadSticker(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                DispatchQueue.main.async {
                    if let image = imagesMap[attachment.token!] {
                        imagesMap.removeValue(forKey: attachment.token!)
                        image.setSticker(for: attachment)
                    }
                }
            }, failure: {
                
            })
        }
    }
    
    func setAvatar(avatar: IGFile, type: PreviewType = PreviewType.largeThumbnail) {
        
        // remove imageview from download list on t on cell reuse
        DispatchQueue.main.async {
            let keys = (imagesMap as NSDictionary).allKeys(for: self) as! [String]
            keys.forEach { (key) in
                imagesMap.removeValue(forKey: key)
            }
        }
        
        var file : IGFile!
        var previewType : PreviewType!
        
        if type == .largeThumbnail ,let largeThumbnail = avatar.largeThumbnail {
            file = largeThumbnail
            previewType = PreviewType.largeThumbnail
        } else {
            file = avatar.smallThumbnail
            previewType = PreviewType.smallThumbnail
        }
        
        if IGGlobal.isFileExist(path: avatar.localPath, fileSize: avatar.size), let url = avatar.localUrl {
            self.sd_setImage(with: url, completed: nil)
        } else {
            if file != nil {
                if let url = file.localUrl, IGGlobal.isFileExist(path: url, fileSize: file.size) {
                    self.sd_setImage(with: url, completed: nil)
                } else {
                    DispatchQueue.main.async {
                        imagesMap[file.token!] = self
                        IGDownloadManager.sharedManager.download(file: file, previewType: previewType, completion: { (attachment) -> Void in
                            DispatchQueue.main.async {
                                if let imageMain = imagesMap[attachment.token!] {
                                    if let url = attachment.localUrl {
                                        DispatchQueue.global(qos:.userInteractive).async {
                                            if let data = try? Data(contentsOf: url) {
                                                if let image = UIImage(data: data) {
                                                    DispatchQueue.main.async {
                                                        imageMain.image = image
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }, failure: {
                            print("ERROR HAPPEND IN DOWNLOADNING AVATAR")
                        })
                    }
                }
            }
        }
    }
    
    func setImage(url: URL) {
        
        if let filepath = IGGlobal.makePath(filename: url.lastPathComponent), IGGlobal.isFileExist(path: filepath) {
            self.image = UIImage(contentsOfFile: filepath.path)
            return
        }
        
        imagesMap[(url.absoluteString)] = self
        IGDownloadManager.sharedManager.downloadImage(url: url, completion: { (data) -> Void in
            DispatchQueue.main.async {
                if let imageMain = imagesMap[url.absoluteString] {
                    imageMain.image = UIImage(data: data)
                }
            }
        })
    }
}

//MARK: -
extension UIImage {
    class func colorForNavBar(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }

    /****** Gif ******/
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl) else {
            return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    

    
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


//MARK: -

extension UIFont {
    
    enum FontWeight {
        case ultraLight
        case light
        case regular
        case medium
        case bold
    }
    @objcMembers
    class SMQRCode:NSObject{
        
        static let URL                 = "https://paygear.ir/dl?jj="
        
        public enum SMAccountType:String {
            case User                = "8"
            case Merchant            = "9"
        }
        
    }
    
    class func igFont(ofSize fontSize: CGFloat, weight: FontWeight = .regular) -> UIFont {
        switch weight {
        case .ultraLight:
            return UIFont(name: "IRANSans-UltraLight", size: fontSize)!
        case .light:
            return UIFont(name: "IRANSans-Light", size: fontSize)!
        case .regular:
            return UIFont(name: "IRANSans", size: fontSize)!
        case .medium:
            return UIFont(name: "IRANSans-Medium", size: fontSize)!
        case .bold:
            return UIFont(name: "IRANSans-Bold", size: fontSize)!
        }
    }
    
    class func iGapFonticon(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "iGap_fontico", size: fontSize)!
    }
}

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func setText(color: UIColor) { if let textField = getTextField() { textField.textColor = color } }
    func setPlaceholderText(color: UIColor) { getTextField()?.setPlaceholderText(color: color) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }
    
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
    
    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

extension UITextField {
    
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func setPlaceholderText(color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [.foregroundColor: color])
    }
    
    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}
extension UITextView {
    
    var localizedDirection: NSTextAlignment {
        if LocaleManager.isRTL {
            return NSTextAlignment.right
        } else {
            guard let txt = self.text else { return NSTextAlignment.left }
            if (txt.isRTL()) {
                return NSTextAlignment.right
            } else {
                return NSTextAlignment.left
            }
        }
    }

}
extension UILabel {
    
    var localizedDirection: NSTextAlignment {
        if LocaleManager.isRTL {
            return NSTextAlignment.right
        } else {
            guard let txt = self.text else { return NSTextAlignment.left }
            if txt.isRTL() {
                return NSTextAlignment.right
            } else {
                return NSTextAlignment.left
            }
        }
    }
    
    var localizedDirectionDescriptions: NSTextAlignment {
        if LocaleManager.isRTL {
            return NSTextAlignment.right
        } else {
            guard let txt = self.text else {return NSTextAlignment.left}
            if txt.isRTLDesc() {
                return NSTextAlignment.right
            } else {
                return NSTextAlignment.left
            }
        }
    }
    
}

extension EFAutoScrollLabel {
    var localizedDirection: NSTextAlignment {
        if LocaleManager.isRTL {
            return NSTextAlignment.right
        } else {
            guard let txt = self.text else {return NSTextAlignment.left}
            if (txt.isRTL()) {
                return NSTextAlignment.right
            } else {
                return NSTextAlignment.left
            }
        }
    }
    
}

extension UITextField {
    var localizedDirection: NSTextAlignment {
        if LocaleManager.isRTL {
            return NSTextAlignment.right
        } else {
            guard let txt = self.text else {return NSTextAlignment.left}
            if (txt.isRTL()) {
                return NSTextAlignment.right
            } else {
                return NSTextAlignment.left
            }
        }
    }
    
}
extension UISearchBar {
    
    func change(textFont : UIFont?) {
        for view : UIView in (self.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.font = textFont
            }
        }
    }
    
}
extension String {
    
    func checkTime() -> String {
        var correctedDate : String = self
        if correctedDate.contains("T") {
            return correctedDate
        } else {
            correctedDate = correctedDate.replacingOccurrences(of: " ", with: "T")
            correctedDate = correctedDate + "Z"
            return correctedDate
        }
    }
    
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    func aesEncrypt(publicKey: String) -> String {
        var encryptedMsg : String = ""
        let dataKey = Data(self.utf8)
        do {
            let publicKey = try PublicKey(pemEncoded: publicKey)
            let clear = ClearMessage(data: dataKey)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            encryptedMsg = encrypted.base64String
        } catch  {
            print(error)
        }
        return encryptedMsg
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        
        return ceil(boundingBox.width)
    }
    
    public func getExtension() -> String? {
        let ext = (self as NSString).pathExtension
        if ext.isEmpty {
            return nil
        }
        return ext
    }
    
    var Imagelocalized: String {
         return NSLocalizedString(self, tableName: "ImageLocalizable", comment: "")
    }
    
    var Tablocalized: String {
         return NSLocalizedString(self, tableName: "TabBarLocalizable", comment: "")
    }
    
    var RecentTableViewlocalized: String {
        return NSLocalizedString(self, tableName: "RecentTableViewLocalizable", comment: "")
    }
    
    var MessageViewlocalized: String {
        return NSLocalizedString(self, tableName: "MessageViewLocalizable", comment: "")
    }
    
    var FinancialHistoryLocalization: String {
        return NSLocalizedString(self, tableName: "FinancialHistoryLocalizable", comment: "")
    }
    
    var InternetPackageLocalization: String {
        return NSLocalizedString(self, tableName: "InternetPackageLocalizable", comment: "")
    }
    
    func substring(offset: Int) -> String{
        if self.count < offset {
            return self
        }
        let index = self.index(self.startIndex, offsetBy: offset)
        return String(self.prefix(upTo: index))
    }
    
    func split(limit: Int) -> [String]{
        var stringArray : [String] = []
        if self.count <= limit {
            stringArray = [self]
        } else {
            var countInt : Int = self.count / limit
            let countDouble : Double = Double(self.count) / Double(limit)
            
            if Double(countDouble) - Double(countInt) > 0 {
                countInt += 1
            }
            
            for i in 0..<countInt {
                let startIndex = i * limit
                var endIndex = startIndex + limit
                
                if i == (count - 1) {
                    endIndex = self.count - startIndex
                }
                
                stringArray.append(self[startIndex..<endIndex])
            }
        }
        return stringArray
    }
    
    

    func inRialFormat() -> String {
        
        let nf = NumberFormatter()
        
        nf.locale = Locale.userPreferred
        
        nf.numberStyle = .decimal
        nf.allowsFloats = false
        nf.maximumFractionDigits = 0
        nf.groupingSeparator = ","
        
        
        let str = nf.string(from: NSNumber(value: Double(self) ?? 0)) ?? "0"
        
        return "\(str)"
    }
    
    /* detect first character should be write RTL or LTR */
    func isRTL() -> Bool {
        if self.count > 0 {
            if String(self.prefix(20)).containsEmoji, let first = String(self.prefix(20)).removeEmoji().trimmingCharacters(in: .whitespacesAndNewlines).first {
                if IGGlobal.matches(for: "[\\u0591-\\u07FF]", in: String(String(first).prefix(10))) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isRTLDesc() -> Bool {
        if self.count > 0 {
            if String(self).containsEmoji,let first = String(self).removeEmoji().trimmingCharacters(in: .whitespacesAndNewlines).first {
                if IGGlobal.matches(for: "[\\u0591-\\u07FF]", in: String(String(first))) {
                    return true
                }
            }
        }
        
        return false
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    
    func removeEmoji() -> String {
        
        return String(self.filter {
            !$0.isEmoji()
        })
    }
    var containsEmoji: Bool {
        return (unicodeScalars.contains { !$0.isEmoji })
    }
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
    }
    
    func dateFromStringFormat(format: String, showHour: Bool = false) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)?.completeHumanReadableTime(showHour: showHour)
    }
}

extension Character {
    fileprivate func isEmoji() -> Bool {
        return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
            || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
    }
}
extension UnicodeScalar {
    /// Note: This method is part of Swift 5, so you can omit this.
    /// See: https://developer.apple.com/documentation/swift/unicode/scalar
    var isEmoji: Bool {
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF, // Misc symbols
        0x2700...0x27BF, // Dingbats
        0xE0020...0xE007F, // Tags
        0xFE00...0xFE0F, // Variation Selectors
        0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
        0x1F018...0x1F270, // Various asian characters
        0x238C...0x2454, // Misc items
        0x20D0...0x20FF: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    
}
extension Float {
    var cleanDecimal: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension UIButton {
    
    func removeUnderline() {
        if let text = self.titleLabel?.text {
            let attrs = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font) : self.titleLabel?.font as Any,
                          convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : self.titleLabel?.textColor as Any,
                          convertFromNSAttributedStringKey(NSAttributedString.Key.underlineStyle) : 0 ] as [String : Any]
            
            self.setAttributedTitle(NSMutableAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary(attrs)), for: self.state)
        }
    }
}

extension URLRequest {
    private static let alloweCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_.*")
    
    public mutating func setURLEncodedFormData(parameters: [String: String?]) {
        
        var encodedParameters = ""
        
        for (key, value) in parameters {
            
            if !encodedParameters.isEmpty {
                encodedParameters += "&"
            }
            
            encodedParameters += URLRequest.urlEncoded(value: key)
            encodedParameters += "="
            if let value = value {
                encodedParameters += URLRequest.urlEncoded(value: value)
            }
        }
        
        self.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        self.httpBody = encodedParameters.data(using: .utf8)
    }
    
    private static func urlEncoded(value: String) -> String {
        return value.addingPercentEncoding(withAllowedCharacters: alloweCharacters)!.replacingOccurrences(of: " ", with: "+")
    }
    
}
extension UIView {
    
    func fadeIn(_ duration: TimeInterval = 1.0, _ alpha: CGFloat = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
    
    func fadeOut(_ duration: TimeInterval = 1.0, _ alpha: CGFloat = 0.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        })
    }
    
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    /// returns very first tab bar controller on view hirarchy
    static func topTabBarController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UITabBarController? {
        if let nav = base as? UINavigationController {
            return topTabBarController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return tab
        }
        if let presented = base?.presentedViewController {
            return topTabBarController(base: presented)
        }
        
        return nil
    }
    
    /// returns very first navigation controller on view hirarchy
    static func topNavigationController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UINavigationController? {
        if let nav = base as? UINavigationController {
            return nav
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topNavigationController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topNavigationController(base: presented)
        }
        
        return nil
    }
    
}

extension PHAsset {
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension Realm {
    func writeAsync<T : ThreadConfined>(obj: T, errorHandler: @escaping ((_ error : Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                }
                catch {
                    errorHandler(error)
                }
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// 1. Declare outside class definition (or in its own file).
// 2. UIKit must be included in file where this code is added.
// 3. Extends UIDevice class, thus is available anywhere in app.
//
// Usage example:
//
//    if UIDevice().type == .simulator {
//       print("You're running on the simulator... boring!")
//    } else {
//       print("Wow! Running on a \(UIDevice().type.rawValue)")
//    }
public enum Model : String {
    case simulator   = "simulator/sandbox",
    iPod1            = "iPod 1",
    iPod2            = "iPod 2",
    iPod3            = "iPod 3",
    iPod4            = "iPod 4",
    iPod5            = "iPod 5",
    iPad2            = "iPad 2",
    iPad3            = "iPad 3",
    iPad4            = "iPad 4",
    iPhone4          = "iPhone 4",
    iPhone4S         = "iPhone 4S",
    iPhone5          = "iPhone 5",
    iPhone5S         = "iPhone 5S",
    iPhone5C         = "iPhone 5C",
    iPadMini1        = "iPad Mini 1",
    iPadMini2        = "iPad Mini 2",
    iPadMini3        = "iPad Mini 3",
    iPadAir1         = "iPad Air 1",
    iPadAir2         = "iPad Air 2",
    iPadPro9_7       = "iPad Pro 9.7\"",
    iPadPro9_7_cell  = "iPad Pro 9.7\" cellular",
    iPadPro10_5      = "iPad Pro 10.5\"",
    iPadPro10_5_cell = "iPad Pro 10.5\" cellular",
    iPadPro12_9      = "iPad Pro 12.9\"",
    iPadPro12_9_cell = "iPad Pro 12.9\" cellular",
    iPhone6          = "iPhone 6",
    iPhone6plus      = "iPhone 6 Plus",
    iPhone6S         = "iPhone 6S",
    iPhone6Splus     = "iPhone 6S Plus",
    iPhoneSE         = "iPhone SE",
    iPhone7          = "iPhone 7",
    iPhone7plus      = "iPhone 7 Plus",
    iPhone8          = "iPhone 8",
    iPhone8plus      = "iPhone 8 Plus",
    iPhoneX          = "iPhone X",
    iPhoneXS         = "iPhone XS",
    iPhoneXSmax      = "iPhone XS Max",
    iPhoneXR         = "iPhone XR",
    iPhone11         = "iPhone 11",
    iPhone11Pro      = "iPhone 11 Pro",
    iPhone11ProMax   = "iPhone 11 Pro Max",
    unrecognized     = "?unrecognized?"
}

public extension UIDevice {
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)

            }
        }
        let modelMap : [ String : Model ] = [
            "i386"       : .simulator,
            "x86_64"     : .simulator,
            "iPod1,1"    : .iPod1,
            "iPod2,1"    : .iPod2,
            "iPod3,1"    : .iPod3,
            "iPod4,1"    : .iPod4,
            "iPod5,1"    : .iPod5,
            "iPad2,1"    : .iPad2,
            "iPad2,2"    : .iPad2,
            "iPad2,3"    : .iPad2,
            "iPad2,4"    : .iPad2,
            "iPad2,5"    : .iPadMini1,
            "iPad2,6"    : .iPadMini1,
            "iPad2,7"    : .iPadMini1,
            "iPhone3,1"  : .iPhone4,
            "iPhone3,2"  : .iPhone4,
            "iPhone3,3"  : .iPhone4,
            "iPhone4,1"  : .iPhone4S,
            "iPhone5,1"  : .iPhone5,
            "iPhone5,2"  : .iPhone5,
            "iPhone5,3"  : .iPhone5C,
            "iPhone5,4"  : .iPhone5C,
            "iPad3,1"    : .iPad3,
            "iPad3,2"    : .iPad3,
            "iPad3,3"    : .iPad3,
            "iPad3,4"    : .iPad4,
            "iPad3,5"    : .iPad4,
            "iPad3,6"    : .iPad4,
            "iPhone6,1"  : .iPhone5S,
            "iPhone6,2"  : .iPhone5S,
            "iPad4,1"    : .iPadAir1,
            "iPad4,2"    : .iPadAir2,
            "iPad4,4"    : .iPadMini2,
            "iPad4,5"    : .iPadMini2,
            "iPad4,6"    : .iPadMini2,
            "iPad4,7"    : .iPadMini3,
            "iPad4,8"    : .iPadMini3,
            "iPad4,9"    : .iPadMini3,
            "iPad6,3"    : .iPadPro9_7,
            "iPad6,11"   : .iPadPro9_7,
            "iPad6,4"    : .iPadPro9_7_cell,
            "iPad6,12"   : .iPadPro9_7_cell,
            "iPad6,7"    : .iPadPro12_9,
            "iPad6,8"    : .iPadPro12_9_cell,
            "iPad7,3"    : .iPadPro10_5,
            "iPad7,4"    : .iPadPro10_5_cell,
            "iPhone7,1"  : .iPhone6plus,
            "iPhone7,2"  : .iPhone6,
            "iPhone8,1"  : .iPhone6S,
            "iPhone8,2"  : .iPhone6Splus,
            "iPhone8,4"  : .iPhoneSE,
            "iPhone9,1"  : .iPhone7,
            "iPhone9,2"  : .iPhone7plus,
            "iPhone9,3"  : .iPhone7,
            "iPhone9,4"  : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSmax,
            "iPhone11,6" : .iPhoneXSmax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax
        ]

    if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        return Model.unrecognized
    }
}
