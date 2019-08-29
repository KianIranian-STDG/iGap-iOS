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
import RealmSwift
import IGProtoBuff
///import INSPhotoGallery
import RxRealm
import RxSwift
import Gifu
import NVActivityIndicatorView
import MapKit
public var currentSize : Int!
public var currentIndexOfImage : Int!
public var sizesArray = [Int?]()
public var isAvatar = true

class IGSettingTableViewController: BaseTableViewController, NVActivityIndicatorViewable, CLLocationManagerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: IGAvatarView!

    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var switchInAppBrowser: UISwitch!

    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var lblContacts: UILabel!
    @IBOutlet weak var lblNearby: UILabel!
    @IBOutlet weak var lblWallet: UILabel!
    @IBOutlet weak var lblFinancialServices: UILabel!
    @IBOutlet weak var lblChangeLang: UILabel!
    @IBOutlet weak var lblChatWallpaper: UILabel!
    @IBOutlet weak var lblInAppBrowser: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!
    @IBOutlet weak var lblCache: UILabel!
    @IBOutlet weak var lblInviteFreind: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblQRScan: UILabel!

    var userInDb : IGRegisteredUser!
    var imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var shareContent = NSString()
    var user : IGRegisteredUser?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    //var downloadIndicatorMainView : IGDownloadUploadIndicatorView?
    var notificationToken: NotificationToken?

    
    let disposeBag = DisposeBag()
    
    @IBAction func switchInAppBrowser(_ sender: UISwitch) {
        IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: sender.isOn)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestToGetAvatarList()
        
        initDetails()

        
