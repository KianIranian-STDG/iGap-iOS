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
import SwiftProtobuf
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import IGProtoBuff
import MGSwipeTableCell
import MBProgressHUD
import NVActivityIndicatorView

class IGGroupProfile: BaseTableViewController {
    
    // new start
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var txtGroupLinkTitle: UILabel!
    @IBOutlet weak var txtGroupLinkValue: UILabel!
    @IBOutlet weak var txtNotificationTitle: UILabel!
    @IBOutlet weak var txtNotificationValue: UILabel!
    @IBOutlet weak var txtSharedContentTitle: UILabel!
    @IBOutlet weak var txtSharedPhotosTitle: UILabel!
    @IBOutlet weak var txtSharedPhotosValue: UILabel!
    @IBOutlet weak var txtSharedVideoTitle: UILabel!
    @IBOutlet weak var txtSharedVideosValue: UILabel!
    @IBOutlet weak var txtSharedFilesTitle: UILabel!
    @IBOutlet weak var txtSharedFilesValue: UILabel!
    @IBOutlet weak var txtSharedAudiosTitle: UILabel!
    @IBOutlet weak var txtSharedAudiosValue: UILabel!
    @IBOutlet weak var txtSharedVoicesTitle: UILabel!
    @IBOutlet weak var txtSharedVoicesValue: UILabel!
    @IBOutlet weak var txtSharedLinksTitle: UILabel!
    @IBOutlet weak var txtSharedLinksValue: UILabel!
    @IBOutlet weak var txtSharedGifsTitle: UILabel!
    @IBOutlet weak var txtSharedGifsValue: UILabel!
    @IBOutlet weak var txtAddMember: UILabel!
    @IBOutlet weak var txtShowMember: UILabel!
    // new end
    
    var room : IGRoom?
    var hud = MBProgressHUD()
    var myRole : IGGroupMember.IGRole!
    var signMessageIndexPath : IndexPath?
    var imagePicker = UIImagePickerController()
    var selectedGroup: IGGroupRoom?
    var groupRoom : Results<IGRoom>!
    var mode : String? = "Members"
    var notificationToken: NotificationToken?
    var connectionStatus: IGAppManager.ConnectionStatus?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRole = room?.groupRoom?.role
        groupRoom = try! Realm().objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", (room?.id)!))
        
