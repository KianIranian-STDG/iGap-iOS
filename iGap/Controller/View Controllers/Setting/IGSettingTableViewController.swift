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
import INSPhotoGallery
import RxRealm
import RxSwift
import Gifu
import NVActivityIndicatorView
import MapKit

class IGSettingTableViewController: BaseTableViewController, NVActivityIndicatorViewable, CLLocationManagerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: IGAvatarView!
    @IBOutlet weak var cameraButton: UIButton!
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
        
    
    let disposeBag = DisposeBag()
    
    @IBAction func switchInAppBrowser(_ sender: UISwitch) {
        IGHelperPreferences.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: sender.isOn)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestToGetAvatarList()
        let currentUserId = IGAppManager.sharedManager.userID()
        
        self.clearsSelectionOnViewWillAppear = true
        
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        if let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first {
            userAvatarView.setUser(userInDb, showMainAvatar: true)
            usernameLabel.text = userInDb.displayName
            user = userInDb
            userAvatarView.avatarImageView?.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
            userAvatarView.avatarImageView?.addGestureRecognizer(tap)

            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.addModalViewItems(leftItemText: nil, rightItemText: "GLOBAL_CLOSE".localizedNew, title: "SETTING_VIEW".localizedNew)
        }
        
        let navigationItem = self.navigationItem as! IGNavigationItem
       // navigationItem.setChatListsNavigationItems()
        navigationItem.rightViewContainer?.addAction {
            self.dismiss(animated: true, completion: { 
                
            })
        }
        
        
        //roundUserImage(cameraButton)
        let cameraBtnImage = UIImage(named: "camera")
        cameraButton.setBackgroundImage(cameraBtnImage, for: .normal)
        
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        
        tableView.tableFooterView = UIView()
        imagePicker.delegate = self
        
        
      
        
        if IGHelperPreferences.readBoolean(key: IGHelperPreferences.keyInAppBrowser) {
            switchInAppBrowser.isOn = true
        } else {
            switchInAppBrowser.isOn = false
        }
        
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
                    /*
                    for avatar in self.avatars {
                        let avatarView = IGImageView()
                        avatarView.setImage(avatar: avatar)
                    }
                    */
                    
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
            showAvatar( avatar: userAvatar)
            }
        }
    }
    
    var avatarPhotos : [INSPhotoViewable]?
    var galleryPhotos: INSPhotosViewController?
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    func showAvatar(avatar : IGAvatar) {
            var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
                return IGMedia(avatar: avatar)
            }
        avatarPhotos = photos
        if photos.count == 0 {
            return
        }
        let currentPhoto = photos[0]
//        let deleteViewFrame = CGRect(x:320, y:595, width: 25 , height:25)
        let trashImageView = UIImageView()
        trashImageView.image = UIImage(named: "IG_Trash_avatar")
        trashImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        deleteView = IGTappableView(frame: deleteViewFrame)
//        deleteView?.addSubview(trashImageView)
        let downloadViewFrame = self.view.bounds
//        deleteView?.addAction {
//            self.didTapOnTrashButton()
//        }
        let downloadIndicatorMainView = UIView()
        downloadIndicatorMainView.backgroundColor = UIColor.white
        downloadIndicatorMainView.frame = downloadViewFrame
        let andicatorViewFrame = CGRect(x: view.bounds.midX, y: view.bounds.midY,width: 50 , height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame,
                                                            type: NVActivityIndicatorType.audioEqualizer)
        downloadIndicatorMainView.addSubview(activityIndicatorView)
        
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: userAvatarView)//, deleteView: deleteView, downloadView: downloadIndicatorMainView)
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            return self?.userAvatarView
        }
        galleryPhotos = galleryPreview
        present(galleryPreview, animated: true, completion: nil)
        activityIndicatorView.startAnimating()
        //activityIndicatorView.startAnimating()

//        DispatchQueue.main.async {
//            let size = CGSize(width: 30, height: 30)
//            self.startAnimating(size, message: nil, type: NVActivityIndicatorType.ballRotateChase)
//
//            let thisPhoto = galleryPreview.accessCurrentPhotoDetail()
//
//            //self.avatarPhotos.index(of:thisPhoto)
//           if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
//            self.lastIndex = index
//            let currentAvatarFile = self.avatars[index].file
//            self.currentAvatarId = self.avatars[index].id
//            if currentAvatarFile?.status == .downloading {
//                return
//            }
//
//            if let attachment = currentAvatarFile {
//                IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
//                    DispatchQueue.main.async {
//                        galleryPreview.hiddenDownloadView()
//                        self.stopAnimating()
//                    }
//                }, failure: {
//
//                })
//            }
//
//            }
//            self.scheduledTimerWithTimeInterval()
//       }
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
//        let nextPhoto = galleryPhotos?.accessCurrentPhotoDetail()
//        if let index =  self.avatarPhotos?.index(where: {$0 === nextPhoto}) {
//            let currentAvatarFile = self.avatars[index].file
//            let nextAvatarId = self.avatars[index].id
//            if nextAvatarId != self.currentAvatarId {
//                let size = CGSize(width: 30, height: 30)
//                self.startAnimating(size, message: nil, type: NVActivityIndicatorType.ballRotateChase)
//                if currentAvatarFile?.status == .downloading {
//                    return
//                }
//
//                if let attachment = currentAvatarFile {
//                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
//                        self.galleryPhotos?.hiddenDownloadView()
//                        self.stopAnimating()
//                    }, failure: {
//
//                    })
//                }
//                self.currentAvatarId = nextAvatarId
//            } else {
//
//            }
//        }
    }

    


    func setThumbnailForAttachments() {
        /*
        if let attachment = self.userAvatar?.file {
            self.currentPhoto.isHidden = false
        }
        */
    }

    
    func deleteAvatar() {
        let avatar = self.avatars[0]
        IGUserAvatarDeleteRequest.Generator.generate(avatarID: avatar.id).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let userAvatarDeleteResponse as IGPUserAvatarDeleteResponse :
                    IGUserAvatarDeleteRequest.Handler.interpret(response: userAvatarDeleteResponse)
                    self.avatarPhotos?.remove(at: 0)
                    self.avatars.remove(at: 0)
                    self.getUserInfo() // TODO - now for update show avatars in room list and chat cloud i use from getUserInfo. HINT: remove this state and change avatar list for this user
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
        
        //        timer.invalidate()
        //        let thisPhoto = galleryPhotos?.accessCurrentPhotoDetail()
        //        if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
        //            let thisAvatarId = self.avatars[index].id
        //        }
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
                    IGHelperPreferences.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: false)
                } else {
                    switchInAppBrowser.setOn(true, animated: true)
                    IGHelperPreferences.writeBoolean(key: IGHelperPreferences.keyInAppBrowser, state: true)
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
        choosePhotoActionSheet(sender: cameraButton)
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
                case .default: UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                case .cancel: print("cancel")
                case .destructive: print("destructive")

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
        
        let deleteAction = UIAlertAction(title: "DELETE_MAIN_AVATAR".localizedNew, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.deleteAvatar()
        })
        
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
        
        if self.avatars.count > 0 {
            optionMenu.addAction(deleteAction)
        }
        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = cameraButton
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension IGSettingTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.userAvatarView.setImage(pickedImage)
            
            let avatar = IGFile()
            avatar.attachedImage = pickedImage
            let randString = IGGlobal.randomString(length: 32)
            avatar.primaryKeyId = randString
            avatar.name = randString
            
            IGUploadManager.sharedManager.upload(file: avatar, start: {
                
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
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
                
            })
        }
        imagePicker.dismiss(animated: true, completion: {
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
