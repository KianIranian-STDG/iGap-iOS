//
//  IGProfileTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/20/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import RealmSwift
import IGProtoBuff
///import INSPhotoGallery
import RxRealm
import RxSwift
import Gifu
import NVActivityIndicatorView
import MapKit
import MBProgressHUD


class IGProfileTableViewController: UITableViewController,CLLocationManagerDelegate {
    lazy var colorView = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = false
        //        self.navigationController?.navigationBar.addSubview(view)
        //        self.navigationController?.navigationBar.sendSubviewToBack(view)
        return view
    }()
    
    var canCallNextRequest : Bool! = false
    var currentGender : IGPGender.RawValue = 0
    var currentName : String = ""
    var currentUserName : String = ""
    var currentBio : String = ""
    var currentEmail : String = ""
    var currentReferral : String = ""

    var isEditMode = false
    var shouldSave = false
    var tapCount = 0
    var hud = MBProgressHUD()
    var isMaleChecked : Bool! = false
    var isFMaleChecked : Bool! = false

    var tmpGender: IGGender = .unknown
    var tmpEmail: String = ""

    private var goToSettings : Bool! = false
    @IBOutlet weak var stack0: UIStackView!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack3: UIStackView!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var lblTel: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var viewBackgroundImage: UIView!
    @IBOutlet weak var lblChoosenLanguage: IGLabel!
    @IBOutlet weak var imgBackgroundImage: UIImageView!
    @IBOutlet weak var lblCloud: UILabel!
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var lblNew: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var lblInviteF: UILabel!
    @IBOutlet weak var lblQR: UILabel!
    @IBOutlet weak var lblNearby: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblFaq: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblMoneyAmount: UILabel!
    @IBOutlet weak var lblScoreAmount: UILabel!
    @IBOutlet weak var btnEditProfile : UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBioInner: UILabel!
    @IBOutlet weak var lblEmailInner: UILabel!
    @IBOutlet weak var lblGenderInner: UILabel!
    @IBOutlet weak var lblMenGender: UILabel!
    @IBOutlet weak var lblWomenGender: UILabel!
    @IBOutlet weak var lblBioTop: EFAutoScrollLabel!
    @IBOutlet weak var btnMenGender: UIButton!
    @IBOutlet weak var btnWomenGender: UIButton!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfBio: UITextField!

    var hasNameChanged: Bool! = false
    var hasUserNameChanged: Bool! = false
    var hasBioChanged: Bool! = false
    var hasEmailChanged: Bool! = false
    var hasGenderChanged: Bool! = false
    var hasRefrralChanged: Bool! = false
    
    var userInDb : IGRegisteredUser!
    var imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var shareContent = String()
    var user : IGRegisteredUser?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    //var downloadIndicatorMainView : IGDownloadUploadIndicatorView?
    var notificationToken: NotificationToken?
    
    var isPoped = false
    let disposeBag = DisposeBag()
    var userCards: [SMCard]?

    @IBOutlet weak var userAvatarView: IGAvatarView!
    
    @IBOutlet weak var btnCamera: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.alwaysBounceVertical = false
        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.navigationBar.isHidden = true
        navigationControllerr.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationControllerr.navigationBar.isTranslucent = true

        initView()
        initServices()
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.removeNavButtons()

    }
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.navigationBar.isHidden = true
        navigationControllerr.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationControllerr.navigationBar.isTranslucent = true
        IGRequestWalletGetAccessToken.sendRequest()
        //Hint:- Check if request was not successfull call services again
        if lblMoneyAmount.text == "..." {
            self.finishDefault(isPaygear: true, isCard: false)
        }
        if lblScoreAmount.text == "..." {
            getScore()
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(segueToChatNotificationReceived(_:)),
                                               name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoomAtProfile),
                                               object: nil)

        USERinDB()
        textManagment()
        self.tableView.alwaysBounceVertical = false
        
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
       
        
        
        navigationItem.removeNavButtons()
        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.navigationBar.isHidden = true
        navigationControllerr.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()


        ////
        //
        //        navigationControllerr.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //        navigationControllerr.navigationBar.shadowImage = UIImage()
        //        navigationControllerr.navigationBar.isTranslucent = true
        //        //  Converted to Swift 5 by Swiftify v5.0.30657 - https://objectivec2swift.com/
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        
        
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        //Hint: - check if tab is changed or not if changed it will show the navbar ,if not it depends on the destination
        if currentTabIndex == CurrentTab.Profile.rawValue {
            
            if goToSettings {
                navigationControllerr.navigationBar.isHidden = true
            } else {
                navigationControllerr.navigationBar.isHidden = false
            }
        } else {
            navigationControllerr.navigationBar.isHidden = false
        }

        
    }
    func initServices() {
        getUserEmail()
        self.finishDefault(isPaygear: true, isCard: false)
        getScore()


    }
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
//        SMLoading.showLoadingPage(viewcontroller: self)
        SMCard.getAllCardsFromServer({ cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0 {
                        //                        self.walletView.dismissPresentedCardView(animated: true)
                        //                        self.walletHeaderView.alpha = 1.0
                        self.userCards = SMCard.getAllCardsFromDB()
                        if let cards = self.userCards {
                            var tmpSum : Int64! = 0
                            for card in cards {
                                if card.balance != nil {
                                    let tmpBalance = card.balance!
                                    tmpSum =  tmpSum + tmpBalance
                                }
                            }
                            self.lblMoneyAmount.text = String(tmpSum).inRialFormat()

                        }

                    }
                }
            }
            needToUpdate = true
        }, onFailed: {err in
            //            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
        })
    }

    func initView() {

        btnMenGender.setTitle("", for: .normal)
        btnMenGender.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnWomenGender.setTitle("", for: .normal)
        btnWomenGender.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: (self.navigationController?.navigationBar.frame.width)!, height: UIApplication.shared.statusBarFrame.height)
        colorView.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: colorView).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: colorView.frame.size.width/2, bottom: 0, right: colorView.frame.size.width/2), resizingMode: .stretch))
        btnCamera.setBackgroundImage(UIImage(named: "ig_add_image_icon"), for: .normal)
        
        
        self.view.insertSubview(colorView, at: 1)
        
        viewBackgroundImage.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMinXMaxYCorner], radius: 10)
        viewBackgroundImage.clipsToBounds = true
        initChangeLang()
        requestToGetAvatarList()
        let tapCloud = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapCloud(recognizer:)))
        stack0.addGestureRecognizer(tapCloud)
        
        let tapSettings = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapSettings(recognizer:)))
        stack1.addGestureRecognizer(tapSettings)
        
        let tapNew = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapNew(recognizer:)))
        stack3.addGestureRecognizer(tapNew)
        
        
        
    }
    func initChangeLang() {
        
        lblName.text = "NAME".localizedNew
        lblUserName.text = "SETTING_PAGE_ACCOUNT_USERNAME".localizedNew
        lblBioInner.text = "SETTING_PAGE_ACCOUNT_BIO".localizedNew
        
        btnName.setTitle("NAME".localizedNew, for: .normal)
        lblCloud.text = "MY_CLOUD".localizedNew
        lblSetting.text = "SETTING_VIEW".localizedNew
        lblNew.text = "NEW".localizedNew
        lblCredit.text = "CREDITS".localizedNew
        lblScore.text = "SETTING_PAGE_ACCOUNT_SCORE_PAGE".localizedNew
//        lblMoneyAmount.text = "1254790".inRialFormat().inLocalizedLanguage() + "CURRENCY".localizedNew
        lblScoreAmount.text = "..."
        lblInviteF.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
        lblQR.text = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
        lblNearby.text = "SETTING_NEARBY".localizedNew
        lblFaq.text = "FAQ".localizedNew
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lblVersion.text = "SETTING_PAGE_FOOTER_VERSION".localizedNew + " \(version)".inLocalizedLanguage()
        }
        lblEmailInner.text = "SETTING_PS_TV_EMAIL".localizedNew
        lblMenGender.text = "MEN_GENDER".localizedNew
        lblMenGender.font = UIFont.igFont(ofSize: 15)
        lblWomenGender.font = UIFont.igFont(ofSize: 15)
        lblWomenGender.text = "WOMEN_GENDER".localizedNew
        lblGenderInner.text = "GENDER".localizedNew

    }
    func textManagment() {

        lblBioTop.text = (userInDb.bio)
        btnName.setTitle((userInDb.displayName), for: .normal)
        btnName.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnUsername.setTitle((userInDb.displayName), for: .normal)
        btnUsername.titleLabel?.font = UIFont.igFont(ofSize: 14)
        lblTel.text = String(userInDb.phone).inLocalizedLanguage()

        tfEmail.text = (userInDb.email)
        tfName.text = (userInDb.displayName)
        tfUserName.text = (userInDb.username)
        tfBio.text = (userInDb.bio)
        
        if let sessionInfo = IGDatabaseManager.shared.realm.objects(IGSessionInfo.self).first {
            tmpGender = sessionInfo.gender
        }
        //check if user didNot check also check the serverside
        if tmpGender == .unknown {
            
        } else {
            
            switch tmpGender {
            case .unknown:
                //uncheck Both buttons
                currentGender = 0
                btnWomenGender.setTitle("", for: .normal)
                btnMenGender.setTitle("", for: .normal)
                
                break
            case .male:
                //check male button - uncheck Fmale Button
                currentGender = 1
                isFMaleChecked = false
                isMaleChecked = true
                
                btnWomenGender.setTitle("", for: .normal)
                btnMenGender.setTitle("", for: .normal)
                
                break
            case .female:
                //UnCheck Male Button - Check Fmale Button
                currentGender = 2
                isFMaleChecked = true
                isMaleChecked = false
                btnMenGender.setTitle("", for: .normal)
                btnWomenGender.setTitle("", for: .normal)
                
                break
            default:
                break
            }
        }

        lblBioTop.font = UIFont.igFont(ofSize: 10)
        lblBioTop.labelSpacing = 30                       // Distance between start and end labels
        lblBioTop.pauseInterval = 2.0                     // Seconds of pause before scrolling starts again
        lblBioTop.scrollSpeed = 30                        // Pixels per second
        if lastLang == "en" {
            lblBioTop.textAlignment = .left
        }
        else{
            lblBioTop.textAlignment = .right
        }
        lblBioTop.fadeLength = 12                         // Length of the left and right edge fade, 0 to disable
        lblBioTop.scrollDirection = EFAutoScrollDirection.left
        if lastLang == "en" {
            lblBioTop.scrollDirection = EFAutoScrollDirection.left
        }
        else{
            lblBioTop.scrollDirection = EFAutoScrollDirection.right
        }


    }
    
    func getUserEmail() {
        DispatchQueue.global(qos: .userInteractive).async {
            
            IGUserProfileGetEmailRequest.Generator.generate().success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let getUserEmailResponse as IGPUserProfileGetEmailResponse:
                        let userEmail = IGUserProfileGetEmailRequest.Handler.interpret(response: getUserEmailResponse)
                        DispatchQueue.main.async {
                            self.tfEmail.text = userEmail
                        }
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "TIME_OUT_MSG_EMAIL".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
            
        }
    }
    
    func getUserGender() {
        DispatchQueue.global(qos: .userInteractive).async {
            
            IGUserProfileGetGenderRequest.Generator.generate().success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let getUserGenderResponse as IGPUserProfileGetGenderResponse:
                        let userEmail = IGUserProfileGetGenderRequest.Handler.interpret(response: getUserGenderResponse)
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "TIME_OUT_MSG_EMAIL".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
            
        }
    }
    func USERinDB() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
        if userAvatarView.avatarImageView?.image == nil {
        userAvatarView.setUser(userInDb, showMainAvatar: true)
        }
        user = userInDb
        userAvatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        userAvatarView.avatarImageView?.addGestureRecognizer(tap)
        
    }
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = user?.avatar {
                showAvatar( avatar: userAvatar)
            }
        }
    }
    @objc func handleTapCloud(recognizer:UITapGestureRecognizer) {
        
        
    }
    @objc func handleTapSettings(recognizer:UITapGestureRecognizer) {
        
        
    }
    @objc func handleTapNew(recognizer:UITapGestureRecognizer) {
        
        
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
        let downloadViewFrame = self.view.bounds
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: userAvatarView)//, deleteView: deleteView, downloadView: downloadIndicatorMainView)
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            let currentIndex : Int! = photos.firstIndex{$0 === photo}
            currentSize = self!.avatars[currentIndex].file?.size
            
            return self?.userAvatarView
        }
        
        
        galleryPhotos = galleryPreview
        galleryPreview.deletePhotoHandler = { [weak self] photo in
            let currentIndex : Int! = photos.firstIndex{$0 === photo}
            
            self!.deleteAvatar(index: currentIndex)
            
        }
        
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func deleteAvatar(index: Int!) {
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
                    self.userAvatarView.avatarImageView?.setImage(avatar: self.avatars[0], showMain: true)
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
    
    func requestToGetAvatarList() {
        DispatchQueue.global(qos: .userInteractive).async {
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

    }
    private func getScore(){
        DispatchQueue.global(qos: .userInteractive).async {

        IGUserIVandGetScoreRequest.Generator.generate().success({ (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self.lblScoreAmount.text = String(describing: response.igpScore).inRialFormat().inLocalizedLanguage()
                }
            }
        }).error({ (errorCode, waitTime) in
            
            switch errorCode {
            case .timeout :
                    self.getScore()
            default:
                break
            }
        }).send()
        }
    }
    //
    func gradientImage(withColours colours: [UIColor], location: [Double], view: UIView) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = location as [NSNumber]
        gradient.cornerRadius = view.layer.cornerRadius
        return UIImage.image(from: gradient) ?? UIImage()
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
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y

        if offset < 0 {
            scrollView.contentOffset.y = 0

        } else {

        }

    }
    //Hint: - Go To Setting Action Handler
    @IBAction func didTapOnGoToSettings(_ sender: Any) {
        goToSettings = true
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    //Hint: - Go To Cloud Action Handler
    @IBAction func didTapOnGoToCloud(_ sender: Any) {
        goToSettings = false

        if let userId = IGAppManager.sharedManager.userID() {
            IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let chatGetRoomResponse as IGPChatGetRoomResponse:
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        //segue to created chat
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                                        object: nil,
                                                        userInfo: ["room": roomId])
                        break
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew, preferredStyle: .alert)
                    
                    let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alertC.addAction(cancel)
                    self.present(alertC, animated: true, completion: nil)
                }
            }).send()
        }
    }
    //Hint :- Go to Creat New chat/Group/Channel
    @IBAction func didTapOnGoToCreatNewCGC(_ sender: Any) {
        goToSettings = false
        let createChat = IGCreateNewChatTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        self.navigationController!.pushViewController(createChat, animated: true)

    }
    @IBAction func btnEditProfileTapped(_ sender: Any) {
        print(tapCount)
        tapCount += 1


        //end editMode
        if tapCount % 2 == 0 {
            isEditMode = false
            if shouldSave {
                shouldSave = false
                saveChanges(nameChnaged: hasNameChanged, userNameChnaged: hasUserNameChanged, bioChnaged: hasBioChanged, emailChanged: hasEmailChanged, referralChnaged: hasRefrralChanged, genderChanged: hasGenderChanged)
            } else {
                shouldSave = false
            }
            UIView.transition(with: btnEditProfile, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.btnEditProfile.setTitle("", for: .normal)

            })
            
            btnEditProfile.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
            
            self.tableView.beginUpdates()
            self.btnCamera.isHidden = true
            self.tableView.endUpdates()

        }
            //gotTo EditMode
        else {
            USERinDB()
            textManagment()
            isEditMode = true
            shouldSave = false
            btnEditProfile.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
            UIView.transition(with: btnEditProfile, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.btnEditProfile.setTitle("", for: .normal)
            })
            self.tableView.beginUpdates()
            self.btnCamera.isHidden = false
            self.tableView.endUpdates()

        }
        
    }
    private func updateBtnEditStateView(hasChnagedValue: Bool! = false) {
        if hasChnagedValue {
            UIView.transition(with: btnEditProfile, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.btnEditProfile.setTitle("", for: .normal)
            })
            shouldSave = true
        } else {
            UIView.transition(with: btnEditProfile, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.btnEditProfile.setTitle("", for: .normal)
            })
            shouldSave = false

        }
    }
    @IBAction func btnCameraPickTapped(_ sender: Any) {
    }
    @IBAction func btnScoreTapped(_ sender: Any) {
        let score = IGScoreViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        self.navigationController!.pushViewController(score, animated: true)
    }
    @IBAction func btnCreditTapped(_ sender: Any) {
        let scoreHistory = packetTableViewController.instantiateFromAppStroryboard(appStoryboard: .Wallet)
        self.navigationController!.pushViewController(scoreHistory, animated:true)

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
                
            case 0 :
                if isEditMode {
                    return 0
                }
                else {
                    return 84
                }
            case 1 :
                if isEditMode {
                    return 0
                }
                else {
                    return 74
                }
                
            case 2 :
                if isEditMode {
                    return 0
                }
                else {
                    return 44
                }
                
                
            case 3 :
                if isEditMode {
                    return 0
                }
                else {
                    return 44
                }
                
            case 4 :
                if isEditMode {
                    return 0
                }
                else {
                    return 44
                }
                
                
            case 5 :
                if isEditMode {
                    return 0
                }
                else {
                    return 44
                }
                
                
            case 6 :
                if isEditMode {
                    return 0
                }
                else {
                    return 44
                }
                
            case 7 :
                if isEditMode {
                    return 44
                }
                else {
                    return 0
                }
                
                
            case 8 :
                if isEditMode {
                    return 44
                }
                else {
                    return 0
                }
                
                
            case 9 :
                if isEditMode {
                    return 44
                }
                else {
                    return 0
                }
                
            case 10 :
                if isEditMode {
                    return 44
                }
                else {
                    return 0
                }
                
            case 11 :
                if isEditMode {
                    return 44
                }
                else {
                    return 0
                }
                
                
                
            default :
                if isEditMode {
                    return 0
                }
                else {
                    return 0
                }
                
            }
        }
        else {
            return 0
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
            var rowIndex = indexPath.row
            
            switch indexPath.row {
            case 0 :
                break
            case 1 :
                break
            case 2 :
                
                shareContent = "HEY_JOIN_IGAP".localizedNew
                let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
                present(activityViewController, animated: true, completion: nil)
            case 3 :
                self.tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "ShowQRScanner", sender: self)
            case 4 :
                manageOpenMap()
            case 5 :
//                self.tableView.deselectRow(at: indexPath, animated: true)
//                performSegue(withIdentifier: "showChangeLanguagePage", sender: self)
//                break
                self.tableView.deselectRow(at: indexPath, animated: true)
                var stringUrl = ""
                if SMLangUtil.loadLanguage() == "fa" {
                    stringUrl = "https://blog.igap.net/fa"
                } else {
                    stringUrl = "https://blog.igap.net"
                }
                if let url = NSURL(string: stringUrl){
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }

                break
            case 6 :
                break

            case 7 :

                break
            case 8 :
                break
            case 9 :
                break
                
            case 10 :
                break
                
            case 11 :
                break
                

                
            default:
                break
            }
            
        }
        
        
    }
    //MARK : - ACTIONS

    @IBAction func btnMaleGendedidTapOnMaleGender(_ sender: Any) {
        if isMaleChecked {
        } else {
            isFMaleChecked = false
            btnWomenGender.setTitle("", for: .normal)
            btnMenGender.setTitle("", for: .normal)

        }
        let tmpCurrentGender = 1
        if currentGender != tmpCurrentGender {
            currentGender = 1
            hasGenderChanged = true
            updateBtnEditStateView(hasChnagedValue: true)
        } else {
            hasGenderChanged = false
            updateBtnEditStateView(hasChnagedValue: false)
        }

    }
    @IBAction func didTapOnFemaleGender(_ sender: Any) {
        if isFMaleChecked {
        } else {
            isMaleChecked = false
            btnMenGender.setTitle("", for: .normal)
            btnWomenGender.setTitle("", for: .normal)
        }
        let tmpCurrentGender = 2
        if currentGender != tmpCurrentGender {
            currentGender = 2
            hasGenderChanged = true
            updateBtnEditStateView(hasChnagedValue: true)
        } else {
            hasGenderChanged = false
            updateBtnEditStateView(hasChnagedValue: false)
        }

    }
    @IBAction func emailTextFieldChanged(_ sender: UITextField) {
    }
    
    private func saveChanges(nameChnaged: Bool! = false,userNameChnaged: Bool! = false, bioChnaged: Bool! = false, emailChanged : Bool! = false, referralChnaged : Bool! = false, genderChanged : Bool! = false) {
        SMLoading.showLoadingPage(viewcontroller: self)
        if nameChnaged {
            sendNameRequest(current: currentName)
        }
        if userNameChnaged {
            sendUserNameRequest(current: currentUserName)
        }
        if bioChnaged {
                sendBioRequest(current: currentEmail)
        }
        if emailChanged {
                sendEmailRequest(current: currentEmail)
        }
        if referralChnaged {
                sendReferralRequest(current: currentReferral)
        }
        if genderChanged {
                sendGenderRequest(current: currentGender)
        }

    }
    //Mark : - Services Requests

    //Hint: - send UserName Change Request
    private func sendNameRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileUpdateUsernameRequest.Generator.generate(username: current).success({ (protoResponse) in
            SMLoading.hideLoadingPage()
            self.canCallNextRequest = true
            DispatchQueue.main.async {
                switch protoResponse {
                case let setUsernameProtoResponse as IGPUserProfileUpdateUsernameResponse:
                    IGUserProfileUpdateUsernameRequest.Handler.interpret(response: setUsernameProtoResponse)
         
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userProfileUpdateUsernameIsInvaild:
                    let alert = UIAlertController(title: "Timeout", message: "Username is invalid", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userProfileUpdateUsernameHasAlreadyBeenTaken:
                    let alert = UIAlertController(title: "Timeout", message: "Username has already been taken by another user", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userProfileUpdateLock:
                    let time = waitTime
                    let remainingMiuntes = time!/60
                    let alert = UIAlertController(title: "Error", message: "You can not change your username because you've recently changed it. waiting for \(remainingMiuntes) minutes", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true,completion: nil)
                    break
                    
                default:
                    break
                }
            }
        }).send()
    }
    //Hint: - send Name Change Request
    private func sendUserNameRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetNicknameRequest.Generator.generate(nickname: current).success({ (protoResponse) in
            SMLoading.hideLoadingPage()
            self.canCallNextRequest = true
            
            DispatchQueue.main.async {
                switch protoResponse {
                case let setNicknameProtoResponse as IGPUserProfileSetNicknameResponse:
                    IGUserProfileSetNicknameRequest.Handler.interpret(response: setNicknameProtoResponse)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    self.canCallNextRequest = false
                default:
                    break
                }
            }
        }).send()
    }
    //Hint: - send Bio Change Request
    private func sendBioRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetBioRequest.Generator.generate(bio: current).success({ (protoResponse) in
            SMLoading.hideLoadingPage()
            self.canCallNextRequest = true
            DispatchQueue.main.async {
                switch protoResponse {
                case let userProfileSetBioResponse as IGPUserProfileSetBioResponse:
                    IGUserProfileSetBioRequest.Handler.interpret(response: userProfileSetBioResponse)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
            SMLoading.hideLoadingPage()
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    self.canCallNextRequest = false
                default:
                    break
                }
            }
        }).send()
    }
    //Hint: - send Email Change Request
    private func sendEmailRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetEmailRequest.Generator.generate(userEmail: current).success({ (protoResponse) in
            SMLoading.hideLoadingPage()
            self.canCallNextRequest = true
            
            DispatchQueue.main.async {
                switch protoResponse {
                case let setUserEmailProtoResponse as IGPUserProfileSetEmailResponse:
                    IGUserProfileSetEmailRequest.Handler.interpret(response: setUserEmailProtoResponse)
                    
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    self.canCallNextRequest = false
                default:
                    break
                }
            }
        }).send()
    }
    //Hint: - send Referral Change Request
    private func sendReferralRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetRepresentativeRequest.Generator.generate(phone: current).success({ (protoResponse) in
            SMLoading.hideLoadingPage()
            self.canCallNextRequest = true
            if let response = protoResponse as? IGPUserProfileSetRepresentativeResponse {
                IGUserProfileSetRepresentativeRequest.Handler.interpret(response: response)
            }

        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    self.canCallNextRequest = false
                default:
                    break
                }
            }
        }).send()
    }
    //Hint: - send gender Change Request
    private func sendGenderRequest(current: IGPGender.RawValue) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetGenderRequest.Generator.generate(gender: IGPGender(rawValue: current)!).success({ (protoResponse) in
            SMLoading.hideLoadingPage()
            DispatchQueue.main.async {
                let userId = IGAppManager.sharedManager.userID()
                let gender: IGPGender = IGPGender(rawValue: current)!
                IGFactory.shared.updateProfileGender(userId!, igpGender: gender)
            }
            self.canCallNextRequest = true
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    self.canCallNextRequest = false
                default:
                    break
                }
            }
        }).send()
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
 
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
    
    @objc func segueToChatNotificationReceived(_ aNotification: Notification) {
        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.navigationBar.isHidden = true

        if let roomId = aNotification.userInfo?["room"] as? Int64 {
            let predicate = NSPredicate(format: "id = %lld", roomId)
            
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                    switch protoResponse {
                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),object: nil,userInfo: ["room": roomId])
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                    self.hud.hide(animated: true)
                }
            }).send()
            
        }
    }
}

//MARK: SEARCH BAR DELEGATE
extension IGProfileTableViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        //Filter function
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        IGGlobal.heroTabIndex = (self.tabBarController?.selectedIndex)!
        (searchBar.value(forKey: "cancelButton") as? UIButton)?.setTitle("CANCEL_BTN".RecentTableViewlocalizedNew, for: .normal)
        
        let lookAndFind = UIStoryboard(name: "IGSettingStoryboard", bundle: nil).instantiateViewController(withIdentifier: "IGLookAndFind")
        lookAndFind.hero.isEnabled = true
        //        self.searchBar.hero.id = "searchBar"
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .fade
        self.hero.replaceViewController(with: lookAndFind)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        
        
        //Filter function
        //        self.filterFunction(searchText: term)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
        //Filter function
        //        self.filterFunction(searchText: searchBar.text)
    }
}



