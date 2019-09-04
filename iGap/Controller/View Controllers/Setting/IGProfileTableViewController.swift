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


class IGProfileTableViewController: UITableViewController,CLLocationManagerDelegate {
    lazy var colorView = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = false
        //        self.navigationController?.navigationBar.addSubview(view)
        //        self.navigationController?.navigationBar.sendSubviewToBack(view)
        return view
    }()
    var isEditMode = false
    var tapCount = 0
    fileprivate let searchController = UISearchController(searchResultsController: nil)

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
        IGRequestWalletGetAccessToken.sendRequest()

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        USERinDB()
        textManagment()
        self.tableView.alwaysBounceVertical = false
        
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        if navigationItem.searchController == nil {
            let gradient = CAGradientLayer()
            let sizeLength = UIScreen.main.bounds.size.height * 2
            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: 64)
            
            gradient.frame = defaultNavigationBarFrame
            gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
            gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
            gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
            gradient.locations = orangeGradientLocation as [NSNumber]
            
            
            
            if #available(iOS 11.0, *) {
                
                if let navigationBar = self.navigationController?.navigationBar {
                    navigationBar.barTintColor = UIColor(patternImage: self.image(fromLayer: gradient))
                }
                
                
                IGGlobal.setLanguage()
                self.searchController.searchBar.searchBarStyle = UISearchBar.Style.default
                
                
                if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    IGGlobal.setLanguage()
                    
                    if textField.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                        let centeredParagraphStyle = NSMutableParagraphStyle()
                        centeredParagraphStyle.alignment = .center
                        
                        let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.paragraphStyle: centeredParagraphStyle]
                        textField.attributedPlaceholder = NSAttributedString(string: "SEARCH_PLACEHOLDER".localizedNew, attributes: attributeDict)
                        textField.textAlignment = .center
                    }
                    
                    let imageV = textField.leftView as! UIImageView
                    imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    imageV.tintColor = UIColor.white
                    
                    if let backgroundview = textField.subviews.first {
                        backgroundview.backgroundColor = UIColor.white.withAlphaComponent(0.75)
                        backgroundview.layer.cornerRadius = 10;
                        backgroundview.clipsToBounds = true;
                        
                    }
                }
                if navigationItem.searchController == nil {
                    navigationItem.searchController = searchController
                    navigationItem.hidesSearchBarWhenScrolling = true
                }
            } else {
                tableView.tableHeaderView = searchController.searchBar
            }
            
        }
        
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

        navigationControllerr.navigationBar.isHidden = false

        
    }
    func initServices() {
        getUserEmail()
        self.finishDefault(isPaygear: true, isCard: false)

    }
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
        SMLoading.showLoadingPage(viewcontroller: self)
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
                            self.lblMoneyAmount.text = String(tmpSum).inRialFormat().inLocalizedLanguage()

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
        getScore()
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
        
        self.performSegue(withIdentifier: "showSettings", sender: self)
        
        
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
//        if(offset > -UIApplication.shared.statusBarFrame.height){
//            colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: (self.navigationController?.navigationBar.frame.width)!, height: UIApplication.shared.statusBarFrame.height)
//
//
//        }else{
//            colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: (self.navigationController?.navigationBar.frame.width)!, height: UIApplication.shared.statusBarFrame.height)
//        }
        if offset < 0 {
            scrollView.contentOffset.y = 0

        } else {

        }

    }
    @IBAction func btnEditProfileTapped(_ sender: Any) {
        print(tapCount)
        tapCount += 1

        if tapCount % 2 == 0 {
            isEditMode = false
            UIView.transition(with: btnEditProfile, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.btnEditProfile.setTitle("", for: .normal)

            })
            
            btnEditProfile.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
            
            self.tableView.beginUpdates()
            self.btnCamera.isHidden = true
            self.tableView.endUpdates()

        }
        else {
            
            isEditMode = true
            btnEditProfile.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
            UIView.transition(with: btnEditProfile, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.btnEditProfile.setTitle("", for: .normal)
            })
            self.tableView.beginUpdates()
            self.btnCamera.isHidden = false
            self.tableView.endUpdates()

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
                self.tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "showChangeLanguagePage", sender: self)
                break
            case 6 :
                self.tableView.deselectRow(at: indexPath, animated: true)
                var stringUrl = ""
                if SMLangUtil.loadLanguage() == "fa" {
                    stringUrl = "https://blog.igap.net/fa"
                }
                else {
                    stringUrl = "https://blog.igap.net"
                }
                if let url = NSURL(string: stringUrl){
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
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
    }
    @IBAction func didTapOnFemaleGender(_ sender: Any) {
    }
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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



