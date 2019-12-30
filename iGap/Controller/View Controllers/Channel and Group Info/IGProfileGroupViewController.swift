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

class IGProfileGroupViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,cellTypeTwoDelegate {
    
    //MARK: -Variables
    private var adminsCount : String = "0"
    private var moderatprsCount : String = "0"
    private var adminsMembersCount : Results<IGRealmMember>!
    private var moderatorsMembersCount : Results<IGRealmMember>!
    private var adminsRole = IGPChannelRoom.IGPRole.admin.rawValue
    private var moderatorRole = IGPChannelRoom.IGPRole.moderator.rawValue
    private var predicateAdmins : NSPredicate!
    private var predicateModerators : NSPredicate!
    private var notificationTokenModerator: NotificationToken?
    private var notificationAdmin: NotificationToken?
    private var avatarObserver: NotificationToken?
    private var groupInfoObserver: NotificationToken?
    
    var isFistLaunch : Bool! = true
    var groupLink: String? = ""
    let headerViewMaxHeight: CGFloat = 100
    let headerViewMinHeight: CGFloat = 45
    var originalTransform : CGAffineTransform!
    private var lastContentOffset: CGFloat = 0
    private var hasScaledDown: Bool = false
    var room : IGRoom?
    var hud = MBProgressHUD()
    var myRole : IGPGroupRoom.IGPRole!
    var signMessageIndexPath : IndexPath?
    var imagePicker = UIImagePickerController()
    var selectedGroup: IGGroupRoom?
    var groupRoom : Results<IGRoom>!
    var mode : String? = "Members"
    var connectionStatus: IGAppManager.ConnectionStatus?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    var maxNavHeight : CGFloat = 100
    
    
    //MARK: -Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewBGTwo: UIView!

