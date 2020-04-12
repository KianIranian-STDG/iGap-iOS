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
import RxSwift
import RxCocoa
import IGProtoBuff
import MGSwipeTableCell
import MBProgressHUD

class IGProfileChannelViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource ,cellTypeTwoDelegate{

    //MARK: -Variables
    private var lastContentOffset: CGFloat = 0
    private var hasScaledDown: Bool = false
    
    var memberRole: IGMemberRole = .all
    var adminsCount : String = "" // admins count not exist
    var moderatprsCount : String = "" // moderator count not exist
    var isVerified : Bool! = false
    var maxNavHeight : CGFloat = 100
    var lastIndex: Array<Any>.Index?
    var currentAvatarId: Int64?
    var timer = Timer()
    var isFistLaunch : Bool! = true
    var channelLink: String? = ""
    let headerViewMaxHeight: CGFloat = 100
    let headerViewMinHeight: CGFloat = 45
    var originalTransform : CGAffineTransform!
    var selectedChannel : IGChannelRoom?
    var room : IGRoom?
    var channelRoom : Results<IGRoom>!
    var hud = MBProgressHUD()
    var allMember = [IGRealmMember]()
    var myRole : IGPChannelRoom.IGPRole!
    var signMessageIndexPath : IndexPath?
    var channelLinkIndexPath : IndexPath?
    var notificationToken: NotificationToken?
    var connectionStatus: IGAppManager.ConnectionStatus?
    var avatars: [IGAvatar] = []
    var deleteView: IGTappableView?
    var userAvatar: IGAvatar?
    private var roomAccess: IGRealmRoomAccess?
    private var avatarObserver: NotificationToken?
    private var roomAccessObserver: NotificationToken?
    private var navItem: IGNavigationItem!

    //MARK: -Outlets
    @IBOutlet weak var channelNameLabelTitle: UILabel!
    @IBOutlet weak var channelImage: IGAvatarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var channelUserCountLabel: UILabel!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGTwo: UIView!

    //MARK: -ViewController Initialisers
    override func viewDidLoad() {
        super.viewDidLoad()

        channelNameLabelTitle.font = UIFont.igFont(ofSize: 15,weight: .bold)
        channelUserCountLabel.font = UIFont.igFont(ofSize: 15,weight: .bold)
        channelNameLabelTitle.textColor = .white
        
        
        initGradientView()
        channelFirstInitialiser()
        navItem = self.navigationItem as? IGNavigationItem
        navItem.setNavigationBarForProfileRoom(.channel, id: nil, groupRole: nil, channelRole: room?.channelRoom?.role,roomValue: self.room!)

        navItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        signMessageIndexPath = IndexPath(row: 2, section: 1)

        initTheme()
        initAvatarObserver()
        initRoomAccessObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avatarObserver?.invalidate()
        notificationToken?.invalidate()
        roomAccessObserver?.invalidate()
    }
    
