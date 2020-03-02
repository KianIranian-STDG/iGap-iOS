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
import UserNotifications
import Contacts
import AddressBook
import messages
import webservice
import KeychainSwift
import SDWebImage
import MarkdownKit
import SwiftEventBus


class IGRecentsTableViewController: BaseTableViewController, UNUserNotificationCenterDelegate {
    var headerHeight: CGFloat = 0
    var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = ""
        searchController.searchBar.setValue(IGStringsManager.GlobalCancel.rawValue.localized, forKey: "cancelButtonText")
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [ThemeManager.currentTheme.NavigationFirstColor.cgColor, ThemeManager.currentTheme.NavigationSecondColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        
        return searchController
    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                self.setSearchBarGradient()
            }
        }
    }
    
    private func setSearchBarGradient() {
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [ThemeManager.currentTheme.NavigationFirstColor.cgColor, ThemeManager.currentTheme.NavigationSecondColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    
    var nameLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 13,weight: .bold)
        label.textColor = .black
        label.textAlignment = label.localizedDirection
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var testArray = [IGAvatarView]()
    var testLastMsgArray = [String]()
    var testImageArray = [UIImage]()
    static var visibleChat: [Int64 : Bool] = [:]
    var selectedRoomForSegue : IGRoom?
    var cellIdentifer = IGChatRoomListTableViewCell.cellReuseIdentifier()
    var rooms: Results<IGRoom>? = nil
    var notificationToken: NotificationToken?
    var hud = MBProgressHUD()
    var connectionStatus: IGAppManager.ConnectionStatus?
    static var connectionStatusStatic: IGAppManager.ConnectionStatus?
    static var needGetInfo: Bool = true
    let iGapStoreLink = URL(string: "https://new.sibapp.com/applications/igap")
    var cellId = "cellId"
    var singerName : String! = ""
    var songName : String! = ""
    var songTimer : Float! = 0.0
    private var roomTypeCache: [Int64:IGRoom.IGType] = [:]
    
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
                    self.setDefaultNavigationItem()
                default:
                    self.navItemInit()
                }
                break
            }
        }
    }
    
    private func navItemInit() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.setChatListsNavigationItems()

        navigationItem.rightViewContainer?.addAction { [weak self] in
            self?.showAlertOptions()
        }
    }
    
    private func showAlertOptions() {
        
        let alertController = UIAlertController(title: nil, message: IGStringsManager.WhichTypeOfMessage.rawValue.localized, preferredStyle: IGGlobal.detectAlertStyle())
        let myCloud = UIAlertAction(title: IGStringsManager.Cloud.rawValue.localized, style: .default, handler: { (action) in
            if let userId = IGAppManager.sharedManager.userID() {
                IGGlobal.prgShow()
                IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        SwiftEventBus.postToMainThread(EventBusManager.openRoom, sender: roomId)
                    }
                }).error({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                }).send()
            }
        })
        let newChat = UIAlertAction(title: IGStringsManager.NewChat.rawValue.localized, style: .default, handler: { (action) in
            let createChat = IGPhoneBookTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            createChat.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(createChat, animated: true)
        })
        let newGroup = UIAlertAction(title: IGStringsManager.NewGroup.rawValue.localized, style: .default, handler: { (action) in
            let createGroup = IGMemberAddOrUpdateState.instantiateFromAppStroryboard(appStoryboard: .Profile)
            createGroup.mode = "CreateGroup"
            createGroup.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(createGroup, animated: true)
        })
        let newChannel = UIAlertAction(title: IGStringsManager.NewChannel.rawValue.localized, style: .default, handler: { (action) in
            let createChannel = IGCreateNewChannelTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
            createChannel.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(createChannel, animated: true)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertController.addAction(myCloud)
        alertController.addAction(newChat)
        alertController.addAction(newGroup)
        alertController.addAction(newChannel)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setDefaultNavigationItem() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navItemInit()
        
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if navigationItem.searchController == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        let _ : String = SMLangUtil.loadLanguage()
        self.hideKeyboardWhenTappedAround()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initialiseSearchBar()
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    
    private func initTheme() {
        setTabbarBadge()
        setSearchBarGradient()
        initialiseSearchBar()
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        self.tableView.reloadData() //in order to update unread count color of each cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isfromPacket = false
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.initNavBarWithIgapIcon()

        self.tableView.bounces = false
        self.searchController.searchBar.delegate = self
        self.tableView.contentOffset = CGPoint(x: 0, y: 55)
        self.tableView.register(IGRoomListtCell.self, forCellReuseIdentifier: cellId)
        
        let sortProperties = [SortDescriptor(keyPath: "priority", ascending: false), SortDescriptor(keyPath: "pinId", ascending: false), SortDescriptor(keyPath: "sortimgTimestamp", ascending: false)]
        do {
            let realm = try Realm()
            self.rooms = realm.objects(IGRoom.self).filter("isParticipant = 1").sorted(by: sortProperties)
        } catch _ as NSError {
            print("RLM EXEPTION ERR HAPPENDED IN VIEWDIDLOAD:",String(describing: self))
        }
        
        self.tableView.tableFooterView = UIView()
        self.view.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.tableView.tableHeaderView?.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { [weak self] (connectionStatus) in
            self?.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        self.addRoomChangeNotificationBlock()
        
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            if IGRecentsTableViewController.needGetInfo {
                IGHelperGetShareData.manageShareDate()
                self.checkAppVersion()
                self.checkPermission()
                self.fetchRoomList()
            }
        }
        
        // use current line for enable support gif in SDWebImage library
        SDWebImageCodersManager.sharedInstance().addCoder(SDWebImageGIFCoder.shared())
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_ROOM_PAGE)
        self.hidesBottomBarWhenPushed = false
        
        eventBusInitialiser()
    }
    
    private func eventBusInitialiser() {
        
        /***** unregister all events for avoid from duplicate regsiteration for an event *****/
        unregisterEventBus()
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.initTheme) { [weak self] result in
            self?.initTheme()
        }
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.showTopMusicPlayer) { [weak self] result in
            let musicFile : MusicFile = result?.object as! MusicFile
            IGGlobal.topBarSongTime = musicFile.songTime
            self?.songName = musicFile.songName
            self?.singerName = musicFile.singerName
            self?.showMusicTopPlayerWithAnimation()
        }
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.hideTopMusicPlayer) { [weak self] result in
            self?.hideMusicTopPlayerWithAnimation()
        }
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.stopMusicPlayer) { [weak self] result in
            self?.playMusic()
        }
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.playMusicPlayer) { [weak self] result in
            self?.stopMusic()
        }
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.updateLabelsData) { [weak self] result in
            self?.updateLabelsData(singerName: IGGlobal.topBarSongSinger,songName: IGGlobal.topBarSongName)
        }
        
        SwiftEventBus.on(IGGlobal.eventBusObject, name: EventBusManager.login, queue: OperationQueue.current) { [weak self] (result) in
            self?.userDidLogin()
        }
        
        SwiftEventBus.onMainThread(IGGlobal.eventBusObject, name: EventBusManager.openRoom) { [weak self] (result) in
            if let roomId = result?.object as? Int64 {
                self?.openRoom(roomId: roomId)
            }
        }
        
        SwiftEventBus.on(IGGlobal.eventBusObject, name: EventBusManager.changeDirection, queue: OperationQueue.current) { [weak self] (result) in
            self?.changeDirectionOfUI()
        }
        
        /***** Receive Message *****/
        SwiftEventBus.on(IGGlobal.eventBusObject, name: EventBusManager.messageReceiveGlobal, queue: OperationQueue.current) { [weak self]  result in
            if let messageInfo = result?.object as? (roomId: Int64, messages: [IGPRoomMessage]) {
                for message in messageInfo.messages {
                    var roomType: IGRoom.IGType = .chat
                    var roomMessageStatus: IGRoomMessageStatus = .delivered
                    
                    if let type = self?.roomTypeCache[messageInfo.roomId] {
                        roomType = type
                    } else {
                        if let roomInfo = IGDatabaseManager.shared.realm.objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", messageInfo.roomId)).first {
                            roomType = roomInfo.type
                            self?.roomTypeCache[messageInfo.roomId] = roomType
                        }
                    }
                    
                    let seenStatus = IGRecentsTableViewController.visibleChat[messageInfo.roomId]
                    if seenStatus != nil && seenStatus! {
                        roomMessageStatus = .seen
                    }
                    
                    IGFactory.shared.manageUnreadMessage(roomId: messageInfo.roomId, roomType: roomType, message: message)
                    IGHelperMessageStatus.shared.sendStatus(roomId: messageInfo.roomId, roomType: roomType, status: roomMessageStatus, roomMessages: [message])
                }
            }
        }
    }
    
    private func unregisterEventBus(){
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.initTheme)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.showTopMusicPlayer)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.hideTopMusicPlayer)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.stopMusicPlayer)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.playMusicPlayer)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.updateLabelsData)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.login)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.openRoom)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.changeDirection)
        SwiftEventBus.unregister(IGGlobal.eventBusObject, name: EventBusManager.messageReceiveGlobal)
    }
    
    @objc func updateLabelsData(singerName: String!,songName: String!) {
        self.tableView.beginUpdates()
        let sectionToReload = 0
        let indexSet: IndexSet = [sectionToReload]

        self.tableView.reloadSections(indexSet, with: .automatic)
        self.tableView.endUpdates()
    }
    
    private func hideMusicTopPlayerWithAnimation() {
        self.tableView.beginUpdates()
        self.headerHeight = 0
        self.tableView.endUpdates()
        IGPlayer.shared.stopMedia()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
        }
    }
    
    private func showMusicTopPlayerWithAnimation() {
        self.tableView.beginUpdates()
        self.headerHeight = 40
        
        self.tableView.endUpdates()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.tableView.layoutIfNeeded()
        }
    }
    
    private func stopMusic() {
        IGPlayer.shared.pauseMusic()
    }
    
    private func playMusic() {
        IGPlayer.shared.playMusic()
    }
    
    private func changeDirectionOfUI() {
        let _ : String = SMLangUtil.loadLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isfromPacket = false
        
        setDefaultNavigationItem()

        DispatchQueue.main.async {
            if let navigationItem = self.navigationItem as? IGNavigationItem {
                IGTabBarController.currentTabStatic = .Recent
                navigationItem.addiGapLogo()
            }
        }
        //self.addRoomChangeNotificationBlock()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.isUserInteractionEnabled = true
        if currentTabIndex == TabBarTab.Recent.rawValue {
            if let navigationBar = self.navigationController?.navigationBar {
                navigationBar.backgroundColor = .clear
            }
        }
    }
    
    deinit {
        print("Deinit IGRecentsTableViewController")
    }
    
    //MARK: Room List actions
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    private func userDidLogin() {
        IGHelperGetShareData.manageShareDate()
        self.checkAppVersion()
        self.checkPermission()
        self.addRoomChangeNotificationBlock()
        self.fetchRoomList()
    }
    
    /* check app need update or is deprecated now and don't allow */
    private func checkAppVersion() {
        DispatchQueue.main.async {
            if AppDelegate.isDeprecatedClient {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.DepricatedVersion.rawValue.localized, doneText: IGStringsManager.Update.rawValue.localized,cancelText: IGStringsManager.GlobalClose.rawValue.localized ,done: {
                    UIApplication.shared.open(self.iGapStoreLink!, options: [:], completionHandler: nil)
                })
            } else if AppDelegate.isUpdateAvailable {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .question, title: IGStringsManager.Update.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.NewVersionAvailable.rawValue.localized, doneText: IGStringsManager.Update.rawValue.localized,cancelText: IGStringsManager.GlobalClose.rawValue.localized ,done: {
                    UIApplication.shared.open(self.iGapStoreLink!, options: [:], completionHandler: nil)
                })
            }
        }
    }
    
    private func checkPermission() {
        
        /********** Contact Permission **********/
        CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
            IGContactManager.sharedManager.manageContact()
            
            /********** Microphon Permission **********/
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                
                /********** Receive Notification Permission **********/
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .carPlay]
                    UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
                }
            }
        })
    }
    
    private func addRoomChangeNotificationBlock() {
        self.notificationToken?.invalidate()
        
        self.notificationToken = rooms!.observe { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self?.setTabbarBadge()
                break
                
            case .update(_, let deletions, let insertions, let modifications):
                // Query messages have changed, so apply them to the TableView
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .none)
                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .none)
                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .none)
                self?.tableView.endUpdates()
                self?.setTabbarBadge()
                break
                
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
    }
    
    @objc private func fetchRoomList(offset: Int32 = 0 , limit: Int32 = Int32(IGAppManager.sharedManager.LOAD_ROOM_LIMIT)) {
        
        var clientConditionRooms: [IGPClientCondition.IGPRoom]?
        if offset == 0 { // is first page
            clientConditionRooms = IGClientCondition.computeClientCondition()
        }
        
        IGAppManager.sharedManager.allowFetchRoomList = false
        IGClientGetRoomListRequest.Generator.generate(offset: offset, limit: limit).successPowerful ({ [weak self] (responseProtoMessage, requestWrapper) in
            if let getRoomListResponse = responseProtoMessage as? IGPClientGetRoomListResponse {
                if let getRoomListRequest = requestWrapper.message as? IGPClientGetRoomList {
                    let fetchedCount = IGClientGetRoomListRequest.Handler.interpret(response: getRoomListResponse)
                    
                    if getRoomListRequest.igpPagination.igpOffset == 0 { // is first page
                        IGFactory.shared.markRoomsAsDeleted(igpRooms: getRoomListResponse.igpRooms)
                        IGClientGetPromoteRequest.fetchPromotedRooms()
                        IGClientConditionRequest.sendRequest(clientConditionRooms: clientConditionRooms!)
                        if getRoomListResponse.igpRooms.count == 0 {
                            print("AAA || Warning! -------- Offset & Count is ZERO")
                        }
                    }
                    IGAppManager.sharedManager.fetchRoomListOffset = Int(getRoomListRequest.igpPagination.igpOffset) + getRoomListResponse.igpRooms.count
                    
                    if fetchedCount == IGAppManager.sharedManager.LOAD_ROOM_LIMIT { // this means rooms list not reached to end yet
                        IGAppManager.sharedManager.allowFetchRoomList = true
                        
                        if self?.tableView.indexPathsForVisibleRows?.last?.row ?? 0 > IGAppManager.sharedManager.fetchRoomListOffset {
                            self?.loadMoreRooms()
                        }
                    }
                }
            }
        }).error({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self?.fetchRoomList(offset: offset, limit: limit)
                break
                
            case .floodRequest:
                IGWebSocketManager.sharedManager.closeConnection()
                break
                
            default:
                break
            }
        }).send()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return IGHelperMusicPlayer.shared.showTopMusicPlayer(view: self, songTime: IGGlobal.topBarSongTime, singerName: IGGlobal.topBarSongSinger, songName: IGGlobal.topBarSongName)
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row + 1 == IGAppManager.sharedManager.fetchRoomListOffset {
            loadMoreRooms()
        }

        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId) as! IGRoomListtCell
        
        if self.rooms![indexPath.row].unreadCount == 0 {
            cell.showStateImage =  true
        } else {
            cell.showStateImage =  false
        }
        cell.roomII = self.rooms![indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let room = rooms![indexPath.row]
        var muteTitle = IGStringsManager.UnMute.rawValue.localized
        if room.mute == IGRoom.IGRoomMute.mute {
            muteTitle = IGStringsManager.UnMute.rawValue.localized
        } else {
            muteTitle = IGStringsManager.Mute.rawValue.localized
        }
        
        var pinTitle = IGStringsManager.Pin.rawValue.localized
        if room.pinId > 0 {
            pinTitle = IGStringsManager.UnPin.rawValue.localized
        }
        //MUTE
        let btnMuteSwipeCell = UIContextualAction(style: .normal, title: muteTitle) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action
            
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

            } else {
                self.muteRoom(room: room)
                
            }
        }
        
        
        btnMuteSwipeCell.backgroundColor = UIColor.swipeGray()
        
        //PIN
        let btnPinSwipeCell = UIContextualAction(style: .normal, title: pinTitle) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action

            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            } else {
                self.pinRoom(room: room)
            }
        }
        btnPinSwipeCell.backgroundColor = UIColor.swipeBlueGray()
        
        
        //MORE
        let btnMoreSwipeCell = UIContextualAction(style: .normal, title: IGStringsManager.More.rawValue.localized) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action

            let title = room.title != nil ? room.title! : IGStringsManager.Delete.rawValue.localized
            let alertC = UIAlertController(title: title, message: IGStringsManager.WhatToDo.rawValue.localized, preferredStyle: IGGlobal.detectAlertStyle())
            let clear = UIAlertAction(title: IGStringsManager.ClearHistory.rawValue.localized, style: .default, handler: { (action) in
                switch room.type{
                case .chat:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                    } else {
                        self.clearChatMessageHistory(room: room)
                    }
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                    } else {
                        self.clearGroupMessageHistory(room: room)
                    }
                default:
                    break
                }
            })
            
            let clearLocalMessage = UIAlertAction(title: IGStringsManager.CLearCashe.rawValue.localized, style: .default, handler: { (action) in
                IGRoomMessage.clearLocalMessage(roomId: room.id)
            })
            
            let mute = UIAlertAction(title: muteTitle, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                } else {
                    self.muteRoom(room: room)
                }
            })
            
            let pin = UIAlertAction(title: pinTitle, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                } else {
                    self.pinRoom(room: room)
                }
            })
            
            let report = UIAlertAction(title: IGStringsManager.Report.rawValue.localized, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                } else {
                    self.report(room: room)
                }
            })
            
            let remove = UIAlertAction(title: IGStringsManager.Delete.rawValue.localized, style: .destructive, handler: { (action) in
                switch room.type {
                case .chat:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                    } else {
                        self.deleteChat(room: room)
                    }
                    break
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                    } else {
                        self.deleteGroup(room: room)
                    }
                    break
                case .channel:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                    } else {
                        self.deleteChannel(room: room)
                    }
                    break
                }
            })
            
            let leave = UIAlertAction(title: IGStringsManager.Leave.rawValue.localized, style: .destructive, handler: { (action) in
                switch room.type {
                case .chat:
                    break
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                        
                    } else {
                        self.leaveGroup(room: room)
                    }
                case .channel:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {

                        
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )

                    } else {
                        self.leaveChannel(room: room)
                    }
                }
            })
            
            let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
            
            if room.type == .chat || room.type == .group {
                alertC.addAction(clear)
            }
            
            alertC.addAction(pin)
            alertC.addAction(clearLocalMessage)
            alertC.addAction(mute)
            alertC.addAction(report)
            
            if room.chatRoom != nil {
                alertC.addAction(remove)
            } else {
                if let groupRoom = room.groupRoom {
                    if groupRoom.role == .owner {
                        if groupRoom.publicExtra == nil { // owner can leave just from private
                            alertC.addAction(leave)
                        }
                        alertC.addAction(remove)
                    } else{
                        alertC.addAction(leave)
                    }
                } else if let channel = room.channelRoom {
                    if channel.role == .owner {
                        if channel.publicExtra == nil { // owner can leave just from private
                            alertC.addAction(leave)
                        }
                        alertC.addAction(remove)
                    } else{
                        alertC.addAction(leave)
                    }
                }
            }
            
            alertC.addAction(cancel)
            
            self.present(alertC, animated: true, completion: nil)
            
            
        }
        btnMoreSwipeCell.backgroundColor = UIColor.swipeDarkBlue()
        
        
        
        let config = UISwipeActionsConfiguration(actions: [btnMuteSwipeCell, btnPinSwipeCell, btnMoreSwipeCell])
        
        config.performsFirstActionWithFullSwipe = false
        return config
        
    }
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoomForSegue = rooms![indexPath.row]
        if selectedRoomForSegue == nil || selectedRoomForSegue!.isInvalidated {
            return
        }
        
        if IGGlobal.isForwardEnable() {
            IGHelperAlert.shared.showForwardAlert(title: selectedRoomForSegue!.title!, isForbidden: selectedRoomForSegue!.isReadOnly, cancelForward: {
                IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            }, done: {
                self.performSegue(withIdentifier: "showRoomMessages", sender: self)
            })
        } else {
            performSegue(withIdentifier: "showRoomMessages", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true

        if (segue.identifier == "showRoomMessages") {
            
            let destination = segue.destination as! IGMessageViewController
            destination.hidesBottomBarWhenPushed = true
            destination.room = selectedRoomForSegue
            
        } else if segue.identifier == "createANewGroup" {
            let destination = segue.destination as! IGNavigationController
            destination.hidesBottomBarWhenPushed = true
            let chooseContactTv =  destination.topViewController as! IGMemberAddOrUpdateState
            chooseContactTv.mode = "CreateGroup"
        } else if segue.identifier == "showReportPage" {
            let report = segue.destination as! IGReport
            report.hidesBottomBarWhenPushed = true
            report.room = selectedRoomForSegue
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    //MARK: - Tabbar badge
    func setTabbarBadge() {
        var unreadCount = 0
        do {
            let realm = try Realm()
            let rooms = realm.objects(IGRoom.self).filter("isParticipant = 1 AND muteRoom = %d", IGRoom.IGRoomMute.unmute.rawValue)
            unreadCount = rooms.sum(ofProperty: "unreadCount")
            if unreadCount == 0 {
                self.tabBarController?.tabBar.items?[2].badgeValue = nil
            } else {
                self.tabBarController?.tabBar.items?[2].badgeValue = "\(unreadCount)".inLocalizedLanguage()
            }
            self.tabBarController?.tabBar.items?[2].setBadgeTextAttributes([
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.igFont(ofSize: 15)
                ], for: .normal)

            
        } catch _ as NSError {
            // handle error
            print("RLM EXEPTION ERR HAPPENDED IN SET TABBAR BADGE:",String(describing: self))
            
        }
        
        if !AppDelegate.appIsInBackground {
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }
    }
    
    
    func openRoom(roomId: Int64) {
        let predicate = NSPredicate(format: "id = %lld", roomId)
        if let room = rooms!.filter(predicate).first {
            let chatPage = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            chatPage.room = room
            chatPage.hidesBottomBarWhenPushed = true
            UIApplication.topNavigationController()!.pushViewController(chatPage, animated: true)
        } else {
            IGGlobal.prgShow()
            IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ [weak self] (protoResponse) in
                IGGlobal.prgHide()
                if let clientGetRoomResponse = protoResponse as? IGPClientGetRoomResponse {
                    IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self?.openRoom(roomId: clientGetRoomResponse.igpRoom.igpID)
                    }
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
            }).send()
        }
    }
}


