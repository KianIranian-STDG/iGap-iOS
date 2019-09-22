//
//  IGProfileChannelViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/22/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SwiftProtobuf
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import IGProtoBuff
import MGSwipeTableCell
import MBProgressHUD
import NVActivityIndicatorView

class IGProfileChannelViewController: BaseViewController , NVActivityIndicatorViewable,UITableViewDelegate,UITableViewDataSource {

    //MARK: -Variables
    var isVerified : Bool! = false
    var maxNavHeight : CGFloat = 144
    var avatarPhotos : [INSPhotoViewable]?
    var galleryPhotos: INSPhotosViewController?
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    var isFistLaunch : Bool! = true
    var channelLink: String? = ""
    let headerViewMaxHeight: CGFloat = 144
    let headerViewMinHeight: CGFloat = 44 + UIApplication.shared.statusBarFrame.height
    var originalTransform : CGAffineTransform!
    private var lastContentOffset: CGFloat = 0
    private var hasScaledDown: Bool = false

    var selectedChannel : IGChannelRoom?
    private let disposeBag = DisposeBag()
    var room : IGRoom?
    var hud = MBProgressHUD()
    var allMember = [IGChannelMember]()
    var myRole : IGChannelMember.IGRole!
    var signMessageIndexPath : IndexPath?
    var channelLinkIndexPath : IndexPath?
    var imagePicker = UIImagePickerController()
    var notificationToken: NotificationToken?
    var connectionStatus: IGAppManager.ConnectionStatus?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?

    //MARK: -Outlets
    @IBOutlet weak var channelNameLabelTitle: UILabel!
    @IBOutlet weak var channelImage: IGAvatarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var channelUserCountLabel: UILabel!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewBG: UIView!

