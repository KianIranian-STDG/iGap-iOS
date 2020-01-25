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
import RxSwift
import Gifu
import MapKit
import YPImagePicker
import SwiftEventBus

class IGProfileTableViewController: BaseTableViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    lazy var colorView = { () -> UIView in
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    @IBOutlet weak var btnCountryCodeWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var tfRefferalWidthConstraints: NSLayoutConstraint!
    var libraryBanner: [IGFile] = []
    var wallpapersList: Results<IGRealmWallpaper>!
    var userAvatarAttachment: IGFile!

    var canCallNextRequest: Bool! = false
    var currentGender: IGPGender.RawValue = 0
    var currentName: String = ""
    var currentUserName: String = ""
    var currentBio: String = ""
    var currentEmail: String = ""
    var currentReferral: String = ""
    internal static var allowGetCountry:Bool = true
    var phone: String?
    var selectedCountry: IGCountryInfo?
    var registrationResponse : (username:String, userId:Int64, authorHash:String, verificationMethod: IGVerificationCodeSendMethod, resendDelay:Int32, codeDigitsCount:Int32, codeRegex:String, callMethodSupport:Bool)?

    var isEditMode = false
    var shouldSave = false
    var tapCount = 0
    var isMaleChecked: Bool! = false
    var isFMaleChecked: Bool! = false

    var tmpGender: IGGender = .unknown
    var tmpEmail: String = ""

    private var goToSettings : Bool! = false
    @IBOutlet var iconArray: [UILabel]!
    @IBOutlet weak var stack0: UIStackView!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack3: UIStackView!
    @IBOutlet weak var lblNameTop: UILabel!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var btnUsername: UIButton!
    @IBOutlet weak var lblTel: UILabel!
    @IBOutlet weak var viewTop: UIView!
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
    @IBOutlet weak var versionTitleLbl: UILabel!
    @IBOutlet weak var checkUpdateLbl: UILabel!
    @IBOutlet weak var lblMoneyAmount: UILabel!
    @IBOutlet weak var lblScoreAmount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBioInner: UILabel!
    @IBOutlet weak var lblEmailInner: UILabel!
    @IBOutlet weak var lblReferralInner: UILabel!
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
    @IBOutlet weak var tfReferral: AKMaskField!

    var hasNameChanged: Bool! = false
    var hasUserNameChanged: Bool! = false
    var hasBioChanged: Bool! = false
    var hasEmailChanged: Bool! = false
    var hasGenderChanged: Bool! = false
    var hasRefrralChanged: Bool! = false
    
    var userInDb : IGRegisteredUser!
    let locationManager = CLLocationManager()
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var shareContent = String()
    var user : IGRegisteredUser?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    var notificationToken: NotificationToken?
    private var avatarObserver: NotificationToken?
    
    var isPoped = false
//    let disposeBag = DisposeBag()
    var userCards: [SMCard]?
    
    var editProfileNavBtn: UIButton!
    var connectionStatus: IGAppManager.ConnectionStatus?

    @IBOutlet weak var userAvatarView: IGAvatarView!
    
    @IBOutlet weak var btnCamera: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.initNavBarWithIgapIcon()
        