        initNavigation()
        requestToGetRoom()
        requestToGetAvatarList()
        showGroupInfo()
        connectionState()
        groupInfoObserver()
        getSharedMediaCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageViewState()
    }
    
    private func initNavigation(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "GROUP_INFO".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.setNavigationBarForRoom(self.room!)
    }
    
    private func connectionState(){
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateConnectionStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
    }
    
    /**
     * change view according to state of user (owner/admin/moderator/member)
     */
    private func manageViewState(){
        txtGroupLinkTitle.text = "GROUP_LINK".localizedNew
        txtNotificationTitle.text = "NOTIFICATIONS".localizedNew
        txtNotificationValue.text = "On"
        txtSharedContentTitle.text = "SHAREDMEDIA".localizedNew
        txtSharedPhotosTitle.text = "IMAGES".localizedNew
        txtSharedVideoTitle.text = "VIDEOS".localizedNew
        txtSharedFilesTitle.text = "FILES".localizedNew
        txtSharedAudiosTitle.text = "AUDIOS".localizedNew
        txtSharedVoicesTitle.text = "VOICES".localizedNew
        txtSharedLinksTitle.text = "LINKS".localizedNew
        txtSharedGifsTitle.text = "GIFS".localizedNew
        txtAddMember.text = "ADD_MEMBER".localizedNew
        txtShowMember.text = "ALLMEMBER".localizedNew
        
        self.tableView.isUserInteractionEnabled = true
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        tableView.tableFooterView = UIView()
//        groupAvatarView.avatarImageView?.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
//        groupAvatarView.avatarImageView?.addGestureRecognizer(tap)
//
//        switch myRole! {
//        case .admin:
//            cameraButton.isHidden = false
//            groupTypeCell.accessoryType = .none
//            groupTypeLabelTrailingConstraint.constant = 10
//            break
//        case .owner:
//            leaveGroupLabel.text = "DELETE_GROUP".localizedNew
//            cameraButton.isHidden = false
//            break
//        case .member:
//            if room?.groupRoom?.type == .publicRoom {
//                groupAllMemberCell.isHidden = true
//
//            } else {
//                groupAllMemberCell.isHidden = false
//            }
//            adminsAndModeratorCell.isHidden = true
//            groupLinkCell.isHidden = true
//            groupNameCell.accessoryType = .none
//            groupNameLabelTrailingConstraint.constant = 10
//            groupTypeCell.accessoryType = .none
//            groupTypeLabelTrailingConstraint.constant = 10
//            cameraButton.isHidden = true
//            break
//        case .moderator:
//            if room?.groupRoom?.type == .publicRoom {
//                groupAllMemberCell.isHidden = true
//                groupLinkCell.isHidden = true
//            } else {
//                groupAllMemberCell.isHidden = false
//            }
//            adminsAndModeratorCell.isHidden = true
//            groupNameCell.accessoryType = .none
//            groupNameLabelTrailingConstraint.constant = 10
//            groupTypeCell.accessoryType = .none
//            groupTypeLabelTrailingConstraint.constant = 10
//            cameraButton.isHidden = true
//            break
//        }
    }
    
    private func groupInfoObserver(){
        
        self.notificationToken = groupRoom.observe { (changes: RealmCollectionChange) in
            if self.room == nil || self.room!.isInvalidated {return}
            
            let predicatea = NSPredicate(format: "id = %lld", (self.room?.id)!)
            self.room =  try! Realm().objects(IGRoom.self).filter(predicatea).first!
            self.showGroupInfo()
        }
    }
    
    private func getSharedMediaCount() {
        IGClientCountRoomHistoryRequest.Generator.generate(roomID: self.room!.id).success({ (protoResponse) in
            if let clientCountRoomHistory = protoResponse as? IGPClientCountRoomHistoryResponse {
                let response = IGClientCountRoomHistoryRequest.Handler.interpret(response: clientCountRoomHistory)
                DispatchQueue.main.async {
                    self.txtSharedVideosValue.text = "\(response.video)".inLocalizedLanguage()
                    self.txtSharedFilesValue.text = "\(response.file)".inLocalizedLanguage()
                    self.txtSharedPhotosValue.text = "\(response.image)".inLocalizedLanguage()
                    self.txtSharedVoicesValue.text = "\(response.voice)".inLocalizedLanguage()
                    self.txtSharedAudiosValue.text = "\(response.audio)".inLocalizedLanguage()
                    self.txtSharedLinksValue.text = "\(response.url)".inLocalizedLanguage()
                    self.txtSharedGifsValue.text = "\(response.gif)".inLocalizedLanguage()
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getSharedMediaCount()
            default:
                break
            }
        }).send()
    }
    
    func deleteAvatar(){
        let avatar = self.avatars[0]
        IGGroupAvatarDeleteRequest.Generator.generate(avatarId: avatar.id, roomId: (room?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let groupAvatarDeleteResponse as IGPGroupAvatarDeleteResponse :
                    IGGroupAvatarDeleteRequest.Handler.interpret(response: groupAvatarDeleteResponse)
                    self.avatarPhotos?.remove(at: 0)
                    self.avatars.remove(at: 0)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.deleteAvatar()
            default:
                break
            }
            
        }).send()
    }
    
    func updateConnectionStatus(_ status: IGAppManager.ConnectionStatus) {
        
        switch status {
        case .connected:
            connectionStatus = .connected
            break
        case .connecting:
            connectionStatus = .connecting
            break
        case .waitingForNetwork:
            connectionStatus = .waitingForNetwork
            break
        case .iGap:
            connectionStatus = .iGap
            break
        }
    }
    
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            if let userAvatar = room?.groupRoom?.avatar {
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
//        var photos: [INSPhotoViewable] = self.avatars.map { (avatar) -> IGMedia in
//            return IGMedia(avatar: avatar)
//        }
//
//        if(photos.count==0){
//            return
//        }
//        avatarPhotos = photos
//        let currentPhoto = photos[0]
//        let downloadIndicatorMainView = UIView()
//        let downloadViewFrame = self.view.bounds
//        downloadIndicatorMainView.backgroundColor = UIColor.white
//        downloadIndicatorMainView.frame = downloadViewFrame
//        let andicatorViewFrame = CGRect(x: view.bounds.midX, y: view.bounds.midY,width: 50 , height: 50)
//        let activityIndicatorView = NVActivityIndicatorView(frame: andicatorViewFrame,
//                                                            type: NVActivityIndicatorType.audioEqualizer)
//        downloadIndicatorMainView.addSubview(activityIndicatorView)
//
//        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: groupAvatarView)//, deleteView: deleteView, downloadView: downloadIndicatorMainView)
//        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
//            return self?.groupAvatarView
//        }
//        galleryPhotos = galleryPreview
//        present(galleryPreview, animated: true, completion: nil)
//        activityIndicatorView.startAnimating()
    }
    
    
    func requestToGetAvatarList() {
        if let currentRoomID = room?.id {
            IGGroupAvatarGetListRequest.Generator.generate(roomId: currentRoomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupAvatarGetListResponse as IGPGroupAvatarGetListResponse:
                        let responseAvatars = IGGroupAvatarGetListRequest.Handler.interpret(response: groupAvatarGetListResponse)
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
    
    
    func showGroupInfo() {
        if !(room!.isInvalidated) {
            if let description = room?.groupRoom?.roomDescription, !description.isEmpty{
                txtDescription.text = description
                txtDescription.textColor = UIColor.black
            } else {
                txtDescription.text = "NO_DESCRIPTION".localizedNew
                txtDescription.textColor = UIColor.lightGray
            }
            
            /*
            if let groupRoom = room {
                groupAvatarView.setRoom(groupRoom, showMainAvatar: true)
            }
            if let memberCount = room?.groupRoom?.participantCount {
                memberCountLabel.text = "\(memberCount)"
            }
            */
            var groupLink: String? = ""
            if room?.groupRoom?.type == .privateRoom {
                groupLink = room?.groupRoom?.privateExtra?.inviteLink
            }
            if room?.groupRoom?.type == .publicRoom {
                if let groupUsername = room?.groupRoom?.publicExtra?.username {
                    groupLink = "iGap.net/\(groupUsername)"
                }
            }
            txtGroupLinkValue.text = groupLink
        }
    }
    
    func requestToGetRoom() {
        if let groupRoom = room {
            IGClientGetRoomRequest.Generator.generate(roomId: groupRoom.id).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                        _ = IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                        
                        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupNameSetting" {
            let destination = segue.destination as! IGGroupInfoEditNameTableViewController
            destination.room = room
        } else if segue.identifier == "showDescribeGroupSetting" {
            let destination = segue.destination as! IGGroupEditDescriptionTableViewController
            destination.room = room
        } else if segue.identifier ==  "showGroupTypeSetting" {
            let destination = segue.destination as! IGGroupInfoEditTypeTableViewController
            destination.room = room
        } else if segue.identifier == "showGroupMemberSetting" {
            let destination = segue.destination as! IGGroupInfoMemberListTableViewController
            destination.room = room
        } else if segue.identifier == "showGroupAdminsAnadModeratorsSetting" {
            let destination = segue.destination as! IGGroupInfoAdminsAndModeratorsListTableViewController
            destination.room = room
        } else if segue.identifier == "showGroupSharedMediaSetting" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        } else if segue.identifier == "showContactToAddMember" {
            let destinationTv = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
            destinationTv.mode = "Members"
            destinationTv.room = room
        }
    }
    
    /****************************************************************************************************************/
    /************************************************** Table View **************************************************/
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
            
        case 1:
            return 1
            
        case 2:
            return 2
            
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            break
        case 2:
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "showContactToAddMember", sender: self)
            } else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
            }
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 44
            } else if indexPath.row == 1 {
                return 65
            }
            
        case 1:
            return 255
            
        case 2:
            if indexPath.row == 0 {
                return 44
            } else if indexPath.row == 1 {
                return 44
            }
            
        default:
            return 0
        }
        
        return 0
    }
    
}