extension IGRecentsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        if remaining < 100 {
            self.loadMoreRooms()
        }
    }
    
    func loadMoreRooms() {
        if IGAppManager.sharedManager.allowFetchRoomList {
            fetchRoomList(offset: Int32(IGAppManager.sharedManager.fetchRoomListOffset), limit: Int32(IGAppManager.sharedManager.LOAD_ROOM_LIMIT))
        }
    }
}



//MARK:- Room Clear, Delete, Leave
extension IGRecentsTableViewController {
    func clearChatMessageHistory(room: IGRoom) {
        IGGlobal.prgShow()
        IGChatClearMessageRequest.Generator.generate(room: room).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let clearChatMessages = protoResponse as? IGPChatClearMessageResponse {
                IGChatClearMessageRequest.Handler.interpret(response: clearChatMessages)
            }
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func clearGroupMessageHistory(room: IGRoom) {
        IGGlobal.prgShow()
        IGGroupClearMessageRequest.Generator.generate(group: room).success({ (protoResponse) in
            if let deleteGroupMessageHistory = protoResponse as? IGPGroupClearMessageResponse {
                IGGroupClearMessageRequest.Handler.interpret(response: deleteGroupMessageHistory)
            }
            IGGlobal.prgHide()
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func muteRoom(room: IGRoom) {
        
        let roomId = room.id
        var roomMute = IGRoom.IGRoomMute.mute
        if room.mute == IGRoom.IGRoomMute.mute {
            roomMute = .unmute
        }
        
        IGGlobal.prgShow()
        IGClientMuteRoomRequest.Generator.generate(roomId: roomId, roomMute: roomMute).success({ (protoResponse) in
            IGGlobal.prgHide()
            if let muteRoomResponse = protoResponse as? IGPClientMuteRoomResponse {
                IGClientMuteRoomRequest.Handler.interpret(response: muteRoomResponse)
            }
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func pinRoom(room: IGRoom) {
        
        let roomId = room.id
        var pin = true
        if room.pinId > 0 {
            pin = false
        }
        
        if pin {
            // check number of pined rooms limitation
            if self.rooms?.filter({
                IGRoom.isPin(roomId: $0.id)
            }).count ?? 0 >= 5 {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: false, message: IGStringsManager.MaxPinAlert.rawValue.localized, doneText: IGStringsManager.GlobalOK.rawValue.localized)
                return
            }
        }
        
        IGGlobal.prgShow()
        IGClientPinRoomRequest.Generator.generate(roomId: roomId, pin: pin).success({ [weak self] (protoResponse) in
            IGGlobal.prgHide()
            if let pinRoomResponse = protoResponse as? IGPClientPinRoomResponse {
                IGClientPinRoomRequest.Handler.interpret(response: pinRoomResponse)
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func reportRoom(roomId: Int64, reason: IGPClientRoomReport.IGPReason) {
        IGGlobal.prgShow()
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, reason: reason).success({ (protoResponse) in
            IGGlobal.prgHide()
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.ReportSent.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
            switch errorCode {
            case .timeout:
                break
                
            case .clientRoomReportReportedBefore:
                break
                
            case .clientRoomReportForbidden:
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "Room Report Fobidden", cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                
                break
            default:
                break
            }
        }).send()
    }
    
    func reportUser(userId: Int64, reason: IGPUserReport.IGPReason) {
        IGGlobal.prgShow()
        IGUserReportRequest.Generator.generate(userId: userId, reason: reason).success({ (protoResponse) in
            IGGlobal.prgHide()
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.ReportSent.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
            switch errorCode {
            case .timeout:
                break
                
            case .userReportReportedBefore:
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UserReportedBefore.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                break
                
            case .userReportForbidden:
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "User Report Forbidden.", cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                break
                
            default:
                break
            }
        }).send()
    }
    
    func deleteChat(room: IGRoom) {
        IGGlobal.prgShow()
        IGChatDeleteRequest.Generator.generate(room: room).success({ (protoResponse) in
            if let deleteChat = protoResponse as? IGPChatDeleteResponse {
                IGChatDeleteRequest.Handler.interpret(response: deleteChat)
            }
            IGGlobal.prgHide()
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func deleteGroup(room: IGRoom) {
        IGGlobal.prgShow()
        IGGroupDeleteRequest.Generator.generate(group: room).success({ (protoResponse) in
            if let deleteGroup = protoResponse as? IGPGroupDeleteResponse {
                IGGroupDeleteRequest.Handler.interpret(response: deleteGroup)
            }
            IGGlobal.prgHide()
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func leaveGroup(room: IGRoom) {
        IGGlobal.prgShow()
        IGGroupLeftRequest.Generator.generate(room: room).success{ (protoResponse) in
            if let response = protoResponse as? IGPGroupLeftResponse {
                IGGroupLeftRequest.Handler.interpret(response: response)
            }
            IGGlobal.prgHide()
        }.error { (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                default:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "There was an error leaving this group.", cancelText: IGStringsManager.GlobalClose.rawValue.localized )
                }
                IGGlobal.prgHide()
            }
        }.send()
    }
    
    func leaveChannel(room: IGRoom) {
        IGGlobal.prgShow()
        IGChannelLeftRequest.Generator.generate(room: room).success { (protoResponse) in
            if let response = protoResponse as? IGPChannelLeftResponse {
                IGChannelLeftRequest.Handler.interpret(response: response)
            }
            IGGlobal.prgHide()
        }.error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    func deleteChannel(room: IGRoom) {
        IGGlobal.prgShow()
        IGChannelDeleteRequest.Generator.generate(roomID: room.id).success({ (protoResponse) in
            if let deleteChannel = protoResponse as? IGPChannelDeleteResponse {
                let _ = IGChannelDeleteRequest.Handler.interpret(response: deleteChannel)
            }
            IGGlobal.prgHide()
        }).error({ (errorCode , waitTime) in
            IGGlobal.prgHide()
        }).send()
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
                self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.abuse)
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.abuse)
            }
        })
        
        let spam = UIAlertAction(title: IGStringsManager.Spam.rawValue.localized, style: .default, handler: { (action) in
            
            if roomType == .chat {
                self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.spam)
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.spam)
            }
        })
        
        let fakeAccount = UIAlertAction(title: IGStringsManager.FakeAccount.rawValue.localized, style: .default, handler: { (action) in
            self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.fakeAccount)
        })
        
        let violence = UIAlertAction(title: IGStringsManager.Violence.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: IGStringsManager.Pornography.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let other = UIAlertAction(title: IGStringsManager.Other.rawValue.localized, style: .default, handler: { (action) in
            self.selectedRoomForSegue = room
            self.performSegue(withIdentifier: "showReportPage", sender: self)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertC.addAction(abuse)
        alertC.addAction(spam)
        if roomType == .chat {
            alertC.addAction(fakeAccount)
        } else {
            alertC.addAction(violence)
            alertC.addAction(pornography)
        }
        alertC.addAction(other)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    } 
}


extension IGRecentsTableViewController {
    
    private func initialiseSearchBar() {
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = ThemeManager.currentTheme.BackGroundColor
                for view in backgroundview.subviews {
                    view.backgroundColor = .clear
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;                
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14, weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
                searchBarCancelButton.setTitleColor(UIColor.white, for: .normal)
            }

            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeHolderInsideSearchField.textColor = ThemeManager.currentTheme.LabelColor
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = IGStringsManager.SearchPlaceHolder.rawValue.localized
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15, weight: .bold)
            }
        }
        self.setSearchBarGradient()
    }
}

//MARK: SEARCH BAR DELEGATE
extension IGRecentsTableViewController: UISearchBarDelegate/*, UISearchResultsUpdating*/ {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Filter function
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchController.isActive = false
        let lookAndFind = IGLookAndFind.instantiateFromAppStroryboard(appStoryboard: .Setting)
        lookAndFind.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(lookAndFind, animated: false)
        return false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        searchBar.text = String()
        searchBar.resignFirstResponder()
    }
}



