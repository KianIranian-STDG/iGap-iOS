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
    @IBOutlet weak var btnName: UIButton!
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
    @IBOutlet weak var userAvatarView: IGAvatarView!
    
    @IBOutlet weak var btnCamera: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        //        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func initView() {
        colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: (self.navigationController?.navigationBar.frame.width)!, height: UIApplication.shared.statusBarFrame.height)
        colorView.backgroundColor = UIColor(patternImage: gradientImage(withColours: orangeGradient, location: orangeGradientLocation, view: colorView).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: colorView.frame.size.width/2, bottom: 0, right: colorView.frame.size.width/2), resizingMode: .stretch))
        btnCamera.setBackgroundImage(UIImage(named: "IG_Settings_Camera"), for: .normal)
        
        
        self.view.insertSubview(colorView, at: 0)
        
        viewBackgroundImage.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMinXMaxYCorner], radius: 10)
        viewBackgroundImage.clipsToBounds = true
        initChangeLang()
        requestToGetAvatarList()
        getScore()
        USERinDB()
    }
    func initChangeLang() {
        if SMLangUtil.loadLanguage() == "fa" {
            lblChoosenLanguage.text = "SETTING_CHL_PERSIAN".localizedNew
        }
        else {
            lblChoosenLanguage.text = "SETTING_CHL_ENGLISH".localizedNew
        }
        btnName.setTitle("NAME".localizedNew, for: .normal)
        lblCloud.text = "MY_CLOUD".localizedNew
        lblSetting.text = "SETTING_VIEW".localizedNew
        lblNew.text = "NEW".localizedNew
        lblCredit.text = "CREDITS".localizedNew
        lblScore.text = "SETTING_PAGE_ACCOUNT_SCORE_PAGE".localizedNew
        lblMoneyAmount.text = "1254790".inRialFormat().inLocalizedLanguage() + "CURRENCY".localizedNew
        lblScoreAmount.text = "..."
        lblInviteF.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
        lblQR.text = "SETTING_PAGE_QRCODE_SCANNER".localizedNew
        lblNearby.text = "SETTING_NEARBY".localizedNew
        lblLanguage.text = "SETTING_PAGE_CHANGE_LANGUAGE".localizedNew
        lblFaq.text = "FAQ".localizedNew
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lblVersion.text = "SETTING_PAGE_FOOTER_VERSION".localizedNew + " \(version)".inLocalizedLanguage()
        }
        
        
    }
    func USERinDB() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first
        userAvatarView.setUser(userInDb, showMainAvatar: true)
        btnName.setTitle(userInDb.displayName, for: .normal)
        btnName.titleLabel?.font = UIFont.igFont(ofSize: 14)
        lblTel.text = String(userInDb.phone).inLocalizedLanguage()
        lblBio.text = (userInDb.bio)
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
    private func getScore(){
        IGUserIVandGetScoreRequest.Generator.generate().success({ (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self.lblScoreAmount.text = String(describing: response.igpScore).inRialFormat().inLocalizedLanguage()
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
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
        let offset = scrollView.contentOffset.y
        if(offset > -UIApplication.shared.statusBarFrame.height){
            colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: (self.navigationController?.navigationBar.frame.width)!, height: UIApplication.shared.statusBarFrame.height)
            
        }else{
            colorView.frame = CGRect(x: 0, y: -UIApplication.shared.statusBarFrame.height, width: (self.navigationController?.navigationBar.frame.width)!, height: UIApplication.shared.statusBarFrame.height)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8
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
                break
                
            default:
                break
            }
            
        }
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
    
}
