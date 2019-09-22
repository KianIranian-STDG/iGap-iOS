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


class IGProfileUserViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {

    //MARK: -Variables
    let headerViewMaxHeight: CGFloat = 144
    let headerViewMinHeight: CGFloat = 44 + UIApplication.shared.statusBarFrame.height
    var originalTransform : CGAffineTransform!
    private var lastContentOffset: CGFloat = 0
    private var hasScaledDown: Bool = false
    var user: IGRegisteredUser?
    var previousRoomId: Int64?
    var room: IGRoom?
    var roomType: String? = "CHAT"
    var hud = MBProgressHUD()
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    var avatarPhotos : [INSPhotoViewable]?
    var galleryPhotos: INSPhotosViewController?
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    var maxNavHeight : CGFloat = 144
    //MARK: -Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var viewBG: UIView!

    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!

    //MARK: -ViewController Initialisers
    override func viewDidLoad() {
        super.viewDidLoad()
        maxNavHeight = self.heightConstraints.constant
        originalTransform = self.avatarView.transform
        tableView.contentInset = UIEdgeInsets(top: maxNavHeight, left: 0, bottom: 0, right: 0)
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        
        var roomTypeFinal : IGRoom.IGType? = .chat
        
        navigaitonItem.setNavigationBarForProfileRoom(.chat, id: user?.id, groupRole: nil, channelRole: nil)

        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
    //MARK: -Development functions
    
    
    //MARK: -Check if is For Bot
    private func isBotRoom() -> Bool{
        return (user?.isBot)!
    }

    private func initView() {
        //MARK: -Avatar View Initialiser
        initAvatarView()
        //MARK: -GradientView Initialiser
        initGradientView()
        //MARK: -Labels initialisers
        initLabels()
    }
    func initLabels() {

    }
    func initGradientView() {
        let gradient = CAGradientLayer()
        gradient.frame = viewBG.frame
        gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
        gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
        gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
        gradient.locations = orangeGradientLocation as [NSNumber]
        viewBG.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    
    //MARK: -Avatar Sequence
    func initAvatarView() {
        if user != nil {
            requestToGetAvatarList()
            self.avatarView.setUser(user!, showMainAvatar: true)
            self.displayNameLabel.text = user!.displayName
            displayNameLabel.textColor = .white
            timeLabel.textColor = .white
            if let phone = user?.phone {
                if phone == 0 {
                    self.phoneNumberLabel.text = "HIDDEN".localizedNew
                } else {
                    self.phoneNumberLabel.text = "\(phone)".inLocalizedLanguage()
                }
            }
            self.usernameLabel.text = user!.username
            switch user!.lastSeenStatus {
            case .longTimeAgo:
                self.timeLabel!.text = "A_LONG_TIME_AGO".localizedNew
                break
            case .lastMonth:
                self.timeLabel!.text = "LAST_MONTH".localizedNew
                break
            case .lastWeek:
                self.timeLabel!.text = "LAST_WEAK".localizedNew
                break
            case .online:
                self.timeLabel!.text = "ONLINE".localizedNew
                break
            case .exactly:
                self.timeLabel!.text = "\(user!.lastSeen!.humanReadableForLastSeen())".inLocalizedLanguage()
                break
            case .recently:
                self.timeLabel!.text = "A_FEW_SEC_AGO".localizedNew
                break
            case .support:
                self.timeLabel!.text = "IGAP_SUPPORT".localizedNew
                break
            case .serviceNotification:
                self.timeLabel!.text = "SERVICE_NOTIFI".localizedNew
                break
            }
        }
        if let selectedUser = user {
            let blockedUserPredicate = NSPredicate(format: "id = %lld", selectedUser.id)
            if let blockedUser = try! Realm().objects(IGRegisteredUser.self).filter(blockedUserPredicate).first {
                print(blockedUser.displayName)
                if blockedUser.isBlocked == true {
//                    blockContactLabel.text = "UNBLOCK".localizedNew
                }
            }
        }
        avatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        avatarView.avatarImageView?.addGestureRecognizer(tap)
        
        self.view.bringSubviewToFront(avatarView)

    }
    //MARK: -Avatar List Request
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
    //MARK: - Avatar Tap Handler
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = user?.avatar {
                showAvatar(avatar: userAvatar)
            }
        }
    }
    
