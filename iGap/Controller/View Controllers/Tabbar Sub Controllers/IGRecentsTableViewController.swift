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

class IGRecentsTableViewController: UITableViewController, MessageReceiveObserver, UNUserNotificationCenterDelegate, ForwardStartObserver {
    
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
    
    @IBOutlet weak var searchBar: UISearchBar!
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
                self.setDefaultNavigationItem()
                break
            }
        }
    }
    
    private func setDefaultNavigationItem() {
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setChatListsNavigationItems()
        navigationItem.rightViewContainer?.addAction {
            
            if IGTabBarController.currentTabStatic == .Call {
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
                
                let newChat = UIAlertAction(title: "New Call", style: .default, handler: { (action) in
                    let createChat = IGCreateNewChatTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                    createChat.forceCall = true
                    self.navigationController!.pushViewController(createChat, animated: true)
                })
                
                let clearCallLog = UIAlertAction(title: "Clear Call History", style: .default, handler: { (action) in
                    if IGAppManager.sharedManager.userID() != nil {
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.mode = .indeterminate
                        
                        let sortProperties = [SortDescriptor(keyPath: "offerTime", ascending: false)]
                        guard let clearId = try! Realm().objects(IGRealmCallLog.self).sorted(by: sortProperties).first?.id else {
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
                    }
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(newChat)
                alertController.addAction(clearCallLog)
                alertController.addAction(cancel)
                
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let alertController = UIAlertController(title: "New Message", message: "Which type of conversation would you like to initiate?", preferredStyle: IGGlobal.detectAlertStyle())
            let myCloud = UIAlertAction(title: "My Cloud", style: .default, handler: { (action) in
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
                            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)

                            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            })
            let newChat = UIAlertAction(title: "New (Conversation OR Call)", style: .default, handler: { (action) in
                let createChat = IGCreateNewChatTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                self.navigationController!.pushViewController(createChat, animated: true)
            })
            let newGroup = UIAlertAction(title: "New Group", style: .default, handler: { (action) in
                let createGroup = IGChooseMemberFromContactsToCreateGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                createGroup.mode = "CreateGroup"
                self.navigationController!.pushViewController(createGroup, animated: true)
            })
            let newChannel = UIAlertAction(title: "New Channel", style: .default, handler: { (action) in
                let createChannel = IGCreateNewChannelTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                self.navigationController!.pushViewController(createChannel, animated: true)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
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
                self.performSegue(withIdentifier: "showSettings", sender: self)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IGRecentsTableViewController.forwardStartObserver = self
        IGRecentsTableViewController.messageReceiveDelegat = self
        searchBar.delegate = self
        
        let sortProperties = [SortDescriptor(keyPath: "priority", ascending: false), SortDescriptor(keyPath: "pinId", ascending: false), SortDescriptor(keyPath: "sortimgTimestamp", ascending: false)]
        self.rooms = try! Realm().objects(IGRoom.self).filter("isParticipant = 1").sorted(by: sortProperties)
        
        self.tableView.register(IGChatRoomListTableViewCell.nib(), forCellReuseIdentifier: IGChatRoomListTableViewCell.cellReuseIdentifier())
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        
        
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
                self.fetchRoomList()
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
        
        // use current line for enable support gif in SDWebImage library
        SDWebImageCodersManager.sharedInstance().addCoder(SDWebImageGIFCoder.shared())
    }
    
    @objc func addressBookDidChange(_ notification: UITapGestureRecognizer) {
        if !IGContactManager.syncedPhoneBookContact {
            IGContactManager.syncedPhoneBookContact = true
            IGContactManager.sharedManager.manageContact()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
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
        super.viewWillAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        //self.notificationToken?.stop()
    }
    
    //MARK: Room List actions
    @objc private func userDidLogin() {
        IGHelperGetShareData.manageShareDate()
        self.checkAppVersion()
        self.checkPermission()
        self.addRoomChangeNotificationBlock()
        self.deleteChannelMessages()
        self.fetchRoomList()
    }
    
    /* check app need update or is deprecated now and don't allow */
    private func checkAppVersion() {
        DispatchQueue.main.async {
            if AppDelegate.isDeprecatedClient {
                let alert = UIAlertController(title: "Alert", message: "Version is deprecated please update to use", preferredStyle: .alert)
                let update = UIAlertAction(title: "update", style: .default, handler: { (action) in
                    UIApplication.shared.open(self.iGapStoreLink!, options: [:], completionHandler: nil)
                })
                alert.addAction(update)
                self.present(alert, animated: true, completion: nil)
            } else if AppDelegate.isUpdateAvailable {
                let alert = UIAlertController(title: "Update", message: "New version is available", preferredStyle: .alert)
                let update = UIAlertAction(title: "update", style: .default, handler: { (action) in
                    UIApplication.shared.open(self.iGapStoreLink!, options: [:], completionHandler: nil)
                })
                let cancel = UIAlertAction(title: "cancel", style: .destructive, handler: nil)
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
        if IGHelperPreferences.readBoolean(key: IGHelperPreferences.keyChannelDeleteMessage) {
            IGHelperPreferences.writeBoolean(key: IGHelperPreferences.keyChannelDeleteMessage, state: false)
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
                        newLimit = newOffset + Int32(IGAppManager.sharedManager.LOAD_ROOM_LIMIT)
                        
                        if getRoomListRequest.igpPagination.igpOffset == 0 { // is first page
                            IGFactory.shared.markRoomsAsDeleted(igpRooms: getRoomListResponse.igpRooms)
                            self.fetchPromotedRooms()
                            self.sendClientCondition(clientConditionRooms: clientConditionRooms!)
                        }
                        
                        if getRoomListResponse.igpRooms.count != 0 {
                            self.allRoomsFetched = false
                            self.numberOfRoomFetchedInLastRequest = IGClientGetRoomListRequest.Handler.interpret(response: getRoomListResponse)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    
    private func fetchPromotedRooms() {
        IGClientGetPromoteRequest.Generator.generate().success ({ (responseProtoMessage) in
            if let promoteResponse = responseProtoMessage as? IGPClientGetPromoteResponse {
                IGClientGetPromoteRequest.Handler.interpret(response: promoteResponse)
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.fetchPromotedRooms()
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
        return rooms!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IGChatRoomListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifer) as! IGChatRoomListTableViewCell
        cell.setRoom(room: rooms![indexPath.row])
        
        let room = cell.room!
        
        var muteTitle = "Mute"
        if room.mute == IGRoom.IGRoomMute.mute {
            muteTitle = "UnMute"
        }
        
        var pinTitle = "Pin"
        if room.pinId > 0 {
            pinTitle = "UnPin"
        }
        
        let btnMuteSwipeCell = MGSwipeButton(title: muteTitle, backgroundColor: UIColor.swipeGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.muteRoom(room: room)
            }
            return true
        })
        
        let btnPinSwipeCell = MGSwipeButton(title: pinTitle, backgroundColor: UIColor.swipeBlueGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                self.pinRoom(room: room)
            }
            return true
        })
        
        let btnMoreSwipeCell = MGSwipeButton(title: "More...", backgroundColor: UIColor.swipeDarkBlue(), callback: { (sender: MGSwipeTableCell!) -> Bool in
            
            let title = room.title != nil ? room.title! : "Delete"
            let alertC = UIAlertController(title: title, message: "What do you want to do?", preferredStyle: IGGlobal.detectAlertStyle())
            let clear = UIAlertAction(title: "Clear History", style: .default, handler: { (action) in
                switch room.type{
                case .chat:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.clearChatMessageHistory(room: room)
                    }
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.clearGroupMessageHistory(room: room)
                    }
                default:
                    break
                }
            })
            
            let mute = UIAlertAction(title: muteTitle, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.muteRoom(room: room)
                }
            })
            
            let pin = UIAlertAction(title: pinTitle, style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.pinRoom(room: room)
                }
            })
            
            let report = UIAlertAction(title: "Report", style: .default, handler: { (action) in
                if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                    let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.report(room: room)
                }
            })
            
            let remove = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                switch room.type {
                case .chat:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.deleteChat(room: room)
                    }
                    break
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.deleteGroup(room: room)
                    }
                    break
                case .channel:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.deleteChannel(room: room)
                    }
                    break
                }
            })
            
            let leave = UIAlertAction(title: "Leave", style: .destructive, handler: { (action) in
                switch room.type {
                case .chat:
                    break
                case .group:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    } else {
                        self.leaveGroup(room: room)
                    }
                case .channel:
                    if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                        let alert = UIAlertController(title: "Error", message: "No Network Connection", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    } else {
                        self.leaveChannel(room: room)
                    }
                }
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            if room.type == .chat || room.type == .group {
                alertC.addAction(clear)
            }
            
            if !IGHelperPromote.isPromotedRoom(room: room) {
                alertC.addAction(pin)
            }
            alertC.addAction(mute)
            alertC.addAction(report)
            
            if room.chatRoom != nil {
                if !IGHelperPromote.isPromotedRoom(room: room) {
                    alertC.addAction(remove)
                }
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
            
            return true
        })
        
        
        var buttons = [btnMuteSwipeCell, btnPinSwipeCell, btnMoreSwipeCell]
        if IGHelperPromote.isPromotedRoom(room: room) {
            buttons = [btnMuteSwipeCell, btnMoreSwipeCell]
        }
        cell.rightButtons = buttons
        removeButtonsUnderline(buttons: buttons)
        
        cell.rightSwipeSettings.transition = MGSwipeTransition.border
        cell.rightExpansion.buttonIndex = 0
        cell.rightExpansion.fillOnTrigger = true
        cell.rightExpansion.threshold = 1.5
        
        cell.clipsToBounds = true
        cell.swipeBackgroundColor = UIColor.clear
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 82.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRoomForSegue = rooms![indexPath.row]
        self.tableView.isUserInteractionEnabled = false
        performSegue(withIdentifier: "showRoomMessages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        return 78.0
    }
    
    //MARK: - Tabbar badge
    func setTabbarBadge() {
        var unreadCount = 0
        let rooms = try! Realm().objects(IGRoom.self).filter("isParticipant = 1 AND muteRoom = %d", IGRoom.IGRoomMute.unmute.rawValue)
        unreadCount = rooms.sum(ofProperty: "unreadCount")
        if unreadCount == 0 {
            self.tabBarController?.tabBar.items?[0].badgeValue = nil
        } else {
            self.tabBarController?.tabBar.items?[0].badgeValue = "\(unreadCount)"
        }
        /*
        if unreadCount == 0 {
            self.tabBarController?.tabBar.items?[0].badgeValue = nil
            self.tabBarController?.tabBar.items?[1].badgeValue = nil
            self.tabBarController?.tabBar.items?[2].badgeValue = nil
            self.tabBarController?.tabBar.items?[3].badgeValue = nil
        } else {
            let predicateChat = NSPredicate(format: "typeRaw = %d", IGRoom.IGType.chat.rawValue)
            let predicateGroup = NSPredicate(format: "typeRaw = %d", IGRoom.IGType.group.rawValue)
            let predicateChannel = NSPredicate(format: "typeRaw = %d", IGRoom.IGType.channel.rawValue)

            var countChat : Int32 = 0
            var countGroup : Int32 = 0
            var countChannel : Int32 = 0
            
            for chat in rooms.filter(predicateChat) {
                countChat += chat.unreadCount
            }
            
            for group in rooms.filter(predicateGroup) {
                countGroup += group.unreadCount
            }
            
            for channel in rooms.filter(predicateChannel) {
                countChannel += channel.unreadCount
            }
            
            if countChannel == 0 {
                self.tabBarController?.tabBar.items?[0].badgeValue = nil
            } else {
                self.tabBarController?.tabBar.items?[0].badgeValue = "\(countChannel)"
            }
            
            if countGroup == 0 {
                self.tabBarController?.tabBar.items?[1].badgeValue = nil
            } else {
                self.tabBarController?.tabBar.items?[1].badgeValue = "\(countGroup)"
            }
            
            if countChat == 0 {
                self.tabBarController?.tabBar.items?[3].badgeValue = nil
            } else {
                self.tabBarController?.tabBar.items?[3].badgeValue = "\(countChat)"
            }
            
            self.tabBarController?.tabBar.items?[2].badgeValue = "\(unreadCount)"
        }
        */
        
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
            }
        }
    }
    
    func openForwardPage() {
        self.performSegue(withIdentifier: "showForwardMessageTable", sender: self)
    }
    
    func onForwardStart(user: IGRegisteredUser?, room: IGRoom?, type: IGPClientSearchUsernameResponse.IGPResult.IGPType) {
        IGHelperChatOpener.manageOpenChatOrProfile(viewController: self, usernameType: type, user: user, room: room, isForwardEnable: true)
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
            }
        }).error({ (errorCode , waitTime) in
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
    }
    
    func reportRoom(roomId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, reason: reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    let alert = UIAlertController(title: "Success", message: "Your report has been successfully submitted", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportReportedBefore:
                    let alert = UIAlertController(title: "Error", message: "This Room Reported Before", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                    let alert = UIAlertController(title: "Success", message: "Your Report has been successfully submitted", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .userReportReportedBefore:
                    let alert = UIAlertController(title: "Error", message: "This User Reported Before", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
            title = "Report User Reason"
        } else {
            title = "Report Room Reason"
        }
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let abuse = UIAlertAction(title: "Abuse", style: .default, handler: { (action) in
            
            if roomType == .chat {
                self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.abuse)
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.abuse)
            }
        })
        
        let spam = UIAlertAction(title: "Spam", style: .default, handler: { (action) in
            
            if roomType == .chat {
                self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.spam)
            } else {
                self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.spam)
            }
        })
        
        let fakeAccount = UIAlertAction(title: "Fake Account", style: .default, handler: { (action) in
            self.reportUser(userId: (room.chatRoom?.peer?.id)!, reason: IGPUserReport.IGPReason.fakeAccount)
        })
        
        let violence = UIAlertAction(title: "Violence", style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: "Pornography", style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let other = UIAlertAction(title: "Other ", style: .default, handler: { (action) in
            self.selectedRoomForSegue = room
            self.performSegue(withIdentifier: "showReportPage", sender: self)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
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
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
    }
    
    /***************** Send Rooms Status *****************/
    
    func onMessageRecieve(messages: [IGPRoomMessage]) {
        
        let realm = try! Realm()
        
        for message in messages {
            var roomId: Int64 = 0
            var roomType: IGRoom.IGType = .chat
            var roomMessageStatus: IGPRoomMessageStatus = .delivered
            
            if message.igpAuthor.hasIgpUser { // chat
                
                let predicate = NSPredicate(format: "chatRoom.peer.id = %lld", message.igpAuthor.igpUser.igpUserID)
                if let roomInfo = realm.objects(IGRoom.self).filter(predicate).first {
                    roomId = roomInfo.id
                }
            } else { // group or channel
                
                let predicate = NSPredicate(format: "id = %lld", message.igpAuthor.igpRoom.igpRoomID)
                if let roomInfo = realm.objects(IGRoom.self).filter(predicate).first {
                    roomId = roomInfo.id
                    if roomInfo.groupRoom != nil {
                        roomType = .group
                    } else {
                        roomType = .channel
                    }
                }
            }
            
            let seenStatus = IGRecentsTableViewController.visibleChat[roomId]
            
            if seenStatus != nil && seenStatus! {
                roomMessageStatus = .seen
            }
            
            sendSeenForReceivedMessage(roomId: roomId, roomType: roomType, message: message, status: roomMessageStatus)
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
    
}


extension IGRecentsTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        if remaining < 100 {
            //self.loadMoreRooms()
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

extension IGRecentsTableViewController: UISearchBarDelegate{
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        IGLookAndFind.enableForward = false
        IGGlobal.heroTabIndex = (self.tabBarController?.selectedIndex)!
        let lookAndFind = UIStoryboard(name: "IGSettingStoryboard", bundle: nil).instantiateViewController(withIdentifier: "IGLookAndFind")
        lookAndFind.hero.isEnabled = true
        self.searchBar.hero.id = "searchBar"
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .fade
        self.hero.replaceViewController(with: lookAndFind)
        return true
    }
}
