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
import Contacts
import RealmSwift
import IGProtoBuff
import MBProgressHUD
import NVActivityIndicatorView
///import INSPhotoGallery

class IGRegistredUserInfoTableViewController: BaseTableViewController , NVActivityIndicatorViewable {

    var user: IGRegisteredUser?
    var previousRoomId: Int64?
    var room: IGRoom?
    var hud = MBProgressHUD()
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    var avatarPhotos : [INSPhotoViewable]?
    var galleryPhotos: INSPhotosViewController?
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var blockContactLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var viewBG: UIView!

    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblSend: UILabel!
    @IBOutlet weak var lblBlock: UILabel!
    @IBOutlet weak var lblConvert: UILabel!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var lblClearCache: UILabel!
    @IBOutlet weak var lblInchatSearch: UILabel!
    @IBOutlet weak var lblSharedMedia: UILabel!
    @IBOutlet weak var lblNotifications: UILabel!

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var widthConstraints: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = CAGradientLayer()
        
        gradient.frame = viewBG.frame
        gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = orangeGradientLocation as [NSNumber]

        viewBG.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))


        if user != nil {
            requestToGetAvatarList()
            self.avatarView.setUser(user!, showMainAvatar: true)
            self.displayNameLabel.text = user!.displayName
            if let phone = user?.phone {
                if phone == 0 {
                    self.phoneNumberLabel.text = "HIDDEN".localizedNew
                } else {
                    self.phoneNumberLabel.text = "\(phone)".inLocalizedLanguage()
                }
            }
            self.usernameLabel.text = user!.username
            if let bio = user!.bio {
                self.bioLabel.text = bio
            } else {
                self.bioLabel.text = ""
            }
        }
        if let selectedUser = user {
        let blockedUserPredicate = NSPredicate(format: "id = %lld", selectedUser.id)
            if let blockedUser = try! Realm().objects(IGRegisteredUser.self).filter(blockedUserPredicate).first {
                print(blockedUser.displayName)
                   if blockedUser.isBlocked == true {
                       blockContactLabel.text = "UNBLOCK".localizedNew
                   }
            }
        }
        avatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        avatarView.avatarImageView?.addGestureRecognizer(tap)
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
//        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: "CONTACT_INFO".localizedNew)
//        navigaitonItem.setNavigationBarForProfileRoom(room!)

//        if !isBotRoom() && IGAppManager.sharedManager.userID() != user?.id && !IGCall.callPageIsEnable && (room == nil || (!(room?.isReadOnly)!))  {
//            navigaitonItem.addModalViewRightItem(title: "", iGapFont: true)
//            navigaitonItem.rightViewContainer?.addAction {
//                DispatchQueue.main.async {
//                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: (self.user?.id)!, isIncommmingCall: false)
//                }
//            }
//        }
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        self.tableView.contentInset = UIEdgeInsets(top: (navigationController.navigationBar.frame.height) * -1,left: 0,bottom: 0,right: 0);

        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPageName = "iGap.IGRegistredUserInfoTableViewController"
        self.tableView.isUserInteractionEnabled = true
        lblName.text = "PLACE_HOLDER_L_NAME".localizedNew
        blockContactLabel.text = "BLLOCK_CONTACT".localizedNew
        lblPhone.text = "POD_TELPHONE".localizedNew
        lblUsername.text = "FIELD_USERNAME".localizedNew
        lblBio.text = "SETTING_PAGE_ACCOUNT_BIO".localizedNew
        lblSend.text = "PU_SENDMSG".localizedNew
        lblConvert.text = "CONVERT_CHAT_TO_GROUP".localizedNew
        lblDelete.text = "DELETE_CHAT".localizedNew
        lblClearCache.text = "CLEAR_HISTORY".localizedNew
        lblInchatSearch.text = "IN_CHAT_SEARCH".localizedNew
        lblNotifications.text = "NOTIFICATIONS".localizedNew
        lblSharedMedia.text = "SHAREDMEDIA".localizedNew

        let navigationControllerr = self.navigationController as! IGNavigationController
