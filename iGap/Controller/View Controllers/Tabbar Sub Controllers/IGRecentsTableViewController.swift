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
import UserNotifications
import Contacts
import AddressBook
import Hero
import messages
import webservice
import KeychainSwift
import SDWebImage
import MarkdownKit


class IGRecentsTableViewController: BaseTableViewController, MessageReceiveObserver, UNUserNotificationCenterDelegate, ForwardStartObserver {
    
    var searchController : UISearchController = {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = ""
        searchController.searchBar.setValue("CANCEL_BTN".localizedNew, forKey: "cancelButtonText")
        
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
//        gradient.locations = orangeGradientLocation as [NSNumber]

        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        
        return searchController

    }()
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                // appearance has changed
                // Update your user interface based on the appearance
                self.setSearchBarGradient()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setSearchBarGradient() {
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
//        gradient.locations = orangeGradientLocation as [NSNumber]
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        
    }
    
    var nameLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 13,weight: .bold)
        label.textColor = .black
        label.textAlignment = label.localizedNewDirection
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var testArray = [IGAvatarView]()
    var testLastMsgArray = [String]()
    var testImageArray = [UIImage]()
    static var messageReceiveDelegat: MessageReceiveObserver!
    static var forwardStartObserver: ForwardStartObserver!
    static var visibleChat: [Int64 : Bool] = [:]
    var selectedRoomForSegue : IGRoom?
    var cellIdentifer = IGChatRoomListTableViewCell.cellReuseIdentifier()
    var rooms: Results<IGRoom>? = nil
    var notificationToken: NotificationToken?
    var hud = MBProgressHUD()
    var connectionStatus: IGAppManager.ConnectionStatus?
    static var connectionStatusStatic: IGAppManager.ConnectionStatus?
    var isLoadingMoreRooms: Bool = false
    var numberOfRoomFetchedInLastRequest: Int = -1
    var allRoomsFetched = false // use this param for send contact after load all rooms
    static var needGetInfo: Bool = true
    let iGapStoreLink = URL(string: "https://new.sibapp.com/applications/igap")
    var cellId = "cellId"
    
    private let disposeBag = DisposeBag()
    
    private func updateNavigationBarBasedOnNetworkStatus(_ status: IGAppManager.ConnectionStatus) {
        
        if let navigationItem = self.tabBarController?.navigationItem as? IGNavigationItem {
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
                    self.setLastNavigationItem()
                }
                break
            }
        }
    }
    
    private func setLastNavigationItem() {
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        self.hideKeyboardWhenTappedAround()

        if currentTabIndex == TabBarTab.Dashboard.rawValue { // Discovery Tab
            let navigationControllerr = self.navigationController as! IGNavigationController
            let numberOfPages = navigationControllerr.viewControllers.count
            //Hint: - check if we are at the root of navigation or we are in Inner pages
            if numberOfPages == 1 {
                navigationItem.setDiscoveriesNavigationItems()
            }
            
        } else if currentTabIndex == TabBarTab.Contact.rawValue { // Phone Book Tab
            let navigationControllerr = self.navigationController as! IGNavigationController
            let numberOfPages = navigationControllerr.viewControllers.count
            //Hint: - check if we are at the root of navigation or we are in Inner pages
            if numberOfPages == 1 {
                navigationItem.setPhoneBookNavigationItems()
            }
            
        } else if currentTabIndex == TabBarTab.Call.rawValue { // Call List Tab
            let navigationControllerr = self.navigationController as! IGNavigationController
            let numberOfPages = navigationControllerr.viewControllers.count
            //Hint: - check if we are at the root of navigation or we are in Inner pages
            if numberOfPages == 1 {
                navigationItem.addiGapLogo()
            }

        } else if currentTabIndex == TabBarTab.Profile.rawValue { // Profile Tab
            let navigationControllerr = self.navigationController as! IGNavigationController
            let numberOfPages = navigationControllerr.viewControllers.count
            //Hint: - check if we are at the root of navigation or we are in Inner pages
            if numberOfPages == 1 {
                navigationItem.addiGapLogo()
            }

        } else if currentTabIndex == TabBarTab.Recent.rawValue { // Recent Tab
            let navigationControllerr = self.navigationController as! IGNavigationController
            let numberOfPages = navigationControllerr.viewControllers.count
            //Hint: - check if we are at the root of navigation or we are in Inner pages
            if numberOfPages == 1 {
                navigationItem.setChatListsNavigationItems()
            }
            
        } else {
            navigationItem.addiGapLogo()
        }

    }
    
    private func navItemInit() {
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setChatListsNavigationItems()

        navigationItem.rightViewContainer?.addAction {
            
            if IGTabBarController.currentTabStatic == .Call {
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
                
                let newChat = UIAlertAction(title: "NEW_CALL".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                    let createChat = IGCreateNewChatTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                    createChat.forceCall = true
                    self.navigationController!.pushViewController(createChat, animated: true)
                })
                
                let clearCallLog = UIAlertAction(title: "CLEAR_HISTORY".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                    if IGAppManager.sharedManager.userID() != nil {
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.mode = .indeterminate
                        
                        let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
                        do {
                            let realm = try Realm()
                            guard let clearId = realm.objects(IGRealmCallLog.self).sorted(by: sortProperties).first?.id else {
                                return
                            }
                            
                            IGSignalingClearLogRequest.Generator.generate(clearId: clearId).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    if let clearLogResponse = protoResponse as? IGPSignalingClearLogResponse {
                                        IGSignalingClearLogRequest.Handler.interpret(response: clearLogResponse)
                                        hud.hide(animated: true)
                                    }
                                }
                            }).error({ (errorCode, waitTime) in
                                DispatchQueue.main.async {
                                    switch errorCode {
                                    case .timeout:
                                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        alert.addAction(okAction)
                                        self.present(alert, animated: true, completion: nil)
                                    default:
                                        break
                                    }
                                    self.hud.hide(animated: true)
                                }
                            }).send()
                            
                        } catch let error as NSError {
                            print("RLM EXEPTION ERR HAPPENDED IN SET DEFAULT NAVIGATION ITEM :",String(describing: self))
                        }
                        
                    }
                })
                
                let cancel = UIAlertAction(title: "CANCEL_BTN".RecentTableViewlocalizedNew, style: .cancel, handler: nil)
                
                alertController.addAction(newChat)
                alertController.addAction(clearCallLog)
                alertController.addAction(cancel)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let alertController = UIAlertController(title: "NEW_MESSAGES".RecentTableViewlocalizedNew, message: "WHICH_TYPE_OF".RecentTableViewlocalizedNew, preferredStyle: IGGlobal.detectAlertStyle())
            let myCloud = UIAlertAction(title: "MY_CLOUD".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                if let userId = IGAppManager.sharedManager.userID() {
                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud.mode = .indeterminate
                    IGChatGetRoomRequest.Generator.generate(peerId: userId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let chatGetRoomResponse as IGPChatGetRoomResponse:
                                let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                //segue to created chat
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                                                object: nil,
                                                                userInfo: ["room": roomId])
                                hud.hide(animated: true)
                                break
                            default:
                                break
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            hud.hide(animated: true)
                            let alertC = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "UNSSUCCESS_OTP".RecentTableViewlocalizedNew, preferredStyle: .alert)
                            
                            let cancel = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            })
            let newChat = UIAlertAction(title: "NEW_C_C".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                let createChat = IGCreateNewChatTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                self.navigationController!.pushViewController(createChat, animated: true)
            })
            let newGroup = UIAlertAction(title: "NEW_GROUP".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                let createGroup = IGChooseMemberFromContactsToCreateGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                createGroup.mode = "CreateGroup"
                self.navigationController!.pushViewController(createGroup, animated: true)
            })
            let newChannel = UIAlertAction(title: "NEW_CHANNEL".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                let createChannel = IGCreateNewChannelTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                self.navigationController!.pushViewController(createChannel, animated: true)
            })
            
            let cancel = UIAlertAction(title: "CANCEL_BTN".RecentTableViewlocalizedNew, style: .cancel, handler: { (action) in
                
            })
            
            alertController.addAction(myCloud)
            alertController.addAction(newChat)
            alertController.addAction(newGroup)
            alertController.addAction(newChannel)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationItem.leftViewContainer?.addAction {

            }
        }

    }
    private func setDefaultNavigationItem() {
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
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
    override func viewDidLoad() {
        super.viewDidLoad()
        isfromPacket = false
        self.tableView.scrollsToTop = false
        self.tableView.bounces = false
        self.searchController.searchBar.delegate = self
        self.tableView.contentOffset = CGPoint(x: 0, y: 55)

//        initialiseSearchBar()
        IGRecentsTableViewController.forwardStartObserver = self
        IGRecentsTableViewController.messageReceiveDelegat = self
        self.tableView.register(IGRoomListtCell.self, forCellReuseIdentifier: cellId)
        
        
        let sortProperties = [SortDescriptor(keyPath: "priority", ascending: false), SortDescriptor(keyPath: "pinId", ascending: false), SortDescriptor(keyPath: "sortimgTimestamp", ascending: false)]
        do {
            let realm = try Realm()
            self.rooms = realm.objects(IGRoom.self).filter("isParticipant = 1").sorted(by: sortProperties)
            
        } catch let error as NSError {
            print("RLM EXEPTION ERR HAPPENDED IN VIEWDIDLOAD:",String(describing: self))
        }
        //        self.tableView.register(IGChatRoomListTableViewCell.nib(), forCellReuseIdentifier: IGChatRoomListTableViewCell.cellReuseIdentifier())
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.view.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        
        
        setDefaultNavigationItem()
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        self.addRoomChangeNotificationBlock()
        
        if IGAppManager.sharedManager.isUserLoggiedIn() {
            if IGRecentsTableViewController.needGetInfo {
                self.checkAppVersion()
                self.deleteChannelMessages()
                DispatchQueue.global(qos: .userInteractive).async {
                    self.fetchRoomList()
                }
            }
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.userDidLogin),
                                                   name: NSNotification.Name(rawValue: kIGUserLoggedInNotificationName),
                                                   object: nil)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(segueToChatNotificationReceived(_:)),
                                               name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                               object: nil)
        
        /* detect contact change */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addressBookDidChange(_:)),
                                               name: NSNotification.Name.CNContactStoreDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.changeDirectionOfUI),
                                               name: NSNotification.Name(rawValue: kIGGoBackToMainNotificationName),
                                               object: nil)
        
        // use current line for enable support gif in SDWebImage library
        SDWebImageCodersManager.sharedInstance().addCoder(SDWebImageGIFCoder.shared())
        
        IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_ROOM_PAGE)
        
    }
    
    @objc private func changeDirectionOfUI() {
        let _ : String = SMLangUtil.loadLanguage()
    }
    
    @objc func addressBookDidChange(_ notification: UITapGestureRecognizer) {
        if !IGContactManager.syncedPhoneBookContact {
            IGContactManager.syncedPhoneBookContact = true
            IGContactManager.sharedManager.manageContact()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setChatListsNavigationItems()
        
                
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if navigationItem.searchController == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        
        isfromPacket = false
        

        DispatchQueue.main.async {
            if let navigationItem = self.tabBarController?.navigationItem as? IGNavigationItem {
                IGTabBarController.currentTabStatic = .Recent
                navigationItem.addiGapLogo()
            }
        }
        self.tableView.isUserInteractionEnabled = true
        //self.addRoomChangeNotificationBlock()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.isUserInteractionEnabled = true
        //self.notificationToken?.stop()
        if currentTabIndex == TabBarTab.Recent.rawValue {
            if let navigationBar = self.navigationController?.navigationBar {
                navigationBar.backgroundColor = .clear


            }

        }
        
    }
    
    //MARK: Room List actions
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    @objc private func userDidLogin() {
        IGHelperGetShareData.manageShareDate()
        self.checkAppVersion()
        self.checkPermission()
        self.addRoomChangeNotificationBlock()
        self.deleteChannelMessages()
        DispatchQueue.global(qos: .userInteractive).async {
            
            self.fetchRoomList()
        }
    }
    
    /* check app need update or is deprecated now and don't allow */
    private func checkAppVersion() {
        DispatchQueue.main.async {
            if AppDelegate.isDeprecatedClient {
                let alert = UIAlertController(title: "GAME_ALERT_TITLE".RecentTableViewlocalizedNew, message: "VERSION_DEPRICATED".RecentTableViewlocalizedNew, preferredStyle: .alert)
                let update = UIAlertAction(title: "UPDATE".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                    UIApplication.shared.open(self.iGapStoreLink!, options: [:], completionHandler: nil)
                    
                })
                alert.addAction(update)
                self.present(alert, animated: true, completion: nil)
            } else if AppDelegate.isUpdateAvailable {
                let alert = UIAlertController(title: "UPDATE".RecentTableViewlocalizedNew, message: "VERSION_NEW".RecentTableViewlocalizedNew, preferredStyle: .alert)
                let update = UIAlertAction(title: "UPDATE".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                    UIApplication.shared.open(self.iGapStoreLink!, options: [:], completionHandler: nil)
                    
                })
                let cancel = UIAlertAction(title: "CANCEL_BTN".RecentTableViewlocalizedNew, style: .destructive, handler: nil)
                alert.addAction(update)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func checkPermission() {
        
        /********** Contact Permission **********/
        CNContactStore().requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
            if self.allRoomsFetched {
                IGContactManager.sharedManager.manageContact()
            }
            
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
        self.notificationToken = rooms!.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                self.setTabbarBadge()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query messages have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                
                self.tableView.endUpdates()
//                self.tableView.reloadData()
                self.setTabbarBadge()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    /**
     * use this method for delete channel messages for get messages
     * from server again and update vote actions data
     **/
    private func deleteChannelMessages() {
        if IGHelperPreferences.shared.readBoolean(key: IGHelperPreferences.keyChannelDeleteMessage) {
            IGHelperPreferences.shared.writeBoolean(key: IGHelperPreferences.keyChannelDeleteMessage, state: false)
            IGRoomMessage.deleteAllChannelMessages()
        }
    }
    
    private func sendClientCondition(clientConditionRooms: [IGPClientCondition.IGPRoom]) {
        IGClientConditionRequest.Generator.generate(clientConditionRooms: clientConditionRooms).success ({ (responseProto) in }).error ({ (errorCode, waitTime) in }).send()
    }
    
    @objc private func fetchRoomList(offset: Int32 = 0 , limit: Int32 = Int32(IGAppManager.sharedManager.LOAD_ROOM_LIMIT)) {
        
        var clientConditionRooms: [IGPClientCondition.IGPRoom]?
        if offset == 0 { // is first page
            clientConditionRooms = IGClientCondition.computeClientCondition()
        }
        
        isLoadingMoreRooms = true
        IGClientGetRoomListRequest.Generator.generate(offset: offset, limit: limit, identity: "identity").successPowerful ({ (responseProtoMessage, requestWrapper) in
            self.isLoadingMoreRooms = false
            DispatchQueue.main.async {
                
                var newOffset: Int32!
                var newLimit: Int32!
                
                if let getRoomListResponse = responseProtoMessage as? IGPClientGetRoomListResponse {
                    if let getRoomListRequest = requestWrapper.message as? IGPClientGetRoomList {
                        
                        newOffset = Int32(getRoomListRequest.igpPagination.igpLimit)
                        //                        newOffset = Int32(getRoomListRequest.igpPagination.igpLimit)
                        newLimit = newOffset + Int32(IGAppManager.sharedManager.LOAD_ROOM_LIMIT)
                        
                        if getRoomListRequest.igpPagination.igpOffset == 0 { // is first page
                            IGFactory.shared.markRoomsAsDeleted(igpRooms: getRoomListResponse.igpRooms)
                            IGClientGetPromoteRequest.fetchPromotedRooms()
                            self.sendClientCondition(clientConditionRooms: clientConditionRooms!)
                        }
                        
                        if getRoomListResponse.igpRooms.count != 0 {
                            self.allRoomsFetched = false
                            self.numberOfRoomFetchedInLastRequest = IGClientGetRoomListRequest.Handler.interpret(response: getRoomListResponse)
                            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
                                self.fetchRoomList(offset: newOffset, limit: newLimit)
                            }
                        } else {
                            self.allRoomsFetched = true
                            self.numberOfRoomFetchedInLastRequest = IGClientGetRoomListRequest.Handler.interpret(response: getRoomListResponse, removeDeleted: true)
                            self.saveAndSendContacts()
                            /*
                             DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                             IGFactory.shared.removeDeletedRooms()
                             IGFactory.shared.deleteShareInfo()
                             }
                             */
                        }
                    }
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.fetchRoomList(offset: offset, limit: limit)
            default:
                break
            }
        }).send()
    }
    
    @objc private func saveAndSendContacts() {
        if !IGContactManager.importedContact {
            IGContactManager.sharedManager.manageContact()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellId) as! IGRoomListtCell
        
        if self.rooms![indexPath.row].unreadCount == 0 {
            cell.showStateImage =  true
        } else {
            cell.showStateImage =  false
        }
        cell.roomII = self.rooms![indexPath.row]
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell: IGRoomListtCell = self.tableView.dequeueReusableCell(withIdentifier: cellId) as! IGRoomListtCell
        
        let room = rooms![indexPath.row]
        var muteTitle = "UN_MUTE".RecentTableViewlocalizedNew
        if room.mute == IGRoom.IGRoomMute.mute {
            muteTitle = "UN_MUTE".RecentTableViewlocalizedNew
        }
        else {
            muteTitle = "MUTE".RecentTableViewlocalizedNew
            
        }
        
        var pinTitle = "PINN".RecentTableViewlocalizedNew
        if room.pinId > 0 {
            pinTitle = "UNPINN".RecentTableViewlocalizedNew
        }
        //MUTE
        let btnMuteSwipeCell = UIContextualAction(style: .normal, title: muteTitle) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action
            
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.muteRoom(room: room)
                
            }
        }
        
        
        
        btnMuteSwipeCell.backgroundColor = UIColor.swipeGray()
        
        //PIN
        let btnPinSwipeCell = UIContextualAction(style: .normal, title: pinTitle) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action

            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.pinRoom(room: room)
            }
            
        }
        btnPinSwipeCell.backgroundColor = UIColor.swipeBlueGray()
        
        
        //MORE
        let btnMoreSwipeCell = UIContextualAction(style: .normal, title: "MORE".RecentTableViewlocalizedNew) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action

            let title = room.title != nil ? room.title! : "BTN_DELETE".RecentTableViewlocalizedNew
            let alertC = UIAlertController(title: title, message: "WHAT_DO_U_WANT".RecentTableViewlocalizedNew, preferredStyle: IGGlobal.detectAlertStyle())
            let clear = UIAlertAction(title: "CLEAR_HISTORY".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                switch room.type{
                case .chat:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.clearChatMessageHistory(room: room)
                    }
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.clearGroupMessageHistory(room: room)
                    }
                default:
                    break
                }
            })
            
            let clearLocalMessage = UIAlertAction(title: "CLEAR_HISTORY_LOCAL".localizedNew, style: .default, handler: { (action) in
                IGRoomMessage.clearLocalMessage(roomId: room.id)
            })
            
            let mute = UIAlertAction(title: muteTitle, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.muteRoom(room: room)
                }
            })
            
            let pin = UIAlertAction(title: pinTitle, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.pinRoom(room: room)
                }
            })
            
            let report = UIAlertAction(title: "REPORT".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.report(room: room)
                }
            })
            
            let remove = UIAlertAction(title: "BTN_DELETE".RecentTableViewlocalizedNew, style: .destructive, handler: { (action) in
                switch room.type {
                case .chat:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.deleteChat(room: room)
                    }
                    break
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.deleteGroup(room: room)
                    }
                    break
                case .channel:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.deleteChannel(room: room)
                    }
                    break
                }
            })
            
            let leave = UIAlertAction(title: "LEAVE".RecentTableViewlocalizedNew, style: .destructive, handler: { (action) in
                switch room.type {
                case .chat:
                    break
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    } else {
                        self.leaveGroup(room: room)
                    }
                case .channel:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "GLOBAL_WARNING".RecentTableViewlocalizedNew, message: "NO_NETWORK".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    } else {
                        self.leaveChannel(room: room)
                    }
                }
            })
            
            let cancel = UIAlertAction(title: "CANCEL_BTN".RecentTableViewlocalizedNew, style: .cancel, handler: nil)
            
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
                        alertC.addAction(leave)
                        alertC.addAction(remove)
                    } else{
                        alertC.addAction(leave)
                    }
                } else if let channel = room.channelRoom {
                    if channel.role == .owner {
                        alertC.addAction(remove)
                        alertC.addAction(leave)
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
        scrollToFirstRow()

        if (segue.identifier == "showRoomMessages") {
            
            let destination = segue.destination as! IGMessageViewController
            destination.room = selectedRoomForSegue
            
            
        } else if segue.identifier == "createANewGroup" {
            let destination = segue.destination as! IGNavigationController
            let chooseContactTv =  destination.topViewController as! IGChooseMemberFromContactsToCreateGroupViewController
            chooseContactTv.mode = "CreateGroup"
        } else if segue.identifier == "showReportPage" {
            let report =  segue.destination as! IGReport
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

            
        } catch let error as NSError {
            // handle error
            print("RLM EXEPTION ERR HAPPENDED IN SET TABBAR BADGE:",String(describing: self))
            
        }
        
        if !AppDelegate.appIsInBackground {
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }
    }
    
    
    @objc func segueToChatNotificationReceived(_ aNotification: Notification) {
        if let roomId = aNotification.userInfo?["room"] as? Int64 {
            let predicate = NSPredicate(format: "id = %lld", roomId)
            if let room = rooms!.filter(predicate).first {
                selectedRoomForSegue = room
                performSegue(withIdentifier: "showRoomMessages", sender: self)
            } else {
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        self.hud.hide(animated: true)
                        switch protoResponse {
                        case let clientGetRoomResponse as IGPClientGetRoomResponse:
                            IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),object: nil,userInfo: ["room": roomId])
                        default:
                            break
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        switch errorCode {
                        case .timeout:
                            let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
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
    }
    
    func onForwardStart(user: IGRegisteredUser?, room: IGRoom?, type: IGPClientSearchUsernameResponse.IGPResult.IGPType) {
        IGHelperChatOpener.manageOpenChatOrProfile(viewController: self, usernameType: type, user: user, room: room)
    }
}

//MARK:- Room Clear, Delete, Leave
extension IGRecentsTableViewController {
    func clearChatMessageHistory(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChatClearMessageRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let clearChatMessages as IGPChatClearMessageResponse:
                    IGChatClearMessageRequest.Handler.interpret(response: clearChatMessages)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
    
    func clearGroupMessageHistory(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGGroupClearMessageRequest.Generator.generate(group: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteGroupMessageHistory as IGPGroupClearMessageResponse:
                    IGGroupClearMessageRequest.Handler.interpret(response: deleteGroupMessageHistory)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
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
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func pinRoom(room: IGRoom) {
        let roomId = room.id
        var pin = true
        if room.pinId > 0 {
            pin = false
        }
        
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientPinRoomRequest.Generator.generate(roomId: roomId, pin: pin).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let pinRoomResponse as IGPClientPinRoomResponse:
                    IGClientPinRoomRequest.Handler.interpret(response: pinRoomResponse)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
                self.tableView.reloadData()

            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func reportRoom(roomId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, reason: reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    let alert = UIAlertController(title: "SUCCESS", message: "REPORT_SUBMITED".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
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
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportReportedBefore:
                    let alert = UIAlertController(title: "GLLOBAL_WARNING".RecentTableViewlocalizedNew, message: "ROOM_REPORTED_BEFOR".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportForbidden:
                    let alert = UIAlertController(title: "Error", message: "Room Report Fobidden", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func reportUser(userId: Int64, reason: IGPUserReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGUserReportRequest.Generator.generate(userId: userId, reason: reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPUserReportResponse:
                    let alert = UIAlertController(title: "SUCCESS".RecentTableViewlocalizedNew, message: "REPORT_SUBMITED".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
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
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userReportReportedBefore:
                    let alert = UIAlertController(title: "GLLOBAL_WARNING".RecentTableViewlocalizedNew, message: "USER_REPORTED_BEFOR".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userReportForbidden:
                    let alert = UIAlertController(title: "Error", message: "User Report Forbidden", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func report(room: IGRoom){
        let roomId = room.id
        let roomType = room.type
        
        var title = ""
        
        if roomType == .chat {
            title = "REPORT_REASON".RecentTableViewlocalizedNew
        } else {
            title = "REPORT_REASON".RecentTableViewlocalizedNew
        }
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let abuse = UIAlertAction(title: "ABUSE".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
            
            if roomType == .chat {
                self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.abuse)
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.abuse)
            }
        })
        
        let spam = UIAlertAction(title: "SPAM".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
            
            if roomType == .chat {
                self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.spam)
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.spam)
            }
        })
        
        let fakeAccount = UIAlertAction(title: "FAKE_ACCOUNT".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
            self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.fakeAccount)
        })
        
        let violence = UIAlertAction(title: "VIOLENCE".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: "PORNOGRAPHY".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let other = UIAlertAction(title: "OTHER".RecentTableViewlocalizedNew, style: .default, handler: { (action) in
            self.selectedRoomForSegue = room
            self.performSegue(withIdentifier: "showReportPage", sender: self)
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".RecentTableViewlocalizedNew, style: .cancel, handler: { (action) in
            
        })
        
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
        
        self.present(alertC, animated: true, completion: {
            
        })
    }
    
    func deleteChat(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChatDeleteRequest.Generator.generate(room: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteChat as IGPChatDeleteResponse:
                    IGChatDeleteRequest.Handler.interpret(response: deleteChat)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
            
        }).send()
    }
    
    func deleteGroup(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGGroupDeleteRequest.Generator.generate(group: room).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteGroup as IGPGroupDeleteResponse:
                    IGGroupDeleteRequest.Handler.interpret(response: deleteGroup)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func leaveGroup(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGGroupLeftRequest.Generator.generate(room: room).success{ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let response as IGPGroupLeftResponse:
                    IGGroupLeftRequest.Handler.interpret(response: response)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
            }.error { (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        let alert = UIAlertController(title: "Error", message: "There was an error leaving this group.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.hud.hide(animated: true)
                }
            }.send()
    }
    
    func leaveChannel(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChannelLeftRequest.Generator.generate(room: room).success { (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let response as IGPChannelLeftResponse:
                    IGChannelLeftRequest.Handler.interpret(response: response)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
            }.error { (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        let alert = UIAlertController(title: "Error", message: "There was an error leaving this channel.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.hud.hide(animated: true)
                }
            }.send()
    }
    
    func deleteChannel(room: IGRoom) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGChannelDeleteRequest.Generator.generate(roomID: room.id).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let deleteChannel as IGPChannelDeleteResponse:
                    let _ = IGChannelDeleteRequest.Handler.interpret(response: deleteChannel)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".RecentTableViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".RecentTableViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".RecentTableViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    /***************** Send Rooms Status *****************/
    
    func onMessageRecieveInRoomList(roomId: Int64, messages: [IGPRoomMessage]) {
        
        let realm = try! Realm()
        
        for message in messages {
            var roomType: IGRoom.IGType = .chat
            var roomMessageStatus: IGPRoomMessageStatus = .delivered
            
            let predicate = NSPredicate(format: "id = %lld", roomId)
            if let roomInfo = realm.objects(IGRoom.self).filter(predicate).first {
                if roomInfo.chatRoom != nil {
                    roomType = .chat
                } else if roomInfo.groupRoom != nil {
                    roomType = .group
                } else {
                    roomType = .channel
                }
            }
            
            let seenStatus = IGRecentsTableViewController.visibleChat[roomId]
            
            if seenStatus != nil && seenStatus! {
                roomMessageStatus = .seen
            }
            
            manageUnreadMessage(roomId: roomId, roomType: roomType, message: message)
            sendSeenForReceivedMessage(roomId: roomId, roomType: roomType, message: message, status: roomMessageStatus)
        }
    }
    
    private func manageUnreadMessage(roomId: Int64, roomType: IGRoom.IGType, message: IGPRoomMessage){
        let realm = try! Realm()
        try! realm.write {
            let room = realm.objects(IGRoom.self).filter(NSPredicate(format: "id = %lld", roomId)).first
            let message = realm.objects(IGRoomMessage.self).filter(NSPredicate(format: "id = %lld", message.igpMessageID)).first
            
            if room != nil && message != nil {
                /**
                 * client checked (room.unreadCount <= 1) because in IGHelperMessage unreadCount++
                 */
                if (room!.unreadCount <= Int32(1)) {
                    message?.futureMessageId = message!.id
                    room?.firstUnreadMessage = message
                }
            }
        }
    }
    
    private func sendSeenForReceivedMessage(roomId: Int64, roomType: IGRoom.IGType, message: IGPRoomMessage, status: IGPRoomMessageStatus) {
        if message.igpAuthor.igpHash == IGAppManager.sharedManager.authorHash() || message.igpStatus == status || (message.igpStatus == .seen && status == .delivered) {
            return
        }
        
        var messageStatus: IGRoomMessageStatus = .seen
        if status == .delivered {
            messageStatus = .delivered
        }
        
        switch roomType {
        case .chat:
            IGChatUpdateStatusRequest.Generator.generate(roomID: roomId, messageID: message.igpMessageID, status: messageStatus).success({ (responseProto) in
                switch responseProto {
                case let response as IGPChatUpdateStatusResponse:
                    IGChatUpdateStatusRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupUpdateStatusRequest.Generator.generate(roomID: roomId, messageID: message.igpMessageID, status: messageStatus).success({ (responseProto) in
                switch responseProto {
                case let response as IGPGroupUpdateStatusResponse:
                    IGGroupUpdateStatusRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
            break
        case .channel:
            /*
             if let message = self.messages?.last {
             IGChannelGetMessagesStatsRequest.Generator.generate(messages: [message], room: self.room!).success({ (responseProto) in
             
             }).error({ (errorCode, waitTime) in
             
             }).send()
             }
             */
            break
        }
    }
    @objc
    func didTapOnSearchBar(sender:UITapGestureRecognizer) {
        print("taped")
    }
}


extension IGRecentsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        let lastContentOffset = scrollView.contentOffset.y

        if remaining < 100 {
            //self.loadMoreRooms()
        }
        if lastContentOffset <= 0 {
//            initialiseSearchBar()
        }
        print(scrollView.contentOffset.y)
        
    }
    
    private func initialiseSearchBar() {
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

            let imageV = textField.leftView as! UIImageView
            imageV.image = nil
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    if view is UIView {
                        view.backgroundColor = .clear
                    }
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;                
                
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
            }

            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeHolderInsideSearchField.textColor = UIColor.white
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
                
            }
            
        }
    }
}



extension IGRecentsTableViewController {
    func loadMoreRooms() {
        if !isLoadingMoreRooms && numberOfRoomFetchedInLastRequest % IGAppManager.sharedManager.LOAD_ROOM_LIMIT == 0 {
            isLoadingMoreRooms = true
            let offset = rooms!.count
            IGClientGetRoomListRequest.Generator.generate(offset: Int32(offset), limit: Int32(IGAppManager.sharedManager.LOAD_ROOM_LIMIT)).success ({ (responseProtoMessage) in
                DispatchQueue.main.async {
                    self.isLoadingMoreRooms = false
                    switch responseProtoMessage {
                    case let response as IGPClientGetRoomListResponse:
                        self.numberOfRoomFetchedInLastRequest = IGClientGetRoomListRequest.Handler.interpret(response: response)
                    default:
                        break;
                    }
                }
            }).error({ (errorCode, waitTime) in }).send()
        }
    }
}

//MARK: SEARCH BAR DELEGATE
extension IGRecentsTableViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        //Filter function
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        IGGlobal.heroTabIndex = (self.tabBarController?.selectedIndex)!
        if let searchBarCancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
            searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
            searchBarCancelButton.tintColor = UIColor.white
        }

        let lookAndFind = UIStoryboard(name: "IGSettingStoryboard", bundle: nil).instantiateViewController(withIdentifier: "IGLookAndFind")
        lookAndFind.hero.isEnabled = true
        //        self.searchBar.hero.id = "searchBar"
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .fade
        self.hero.replaceViewController(with: lookAndFind)
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        

        
        //Filter function
//        self.filterFunction(searchText: term)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        
        //Filter function
//        self.filterFunction(searchText: searchBar.text)
    }
}