//        btnCamera.backgroundColor = .red
       btnCamera.setBackgroundImage(UIImage(named: "IG_Settings_Camera"), for: .normal)
        
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        
        tableView.tableFooterView = UIView()
        imagePicker.delegate = self
        
        
      
        
        if IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
            switchInAppBrowser.isOn = true
        } else {
            switchInAppBrowser.isOn = false
        }
        
    }
    func initDetails() {
        
        self.clearsSelectionOnViewWillAppear = true
        
        USERinDB()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addModalViewItems(leftItemText: nil, rightItemText: "GLOBAL_CLOSE".localizedNew, title: "SETTING_VIEW".localizedNew)
        
        // navigationItem.setChatListsNavigationItems()
        navigationItem.rightViewContainer?.addAction {
            self.dismiss(animated: true, completion: {
                
            })
        }
        
    }
    func USERinDB() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
        userAvatarView.setUser(userInDb, showMainAvatar: true)
        usernameLabel.text = userInDb.displayName
        user = userInDb
        userAvatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        userAvatarView.avatarImageView?.addGestureRecognizer(tap)
    }
    func initChangeLanguage() {

        let transform = SMDirection.PageAffineTransform()
        switchInAppBrowser.transform = transform
        lblAccount.text = "SETTING_PAGE_ACCOUNT".localizedNew
        lblContacts.text = "SETTING_PAGE_CONTACTS".localizedNew
        lblNearby.text = "SETTING_PAGE_NEARBY".localizedNew
        lblWallet.text = "SETTING_PAGE_WALLET".localizedNew
        lblFinancialServices.text = "SETTING_PAGE_FINANCIAL_SERVICES".localizedNew
        lblChangeLang.text = "SETTING_PAGE_CHANGE_LANGUAGE".localizedNew
        lblChatWallpaper.text = "SETTING_PAGE_CHAT_WALLPAPER".localizedNew
        lblInAppBrowser.text = "SETTING_PAGE_IN_APP_BROWSER".localizedNew
        lblPrivacy.text = "SETTING_PAGE_PRIVACY_AND_SECURITY".localizedNew
        lblCache.text = "SETTING_PAGE_CACHE_SETTINGS".localizedNew
        lblInviteFreind.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
        lblAbout.text = "SETTING_PAGE_ABOUT".localizedNew
        lblQRScan.text = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
        lblQRScan.font = UIFont.igFont(ofSize: 15)

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionLabel.text = "SETTING_PAGE_FOOTER_VERSION".localizedNew + " \(version)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        // requestToGetAvatarList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLanguage()
        self.tableView.isUserInteractionEnabled = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.isUserInteractionEnabled = true
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    func requestToGetAvatarList() {
        if let currentUserId = IGAppManager.sharedManager.userID() {
        IGUserAvatarGetListRequest.Generator.generate(userId: currentUserId).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let UserAvatarGetListoResponse as IGPUserAvatarGetListResponse:
                    let responseAvatars =   IGUserAvatarGetListRequest.Handler.interpret(response: UserAvatarGetListoResponse, userId: currentUserId)
                    self.avatars = responseAvatars
                    sizesArray.removeAll()

                    for element in responseAvatars {
                        sizesArray.append(element.file?.size)
                    }
                    //                    print(respo)
                    
                    
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
        }
    }
    
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = user?.avatar {
            requestToGetAvatarList()
            showAvatar( avatar: userAvatar)
            }
        }
    }
    var insDelete : INSPhotosOverlayView!
    var avatarPhotos : [INSPhotoViewable]?
    var galleryPhotos: INSPhotosViewController?
    var galleryPhoto: INSPhotoViewController?
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    open private(set) var deleteToolbar: UIToolbar!

  
    
    
    func showAvatar(avatar : IGAvatar) {
        
        var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMediaUserAvatar in
            return IGMediaUserAvatar(avatar: avatar)
        }
        
        avatarPhotos = photos
        
        if photos.count == 0 {
            return
        }
        let currentPhoto = photos[0]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: userAvatarView)//, deleteView: deleteView, downloadView: downloadIndicatorMainView)
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            let currentIndex : Int! = photos.firstIndex{$0 === photo}
            if self!.avatars.count <= currentIndex {
                currentSize = self!.avatars[currentIndex].file?.size
            }
            return self?.userAvatarView
        }
        
        galleryPhotos = galleryPreview
        galleryPreview.deletePhotoHandler = { [weak self] photo in
            let currentIndex : Int! = photos.firstIndex{$0 === photo}
            self!.deleteAvatar(index: currentIndex)
        }
        
        present(galleryPreview, animated: true, completion: nil)
    }
    @objc func handleTapp(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .began {
        }
        else {
        }
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){}

    func setThumbnailForAttachments() {}
    
    func deleteAvatar(index: Int!) {
        if self.avatars.count <= index {
            return
        }
        let avatar = self.avatars[index]
        IGUserAvatarDeleteRequest.Generator.generate(avatarID: avatar.id).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userAvatarDeleteResponse as IGPUserAvatarDeleteResponse :
                    IGUserAvatarDeleteRequest.Handler.interpret(response: userAvatarDeleteResponse)
                    self.avatarPhotos?.remove(at: index)
                    self.avatars.remove(at: index)
                    sizesArray.remove(at: index)
                    self.getUserInfo() // TODO - now for update show avatars in room list and chat cloud i use from getUserInfo. HINT: remove this state and change avatar list for this user
                    if self.avatars.count > 0 {
                        self.userAvatarView.avatarImageView?.setImage(avatar: self.avatars[0], showMain: true)
                    } else {
                        self.userAvatarView.avatarImageView?.image = UIImage(named:"AppIcon")
                    }
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
        
    }
    
    func getUserInfo(){
        IGUserInfoRequest.Generator.generate(userID: (self.user?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let userInfoResponse = protoResponse as? IGPUserInfoResponse {
                    IGFactory.shared.saveRegistredUsers([userInfoResponse.igpUser])
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if IGAppManager.sharedManager.mplActive() && IGAppManager.sharedManager.walletActive() {
                return 12
            }
            else if IGAppManager.sharedManager.mplActive() && !(IGAppManager.sharedManager.walletActive()) {
                return 11

            }
            else {
                return 10

            }
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !IGAppManager.sharedManager.mplActive() && indexPath.section == 0 { // hide block contact for mine profile
            if indexPath.row >= 3 {
                return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 0))
            }
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            var rowIndex = indexPath.row
            if !IGAppManager.sharedManager.mplActive() && !(IGAppManager.sharedManager.walletActive()) && indexPath.row >= 3 {
                rowIndex = rowIndex + 2
            }
            else if IGAppManager.sharedManager.mplActive() && !(IGAppManager.sharedManager.walletActive()) && indexPath.row >= 3 {
                rowIndex = rowIndex + 1
            }
            
            if rowIndex == 0 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToAccountSettingPage", sender: self)
            } else if rowIndex == 1 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToContactListPage", sender: self)
            } else if rowIndex == 2 {
                manageOpenMap()
            }
            
            else if rowIndex == 3 {
                let vc = UIStoryboard.init(name: "wallet", bundle: Bundle.main).instantiateViewController(withIdentifier: "packetTableViewController") as? packetTableViewController
                self.navigationController?.pushViewController(vc!, animated: true)

//                let vc2 = UIStoryboard.init(name: "wallet", bundle: Bundle.main).instantiateViewController(withIdentifier: "walletTabbar") as? UITabBarController
//                self.navigationController?.pushViewController(vc2!, animated: true)
//                let mainView = UIStoryboard(name: "wallet", bundle: nil).instantiateViewController(withIdentifier: "walletTabbar")
//                self.hero.replaceViewController(with: mainView)


                
//                                self.performSegue(withIdentifier: "showWallet", sender: self)
//
            }
            else if rowIndex == 4 {
                IGHelperFinancial.getInstance(viewController: self).manageFinancialServiceChoose()
            }
            else if rowIndex == 5 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "showChangeLanguagePage", sender: self)
            }
            else if rowIndex == 6 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "showWallpaperOptionPage", sender: self)
            } else if rowIndex == 7 { // in app browser
                
                if switchInAppBrowser.isOn {
                    switchInAppBrowser.setOn(false, animated: true)
                    IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: false)
                } else {
                    switchInAppBrowser.setOn(true, animated: true)
                    IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: true)
                }
                
            } else if rowIndex == 8 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToPrivacyAndPolicySettingsPage", sender: self)
            } else if rowIndex == 9 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "showCacheSetting", sender: self)
            } else if rowIndex == 10 {
                shareContent = "Hey Join iGap and start new connection with friends and family for free, no matter what device they are on!\niGap Limitless Connection\nwww.iGap.net"
                let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
            } else if rowIndex == 11 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToAboutSettingPage", sender: self)
            }
                
        } else if indexPath.section == 1 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "ShowQRScanner", sender: self)
        }
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
  
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    @IBAction func userImageClick(_ sender: UIButton) {
        //choosePhotoActionSheet(sender: userImage)
    }
    
    @IBAction func cameraButtonClick(_ sender: UIButton) {
        choosePhotoActionSheet(sender: btnCamera)
    }
    
    func manageOpenMap(){
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            IGHelperNearby.shared.openMap()
        }
        else {
            locationManager.stopUpdatingLocation()
            let alert = UIAlertController(title: "LOCATION_SERVICE_DISABLE".localizedNew, message: "LOCATION_SERVICE_ENABLE_IT".localizedNew, preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { action in
                switch action.style{
                case .default: UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
                

                case .cancel: print("cancel")
                case .destructive: print("destructive")

                @unknown default:
                    print("ERROR")

                }
            }))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            IGHelperNearby.shared.openMap()
        }
    }


    func choosePhotoActionSheet(sender : UIButton){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: "TAKE_A_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil{
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = .photo
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                else {
                    self.present(self.imagePicker, animated: true, completion: nil)//4
                    self.imagePicker.popoverPresentationController?.sourceView = (sender )
                    self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                    self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
                }
            }
        })
        
        //let deleteAction = UIAlertAction(title: "DELETE_MAIN_AVATAR".localizedNew, style: .destructive, handler: {
        //    (alert: UIAlertAction!) -> Void in
        //})
        
        let ChoosePhoto = UIAlertAction(title: "CHOOSE_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.present(self.imagePicker, animated: true, completion: nil)//4
                self.imagePicker.popoverPresentationController?.sourceView = (sender)
                self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        // Hint: remove avatar from INSPhotoGallery page
        //if self.avatars.count > 0 {
        //    optionMenu.addAction(deleteAction)
        //}
        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = btnCamera
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension IGSettingTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: {
            self.manageImage(imageInfo: convertFromUIImagePickerControllerInfoKeyDictionary(info))
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showLogoutActionSheet(){
        let logoutConfirmAlertView = UIAlertController(title: "MSG_PAGE_ACCOUNT_LOGOUT".localizedNew, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let logoutAction = UIAlertAction(title: "SETTING_PAGE_ACCOUNT_LOGOUT".localizedNew, style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.logoutAndShowRegisterViewController()
                IGWebSocketManager.sharedManager.closeConnection()
            })
            
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        logoutConfirmAlertView.addAction(logoutAction)
        logoutConfirmAlertView.addAction(cancelAction)
        let alertActions = logoutConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Log out"{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        logoutConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = logoutConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(logoutConfirmAlertView, animated: true, completion: nil)
    }
 
    private func manageImage(imageInfo: [String : Any]){
        let originalImage = imageInfo["UIImagePickerControllerOriginalImage"] as! UIImage
        let filename = "IMAGE_" + IGGlobal.randomString(length: 16)
        let randomString = IGGlobal.randomString(length: 16) + "_"
        var scaledImage = originalImage
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        let fileNameOnDisk = randomString + filename
        
        if (originalImage.size.width) > CGFloat(2000.0) || (originalImage.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: originalImage)
        }
        
        let attachment = IGFile(name: filename)
        attachment.attachedImage = scaledImage
        attachment.fileNameOnDisk = fileNameOnDisk
        attachment.height = Double((scaledImage.size.height))
        attachment.width = Double((scaledImage.size.width))
        attachment.size = (imgData?.count)!
        attachment.data = imgData
        attachment.type = .image
        
        DispatchQueue.main.async {
            self.userAvatarView.avatarImageView?.image = scaledImage
            let path = IGFile.path(fileNameOnDisk: fileNameOnDisk)
            FileManager.default.createFile(atPath: path.path, contents: imgData!, attributes: nil)
        }
        
        IGGlobal.prgShow()
        IGUploadManager.sharedManager.upload(file: attachment, start: {
            
        }, progress: { (progress) in
            
        }, completion: { (uploadTask) in
            IGGlobal.prgHide()
            if let token = uploadTask.token {
                IGUserAvatarAddRequest.Generator.generate(token: token).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let avatarAddResponse as IGPUserAvatarAddResponse:
                            IGUserAvatarAddRequest.Handler.interpret(response: avatarAddResponse)
                        default:
                            break
                        }
                    }
                }).error({ (error, waitTime) in
                    
                }).send()
            }
        }, failure: {
            IGGlobal.prgHide()
        })
    }
}

extension IGSettingTableViewController: UINavigationControllerDelegate {
    
}
extension IGSettingTableViewController: IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGDownloadUploadIndicatorView) {
        if let attachment = self.userAvatar?.file {
            IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
                
            }, failure: {
                
            })
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