        self.hideKeyboardWhenTappedAround()
        initView()
        initServices()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { [weak self] (connectionStatus) in
            self?.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        SwiftEventBus.onMainThread(self, name: "initTheme") { [weak self] result in
            self?.initTheme()
        }

        initTheme()
    }
    private func initTheme() {
        lblQR.textColor = ThemeManager.currentTheme.LabelColor
        lblFaq.textColor = ThemeManager.currentTheme.LabelColor
        lblNew.textColor = ThemeManager.currentTheme.LabelColor
        lblTel.textColor = ThemeManager.currentTheme.LabelColor
        lblCloud.textColor = ThemeManager.currentTheme.LabelColor
        lblName.textColor = ThemeManager.currentTheme.LabelColor
        lblScore.textColor = ThemeManager.currentTheme.LabelColor
        lblBioTop.textColor = ThemeManager.currentTheme.LabelColor
        lblCredit.textColor = ThemeManager.currentTheme.LabelColor
        lblNearby.textColor = ThemeManager.currentTheme.LabelColor
        lblInviteF.textColor = ThemeManager.currentTheme.LabelColor
        lblNameTop.textColor = .white
        lblSetting.textColor = ThemeManager.currentTheme.LabelColor
        lblBioInner.textColor = ThemeManager.currentTheme.LabelColor
        lblUserName.textColor = ThemeManager.currentTheme.LabelColor
        lblMenGender.textColor = ThemeManager.currentTheme.LabelColor
        lblEmailInner.textColor = ThemeManager.currentTheme.LabelColor
        lblGenderInner.textColor = ThemeManager.currentTheme.LabelColor
        lblMoneyAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblScoreAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblWomenGender.textColor = ThemeManager.currentTheme.LabelColor
        lblReferralInner.textColor = ThemeManager.currentTheme.LabelColor
        checkUpdateLbl.textColor = ThemeManager.currentTheme.LabelColor
        versionTitleLbl.textColor = ThemeManager.currentTheme.LabelColor
        for icon in iconArray {
            icon.textColor = ThemeManager.currentTheme.LabelColor
        }
        btnWomenGender.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        btnMenGender.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.viewTop.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor

        let tfArray = [tfName, tfUserName, tfEmail, tfBio, tfReferral]
        for tf in tfArray {
            tf?.backgroundColor = .clear
            tf?.layer.borderWidth = 1.0
            tf?.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
            tf?.placeHolderColor = ThemeManager.currentTheme.LabelGrayColor
            tf?.layer.cornerRadius = 5
            tf?.textColor = ThemeManager.currentTheme.LabelColor
            
        }
        
        
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        self.initNavBar()
                
        IGRequestWalletGetAccessToken.sendRequest()
        //Hint:- Check if request was not successfull call services again
        if lblMoneyAmount.text == "..." {
            self.finishDefault(isPaygear: true, isCard: false)
        }
        if lblScoreAmount.text == "..." {
            getScore()
        }
        
        fetchUserInfo()
        initAvatarObserver()
        initTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(segueToChatNotificationReceived(_:)),
                                               name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoomAtProfile),
                                               object: nil)
        textManagment()
        self.tableView.alwaysBounceVertical = false
        
        if(IGProfileTableViewController.allowGetCountry){
            getUserCurrentLocation()
        }
        initTheme()
    }
    
    func getUserCurrentLocation() {
        IGInfoLocationRequest.Generator.generate().success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                if self == nil {return}
                if let locationProtoResponse = protoResponse as? IGPInfoLocationResponse {
                   let country = IGCountryInfo(responseProtoMessage: locationProtoResponse)
                   self!.selectedCountry = country
                   self!.setSelectedCountry(self!.selectedCountry!)
                }
            }
        }).send()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navigationBar = self.navigationController?.navigationBar as? IGNavigationBar {
            navigationBar.setGradientBackground(colors: [ThemeManager.currentTheme.NavigationFirstColor, ThemeManager.currentTheme.NavigationSecondColor], startPoint: .centerLeft, endPoint: .centerRight)
        }
    }
    
    deinit {
        print("Deinit IGProfileTableViewController")
    }
    
    private func initNavBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.setProfilePageNavigationItem()
        navigationItem.rightViewContainer?.addAction { [weak self] in
            self?.view.endEditing(true)
            self?.editProfileTapped()
        }
    }
    
    private func updateNavigationBarBasedOnNetworkStatus(_ status: IGAppManager.ConnectionStatus) {
        if let navigationItem = self.navigationItem as? IGNavigationItem {
            switch status {
            case .waitingForNetwork:
                navigationItem.setNavigationItemForWaitingForNetwork()
                connectionStatus = .waitingForNetwork
                IGAppManager.connectionStatusStatic = .waitingForNetwork
                break
                
            case .connecting:
                navigationItem.setNavigationItemForConnecting()
                connectionStatus = .connecting
                IGAppManager.connectionStatusStatic = .connecting
                break
                
            case .connected:
                connectionStatus = .connected
                IGAppManager.connectionStatusStatic = .connected
                break
                
            case .iGap:
                connectionStatus = .iGap
                IGAppManager.connectionStatusStatic = .iGap
                switch  currentTabIndex {
                case TabBarTab.Recent.rawValue:
                    let navItem = self.navigationItem as! IGNavigationItem
                    navItem.addModalViewItems(leftItemText: nil, rightItemText: nil, title: IGStringsManager.Phone.rawValue.localized)
                default:
                    self.initNavBar()
                }
                break
            }
        }
    }
    
    private func initServices() {
        getUserEmail()
        finishDefault(isPaygear: true, isCard: false)
        getScore()
        showProfileWallpaper()
    }
    
    private func showProfileWallpaper(checkUpdate: Bool = true) {
        var fit = IGPInfoWallpaper.IGPFit.phone
        if IGGlobal.hasBigScreen() {
            fit = IGPInfoWallpaper.IGPFit.tablet
        }
        
        let predicateWallpaper = NSPredicate(format: "type = %d", IGPInfoWallpaper.IGPType.profileWallpaper.rawValue)
        if let profileWallpaperList = IGDatabaseManager.shared.realm.objects(IGRealmWallpaper.self).filter(predicateWallpaper).first, let profileWallpaper = profileWallpaperList.file.first {
            self.imgBackgroundImage.setThumbnail(for: profileWallpaper, showMain: true)
        }
        
        if checkUpdate {
            IGInfoWallpaperRequest.Generator.generate(fit: fit , type: .profileWallpaper).successPowerful({ [weak self] (protoResponse, requestWrapper) in
                if let wallpaperRequest = requestWrapper.identity as? IGPInfoWallpaper, wallpaperRequest.igpType == .profileWallpaper {
                    if let wallpaperResponse = protoResponse as? IGPInfoWallpaperResponse {
                        let profileWallpaper = IGRealmWallpaper.fetchProfileWallpaper()
                        if profileWallpaper == nil || profileWallpaper!.cacheID != wallpaperResponse.igpWallpaper.first?.igpFile.igpCacheID {
                            IGInfoWallpaperRequest.Handler.interpret(response: wallpaperResponse ,type: .profileWallpaper)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self?.showProfileWallpaper(checkUpdate: false)
                            }
                        } else {
                            self?.showProfileWallpaper(checkUpdate: false)
                        }
                    }
                }
            }).error({ [weak self] (error, waitTime) in
                if error == .timeout {
                    self?.showProfileWallpaper(checkUpdate: checkUpdate)
                }
            }).send()
        }
    }
    
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
        SMCard.getAllCardsFromServer({ [weak self] cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0 {
                        self?.userCards = SMCard.getAllCardsFromDB()
                        if let cards = self?.userCards {
                            var tmpSum : Int64! = 0
                            for card in cards {
                                if card.balance != nil {
                                    let tmpBalance = card.balance!
                                    tmpSum =  tmpSum + tmpBalance
                                }
                            }
                            self?.lblMoneyAmount.text = String(tmpSum).inRialFormat()
                        }
                    }
                }
            }
            needToUpdate = true
        }, onFailed: {error in })
    }

    func initView() {
        btnMenGender.setTitle("", for: .normal)
        btnMenGender.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnWomenGender.setTitle("", for: .normal)
        btnWomenGender.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        btnCamera.setBackgroundImage(UIImage(named: "ig_add_image_icon"), for: .normal)
        
        self.view.insertSubview(colorView, at: 1)
        
        viewBackgroundImage.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMinXMaxYCorner], radius: 10)
        viewBackgroundImage.clipsToBounds = true
        initChangeLang()
        let tapCloud = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapCloud(recognizer:)))
        stack0.addGestureRecognizer(tapCloud)
        
        let tapSettings = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapSettings(recognizer:)))
        stack1.addGestureRecognizer(tapSettings)
        
        let tapNew = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapNew(recognizer:)))
        stack3.addGestureRecognizer(tapNew)
    }
    
    func initChangeLang() {
        lblName.text = IGStringsManager.FirstName.rawValue.localized
        lblUserName.text = IGStringsManager.Username.rawValue.localized
        lblBioInner.text = IGStringsManager.Bio.rawValue.localized
        lblReferralInner.text = IGStringsManager.Referral.rawValue.localized
        lblBioInner.textColor = ThemeManager.currentTheme.LabelGrayColor
        lblReferralInner.textColor = ThemeManager.currentTheme.LabelGrayColor

        lblNameTop.text = IGStringsManager.FirstName.rawValue
        lblCloud.text = IGStringsManager.Cloud.rawValue.localized
        lblSetting.text = IGStringsManager.Settings.rawValue.localized
        lblNew.text = IGStringsManager.GlobalNew.rawValue.localized
        lblCredit.text = IGStringsManager.Credit.rawValue.localized
        lblScore.text = IGStringsManager.YourScore.rawValue.localized
        lblScoreAmount.text = "..."
        lblInviteF.text = IGStringsManager.InviteFriends.rawValue.localized
        lblQR.text = IGStringsManager.LoginUsingQr.rawValue.localized
        lblNearby.text = IGStringsManager.Nearby.rawValue.localized
        lblFaq.text = IGStringsManager.Faq.rawValue.localized
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionTitleLbl.text = IGStringsManager.GlobalAppVersion.rawValue.localized + "   \(version)".inLocalizedLanguage()
        }
        checkUpdateLbl.text = IGStringsManager.GlobalCheckUpdate.rawValue.localized
        lblEmailInner.text = IGStringsManager.Email.rawValue.localized
        lblMenGender.text = IGStringsManager.Male.rawValue.localized
        lblMenGender.font = UIFont.igFont(ofSize: 15)
        lblWomenGender.font = UIFont.igFont(ofSize: 15)
        lblWomenGender.text = IGStringsManager.Female.rawValue.localized
        lblGenderInner.text = IGStringsManager.Gender.rawValue.localized
    }
    
    func textManagment() {
        lblBioTop.text = (userInDb.bio)
        lblNameTop.text = (userInDb.displayName)
        lblNameTop.font = UIFont.igFont(ofSize: 14)
        btnUsername.setTitle((userInDb.username), for: .normal)
        btnUsername.titleLabel?.font = UIFont.igFont(ofSize: 14)
        lblTel.text = String(userInDb.phone).inLocalizedLanguage()

        tfEmail.text = (userInDb.email)
        if let tmpEmail = tfEmail.text {
            currentEmail = tmpEmail
        }
        tfName.text = (userInDb.displayName)
        currentName = (userInDb.displayName)
        tfUserName.text = (userInDb.username)
        if let tmpName = tfUserName.text {
             currentUserName = tmpName
         }

        tfBio.text = (userInDb.bio)
        if let tmpBio = tfBio.text {
            currentBio = tmpBio
        }
        if let sessionInfo = IGDatabaseManager.shared.realm.objects(IGSessionInfo.self).first {
            tmpGender = sessionInfo.gender
            if let tmpReferralNumber = sessionInfo.representer {
                self.tfReferral.isEnabled = false
                tfReferral.text = tmpReferralNumber
                if let tmpRef = tfReferral.text {
                    currentReferral = tmpRef
                }
                self.btnCountryCodeWidthConstraints.constant = 0
                self.tfRefferalWidthConstraints.constant = 200
            } else {
                self.tfReferral.isEnabled = true
                self.getRepresenter()
            }
            
        }
        //check if user didNot check also check the serverside
        if tmpGender == .unknown {
            
        } else {
            
            switch tmpGender {
            case .unknown:
                //uncheck Both buttons
                currentGender = 0
                btnWomenGender.setTitle("", for: .normal)
                btnMenGender.setTitle("", for: .normal)
                
                break
            case .male:
                //check male button - uncheck Fmale Button
                currentGender = 1
                isFMaleChecked = false
                isMaleChecked = true
                
                btnWomenGender.setTitle("", for: .normal)
                btnMenGender.setTitle("", for: .normal)
                
                break
            case .female:
                //UnCheck Male Button - Check Fmale Button
                currentGender = 2
                isFMaleChecked = true
                isMaleChecked = false
                btnMenGender.setTitle("", for: .normal)
                btnWomenGender.setTitle("", for: .normal)
                
                break
            }
        }

        lblBioTop.font = UIFont.igFont(ofSize: 10)
        lblBioTop.labelSpacing = 30                       // Distance between start and end labels
        lblBioTop.pauseInterval = 2.0                     // Seconds of pause before scrolling starts again
        lblBioTop.scrollSpeed = 30                        // Pixels per second
        if self.isRTL {
            lblBioTop.textAlignment = .right
        } else {
            lblBioTop.textAlignment = .left
        }
        lblBioTop.fadeLength = 12                         // Length of the left and right edge fade, 0 to disable
        lblBioTop.scrollDirection = EFAutoScrollDirection.left
        if self.isRTL {
            lblBioTop.scrollDirection = EFAutoScrollDirection.right
        } else {
            lblBioTop.scrollDirection = EFAutoScrollDirection.left
        }


    }
    
    func getRepresenter(){
        IGUserProfileGetRepresentativeRequest.Generator.generate().success({ [weak self] (protoResponse) in
            if let response = protoResponse as? IGPUserProfileGetRepresentativeResponse {
                
                if response.igpPhoneNumber.isEmpty {
                    self?.tfReferral.isEnabled = true
                } else {
                    self?.tfReferral.isEnabled = false

                }
                IGUserProfileGetRepresentativeRequest.Handler.interpret(response: response)
                
                DispatchQueue.main.async {
                    self?.tfReferral.text = response.igpPhoneNumber
                    if let tmpRef = self?.tfReferral.text {
                        self?.currentReferral = tmpRef
                    }
                }
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self?.getRepresenter()
            default:
                break
            }
        }).send()
    }
    func getUserEmail() {
        IGUserProfileGetEmailRequest.Generator.generate().success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getUserEmailResponse as IGPUserProfileGetEmailResponse:
                    let userEmail = IGUserProfileGetEmailRequest.Handler.interpret(response: getUserEmailResponse)
                    DispatchQueue.main.async {
                        self?.tfEmail.text = userEmail
                        if let tmpEmail = self?.tfEmail.text {
                            self?.currentEmail = tmpEmail
                        }
                    }
                default:
                    break
                }
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self?.getUserEmail()
                break
            default:
                break
            }
            
        }).send()
    }
    
    func getUserGender() {
        IGUserProfileGetGenderRequest.Generator.generate().success({ (protoResponse) in
            if let getUserGenderResponse = protoResponse as? IGPUserProfileGetGenderResponse {
                _ = IGUserProfileGetGenderRequest.Handler.interpret(response: getUserGenderResponse)
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self?.getUserGender()
                break
            default:
                break
            }
            
        }).send()
    }
    
    func fetchUserInfo() {
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        userInDb = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(predicate).first
        if userAvatarView.avatarImageView != nil && userAvatarView.avatarImageView?.image == nil {
            userAvatarView.setUser(userInDb)
        }
        user = userInDb
        userAvatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        userAvatarView.avatarImageView?.addGestureRecognizer(tap)
        
    }
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            showAvatar()
        }
    }
    @objc func handleTapCloud(recognizer:UITapGestureRecognizer) {
        
        
    }
    @objc func handleTapSettings(recognizer:UITapGestureRecognizer) {
        
        
    }
    @objc func handleTapNew(recognizer:UITapGestureRecognizer) {
        
        
    }
    
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    open private(set) var deleteToolbar: UIToolbar!
    
    func showAvatar() {
        if IGAvatar.hasAvatar(ownerId: self.user!.id) {
            let mediaViewer = IGMediaPager.instantiateFromAppStroryboard(appStoryboard: .Main)
            mediaViewer.hidesBottomBarWhenPushed = true
            mediaViewer.ownerId = self.user?.id
            mediaViewer.mediaPagerType = .avatar
            mediaViewer.avatarType = .user
            self.navigationController!.pushViewController(mediaViewer, animated: false)
        }
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
    
    private func initAvatarObserver(){
        self.avatarObserver = IGAvatar.getAvatarsLocalList(ownerId: self.userInDb.id).observe({ [weak self] (ObjectChange) in
            if self != nil {
                self!.userAvatarView.setUser(self!.userInDb)
            }
        })
    }
    
    private func getScore(){
        IGUserIVandGetScoreRequest.Generator.generate().success({ [weak self] (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self?.lblScoreAmount.text = String(describing: response.igpScore).inRialFormat()
                }
            }
        }).error({ [weak self] (errorCode, waitTime) in
            
            switch errorCode {
            case .timeout :
                self?.getScore()
            default:
                break
            }
        }).send()
    }
    
    func manageOpenMap(){
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            IGHelperNearby.shared.openMap()
            
        } else {
            locationManager.stopUpdatingLocation()
            let alert = UIAlertController(title: nil, message: IGStringsManager.MSGEnaleLocationService.rawValue.localized, preferredStyle: UIAlertController.Style.alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { action in
                switch action.style {
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
        let offset = scrollView.contentOffset.y

        if offset < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    //Hint: - Go To Setting Action Handler
    @IBAction func didTapOnPickCountryCode(_ sender: Any) {
        performSegue(withIdentifier: "showCountryCell", sender: self) //presentConutries
    }
    
    @IBAction func didTapOnGoToSettings(_ sender: Any) {
        goToSettings = false
        let settingVC = IGSettingTableViewController.instantiateFromAppStroryboard(appStoryboard: .Setting)
        settingVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(settingVC, animated:true)
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
                        SwiftEventBus.postToMainThread(EventBusManager.openRoom, sender: roomId)
                        break
                    default:
                        break
                    }
                }
            }).error({ [weak self] (errorCode, waitTime) in
                DispatchQueue.main.async {
                    let alertC = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalTryAgain.rawValue.localized, preferredStyle: .alert)
                    
                    let cancel = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alertC.addAction(cancel)
                    self?.present(alertC, animated: true, completion: nil)
                }
            }).send()
        }
    }
    //Hint :- Go to Creat New chat/Group/Channel
    @IBAction func didTapOnGoToCreatNewCGC(_ sender: Any) {
        goToSettings = false
        let createChat = IGPhoneBookTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        createChat.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(createChat, animated: true)
    }
    
    private func editProfileTapped() {
        tapCount += 1
        let navigationItem = self.navigationItem as! IGNavigationItem

        //end editMode
        if tapCount % 2 == 0 {
            isEditMode = false
            if shouldSave {
                shouldSave = false
                saveChanges(nameChnaged: hasNameChanged, userNameChnaged: hasUserNameChanged, bioChnaged: hasBioChanged, emailChanged: hasEmailChanged, referralChnaged: hasRefrralChanged, genderChanged: hasGenderChanged)
            } else {
                shouldSave = false
            }

            UIView.transition(with: navigationItem.btnEdit, duration: 0.5, options: .transitionCrossDissolve, animations: {
                navigationItem.btnEdit.setTitle("", for: .normal)
            })
            
            navigationItem.btnEdit.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
            
            self.tableView.beginUpdates()
            self.btnCamera.isHidden = true
            self.tableView.endUpdates()

        }
            //gotTo EditMode
        else {
            fetchUserInfo()
            textManagment()
            isEditMode = true
            shouldSave = false
            navigationItem.btnEdit.titleLabel!.font = UIFont.iGapFonticon(ofSize: 20)
            UIView.transition(with: navigationItem.btnEdit, duration: 0.5, options: .transitionCrossDissolve, animations: {
                navigationItem.btnEdit.setTitle("", for: .normal)
            })
            self.tableView.beginUpdates()
            self.btnCamera.isHidden = false
            self.tableView.endUpdates()
        }
    }
    
    private func updateBtnEditStateView(hasChnagedValue: Bool! = false) {
        let navigationItem = self.navigationItem as! IGNavigationItem

        if hasChnagedValue {
            UIView.transition(with: navigationItem.btnEdit, duration: 0.5, options: .transitionCrossDissolve, animations: {
            navigationItem.btnEdit.setTitle("", for: .normal)
            })
            shouldSave = true
        } else {
            UIView.transition(with: navigationItem.btnEdit, duration: 0.5, options: .transitionCrossDissolve, animations: {
                navigationItem.btnEdit.setTitle("", for: .normal)
            })
            shouldSave = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
        
        if segue.identifier == "showCountryCell" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! IGRegistrationStepSelectCountryTableViewController
            weak var weakSelf = self
            destination.delegate = weakSelf
        }
    }
    
    fileprivate func setSelectedCountry(_ country:IGCountryInfo) {
        selectedCountry = country
        btnCountryCode.setTitle("+"+String(Int((selectedCountry?.countryCode)!)), for: .normal)
        if country.codePattern != nil && country.codePattern != "" {
            tfReferral.setMask((selectedCountry?.codePatternMask)!, withMaskTemplate: selectedCountry?.codePatternTemplate)
        } else {
            //phoneNumberField.refreshMask()
            
            let codePatternMask = "{ddddddddddddddddddddddddd}"
            let codePatternTemplate = "_________________________"
            tfReferral.setMask(codePatternMask, withMaskTemplate: codePatternTemplate)
        }
    }
    
    @IBAction func btnCameraPickTapped(_ sender: Any) {
        
    }
    
    @IBAction func btnScoreTapped(_ sender: Any) {
        let score = IGScoreViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        score.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(score, animated: true)
    }
    
    @IBAction func btnCreditTapped(_ sender: Any) {
        goToSettings = false
        let walletVC = packetTableViewController.instantiateFromAppStroryboard(appStoryboard: .Wallet)
        walletVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(walletVC, animated:true)

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
                
            case 0 :
                if isEditMode {
                    return 0
                } else {
                    return 84
                }
            case 1 :
                if isEditMode {
                    return 0
                } else {
                    return 74
                }
                
            case 2 :
                if isEditMode {
                    return 0
                } else {
                    return 44
                }
                
                
            case 3 :
                if isEditMode {
                    return 0
                } else {
                    return 44
                }
                
            case 4 :
                if isEditMode {
                    return 0
                } else {
                    return 44
                }
                
            case 5 :
                if isEditMode {
                    return 0
                } else {
                    return 44
                }
                
                
            case 6 :
                if isEditMode {
                    return 0
                } else {
                    return 44
                }
                
            case 7 :
                if isEditMode {
                    return 0
                } else {
                    return 44
                }
                
            case 8 :
                if isEditMode {
                    return 44
                } else {
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
                
            case 12 :
                if isEditMode {
                    return 44
                }
                else {
                    return 0
                }
                
            case 13 :
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToSettings = false

        
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0 :
                break
                
            case 1 :
                break
                
            case 2 :
                shareContent = IGStringsManager.HeyJoinIgap.rawValue.localized
                let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
                present(activityViewController, animated: true, completion: nil)
                break
                
            case 3 :
                self.tableView.deselectRow(at: indexPath, animated: true)
                performSegue(withIdentifier: "ShowQRScanner", sender: self)
                break
                
            case 4 :
                manageOpenMap()
                break
                
            case 5 :
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
                // check for update
                checkVersionUpdate()
                break
                
            case 8 :
                break
                
            case 9 :
                break
                
            case 10 :
                break
                
            case 11 :
                break
                
            case 12 :
                break
                
            default:
                break
            }
        }
    }
    
    
    private func checkVersionUpdate() {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGInfoUpdateResponse.Generator.generate().success { (responseProtoMessage) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
            }
            
            DispatchQueue.main.async {
                switch responseProtoMessage {
                case let response as IGPInfoUpdateResponse:
                    if let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        if let buildV = Int32(buildVersion) {
                            if buildV < response.igpLastVersion {
                                
                                let str = response.igpBody.html2String
                                IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: IGStringsManager.GlobalCheckUpdate.rawValue.localized, showDoneButton: true, showCancelButton: true, message: str, doneText: IGStringsManager.GlobalUpdate.rawValue.localized, cancelText: IGStringsManager.GlobalCancel.rawValue.localized, cancel: {
                                    
                                }, done: {
                                    UIApplication.shared.open(URL(string: "http://d.igap.net/update")!, options: [:], completionHandler: nil)
                                })
                            } else {
                                // you are update
                                IGHelperAlert.shared.showCustomAlert(view: self, alertType: .warning, title: nil, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalUpdateVersion.rawValue.localized, cancelText: IGStringsManager.GlobalCancel.rawValue.localized, cancel: {
                                    
                                }, done: {
                                    
                                })
                            }
                        } else {
                        }
                    } else {
                    }
                    
                default:
                    break;
                }
            }
        }.error({ (errorCode, waitTime) in }).send()
    }
    
    
    //MARK : - ACTIONS
    @IBAction func btnMaleGendedidTapOnMaleGender(_ sender: Any) {
        if isMaleChecked {
        } else {
            isFMaleChecked = false
            btnWomenGender.setTitle("", for: .normal)
            btnMenGender.setTitle("", for: .normal)

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
            btnMenGender.setTitle("", for: .normal)
            btnWomenGender.setTitle("", for: .normal)
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

    @IBAction func nameTFdidEndEditing(_ sender: UITextField) {
        if currentName != sender.text {
            hasNameChanged = true
            currentName = sender.text!
        } else {
            hasNameChanged = false
        }
        self.updateBtnEditStateView(hasChnagedValue: hasNameChanged)

    }
    
    @IBAction func userNameTFdidEndEditing(_ sender: UITextField) {
        if currentUserName != sender.text {
            currentUserName = sender.text!
            hasUserNameChanged = true
        } else {
            hasUserNameChanged = false
        }
        self.updateBtnEditStateView(hasChnagedValue: hasUserNameChanged)

    }
    
    @IBAction func bioTFdidEndEditing(_ sender: UITextField) {
        if currentBio != sender.text {
            currentBio = sender.text!

            hasBioChanged = true
        } else {
            hasBioChanged = false
        }
        self.updateBtnEditStateView(hasChnagedValue: hasBioChanged)

    }
    
    @IBAction func emailTFdidEndEditing(_ sender: UITextField) {
        if currentEmail != sender.text {
            currentEmail = sender.text!
            hasEmailChanged = true
        } else {
            hasEmailChanged = false
        }
        self.updateBtnEditStateView(hasChnagedValue: hasEmailChanged)

    }
    
    @IBAction func referralTFdidEndEditing(_ sender: UITextField) {
        if currentReferral != sender.text {
            currentReferral = sender.text!
            hasRefrralChanged = true
        } else {
            hasRefrralChanged = false
        }
        self.updateBtnEditStateView(hasChnagedValue: hasRefrralChanged)
    }
    
    private func saveChanges(nameChnaged: Bool! = false,userNameChnaged: Bool! = false, bioChnaged: Bool! = false, emailChanged : Bool! = false, referralChnaged : Bool! = false, genderChanged : Bool! = false) {
        SMLoading.showLoadingPage(viewcontroller: self)
        if userNameChnaged {
            sendUserNameRequest(current: currentUserName)
        }
        if nameChnaged {
            sendNameRequest(current: currentName)
        }
        if bioChnaged {
                sendBioRequest(current: currentBio)
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
    private func sendUserNameRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileUpdateUsernameRequest.Generator.generate(username: current).success({ [weak self] (protoResponse) in
            SMLoading.hideLoadingPage()
            self?.canCallNextRequest = true
            DispatchQueue.main.async {
                if let setUsernameProtoResponse = protoResponse as? IGPUserProfileUpdateUsernameResponse {
                    IGUserProfileUpdateUsernameRequest.Handler.interpret(response: setUsernameProtoResponse)
                }
                self?.btnUsername.setTitle((current), for: .normal)
            }

        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    break
                    
                case .userProfileUpdateUsernameIsInvaild:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.InvalidUserName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    break
                    
                case .userProfileUpdateUsernameHasAlreadyBeenTaken:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AlreadyTakenUserName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    break
                    
                case .userProfileUpdateLock:
                    let time = waitTime
                    let remainingMiuntes = time!/60
                    let msg = IGStringsManager.ErrorUpdateUSernameAfter.rawValue.localized + " " + String(remainingMiuntes) + " " + IGStringsManager.Minutes.rawValue.localized
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: msg, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    break
                    
                default:
                    break
                }
            }
        }).send()
    }
    
    //Hint: - send Name Change Request
    private func sendNameRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetNicknameRequest.Generator.generate(nickname: current).success({ [weak self] (protoResponse) in
            SMLoading.hideLoadingPage()
            self?.canCallNextRequest = true
            
            DispatchQueue.main.async {
                switch protoResponse {
                case let setNicknameProtoResponse as IGPUserProfileSetNicknameResponse:
                    IGUserProfileSetNicknameRequest.Handler.interpret(response: setNicknameProtoResponse)
                default:
                    break
                }
                self?.lblNameTop.text = current
            }

        }).error ({ [weak self] (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()

                switch errorCode {
                case .timeout:
                    self?.canCallNextRequest = false
                    break
                default:
                    break
                }
            }
        }).send()
    }
    
    //Hint: - send Bio Change Request
    private func sendBioRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetBioRequest.Generator.generate(bio: current).success({ [weak self] (protoResponse) in
            SMLoading.hideLoadingPage()
            self?.canCallNextRequest = true
            DispatchQueue.main.async {
                switch protoResponse {
                case let userProfileSetBioResponse as IGPUserProfileSetBioResponse:
                    IGUserProfileSetBioRequest.Handler.interpret(response: userProfileSetBioResponse)
                default:
                    break
                }
                self?.lblBioTop.text = current
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            SMLoading.hideLoadingPage()
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    self?.canCallNextRequest = false
                    break
                default:
                    break
                }
            }
        }).send()
    }
    
    //Hint: - send Email Change Request
    private func sendEmailRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetEmailRequest.Generator.generate(userEmail: current).success({ [weak self] (protoResponse) in
            SMLoading.hideLoadingPage()
            self?.canCallNextRequest = true
            
            DispatchQueue.main.async {
                switch protoResponse {
                case let setUserEmailProtoResponse as IGPUserProfileSetEmailResponse:
                    IGUserProfileSetEmailRequest.Handler.interpret(response: setUserEmailProtoResponse)
                    
                default:
                    break
                }
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    self?.canCallNextRequest = false
                    break
                default:
                    break
                }
            }
        }).send()
    }
    
    //Hint: - send Referral Change Request
    private func sendReferralRequest(current: String!) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetRepresentativeRequest.Generator.generate(phone: current).success({ [weak self] (protoResponse) in
            SMLoading.hideLoadingPage()
            self?.canCallNextRequest = true
            if let response = protoResponse as? IGPUserProfileSetRepresentativeResponse {
                IGUserProfileSetRepresentativeRequest.Handler.interpret(response: response)
            }

        }).error ({ [weak self] (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    self?.canCallNextRequest = false
                    break
                default:
                    break
                }
            }
        }).send()
    }
    //Hint: - send gender Change Request
    private func sendGenderRequest(current: IGPGender.RawValue) {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGUserProfileSetGenderRequest.Generator.generate(gender: IGPGender(rawValue: current)!).success({ [weak self] (protoResponse) in
            SMLoading.hideLoadingPage()
            DispatchQueue.main.async {
                let userId = IGAppManager.sharedManager.userID()
                let gender: IGPGender = IGPGender(rawValue: current)!
                IGFactory.shared.updateProfileGender(userId!, igpGender: gender)
            }
            self?.canCallNextRequest = true
        }).error ({ [weak self] (errorCode, waitTime) in
            DispatchQueue.main.async {
                SMLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    self?.canCallNextRequest = false
                    break
                default:
                    break
                }
            }
        }).send()
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor

    }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
    
    @objc func segueToChatNotificationReceived(_ aNotification: Notification) {
        if let roomId = aNotification.userInfo?["room"] as? Int64 {
            IGGlobal.prgShow()
            IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                        SwiftEventBus.postToMainThread(EventBusManager.openRoom, sender: roomId)
                    }
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
            }).send()
        }
    }
    
    @IBAction func cameraButtonClick(_ sender: UIButton) {
        choosePhotoActionSheet(sender: btnCamera)
    }
    
    func choosePhotoActionSheet(sender : UIButton){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: IGStringsManager.Camera.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.photo])
        })
        
        let ChoosePhoto = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.library])
        })
        
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func pickImage(screens: [YPPickerScreen]){
        IGHelperAvatar.shared.pickAndUploadAvatar(roomId: userInDb.id, type: .user, screens: screens) { [weak self] (file) in
            DispatchQueue.main.async {
                if let image = file.attachedImage {
                    self?.userAvatarView?.avatarImageView?.image = image
                } else {
                    self?.userAvatarView?.avatarImageView?.setAvatar(avatar: file)
                }
            }
        }
    }
    
}


//MARK: SEARCH BAR DELEGATE
extension IGProfileTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        /*
        IGGlobal.heroTabIndex = (self.tabBarController?.selectedIndex)!
        (searchBar.value(forKey: "cancelButton") as? UIButton)?.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
        let lookAndFind = UIStoryboard(name: "IGSettingStoryboard", bundle: nil).instantiateViewController(withIdentifier: "IGLookAndFind")
        lookAndFind.hero.isEnabled = true
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .fade
        self.hero.replaceViewController(with: lookAndFind)
        */
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
    }
}

extension IGProfileTableViewController : IGRegistrationStepSelectCountryTableViewControllerDelegate {
    func didSelectCountry(country: IGCountryInfo) {
        self.setSelectedCountry(country)
    }
}