    //MARK: - Show Avatar
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
    //MARK: - Creat Chat With User
    func createChat() {
        if let selectedUser = user {
            let hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
            hud.mode = .indeterminate
            IGChatGetRoomRequest.Generator.generate(peerId: selectedUser.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let chatGetRoomResponse as IGPChatGetRoomResponse:
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        
                        //HINT: -segue to created chat
                        if roomId == self.previousRoomId {
                            _ = self.navigationController?.popViewController(animated: true)
                        } else {
                            //HINT: -segue
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
    //MARK: - Block Current Contact
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
//                        self.blockContactLabel.text = "UNBLOCK".localizedNew
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
    
    //MARK: - UnBlock Current Contact
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
//                        self.blockContactLabel.text = "BLLOCK_CONTACT".localizedNew
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
    
    //AMRK: - Show Delete Pop Over
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
    
    //MARK: - Delete Chat with User
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
    //MARK: -Show Clear History Action Sheet
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
    //MARK: - Clear Chat Message History
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
    
    //MARK: - Detect if is Cloud
    func isCloud() -> Bool{
        if user != nil {
            return user?.id == IGAppManager.sharedManager.userID()
        }
        return false
    }
    
    //MARK: -Segue Prepare Handler
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
        destination.mode = "ConvertChatToGroup"
        destination.roomID = previousRoomId
        let tmp = user
        destination.baseUser = user
    }
    var newHeaderViewHeight : CGFloat = 144

    //MARK: -Scroll View Delegate and DataS ource
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y: CGFloat = maxNavHeight -  (scrollView.contentOffset.y + maxNavHeight)
        let height = min(max(y,headerViewMinHeight),headerViewMaxHeight)
        let range = height / headerViewMaxHeight
        heightConstraints.constant = height
        heightConstraints.constant = height
        let scaledTransform = originalTransform.scaledBy(x: max(0.7,range), y: max(0.7,range))
        let scaledAndTranslatedTransform = scaledTransform.translatedBy(x: 0, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.avatarView.transform = scaledAndTranslatedTransform
            self.hasScaledDown = true
        })
//        let newHeaderViewHeight: CGFloat = heightConstraints.constant - y

        self.view.layoutIfNeeded()

    }

    

    // MARK: -TableViewDelegates and Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1

        case 1:
            return 2

        case 2:
            if IGHelperPromote.isPromotedRoom(userId: (user?.id)!) {
                return 0
            }
            return 1

        case 3:
            if isCloud() { // hide block contact for mine profile
                return 2
            }
            
            if isBotRoom() {
                return 1
            }
            
            return 3
        default:
            return 4
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGProfileUserCell", for: indexPath as IndexPath) as! IGProfileUserCell
        let cellTwo = tableView.dequeueReusableCell(withIdentifier: "IGProfileUSerCellTypeTwo", for: indexPath as IndexPath) as! IGProfileUSerCellTypeTwo
        switch indexPath.section {
        case 0:
            if let bio = user!.bio {
                cell.initLabels(nameLblString: bio)
            } else {
                cell.initLabels(nameLblString: "")
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
                    cell.initLabels(nameLblString: "CLEAR_HISTORY".localizedNew)
                    return cell

                case 1 :
                    cell.initLabels(nameLblString: "REPORT".localizedNew,changeColor: true)
                    return cell

                case 2 :
                    cell.initLabels(nameLblString: "BLLOCK_CONTACT".localizedNew,changeColor: true)
                    return cell
                default:
                    return cell

            }
        default:
            return cell
        }

    }
    //MARK: -Header and Footer
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedNewDirection
        switch section {
        case 0 :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
        case 1 :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
        case 2 :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
        default :
            break
            
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "SETTING_PAGE_ACCOUNT_BIO".localizedNew
        case 1:
            return "NOTIFICATION_SOUNDS".localizedNew
        case 2:
            return "SHAREDMEDIA".localizedNew
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 60
        case 3:
            return 10

        default:
            return 50
        }
    }

    
}