    //MARK: -ViewController Initialisers
    override func viewDidLoad() {
        super.viewDidLoad()
        groupFirstInitialiser()
        maxNavHeight = self.heightConstraints.constant
        originalTransform = self.avatarView.transform
        tableView.contentInset = UIEdgeInsets(top: maxNavHeight + 10, left: 0, bottom: 0, right: 0)
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.setNavigationBarForProfileRoom(.group, id: nil, groupRole: room?.groupRoom?.role, channelRole: nil,roomValue: self.room)
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController
        
        displayNameLabel.textAlignment = .right
        displayNameLabel.textColor = .white
        displayNameLabel.font = UIFont.igFont(ofSize: 15,weight: .bold)
        memberCountLabel.font = UIFont.igFont(ofSize: 15,weight: .bold)
        initTheme()
        initAvatarObserver()
    }
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.viewBGTwo.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        memberCountLabel.textColor = ThemeManager.currentTheme.LabelColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationTokenModerator?.invalidate()
        notificationAdmin?.invalidate()
        avatarObserver?.invalidate()
        groupInfoObserver?.invalidate()
    }

    deinit {
        print("Deint IGProfileGroupViewController")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                // appearance has changed
                // Update your user interface based on the appearance
                self.initGradientView()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK: -Development functions
    
    private func initAvatarObserver(){
        self.avatarObserver = IGAvatar.getAvatarsLocalList(ownerId: self.room!.id).observe({ (ObjectChange) in
            self.avatarView.setRoom(self.room!)
        })
    }
    
    func report(room: IGRoom){
        let roomId = room.id
        let roomType = room.type
        
        var title = ""
        
        if roomType == .chat {
            title = IGStringsManager.Report.rawValue.localized
        } else {
            title = IGStringsManager.Report.rawValue.localized
        }
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let abuse = UIAlertAction(title: IGStringsManager.Abuse.rawValue.localized, style: .default, handler: { (action) in
            
            if roomType == .chat {
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.abuse)
            }
        })
        
        let spam = UIAlertAction(title: IGStringsManager.Spam.rawValue.localized, style: .default, handler: { (action) in
            
            if roomType == .chat {
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.spam)
            }
        })
        
        
        let violence = UIAlertAction(title: IGStringsManager.Violence.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: IGStringsManager.Pornography.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: { (action) in
            
        })
        
        alertC.addAction(abuse)
        alertC.addAction(spam)
        if roomType == .chat {
        } else {
            alertC.addAction(violence)
            alertC.addAction(pornography)
        }
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: {
            
        })
    }
    
    func reportRoom(roomId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, reason: reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    let alert = UIAlertController(title: "SUCCESS", message: IGStringsManager.ReportSent.rawValue.localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                    
                case .clientRoomReportReportedBefore:
                    let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.UserReportedBefore.rawValue.localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportForbidden:
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func didPressMuteSwitch() {
        self.muteRoom(room: self.room!)
    }

    func muteRoom(room: IGRoom) {
        
        let roomId = room.id
        var roomMute = IGRoom.IGRoomMute.mute
        if room.mute == IGRoom.IGRoomMute.mute {
            roomMute = .unmute
        }
        
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientMuteRoomRequest.Generator.generate(roomId: roomId, roomMute: roomMute).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let muteRoomResponse as IGPClientMuteRoomResponse:
                    IGClientMuteRoomRequest.Handler.interpret(response: muteRoomResponse)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    private func initView() {
        initGradientView()
    }
    
    func initGradientView() {
        let gradient = CAGradientLayer()
        gradient.frame = viewBG.frame
        gradient.colors = [ThemeManager.currentTheme.NavigationFirstColor.cgColor, ThemeManager.currentTheme.NavigationSecondColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        viewBG.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    
    func groupFirstInitialiser() {
        requestToGetRoom()
        myRole = room?.groupRoom?.role
        showGroupInfo()
        
        tableView.tableFooterView = UIView()
        
        avatarView.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        avatarView.avatarImageView?.addGestureRecognizer(tap)
        
        let predicate = NSPredicate(format: "id = %lld", (room?.id)!)
        groupRoom =  try! Realm().objects(IGRoom.self).filter(predicate)
        
        self.groupInfoObserver = groupRoom.observe { (changes: RealmCollectionChange) in
            if self.room == nil || self.room!.isInvalidated {return}
            let predicatea = NSPredicate(format: "id = %lld", (self.room?.id)!)
            self.room =  try! Realm().objects(IGRoom.self).filter(predicatea).first!
            self.showGroupInfo()
        }
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
        }, onError: { (error) in
        }, onCompleted: {
        }, onDisposed: {
        }).disposed(by: disposeBag)
        
    }
    
    //MARK: -Actions
    
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        if recognizer.state == .ended {
            showAvatar()
        }
    }
    
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    
    func showAvatar() {
        if IGAvatar.hasAvatar(ownerId: room!.id) {
            let mediaPager = IGMediaPager.instantiateFromAppStroryboard(appStoryboard: .Main)
            mediaPager.hidesBottomBarWhenPushed = true
            mediaPager.ownerId = self.room!.id
            mediaPager.mediaPagerType = .avatar
            mediaPager.avatarType = .group
            self.navigationController!.pushViewController(mediaPager, animated: false)
        }
    }
    
    func showGroupInfo() {
        if !(room!.isInvalidated) {
            displayNameLabel.text = room?.title
            displayNameLabel.text = room?.title
            if let groupRoom = room {
                avatarView.setRoom(groupRoom)
            }
            if let groupType = room?.groupRoom?.type {
                switch groupType {
                case .privateRoom:
                    break
                case .publicRoom:
                    break
                }
            }
            if let memberCount = room?.groupRoom?.participantCount {
                memberCountLabel.text = IGStringsManager.AllMembers.rawValue.localized + ": " + "\(memberCount)"
            }
            if room?.groupRoom?.type == .privateRoom {
                groupLink = room?.groupRoom?.privateExtra?.inviteLink
            }
            if room?.groupRoom?.type == .publicRoom {
                if let groupUsername = room?.groupRoom?.publicExtra?.username {
                    groupLink = "iGap.net/\(groupUsername)"
                }
            }
        }
    }
    
    func showDeleteChannelActionSheet() {
        var title : String!
        var actionTitle: String!
        if myRole == .owner {
            title = IGStringsManager.SureToRemoveGroup.rawValue.localized
            actionTitle = IGStringsManager.Delete.rawValue.localized
        }else{
            title = IGStringsManager.SureToLeaveGroup.rawValue.localized
            actionTitle = IGStringsManager.Leave.rawValue.localized
        }
        let deleteConfirmAlertView = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: actionTitle , style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if self.myRole == .owner {
                if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                    let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    self.deleteGroupRequest()
                }
            }else{
                if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                    let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }else {
                    self.leftGroupRequest(room: self.room!)
                }
            }
            
        })
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style:.cancel , handler: {
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
    
    func showGroupLinkAlert() {
        if selectedGroup != nil {
            var groupLink: String? = ""
            if room?.groupRoom?.type == .privateRoom {
                groupLink = room?.groupRoom?.privateExtra?.inviteLink
            }
            if room?.groupRoom?.type == .publicRoom {
                groupLink = room?.groupRoom?.publicExtra?.username
            }
            
            let alert = UIAlertController(title: IGStringsManager.GroupLink.rawValue.localized, message: groupLink, preferredStyle: .alert)
            
            let copyAction = UIAlertAction(title: IGStringsManager.Copy.rawValue.localized, style: .default, handler: { (alert: UIAlertAction) -> Void in
                UIPasteboard.general.string = groupLink
            })
            
            let shareAction = UIAlertAction(title: IGStringsManager.Share.rawValue.localized, style: .default, handler: { (alert: UIAlertAction) -> Void in
                IGHelperPopular.shareText(message: IGHelperPopular.shareLinkPrefixGroup + "\n" + groupLink!, viewController: self)
            })
            
            
            let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
            
            alert.view.tintColor = UIColor.organizationalColor()
            alert.addAction(copyAction)
            alert.addAction(shareAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func requestToRevolLink() {
        IGGroupRevokLinkRequest.Generator.generate(roomID: (room?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let groupRevokeLinkRequest as IGPGroupRevokeLinkResponse:
                    let _ = IGGroupRevokLinkRequest.Handler.interpret(response: groupRevokeLinkRequest)
                default:
                    break
                }
            }
            
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                break
            default:
                break
            }
            
        }).send()
    }
    private func requestToGetAdminsAndModerators() {
        predicateModerators = NSPredicate(format: "roleRaw = %d AND roomID = %lld", moderatorRole , (room?.id)!)
        moderatorsMembersCount =  try! Realm().objects(IGRealmMember.self).filter(predicateModerators!)
        predicateAdmins = NSPredicate(format: "roleRaw = %d AND roomID = %lld", adminsRole , (room?.id)!)
        adminsMembersCount =  try! Realm().objects(IGRealmMember.self).filter(predicateAdmins!)
        self.notificationTokenModerator = moderatorsMembersCount.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.moderatprsCount = "\(Set(self.moderatorsMembersCount).count)"
                break
            case .update(_, _, _, _):
                self.moderatprsCount = "\(Set(self.moderatorsMembersCount).count)"
                break
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        self.notificationAdmin = adminsMembersCount.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.adminsCount = "\(Set(self.adminsMembersCount).count)"
                break
            case .update(_, _, _, _):
                self.adminsCount = "\(Set(self.adminsMembersCount).count)"
                break
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
    }
    
    func requestToGetRoom() {
        if let groupRoom = room {
            IGClientGetRoomRequest.Generator.generate(roomId: groupRoom.id).success({ (protoResponse) in
                if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                    _ = IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                }
                
            }).error ({ [weak self] (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    self?.hud.hide(animated: true)
                    break
                default:
                    break
                }
            }).send()
        }
    }
    
    func leftGroupRequest(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGGroupLeftRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let groupLeft as IGPGroupLeftResponse:
                    IGGroupLeftRequest.Handler.interpret(response: groupLeft)
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
                    break
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func deleteGroupRequest() {
        if let groupRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGGroupDeleteRequest.Generator.generate(group: groupRoom).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupDeleteResponse as IGPGroupDeleteResponse:
                        IGGroupDeleteRequest.Handler.interpret(response: groupDeleteResponse)
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
                    self.hud.hide(animated: true)
                    switch errorCode {
                    case .timeout:
                        break
                    default:
                        break
                    }
                }
            }).send()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGroupMemberSetting" {
            let destination = segue.destination as! IGMemberTableViewController
            destination.showMembersFilter = .all
            destination.room = room
        }
        if segue.identifier == "showContactToAddMember" {
            let destinationTv = segue.destination as! IGMemberAddOrUpdateState
            destinationTv.mode = "Members"
            destinationTv.room = room
        }
        if segue.identifier == "showGroupSharedMediaSetting" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        }
    }
    
    //MARK: -Scroll View Delegate and DataSource
    var tapCount : Int = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print((scrollView.contentOffset.y ))
        let y: CGFloat = maxNavHeight -  (scrollView.contentOffset.y + maxNavHeight)
        let height = min(max(y,headerViewMinHeight),headerViewMaxHeight)
        let range = height / headerViewMaxHeight
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGProfileUserCell", for: indexPath as IndexPath) as! IGProfileUserCell
        let cellTwo = tableView.dequeueReusableCell(withIdentifier: "IGProfileUSerCellTypeTwo", for: indexPath as IndexPath) as! IGProfileUSerCellTypeTwo
        let cellTypeRed = tableView.dequeueReusableCell(withIdentifier: "IGProfileUserCellTypeRed", for: indexPath as IndexPath) as! IGProfileUserCellTypeRed
        
        let groupType = room?.groupRoom?.type
        
        switch groupType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != ""{
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                switch indexPath.row {
                case 0:
                    cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                    if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                        cellTwo.lblActionDetail.isOn = true
                    } else {
                        cellTwo.lblActionDetail.isOn = false
                    }
                    cellTwo.delegate = self
                    return cellTwo
                    
                default:
                    return cell
                    
                }
                case 2:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 4:
                    switch indexPath.row {
                        
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        return cellTypeRed
                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
            case .member:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != ""{
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 2:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 4:
                    switch indexPath.row {
                        
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Report.rawValue.localized,changeColor: true)
                        return cellTypeRed
                    case 1 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        return cellTypeRed
                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
                
            case .moderator:
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != ""{
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 2:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 4:
                    switch indexPath.row {
                        
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Report.rawValue.localized,changeColor: true)
                        
                        return cellTypeRed
                    case 1 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        
                        return cellTypeRed
                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
            case .owner:
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != ""{
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    
                    cell.initLabels(nameLblString: groupLink)
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                        
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.DeleteGroup.rawValue.localized,changeColor: true)
                        return cellTypeRed
                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
            default:
                return cell
            }
        case .publicRoom?:
            switch myRole {
            case .admin? :
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != "" {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    
                    cell.initLabels(nameLblString: groupLink)
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        return cellTypeRed
                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
            case .owner? :
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != "" {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    
                    cell.initLabels(nameLblString: groupLink)
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        return cellTypeRed
                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
            case .member? :
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != "" {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    
                    cell.initLabels(nameLblString: groupLink)
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Report.rawValue.localized,changeColor: true)
                        return cellTypeRed

                    case 1 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        return cellTypeRed

                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
            case .moderator? :
                
                switch indexPath.section {
                case 0:
                    
                    if let desc = room?.groupRoom?.roomDescription , desc != "" {
                        cell.initLabels(nameLblString: desc)
                    } else {
                        cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                    }
                    
                    
                    
                    return cell
                    
                case 1:
                    
                    cell.initLabels(nameLblString: groupLink)
                    
                    return cell
                case 2:
                    switch indexPath.row {
                    case 0:
                        cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                        if ((room?.mute) == IGRoom.IGRoomMute.mute) {
                            cellTwo.lblActionDetail.isOn = true
                        } else {
                            cellTwo.lblActionDetail.isOn = false
                        }
                        cellTwo.delegate = self
                        return cellTwo
                        
                    default:
                        return cell
                        
                    }
                case 3:
                    cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                    return cell
                    
                case 4:
                    switch indexPath.row {
                    case 0 :
                        cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                        return cell
                        
                    case 1 :
                        cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                        return cell
                        
                    default:
                        return cell
                        
                    }
                    
                case 5:
                    switch indexPath.row {
                    case 0 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Report.rawValue.localized,changeColor: true)
                        return cellTypeRed

                    case 1 :
                        cellTypeRed.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
                        return cellTypeRed

                    default:
                        return cellTypeRed
                        
                    }
                default:
                    return cell
                }
                
            default :
                return cell
            }
        case .none:
            
            switch indexPath.section {
            case 0:
                
                if let desc = room?.groupRoom?.roomDescription {
                    cell.initLabels(nameLblString: desc)
                } else {
                    cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
                }
                
                
                
                return cell
                
            case 1:
                
                cell.initLabels(nameLblString: groupLink)
                
                return cell
            case 2:
                switch indexPath.row {
                case 0:
                    cellTwo.initLabels(nameLblString: IGStringsManager.MuteNotification.rawValue.localized)
                    return cellTwo
                    
                case 1:
                    cell.initLabels(nameLblString: IGStringsManager.NotificationAndSound.rawValue.localized)
                    return cell
                    
                default:
                    return cell
                    
                }
            case 3:
                cell.initLabels(nameLblString: IGStringsManager.SharedMedia.rawValue.localized)
                return cell
                
            case 4:
                switch indexPath.row {
                case 0 :
                    cell.initLabels(nameLblString: IGStringsManager.AddMember.rawValue.localized)
                    return cell
                    
                case 1 :
                    cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized)
                    return cell
                    
                default:
                    return cell
                    
                }
                
            case 5:
                switch indexPath.row {
                case 0 :
                    cell.initLabels(nameLblString: IGStringsManager.ClearHistory.rawValue.localized)
                    return cell
                    
                case 1 :
                    cell.initLabels(nameLblString: IGStringsManager.Report.rawValue.localized,changeColor: true)
                    return cell
                    
                case 2 :
                    cell.initLabels(nameLblString: IGStringsManager.Leave.rawValue.localized,changeColor: true)
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
        if let groupType = room?.groupRoom?.type {
            switch groupType {
            case .privateRoom:
                switch myRole! {
                case .admin:
                    return 5
                    
                case .member:
                    return 5
                    
                case .moderator:
                    return 5
                    
                case .owner:
                    return 6
                    
                default:
                    return 0
                }
                
            case .publicRoom:
                switch myRole! {
                case .admin:
                    return 6
                    
                case .member:
                    return 6
                    
                case .moderator:
                    return 6
                    
                case .owner:
                    return 6
                    
                default:
                    return 0
                }
            }
        } else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groupType = room?.groupRoom?.type
        switch groupType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2 :
                    return 1
                case 3 :
                    return 2
                case 4 :
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
                    return 1
                case 3 :
                    return 1
                case 4 :
                    return 2
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
                    return 1
                case 2 :
                    return 1
                case 3 :
                    return 2
                case 4 :
                    return 2
                default:
                    return 0
                }
            case .moderator:
                
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2 :
                    return 1
                case 3 :
                    return 2
                case 4 :
                    return 2
                default:
                    return 0
                }
             
            default:
                return 0
            }
        case .publicRoom?:
            
            switch myRole {
            case .admin? :
                
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
                case 5 :
                    return 1
                default:
                    return 0
                }
            case .owner? :
                
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
                case 5 :
                    return 1
                default:
                    return 0
                }
            case .member? :
                
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
                case 5 :
                    return 2
                default:
                    return 0
                }
            case .moderator? :
                
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
                case 5 :
                    return 2
                default:
                    return 0
                }
            default :
                
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
                case 5 :
                    return 1
                default:
                    return 0
                }
            }
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }

    //MARK: -Header and Footer
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        containerFooterView.textLabel?.textColor = ThemeManager.currentTheme.LabelColor

        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedDirection
        switch section {
        default :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
            break
            
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let groupType = room?.groupRoom?.type
        switch groupType {
        case .privateRoom?:
            
            switch myRole {
            case .admin?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 2:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            case .owner?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.GroupLink.rawValue.localized
                case 2:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 3:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            case .member?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 2:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            case .moderator?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 2:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            default :
                
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 2:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            }
        case .publicRoom?:
            
            switch myRole {
            case .admin?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.GroupLink.rawValue.localized
                case 2:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 3:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            case .owner?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.GroupLink.rawValue.localized
                case 2:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 3:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            case .member?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.GroupLink.rawValue.localized
                case 2:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 3:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            case .moderator?:
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.GroupLink.rawValue.localized
                case 2:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 3:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            default :
                
                
                switch section {
                case 0:
                    return IGStringsManager.Desc.rawValue.localized
                case 1:
                    return IGStringsManager.NotificationAndSound.rawValue.localized
                case 2:
                    return IGStringsManager.SharedMedia.rawValue.localized
                default:
                    return ""
                }
            }
        case .none:
            switch section {
            case 0:
                return IGStringsManager.Desc.rawValue.localized
            case 1:
                return IGStringsManager.GroupLink.rawValue.localized
            case 2:
                return IGStringsManager.NotificationAndSound.rawValue.localized
            case 3:
                return IGStringsManager.SharedMedia.rawValue.localized
            default:
                return ""
            }        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let groupType = room?.groupRoom?.type
        switch groupType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch section {
                case 0:
                    return 80
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
                    return 80
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
                    return 80
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
                    return 80
                case 3:
                    return 10
                    
                case 4:
                    return 10
                    
                default:
                    return 50
                }
            default:
                return 0
            }
            
        case .publicRoom?:
            switch section {
            case 0:
                return 80
            case 4:
                return 10
                
            case 5:
                return 10
                
            default:
                return 50
            }
            
        default:
            switch section {
            case 0:
                return 80
                
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
        let groupType = room?.groupRoom?.type
        switch groupType {
        case .privateRoom?:
            
            switch myRole! {
            case .admin:
                
                switch indexPath.section {
                case 0:
                    break
                case 1:
//                    self.performSegue(withIdentifier: "showGroupMemberSetting", sender: self)
//                    showGroupLinkAlert()
                    break
                case 2:
                        self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
                        break
                    
                    
                case 3:
                    switch indexPath.row {
                    case 0 :
                        //gotToAddMEmberPage
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)

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
                    showGroupLinkAlert()
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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)

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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)

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
                        report(room: self.room!)
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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)

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
                        report(room: self.room!)
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
                
            default:
                break
            }
            
        case .publicRoom?:
            switch myRole {
            case .admin? :

                switch indexPath.section {
                case 0:
                    break
                case 1:
                    showGroupLinkAlert()
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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)

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
                        //ShowLeaveAlert
                        showDeleteChannelActionSheet()
                        
                        break
                    default:
                        break
                        
                    }
                default:
                    break
                }
            case .owner? :

                switch indexPath.section {
                case 0:
                    break
                case 1:
                    showGroupLinkAlert()
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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)
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
                        //ShowLeaveAlert
                        showDeleteChannelActionSheet()
                        
                        break
                    default:
                        break
                        
                    }
                default:
                    break
                }
            case .moderator? :

                switch indexPath.section {
                case 0:
                    break
                case 1:
                    showGroupLinkAlert()
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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)
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
                        report(room: self.room!)

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
            case .member? :

                switch indexPath.section {
                case 0:
                    break
                case 1:
                    showGroupLinkAlert()
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
                        self.performSegue(withIdentifier: "showContactToAddMember", sender: self)
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
                        report(room: self.room!)

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
            default :
                
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
                        report(room: self.room!)

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
        case .none:
            break
            
        }
    }
}
