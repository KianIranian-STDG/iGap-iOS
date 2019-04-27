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
import INSPhotoGallery

class IGRegistredUserInfoTableViewController: BaseTableViewController , UIGestureRecognizerDelegate , NVActivityIndicatorViewable {

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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: "CONTACT_INFO".localizedNew)
        
        if !isBotRoom() && IGAppManager.sharedManager.userID() != user?.id && !IGCall.callPageIsEnable && (room == nil || (!(room?.isReadOnly)!))  {
            navigaitonItem.addModalViewRightItem(title: "", iGapFont: true)
            navigaitonItem.rightViewContainer?.addAction {
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: (self.user?.id)!, isIncommmingCall: false)
                }
            }
        }
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    }

    private func isBotRoom() -> Bool{
        return (user?.isBot)!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
//        let deleteViewFrame = CGRect(x:320, y:595, width: 25 , height:25)
//        let trashImageView = UIImageView()
//        trashImageView.image = UIImage(named: "IG_Trash_avatar")
//        trashImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
//        let currentUserID = IGAppManager.sharedManager.userID()
//        if let userID = user?.id {
//            if userID == currentUserID {
//                deleteView = IGTappableView(frame: deleteViewFrame)
//                deleteView?.addSubview(trashImageView)
//                deleteView?.addAction {
//                    self.didTapOnTrashButton()
//                }
//
//            } else {
//                deleteView = nil
//            }
//        }
        
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
//        DispatchQueue.main.async {
//            let size = CGSize(width: 30, height: 30)
//            self.startAnimating(size, message: nil, type: NVActivityIndicatorType.ballRotateChase)
//            let thisPhoto = galleryPreview.accessCurrentPhotoDetail()
//            if let index =  self.avatarPhotos?.index(where: {$0 === thisPhoto}) {
//                self.lastIndex = index
//                let currentAvatarFile = self.avatars[index].file
//                self.currentAvatarId = self.avatars[index].id
//                if currentAvatarFile?.status == .downloading {
//                    return
//                }
//
//                if UIImage.originalImage(for: currentAvatarFile!) != nil {
//                    self.galleryPhotos?.hiddenDownloadView()
//                    self.stopAnimating()
//                    return
//                }
//
//                if let attachment = currentAvatarFile {
//                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
//                        DispatchQueue.main.async {
//                            galleryPreview.hiddenDownloadView()
//                            self.stopAnimating()
//                        }
//                    }, failure: {
//
//                    })
//                }
//
//            }
//
//        }
//        scheduledTimerWithTimeInterval()
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        //timer.invalidate()
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
//                if UIImage.originalImage(for: currentAvatarFile!) != nil {
//                    DispatchQueue.main.async {
//                        self.galleryPhotos?.hiddenDownloadView()
//                        self.stopAnimating()
//                    }
//                    
//                    self.currentAvatarId = nextAvatarId
//                    return
//                }
//
//                
//                if let attachment = currentAvatarFile {
//                    IGDownloadManager.sharedManager.download(file: attachment, previewType: .originalFile, completion: { (attachment) -> Void in
//                        DispatchQueue.main.async {
//                            self.galleryPhotos?.hiddenDownloadView()
//                            self.stopAnimating()
//                        }
//                    }, failure: {
//                        
//                    })
//                }
//                self.currentAvatarId = nextAvatarId
//            } else {
//                
//            }
//        }
        //scheduledTimerWithTimeInterval()
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
                                        let roomVC = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! IGMessageViewController
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
        destination.mode = "Convert Chat To Group"
        destination.roomID = previousRoomId
    }

}