    deinit {
        print("Deinit IGProfileChannelViewController")
    }
    
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.viewBGTwo.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        channelUserCountLabel.textColor = ThemeManager.currentTheme.LabelColor
    }

    private func initAvatarObserver(){
        self.avatarObserver = IGAvatar.getAvatarsLocalList(ownerId: self.room!.id).observe({ (ObjectChange) in
            self.channelImage.setRoom(self.room!)
        })
    }
    
    private func initRoomAccessObserver(){
        if room!.type == .group || room!.type == .channel {
            self.roomAccess = IGRealmRoomAccess.getRoomAccess(roomId: self.room!.id, userId: IGAppManager.sharedManager.userID()!)
            self.roomAccessObserver = self.roomAccess?.observe { [weak self] (ObjectChange) in
                DispatchQueue.main.async {
                    if self == nil {return}
                    self?.navItem.setNavigationBarForProfileRoom(.channel, id: nil, groupRole: nil, channelRole: self!.room?.channelRoom?.role,roomValue: self!.room!)
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func channelFirstInitialiser() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        maxNavHeight = self.heightConstraints.constant
        originalTransform = self.channelImage.transform
        tableView.contentInset = UIEdgeInsets(top: maxNavHeight + 10, left: 0, bottom: 0, right: 0)

        
        requestToGetRoom()
        myRole = room?.channelRoom?.role
        showChannelInfo()
        
        tableView.tableFooterView = UIView()
        
        channelImage.avatarImageView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTap(recognizer:)))
        channelImage.avatarImageView?.addGestureRecognizer(tap)

        let predicate = NSPredicate(format: "id = %lld", (room?.id)!)
        channelRoom =  try! Realm().objects(IGRoom.self).filter(predicate)
        
        self.notificationToken = channelRoom.observe { (changes: RealmCollectionChange) in
            if self.room == nil || self.room!.isInvalidated {return}
            let predicatea = NSPredicate(format: "id = %lld", (self.room?.id)!)
            self.room =  try! Realm().objects(IGRoom.self).filter(predicatea).first!
            self.showChannelInfo()
        }
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
        }, onError: { (error) in
        }, onCompleted: {
        }, onDisposed: {
        }).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestToGetRoom()
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
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    func reportRoom(roomId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, reason: reason).success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.ReportSent.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).error({ [weak self] (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                    
                case .clientRoomReportReportedBefore:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UserReportedBefore.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                    break
                    
                case .clientRoomReportForbidden:
                    break
                    
                default:
                    break
                }
                self?.hud.hide(animated: true)
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
        IGClientMuteRoomRequest.Generator.generate(roomId: roomId, roomMute: roomMute).success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let muteRoomResponse as IGPClientMuteRoomResponse:
                    IGClientMuteRoomRequest.Handler.interpret(response: muteRoomResponse)
                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).error({ [weak self] (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).send()
    }
    
    func initGradientView() {
        let gradient = CAGradientLayer()
        gradient.frame = viewBG.frame
        gradient.colors = [ThemeManager.currentTheme.NavigationFirstColor.cgColor, ThemeManager.currentTheme.NavigationSecondColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        viewBG.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            showAvatar()
        }
    }
    func showAvatar() {
        if IGAvatar.hasAvatar(ownerId: room!.id) {
            let mediaPager = IGMediaPager.instantiateFromAppStroryboard(appStoryboard: .Main)
            mediaPager.hidesBottomBarWhenPushed = true
            mediaPager.ownerId = self.room!.id
            mediaPager.mediaPagerType = .avatar
            mediaPager.avatarType = .channel
            self.navigationController!.pushViewController(mediaPager, animated: false)
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    @objc func updateCounting(){}
    
    
    func showDeleteChannelActionSheet() {
        var title : String!
        var actionTitle: String!
        if myRole == .owner {
            title = IGStringsManager.SureToRemoveChannel.rawValue.localized
            actionTitle = IGStringsManager.Delete.rawValue.localized
        } else {
            title = IGStringsManager.SureToLeaveChannel.rawValue.localized
            actionTitle = IGStringsManager.Leave.rawValue.localized
        }
        let deleteConfirmAlertView = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let deleteAction = UIAlertAction(title: actionTitle , style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            if self.myRole == .owner {
                if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                } else {
                    self.deleteChannelRequest()
                }
            } else {
                if self.connectionStatus == .connecting || self.connectionStatus == .waitingForNetwork {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                } else {
                    self.leftChannelRequest(room: self.room!)
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
    
    func showChannelLinkAlert() {
        if selectedChannel != nil {
            if room?.channelRoom?.type == .privateRoom {
                channelLink = room?.channelRoom?.privateExtra?.inviteLink
            }
            if room?.channelRoom?.type == .publicRoom {
                channelLink = room?.channelRoom?.publicExtra?.username
            }
            
            let alert = UIAlertController(title: IGStringsManager.ChannelLink.rawValue.localized, message: channelLink, preferredStyle: .alert)
            let copyAction = UIAlertAction(title: IGStringsManager.Copy.rawValue.localized, style: .default, handler: { (alert: UIAlertAction) -> Void in
                UIPasteboard.general.string = self.channelLink
            })
            
            let shareAction = UIAlertAction(title: IGStringsManager.Share.rawValue.localized, style: .default, handler: { (alert: UIAlertAction) -> Void in
                IGHelperPopular.shareText(message: IGHelperPopular.shareLinkPrefixChannel + "\n" + self.channelLink!, viewController: self)
            })

            
            let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
            
            alert.view.tintColor = UIColor.organizationalColor()
            alert.addAction(copyAction)
            alert.addAction(shareAction)
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
        channelNameLabelTitle.textAlignment = .right
        if let channelRoom = room {
            channelImage.setRoom(channelRoom)
        }
        if let channelType = room?.channelRoom?.type {
            switch channelType {
            case .privateRoom:
                if let link = room?.channelRoom?.privateExtra?.inviteLink  {
                    channelLink =  link
                }
            case .publicRoom:
                if let username = room?.channelRoom?.publicExtra?.username {
                    channelLink = username

                }
            }
            self.tableView.reloadData()
        }
        
        if let memberCount = room?.channelRoom?.participantCount {
            channelUserCountLabel.text = "\(memberCount)".inLocalizedLanguage() + " " + IGStringsManager.Member.rawValue.localized
            channelUserCountLabel.textAlignment = channelUserCountLabel.localizedDirection
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
    }

    func requestToUpdateChannelSignature(_ signatureSwitchStatus: Bool) {
        if let channelRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelUpdateSignatureRequest.Generator.generate(roomId: channelRoom.id, signatureStatus: signatureSwitchStatus).success({ [weak self] (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelUpdateSignatureResponse as IGPChannelUpdateSignatureResponse:
                        let _ = IGChannelUpdateSignatureRequest.Handler.interpret(response: channelUpdateSignatureResponse)
                    default:
                        break
                    }
                    self?.hud.hide(animated: true)
                }
            }).error ({ [weak self] (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        break
                    default:
                        break
                    }
                    self?.hud.hide(animated: true)
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
        IGChannelRevokeLinkRequest.Generator.generate(roomId: (room?.id)!).success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let channelRevokeLinkRequest as IGPChannelRevokeLinkResponse:
                    let _ = IGChannelRevokeLinkRequest.Handler.interpret(response: channelRevokeLinkRequest)
                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).error ({ [weak self] (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).send()
    }
    
    func leftChannelRequest(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChannelLeftRequest.Generator.generate(room: room).success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let channelLeft as IGPChannelLeftResponse:
                    IGChannelLeftRequest.Handler.interpret(response: channelLeft)
                    if self?.navigationController is IGNavigationController {
                        _ = self?.navigationController?.popToRootViewController(animated: true)
                    }
                default:
                    break
                }
                self?.hud.hide(animated: true)
                
            }
        }).error({ [weak self] (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).send()
    }
    
    func deleteChannelRequest() {
        if let channelRoom = room {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGChannelDeleteRequest.Generator.generate(roomID: channelRoom.id).success({ [weak self] (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelDeleteResponse as IGPChannelDeleteResponse:
                        let _ = IGChannelDeleteRequest.Handler.interpret(response: channelDeleteResponse)
                        if self?.navigationController is IGNavigationController {
                            _ = self?.navigationController?.popToRootViewController(animated: true)
                        }
                    default:
                        break
                    }
                    self?.hud.hide(animated: true)
                    
                }
            }).error ({ [weak self] (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        break
                    default:
                        break
                    }
                    self?.hud.hide(animated: true)
                }
            }).send()
        }
        
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChannelInfoSetMembers" {
            let destination = segue.destination as! IGMemberTableViewController
            destination.showMembersFilter = self.memberRole
            destination.room = room
        }
        if segue.identifier == "showGroupSharedMediaSetting" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        }
    }


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
        self.view.layoutIfNeeded()
    }
    
    
    private func detectCurrentSection(section: Int) -> Int {
        if (channelLink == nil || channelLink!.isEmpty) {
            if section >= 1 {
                return section + 1 // return section plus one because of remove link section
            }
        }
        return section
    }
    
    // MARK: -TableViewDelegates and Datasource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGProfileUserCell", for: indexPath as IndexPath) as! IGProfileUserCell
        let cellTwo = tableView.dequeueReusableCell(withIdentifier: "IGProfileUSerCellTypeTwo", for: indexPath as IndexPath) as! IGProfileUSerCellTypeTwo
        let cellTypeRed = tableView.dequeueReusableCell(withIdentifier: "IGProfileUserCellTypeRed", for: indexPath as IndexPath) as! IGProfileUserCellTypeRed
        
        let section = detectCurrentSection(section: indexPath.section)
        var row = indexPath.row
        if myRole != .owner {
            if (((channelLink != nil && !channelLink!.isEmpty) && section == 4) || ((channelLink == nil || channelLink!.isEmpty) && section == 3)) &&
                !(self.roomAccess?.getMember ?? false){
                row = 1
            }
        }
        
        switch section {
        case 0:
            if let desc = room?.channelRoom?.roomDescription , desc != ""{
                cell.initLabels(nameLblString: desc)
            } else {
                cell.initLabels(nameLblString: IGStringsManager.NoDetail.rawValue.localized)
            }
            return cell
            
        case 1:
            if let channelType = room?.channelRoom?.type {
                if channelType == .privateRoom {
                    cell.initLabels(nameLblString: channelLink)
                } else if channelType == .publicRoom {
                    cell.initLabels(nameLblString: IGStringsManager.Username.rawValue.localized, detailLblString: channelLink, changeColor: false)
                }
            }
            
            return cell
        case 2:
            switch row {
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
            switch row {
                
            case 0:
                if let memberCount = room?.channelRoom?.participantCount {
                    cell.initLabels(nameLblString: IGStringsManager.AllMembers.rawValue.localized,detailLblString: "\(memberCount)".inLocalizedLanguage(),changeColor : true, shouldChangeDetailDirection: true)
                }
                return cell
                
            case 1:
                cell.initLabels(nameLblString: IGStringsManager.Admin.rawValue.localized,detailLblString: "\(adminsCount)".inLocalizedLanguage(),changeColor : true, shouldChangeDetailDirection: true)
                return cell
                
            default:
                return cell
            }
            
        case 5:
            switch row {
            case 0 :
                cellTypeRed.initLabels(nameLblString: IGStringsManager.DeleteChannel.rawValue.localized,changeColor: true)
                return cellTypeRed
            default:
                return cellTypeRed
            }
            
        default:
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if room!.isParticipant == false {
            return 2
        }
        
        switch myRole {
            case .owner?:
            return 6
            
        case .admin?, .moderator?, .member? :
            var count = 4
            if self.roomAccess?.getMember ?? false || self.roomAccess?.addAdmin ?? false {
                count = 5
            }
            
            if channelLink == nil || channelLink!.isEmpty {
                count = count - 1
            }
            return count
            
        default:
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch detectCurrentSection(section: section) {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3 :
            return 1
        case 4 :
            var count = 0
            if self.roomAccess?.getMember ?? false {
                count = count + 1
            }
            if self.roomAccess?.addAdmin ?? false {
                count = count + 1
            }
            return count
        case 5 :
            return 1
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
        switch detectCurrentSection(section: section) {
        case 0:
            return IGStringsManager.Desc.rawValue.localized
        case 1:
            return IGStringsManager.Information.rawValue.localized
        case 2:
            return IGStringsManager.NotificationAndSound.rawValue.localized
        case 3:
            return IGStringsManager.SharedMedia.rawValue.localized
        case 4:
            return IGStringsManager.AllMembers.rawValue.localized

        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch detectCurrentSection(section: section) {
        case 0:
            return 80
            
        case 5:
            return 15
            
        default:
            return 30
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch detectCurrentSection(section: indexPath.section) {
        case 0:
            break
            
        case 1:
            showChannelLinkAlert()
            break
            
        case 2:
            break
            
        case 3:
            self.performSegue(withIdentifier: "showGroupSharedMediaSetting", sender: self)
            break
            
        case 4:
            switch indexPath.row {
            case 0 :
                memberRole = .all
                self.performSegue(withIdentifier: "showChannelInfoSetMembers", sender: self)
            case 1 :
                memberRole = .admin
                self.performSegue(withIdentifier: "showChannelInfoSetMembers", sender: self)
            case 2 :
                memberRole = .moderator
                self.performSegue(withIdentifier: "showChannelInfoSetMembers", sender: self)
                
            default:
                memberRole = .all
                self.performSegue(withIdentifier: "showChannelInfoSetMembers", sender: self)
            }
        case 5:
            switch indexPath.row {
            case 0 :
                showDeleteChannelActionSheet()
                break
            default:
                break
            }
        default:
            break
        }
    }
}