//                navigationControllerr.navigationBar.isHidden = true
        navigationControllerr.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationControllerr.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationControllerr.navigationBar.backgroundColor = .clear
        navigationControllerr.navigationBar.isTranslucent = true
        //Hint:- Only hides the gradient background View

        for view in navigationControllerr.navigationBar.subviews {
            if view.tag == 10001 {
                view.isHidden = true
                print("FOUND IT")
            }
        }


    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController

        navigationControllerr.navigationBar.backgroundColor = .clear
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

    private func isBotRoom() -> Bool{
        return (user?.isBot)!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            if isCloud() { // hide block contact for mine profile
                return 2
            }
            
            if isBotRoom() {
                return 1
            }
            
            return 3
        case 2:
            if IGHelperPromote.isPromotedRoom(userId: (user?.id)!) {
                return 0
            }
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCloud() && indexPath.section == 1 { // hide block contact for mine profile
            if indexPath.row == 1 {
                return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: 1))
            }
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if (user?.isInContacts)! && indexPath.row == 0 {
                let alert = UIAlertController(title: "BTN_EDITE_CONTACT".localizedNew, message: nil, preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.placeholder = "PLACE_HOLDER_F_NAME".localizedNew
                    textField.text = String(describing: (self.user?.firstName)!)
                }
                
                alert.addTextField { (textField) in
                    textField.placeholder = "PLACE_HOLDER_L_NAME".localizedNew
                    textField.text = String(describing: (self.user?.lastName)!)
                }
                
                alert.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { [weak alert] (_) in
                    let firstname = alert?.textFields![0]
                    let lastname = alert?.textFields![1]
                    
                    if firstname?.text != nil && !(firstname?.text?.isEmpty)! {
                        self.contactEdit(phone: (self.user?.phone)!, firstname: (firstname?.text)!, lastname: (lastname?.text)!)
                    } else {
                        let alert = UIAlertController(title: "BTN_HINT".localizedNew, message: "MSG_PLEASE_ENTER_F_NAME".localizedNew, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
            } else if indexPath.row == 3 {
                if let bio = user?.bio {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "SETTING_PAGE_ACCOUNT_BIO".localizedNew, message: bio, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                createChat()
                break
                
            case 1:
                
                if isCloud() {
                    self.tableView.isUserInteractionEnabled = false
                    self.performSegue(withIdentifier: "showCreateGroupPage", sender: self)
                    break
                }
                
                if let selectedUser = user {
                    if selectedUser.isBlocked == true {
                        unblockedContact()
                    } else if selectedUser.isBlocked == false {
                        blockedContact()
                    }
                }
                break
                
            case 2:
                self.tableView.isUserInteractionEnabled = false
                self.performSegue(withIdentifier: "showCreateGroupPage", sender: self)
                break
                
            default:
                break
            }
        } else if indexPath.section == 2 && indexPath.row == 0 {
            showDeleteActionSheet()
        } else if indexPath.section == 3 && indexPath.row == 0 {
            showClearHistoryActionSheet()
        }
    }
    
    private func contactEdit(phone: Int64, firstname: String, lastname: String?){
        IGGlobal.prgShow(self.view)
        IGUserContactsEditRequest.Generator.generate(phone: phone, firstname: firstname, lastname: lastname).success({ (protoResponse) in
            
            if let contactEditResponse = protoResponse as? IGPUserContactsEditResponse {
                IGUserContactsEditRequest.Handler.interpret(response: contactEditResponse)
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    self.displayNameLabel.text = contactEditResponse.igpFirstName + " " + contactEditResponse.igpLastName
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
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
    
    func requestToGetAvatarList() {
        if let currentUserId = user?.id {
            IGUserAvatarGetListRequest.Generator.generate(userId: currentUserId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let UserAvatarGetListoResponse as IGPUserAvatarGetListResponse:
                        let responseAvatars = IGUserAvatarGetListRequest.Handler.interpret(response: UserAvatarGetListoResponse, userId: currentUserId)
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

    
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = user?.avatar {
                showAvatar(avatar: userAvatar)
            }
        }
    }
    

    func showAvatar(avatar : IGAvatar) {
        var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
            return IGMedia(avatar: avatar)
        }
        
        if(photos.count == 0){
            return
        }
        
        avatarPhotos = photos
        let currentPhoto = photos[0]
        let downloadIndicatorMainView = UIView()
        let downloadViewFrame = self.view.bounds
        downloadIndicatorMainView.backgroundColor = UIColor.white
        downloadIndicatorMainView.frame = downloadViewFrame
        let andicatorViewFrame = CGRect(x: view.bounds.midX, y: view.bounds.midY,width: 50 , height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame,type: NVActivityIndicatorType.audioEqualizer)
        downloadIndicatorMainView.addSubview(activityIndicatorView)
        
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: avatarView)//, deleteView: deleteView, downloadView: downloadIndicatorMainView)
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            return self?.avatarView
        }
        galleryPhotos = galleryPreview
        present(galleryPreview, animated: true, completion: nil)
        activityIndicatorView.startAnimating()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
    }
    
    
    
    
    func setThumbnailForAttachments() {
        /*
        if let attachment = self.userAvatar?.file {
            self.currentPhoto.isHidden = false
        }
        */
    }
    
    
    func didTapOnTrashButton() {
//        timer.invalidate()
//        let thisPhoto = galleryPhotos?.accessCurrentPhotoDetail()
//        if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
//            let thisAvatarId = self.avatars[index].id
//            IGUserAvatarDeleteRequest.Generator.generate(avatarID: thisAvatarId).success({ (protoResponse) in
//                DispatchQueue.main.async {
//                    switch protoResponse {
//                    case let userAvatarDeleteResponse as IGPUserAvatarDeleteResponse :
//                        IGUserAvatarDeleteRequest.Handler.interpret(response: userAvatarDeleteResponse)
//                        self.avatarPhotos?.remove(at: index)
//                        self.scheduledTimerWithTimeInterval()
//                    default:
//                        break
//                    }
//                }
//            }).error ({ (errorCode, waitTime) in
//                self.timer.invalidate()
//                self.scheduledTimerWithTimeInterval()
//
//                switch errorCode {
//                case .timeout:
//                    DispatchQueue.main.async {
//                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
//                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alert.addAction(okAction)
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                default:
//                    break
//                }
//
//            }).send()
//
//        }
    }

    
    
    func createChat() {
        if let selectedUser = user {
            let hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
            hud.mode = .indeterminate
            IGChatGetRoomRequest.Generator.generate(peerId: selectedUser.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let chatGetRoomResponse as IGPChatGetRoomResponse:
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        
                        //segue to created chat
                        if roomId == self.previousRoomId {
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            //segue
                            IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    switch protoResponse {
                                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                        let room = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let roomVC = storyboard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
                                        roomVC.room = room
                                        self.navigationController!.pushViewController(roomVC, animated: true)
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
                        hud.hide(animated: true)
                        break
                    default:
                        break
                    }
                }
                
            }).error({ (errorCode, waitTime) in
                hud.hide(animated: true)
                let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                alertC.addAction(cancel)
                self.present(alertC, animated: true, completion: nil)
            }).send()
        }
        
    }
    
    func blockedContact() {
        if let selectedUser = user {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGUserContactsBlockRequest.Generator.generate(blockedUserId: selectedUser.id).success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let blockedProtoResponse as IGPUserContactsBlockResponse:
                        let _ = IGUserContactsBlockRequest.Handler.interpret(response: blockedProtoResponse)
                        self.blockContactLabel.text = "UNBLOCK".localizedNew
                        self.hud.hide(animated: true)
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
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
    
    func unblockedContact() {
        if let selectedUser = user {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGUserContactsUnBlockRequest.Generator.generate(unBlockedUserId: selectedUser.id).success({
                (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let unBlockedProtoResponse as IGPUserContactsUnblockResponse:
                        _ = IGUserContactsUnBlockRequest.Handler.interpret(response: unBlockedProtoResponse)
                        self.blockContactLabel.text = "BLLOCK_CONTACT".localizedNew
                        self.hud.hide(animated: true)
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
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
            }).send()
        }
    }
    
    func showDeleteActionSheet() {
        let deleteChatConfirmAlertView = UIAlertController(title: "MSG_SURE_TO_DELETE_CHAT".localizedNew, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "BTN_DELETE".localizedNew, style:.default , handler: { (alert: UIAlertAction) -> Void in
            if let chatRoom = self.room {
                self.deleteChat(room: chatRoom)
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        deleteChatConfirmAlertView.addAction(deleteAction)
        deleteChatConfirmAlertView.addAction(cancelAction)
        let alertActions = deleteChatConfirmAlertView.actions
        for action in alertActions {
            if action.title == "BTN_DELETE".localizedNew{
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        deleteChatConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = deleteChatConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(deleteChatConfirmAlertView, animated: true, completion: nil)
    }
    
    func deleteChat(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChatDeleteRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteChat as IGPChatDeleteResponse:
                    IGChatDeleteRequest.Handler.interpret(response: deleteChat)
                    if self.navigationController is IGNavigationController {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                }
                break
            }
            
        }).send()
    }
    
    func showClearHistoryActionSheet() {
        let clearChatConfirmAlertView = UIAlertController(title: "MSG_SURE_TO_DELETE_CHAT_HISTORY".localizedNew, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: "CLEAR_HISTORY".localizedNew, style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if let chatRoom = self.room {
                self.clearChatMessageHistory(room: chatRoom)
            }
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        clearChatConfirmAlertView.addAction(deleteAction)
        clearChatConfirmAlertView.addAction(cancelAction)
        let alertActions = clearChatConfirmAlertView.actions
        for action in alertActions {
            if action.title == "CLEAR_HISTORY".localizedNew {
                let logoutColor = UIColor.red
                action.setValue(logoutColor, forKey: "titleTextColor")
            }
        }
        clearChatConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = clearChatConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(clearChatConfirmAlertView, animated: true, completion: nil)
    }
    
    func clearChatMessageHistory(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChatClearMessageRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let clearChatMessages as IGPChatClearMessageResponse:
                    IGChatClearMessageRequest.Handler.interpret(response: clearChatMessages)
                    if self.navigationController is IGNavigationController {
                        self.navigationController?.popViewController(animated: true)
                    }
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
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
                DispatchQueue.main.async {
                    self.hud.hide(animated: true)
                }
                break
            }
            
        }).send()
    }

    func isCloud() -> Bool{
        if user != nil {
            return user?.id == IGAppManager.sharedManager.userID()
        }
        return false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
        destination.mode = "ConvertChatToGroup"
        destination.roomID = previousRoomId
        let tmp = user
        destination.baseUser = user
    }
    private var lastContentOffset: CGFloat = 0
    private var hasScaledDown: Bool = false

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Hint:- status bar default height * -1
        let tmpOffset = (UIApplication.shared.statusBarFrame.height) * -1
        let minHeight = (self.navigationController?.navigationBar.frame.size.height ?? 44) + (UIApplication.shared.statusBarFrame.height)
        print(scrollView.contentOffset.y)
        //Hint:- this line is responsible for checking if user was scrolling Up,then maximise height of viewBG
        //and prevent user avatar image to scroll with scrollview
        
        // user scrolled Up

        if scrollView.contentOffset.y > minHeight {
            //Hint:- the value is for adding to Height
            let tmpDiff = (scrollView.contentOffset.y) - minHeight

            viewBG.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 127 + tmpDiff )
        }
        if scrollView.contentOffset.y >= 53 && scrollView.contentOffset.y <= 66 {
            if !hasScaledDown {
                let scrollOffset = (scrollView.contentOffset.y)
                let tmpDiff = (scrollOffset) - minHeight
                print(tmpDiff)

    //            avatarView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

                let originalTransform = avatarView.transform
                let scaledTransform = originalTransform.scaledBy(x: 0.35, y: 0.35)
                let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 70, y: -70)
                UIView.animate(withDuration: 0.7, animations: {
                    self.avatarView.transform = scaledAndTranslatedTransform
                    self.hasScaledDown = true
                    self.avatarView.translatesAutoresizingMaskIntoConstraints = false
                    if #available(iOS 11.0, *) {
                        self.avatarView.removeConstraint(self.bottomConstraint)

                        self.avatarView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
                        self.avatarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
                    } else {
                        self.avatarView.rightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor, constant: 0).isActive = true
                        self.avatarView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 10).isActive = true
                    }

                }, completion: {finished in
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        //UIView.animate(withDuration: 0.5, animations: {
//                            let navigaitonItem = self.navigationItem as! IGNavigationItem
//                            navigaitonItem.setNavigationBarForRoom(self.room!)
//                        })
//                        self.avatarView.isHidden = true
                    })
                }
                )

            }
            
        }
        if scrollView.contentOffset.y >= 62 {
        }

        
        // user scrolled Down

        if scrollView.contentOffset.y <= CGFloat(tmpOffset) {
            scrollView.contentOffset.y = CGFloat(tmpOffset)
        }

    }
}