    //MARK: -ViewController Initialisers
    override func viewDidLoad() {
        super.viewDidLoad()

        channelNameLabelTitle.font = UIFont.igFont(ofSize: 17,weight: .bold)
        channelUserCountLabel.font = UIFont.igFont(ofSize: 17,weight: .bold)
        channelNameLabelTitle.textColor = .white
        channelUserCountLabel.textColor = .white

        initGradientView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        maxNavHeight = self.heightConstraints.constant
        originalTransform = self.channelImage.transform
        tableView.contentInset = UIEdgeInsets(top: maxNavHeight, left: 0, bottom: 0, right: 0)
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.setNavigationBarForProfileRoom(room!)
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        

        requestToGetAvatarList()
        imagePicker.delegate = self
        signMessageIndexPath = IndexPath(row: 2, section: 1)
     
        tableView.tableFooterView = UIView()
        
        let predicate = NSPredicate(format: "id = %lld", (room?.id)!)
        room =  try! Realm().objects(IGRoom.self).filter(predicate).first!
        self.notificationToken = room?.observe({ (objectChange) in
            self.showChannelInfo()
        })
        
        channelImage.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        channelImage.avatarImageView?.addGestureRecognizer(tap)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestToGetRoom()

        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationControllerr.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationControllerr.interactivePopGestureRecognizer?.delegate = self
        
        navigationControllerr.navigationBar.isTranslucent = true
        //Hint:- Only hides the gradient background View
        for view in navigationControllerr.navigationBar.subviews {
            if view.tag == 10001 {
                view.isHidden = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        
        navigationControllerr.navigationBar.backgroundColor = .clear
        navigationControllerr.navigationBar.setBackgroundImage(nil, for: .default)
        navigationControllerr.navigationBar.isTranslucent = false
        //Hint:- Only shows the gradient background View
        
        for view in navigationControllerr.navigationBar.subviews {
            if view.tag == 10001 {
                view.isHidden = false
                print("FOUND IT")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    //MARK: -Development functions
    func initGradientView() {
        let gradient = CAGradientLayer()
        gradient.frame = viewBG.frame
        gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = orangeGradientLocation as [NSNumber]
        viewBG.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = room?.channelRoom?.avatar {
                showAvatar( avatar: userAvatar)
            }
        }
    }
    func showAvatar(avatar : IGAvatar) {
        var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
            return IGMedia(avatar: avatar)
        }
        if(photos.count==0){
            return
        }
        avatarPhotos = photos
        let currentPhoto = photos[0]
        
        let downloadIndicatorMainView = UIView()
        let downloadViewFrame = self.view.bounds
        downloadIndicatorMainView.backgroundColor = UIColor.white
        downloadIndicatorMainView.frame = downloadViewFrame
        let andicatorViewFrame = CGRect(x: view.bounds.midX, y: view.bounds.midY,width: 50 , height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame,
                                                            type: NVActivityIndicatorType.audioEqualizer)
        downloadIndicatorMainView.addSubview(activityIndicatorView)
        
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: channelImage)//, deleteView: deleteView, downloadView: downloadIndicatorMainView)
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            return self?.channelImage
        }
        galleryPhotos = galleryPreview
        present(galleryPreview, animated: true, completion: nil)
        activityIndicatorView.startAnimating()
        
    }
    
    func didTapOnTrashButton() {
    }
    
    
    func requestToGetAvatarList() {
        if let currentRoomID = room?.id {
            IGChannelAvatarGetListRequest.Generator.generate(roomId: currentRoomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelAvatarGetListResponse as IGPChannelAvatarGetListResponse:
                        let responseAvatars = IGChannelAvatarGetListRequest.Handler.interpret(response: channelAvatarGetListResponse)
                        self.avatars = responseAvatars
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
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
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
    }
    
    
    @IBAction func didTapOnCameraBtn(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: "TAKE_A_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take a Photo")
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
            print("Choose Photo")
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
            print("Cancelled")
        })
        
        if self.avatars.count > 0  && (myRole == .owner || myRole == .admin) {
            optionMenu.addAction(deleteAction)
        }
        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
            print ("I don't have a camera.")
        }
        if let popoverController = optionMenu.popoverPresentationController {
//            popoverController.sourceView = cameraButton
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    /*
     * this method will be deleted main(latest) avatar
     */
    func deleteAvatar(){
        let avatar = self.avatars[0]
        IGChannelAvatarDeleteRequest.Generator.generate(avatarId: avatar.id, roomId: (room?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let channelAvatarDeleteResponse as IGPChannelAvatarDeleteResponse :
                    IGChannelAvatarDeleteRequest.Handler.interpret(response: channelAvatarDeleteResponse)
                    self.avatarPhotos?.remove(at: 0)
                    self.avatars.remove(at: 0)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    func showDeleteChannelActionSheet() {
        var title : String!
        var actionTitle: String!
        if myRole == .owner {
            title = "MSG_SURE_TO_DELETE_CHANNEL".localizedNew
            actionTitle = "BTN_DELETE".localizedNew
        } else {
            title = "MSG_SURE_TO_LEAVE_CHANNEL".localizedNew
            actionTitle = "LEAVE".localizedNew
        }
        let deleteConfirmAlertView = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: actionTitle , style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if self.myRole == .owner {
                if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                    let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "NO_NETWORK".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.deleteChannelRequest()
                }
            } else {
                if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                    let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "NO_NETWORK".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.leftChannelRequest(room: self.room!)
                }
            }
            
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteConfirmAlertView.addAction(deleteAction)
        deleteConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteConfirmAlertView.actions
        for action in alertActions {
            if action.title == actionTitle{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteConfirmAlertView, animated: true, completion: nil)
    }
    
    func showChannelLinkAlert() {
        if selectedChannel != nil {
            if room?.channelRoom?.type == .privateRoom {
                channelLink = room?.channelRoom?.privateExtra?.inviteLink
            }
            if room?.channelRoom?.type == .publicRoom {
                channelLink = room?.channelRoom?.publicExtra?.username
            }
            
            let alert = UIAlertController(title: "CHANNEL_LINK".localizedNew, message: channelLink, preferredStyle: .alert)
            let copyAction = UIAlertAction(title: "COPY".localizedNew, style: .default, handler: { (alert: UIAlertAction) -> Void in
                UIPasteboard.general.string = self.channelLink
            })
            
            let shareAction = UIAlertAction(title: "SHARE".localizedNew, style: .default, handler: { (alert: UIAlertAction) -> Void in
                IGHelperPopular.shareText(message: IGHelperPopular.shareLinkPrefixChannel + "\n" + self.channelLink!, viewController: self)
            })
            
            let changeAction = UIAlertAction(title: "CHNAGE".localizedNew, style: .default, handler: { (alert: UIAlertAction) -> Void in
                if self.room?.channelRoom?.type == .publicRoom {
                    self.performSegue(withIdentifier: "showChannelInfoSetType", sender: self)
                }
                else if self.room?.channelRoom?.type == .privateRoom {
                    self.requestToRevolLink()
                }
            })
            
            let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
            
            alert.view.tintColor = UIColor.organizationalColor()
            alert.addAction(copyAction)
            alert.addAction(shareAction)
            if  myRole == .owner {
                alert.addAction(changeAction)
            }
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showChannelInfo(){
        
        if (room?.isInvalidated)! {
            return
        }
        
        if (room?.channelRoom?.isVerified)! {
            isVerified = true
        } else {
            isVerified = false
        }
        
        channelNameLabelTitle.text = room?.title
        channelNameLabelTitle.textAlignment = channelNameLabelTitle.localizedNewDirection
//        channelNameLabel.text = room?.title
//        ChannelDescriptionLabel.text = room?.channelRoom?.roomDescription
        if let channelRoom = room {
            channelImage.setRoom(channelRoom, showMainAvatar: true)
        }
        if let channelType = room?.channelRoom?.type {
            switch channelType {
            case .privateRoom:
//                channelTypeLabel.text = "PRIVATE".localizedNew
                if let link = room?.channelRoom?.privateExtra?.inviteLink  {
                    channelLink = link
                }
            case .publicRoom:
//                channelTypeLabel.text = "PUBLIC".localizedNew
                if let username = room?.channelRoom?.publicExtra?.username {
                    channelLink = "iGap.net/" + username

                }
            }
            myRole = room?.channelRoom?.role

            self.tableView.reloadData()
        }
        
        if let memberCount = room?.channelRoom?.participantCount {
            channelUserCountLabel.text = "\(memberCount)".inLocalizedLanguage() + "MEMBER".localizedNew
            channelUserCountLabel.textAlignment = channelUserCountLabel.localizedNewDirection
            
        }
        
        if room?.channelRoom?.isSignature == true {
//            signMessageSwtich.isOn = true
        } else {
//            signMessageSwtich.isOn = false
        }
        
        if room?.channelRoom?.hasReaction == true {
//            channelReactionSwitch.isOn = true
        } else {
//            channelReactionSwitch.isOn = false
        }
    }
    
    
    func requestToGetRoom() {
        if let channelRoom = room {
            IGClientGetRoomRequest.Generator.generate(roomId: channelRoom.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                        
                    default:
                        break
                    }
                    self.showChannelInfo()

                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func requestToUpdateChannelSignature(_ signatureSwitchStatus: Bool) {
        if let channelRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelUpdateSignatureRequest.Generator.generate(roomId: channelRoom.id, signatureStatus: signatureSwitchStatus).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelUpdateSignatureResponse as IGPChannelUpdateSignatureResponse:
                        let _ = IGChannelUpdateSignatureRequest.Handler.interpret(response: channelUpdateSignatureResponse)
                    default:
                        break
                    }
                    self.hud.hide(animated: true)
                }
            }).error ({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
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
    
    func requestToUpdateChannelReaction(_ reactionSwitchStatus: Bool) {
        if let channelRoom = room {
            IGGlobal.prgShow(self.view)
            IGChannelUpdateReactionStatusRequest.sendRequest(roomId: channelRoom.id, reactionStatus: reactionSwitchStatus)
        }
    }
    
    func requestToRevolLink() {
        
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChannelRevokeLinkRequest.Generator.generate(roomId: (room?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let channelRevokeLinkRequest as IGPChannelRevokeLinkResponse:
                    let revokeResponse = IGChannelRevokeLinkRequest.Handler.interpret(response: channelRevokeLinkRequest)
//                    self.channelLinkLabel.text = revokeResponse.invitedLink
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func leftChannelRequest(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChannelLeftRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let channelLeft as IGPChannelLeftResponse:
                    IGChannelLeftRequest.Handler.interpret(response: channelLeft)
                    if self.navigationController is IGNavigationController {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
                
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func deleteChannelRequest() {
        if let channelRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelDeleteRequest.Generator.generate(roomID: channelRoom.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelDeleteResponse as IGPChannelDeleteResponse:
                        let _ = IGChannelDeleteRequest.Handler.interpret(response: channelDeleteResponse)
                        if self.navigationController is IGNavigationController {
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                    default:
                        break
                    }
                    self.hud.hide(animated: true)
                    
                }
            }).error ({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
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
    
    //    func calculateHeight(inString:String) -> CGFloat {
    //
    //        let messageString = inString
    //        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)]
    //        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
    //        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
    //        let requredSize:CGRect = rect
    //        return requredSize.height
    //    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChannelInfoSetName" {
            let destination = segue.destination as! IGChannelInfoEditNameTableViewController
            destination.room = room
        }
        if  segue.identifier == "showChannelInfoSetDescription" {
            let destination = segue.destination as! IGChannelInfoEditDescriptionTableViewController
            destination.room = room
        }
        
        if segue.identifier ==  "showChannelInfoSetType" {
            let destination = segue.destination as! IGChannelInfoEditTypeTableViewController
            destination.room = room
        }
        if segue.identifier == "showChannelInfoSetMembers" {
            let destination = segue.destination as! IGChannelInfoMemberListTableViewController
            destination.room = room
        }
        if segue.identifier == "showSharedMadiaPage" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        }
        if segue.identifier == "showAdminAndModarators" {
            let destination = segue.destination as! IGChannelInfoAdminsAndModeratorsTableViewController
            destination.room = room
        }
    }
    //MARK: -Actions


    //MARK: -Scroll View Delegate and DataSource
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y: CGFloat = maxNavHeight -  (scrollView.contentOffset.y + maxNavHeight)
        let height = min(max(y,headerViewMinHeight),headerViewMaxHeight)
        let range = height / headerViewMaxHeight
        heightConstraints.constant = height
        heightConstraints.constant = height
        let scaledTransform = originalTransform.scaledBy(x: max(0.7,range), y: max(0.7,range))
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.channelImage.transform = scaledAndTranslatedTransform
            self.hasScaledDown = true
        })
        //        let newHeaderViewHeight: CGFloat = heightConstraints.constant - y
        
        self.view.layoutIfNeeded()
        
    }
    // MARK: -TableViewDelegates and Datasource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGProfileUserCell", for: indexPath as IndexPath) as! IGProfileUserCell
        let cellTwo = tableView.dequeueReusableCell(withIdentifier: "IGProfileUSerCellTypeTwo", for: indexPath as IndexPath) as! IGProfileUSerCellTypeTwo
        let channelType = room?.channelRoom?.type

        switch channelType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    if room?.channelRoom?.type == .privateRoom {
                        cell.initLabels(nameLblString: "CHANNEL_LINK".localizedNew, detailLblString: channelLink, changeColor: false)

                    } else {
                        cell.initLabels(nameLblString: "FIELD_USERNAME".localizedNew, detailLblString: channelLink, changeColor: false)

                    }
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    case 1:
                        cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .member:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    case 1:
                        cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                case 2:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .moderator:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    case 1:
                        cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                case 2:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .owner:
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    
                    cell.initLabels(nameLblString: channelLink)
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    case 1:
                        cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            }
        case .publicRoom?:
            
            switch myRole {
            case .admin?:

                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    cell.initLabels(nameLblString: "FIELD_USERNAME".localizedNew, detailLblString: channelLink, changeColor: false)
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    case 1:
                        cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .member?:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    cell.initLabels(nameLblString: "FIELD_USERNAME".localizedNew, detailLblString: channelLink, changeColor: false)
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
     
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .moderator?:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    return cell
                    
                case 1:
                    cell.initLabels(nameLblString: "FIELD_USERNAME".localizedNew, detailLblString: channelLink, changeColor: false)
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .owner?:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.channelRoom?.roomDescription {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    cell.initLabels(nameLblString: "FIELD_USERNAME".localizedNew, detailLblString: channelLink, changeColor: false)
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                        return cellTwo
                        
                    case 1:
                        cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                        return cell
                    default:
                        return cell
                        
                    }
                default:
                    return cell
                }
            case .none:
                cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                return cell
            }
        case .none:
            
            switch indexPath.section {
            case 0:
                
                if let desc = room?.channelRoom?.roomDescription {
                    cell.initLabels(nameLblString: desc)
                } else {
                    cell.initLabels(nameLblString: "PRODUCTS_NO_DETAILS".localizedNew)
                }
                
                
                
                return cell
                
            case 1:
                cell.initLabels(nameLblString: "FIELD_USERNAME".localizedNew, detailLblString: channelLink, changeColor: false)

                return cell
            case 2:
                switch indexPath.row {
                case 0:
                    cellTwo.initLabels(nameLblString: "MUTE_NOTIFICATION_IN_PROFILE".localizedNew)
                    return cellTwo
                    
                case 1:
                    cell.initLabels(nameLblString: "NOTIFICATION_SOUNDS".localizedNew)
                    return cell
                    
                default:
                    return cell
                    
                }
            case 3:
                cell.initLabels(nameLblString: "SHAREDMEDIA".localizedNew)
                return cell
                
            case 4:
                switch indexPath.row {
                case 0 :
                    cell.initLabels(nameLblString: "ADD_MEMBER".localizedNew)
                    return cell
                    
                case 1 :
                    cell.initLabels(nameLblString: "ALLMEMBER".localizedNew)
                    return cell
                    
                default:
                    return cell
                    
                }
                
            case 5:
                switch indexPath.row {
                case 0 :
                    cell.initLabels(nameLblString: "CLEAR_HISTORY".localizedNew)
                    return cell
                    
                case 1 :
                    cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                    return cell
                    
                case 2 :
                    cell.initLabels(nameLblString: "LEAVE".localizedNew,changeColor: true)
                    return cell
                default:
                    return cell
                    
                }
            default:
                return cell
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let channelType = room?.channelRoom?.type {
            switch channelType {
            case .privateRoom:
                switch myRole! {
                case .admin:
                    return 6
                    
                    
                case .member:
                    return 5
                    
                case .moderator:
                    return 5
                    
                case .owner:
                    return 6
                    
                }
            case .publicRoom:

                switch myRole {
                case .admin?:
                    return 6
                    
                    
                case .member?:
                    return 5
                    
                case .moderator?:
                    return 5
                    
                case .owner?:
                    return 6
                    
                case .none:
                    return 5

                }
                
            }
        } else {
            return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let channelType = room?.channelRoom?.type
        switch channelType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2:
                    return 2
                case 3 :
                    return 1
                case 4 :
                    return 1
                case 5 :
                    return 1
                default:
                    return 0
                }
            case .owner:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2:
                    return 2
                case 3 :
                    return 1
                case 4 :
                    return 1
                case 5 :
                    return 1
                default:
                    return 0
                }
            case .member:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 2
                case 2:
                    return 1
                case 3 :
                    return 1
                case 4 :
                    return 1
                default:
                    return 0
                }
            case .moderator:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 2
                case 2:
                    return 1
                case 3 :
                    return 1
                case 4 :
                    return 1
                default:
                    return 0
                }
                
            }
        case .publicRoom?:
            

            switch myRole {
            case .admin?:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2:
                    return 2
                case 3 :
                    return 1
                case 4 :
                    return 1
                case 5 :
                    return 1
                default:
                    return 0
                }
            case .owner?:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2:
                    return 2
                case 3 :
                    return 1
                case 4 :
                    return 1
                case 5 :
                    return 1
                default:
                    return 0
                }
            case .member?:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2:
                    return 1
                case 3 :
                    return 1
                case 4 :
                    return 2
                default:
                    return 0
                }
            case .moderator?:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 2
                case 2:
                    return 1
                case 3 :
                    return 1
                case 4 :
                    return 2
                default:
                    return 0
                }
            case .none:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 2
                case 2:
                    return 1
                case 3 :
                    return 1
                case 4 :
                    return 1
                default:
                    return 0
                }
                
            }
                
        case .none:
            return 0

        }

    }
    
    //MARK: -Header and Footer
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedNewDirection
        switch section {
        default :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
            break
            
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let channelType = room?.channelRoom?.type
        switch channelType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch section {
                case 0:
                    return "PRODUCTS_DETAILS".localizedNew
                case 1:
                    return "CHANNEL_INFO".localizedNew
                case 2:
                    return "NOTIFICATION_SOUNDS".localizedNew
                case 3:
                    return "SHAREDMEDIA".localizedNew
                default:
                    return ""
                }
            case .owner:
                
                switch section {
                case 0:
                    return "PRODUCTS_DETAILS".localizedNew
                case 1:
                    return "CHANNEL_INFO".localizedNew
                case 2:
                    return "NOTIFICATION_SOUNDS".localizedNew
                case 3:
                    return "SHAREDMEDIA".localizedNew
                default:
                    return ""
                }
            case .member:
                
                switch section {
                case 0:
                    return "PRODUCTS_DETAILS".localizedNew
                case 1:
                    return "NOTIFICATION_SOUNDS".localizedNew
                case 2:
                    return "SHAREDMEDIA".localizedNew
                default:
                    return ""
                }
            case .moderator:
                
                switch section {
                case 0:
                    return "PRODUCTS_DETAILS".localizedNew
                case 1:
                    return "NOTIFICATION_SOUNDS".localizedNew
                case 2:
                    return "SHAREDMEDIA".localizedNew
                default:
                    return ""
                }
                
            }
        case .publicRoom?:
            
            switch section {
            case 0:
                return "PRODUCTS_DETAILS".localizedNew
            case 1:
                return "CHANNEL_INFO".localizedNew
            case 2:
                return "NOTIFICATION_SOUNDS".localizedNew
            case 3:
                return "SHAREDMEDIA".localizedNew
            default:
                return ""
            }
        case .none:
            switch section {
            case 0:
                return "PRODUCTS_DETAILS".localizedNew
            case 1:
                return "CHANNEL_INFO".localizedNew
            case 2:
                return "NOTIFICATION_SOUNDS".localizedNew
            case 3:
                return "SHAREDMEDIA".localizedNew
            default:
                return ""
            }        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let channelType = room?.channelRoom?.type
        switch channelType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch section {
                case 0:
                    return 60
                case 4:
                    return 10
                    
                case 5:
                    return 10
                    
                default:
                    return 50
                }
            case .owner:
                
                switch section {
                case 0:
                    return 60
                case 4:
                    return 10
                    
                case 5:
                    return 10
                    
                default:
                    return 50
                }
            case .member:
                
                switch section {
                case 0:
                    return 60
                case 3:
                    return 10
                    
                case 4:
                    return 10
                    
                default:
                    return 50
                }
            case .moderator:
                
                switch section {
                case 0:
                    return 60
                case 3:
                    return 10
                    
                case 4:
                    return 10
                    
                default:
                    return 50
                }
                
            }
        case .publicRoom?:
            
            switch section {
            case 0:
                return 60
            case 4:
                return 10
                
            case 5:
                return 10
                
            default:
                return 50
            }
        case .none:
            switch section {
            case 0:
                return 60
            case 4:
                return 10
                
            case 5:
                return 10
                
            default:
                return 50
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channelType = room?.channelRoom?.type
        switch channelType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch indexPath.section {
                case 0:
                    break
                case 1:
                    break
                case 2:
                    switch indexPath.row {
                    case 0 :
                        break
                    case 1 :
                        //gotToNotificationSettings
                        break
                    default:
                        break
                    }
                case 3:
                    //goToSharedMedia
                    self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
                    
                    break
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        //gotToAddMEmberPage
                        break
                    case 1 :
                        //gotToMemberListPage
                        self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
                        
                        break
                    default:
                        break
                        
                    }
                case 5:
                    
                    switch indexPath.row {
                    case 0 :
                        //ShowReportAlert
                        break
                    case 1 :
                        //ShowLeaveAlert
                        showDeleteChannelActionSheet()
                        
                        break
                    default:
                        break
                        
                    }
                default:
                    break
                }
            case .owner:
                
                switch indexPath.section {
                case 0:
                    break
                case 1:
                    break
                case 2:
                    switch indexPath.row {
                    case 0 :
                        break
                    case 1 :
                        //gotToNotificationSettings
                        break
                    default:
                        break
                    }
                case 3:
                    //goToSharedMedia
                    self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
                    
                    break
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        //gotToAddMEmberPage
                        break
                    case 1 :
                        //gotToMemberListPage
                        self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
                        
                        break
                    default:
                        break
                        
                    }
                case 5:
                    
                    switch indexPath.row {
                    case 0 :
                        //ShowReportAlert
                        break
                    case 1 :
                        //ShowLeaveAlert
                        showDeleteChannelActionSheet()
                        
                        break
                    default:
                        break
                        
                    }
                default:
                    break
                }
            case .member:
                
                switch indexPath.section {
                case 0:
                    break
                case 1:
                    switch indexPath.row {
                    case 0 :
                        break
                    case 1 :
                        //gotToNotificationSettings
                        break
                    default:
                        break
                    }
                case 2:
                    //goToSharedMedia
                    self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
                    
                    break
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        //gotToAddMEmberPage
                        break
                    case 1 :
                        //gotToMemberListPage
                        self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
                        
                        break
                    default:
                        break
                        
                    }
                case 4:
                    
                    switch indexPath.row {
                    case 0 :
                        //ShowReportAlert
                        break
                    case 1 :
                        //ShowLeaveAlert
                        showDeleteChannelActionSheet()
                        
                        break
                    default:
                        break
                        
                    }
                    
                default:
                    break
                }
            case .moderator:
                
                switch indexPath.section {
                case 0:
                    break
                case 1:
                    switch indexPath.row {
                    case 0 :
                        break
                    case 1 :
                        //gotToNotificationSettings
                        break
                    default:
                        break
                    }
                case 2:
                    //goToSharedMedia
                    self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
                    
                    break
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        //gotToAddMEmberPage
                        break
                    case 1 :
                        //gotToMemberListPage
                        self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
                        
                        break
                    default:
                        break
                        
                    }
                case 4:
                    
                    switch indexPath.row {
                    case 0 :
                        //ShowReportAlert
                        break
                    case 1 :
                        //ShowLeaveAlert
                        showDeleteChannelActionSheet()
                        
                        break
                    default:
                        break
                        
                    }
                default:
                    break
                }
                
            }
        case .publicRoom?:
            
            switch indexPath.section {
            case 0:
                break
            case 1:
                break
            case 2:
                switch indexPath.row {
                case 0 :
                    break
                case 1 :
                    //gotToNotificationSettings
                    break
                default:
                    break
                }
            case 3:
                //goToSharedMedia
                self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
                
                break
                
            case 4:
                switch indexPath.row {
                case 0 :
                    //gotToAddMEmberPage
                    break
                case 1 :
                    //gotToMemberListPage
                    self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
                    
                    break
                default:
                    break
                    
                }
            case 5:
                
                switch indexPath.row {
                case 0 :
                    //ShowReportAlert
                    break
                case 1 :
                    //ShowLeaveAlert
                    showDeleteChannelActionSheet()
                    
                    break
                default:
                    break
                    
                }
            default:
                break
            }
        case .none:
            
            break
            
        }
    }


}
extension IGProfileChannelViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            self.channelImage.setImage(pickedImage)
            
            let avatar = IGFile()
            avatar.attachedImage = pickedImage
            let randString = IGGlobal.randomString(length: 32)
            avatar.cacheID = randString
            avatar.name = randString
            
            IGUploadManager.sharedManager.upload(file: avatar, start: {
                
            }, progress: { (progress) in
                
            }, completion: { (uploadTask) in
                if let token = uploadTask.token {
                    IGChannelAddAvatarRequest.Generator.generate(attachment: token , roomID: (self.room?.id)!).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let avatarAddResponse as IGPChannelAvatarAddResponse:
                                _ = IGChannelAddAvatarRequest.Handler.interpret(response: avatarAddResponse)
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
}

extension IGProfileChannelViewController: UINavigationControllerDelegate {
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
