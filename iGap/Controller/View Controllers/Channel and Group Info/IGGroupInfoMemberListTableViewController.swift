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
import MBProgressHUD
import IGProtoBuff
import MGSwipeTableCell

class IGGroupInfoMemberListTableViewController: BaseTableViewController,cellWithMore,cellWithMoreChannel  {

    var allMember = [IGGroupMember]()
    var allMemberChannel = [IGChannelMember]()

    var room : IGRoom?
    var hud = MBProgressHUD()
    var filterRole : IGRoomFilterRole = .all
    var members : Results<IGGroupMember>!
    var membersChannel : Results<IGChannelMember>!
    var admins : Results<IGChannelMember>!
    var moderators : Results<IGChannelMember>!
    var adminsRole = IGChannelMember.IGRole.admin.rawValue
    var moderatorRole = IGChannelMember.IGRole.moderator.rawValue
    var myRole : IGGroupMember.IGRole?
    var myChannelRole : IGChannelMember.IGRole?
    var roomId: Int64!
    var mode : String? = "Members"
    var notificationToken: NotificationToken?
    var notificationTokenMemberChannel: NotificationToken?
    var notificationTokenModerator: NotificationToken?
    var notificationTokenAdmin: NotificationToken?

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
            if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                    searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
                    searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
                    searchBarCancelButton.tintColor = UIColor.white
                }

                
                print("FOUND TEXTFIELD")
                if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                    print("FOUND LABEL")
                    placeHolderInsideSearchField.textColor = UIColor.white
                    placeHolderInsideSearchField.textAlignment = .center
                    placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
                    if let backgroundview = textField.subviews.first {
                        placeHolderInsideSearchField.center = backgroundview.center
                    }
                    placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
                    


                }
            }
            return searchController

        }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.scrollsToTop = false
        self.tableView.bounces = false
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if tableView.tableHeaderView == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        if room?.type == .channel {
            myChannelRole = room?.channelRoom?.role
            roomId = room?.id

        } else {
            myRole = room?.groupRoom?.role
            roomId = room?.id

        }
        if room?.type == .channel {
             let predicateMemberChannel = NSPredicate(format: "roomID = %lld", (room?.channelRoom?.id)!)
             let predicateModerators = NSPredicate(format: "roleRaw = %d AND roomID = %lld", moderatorRole , (room?.channelRoom?.id)!)
             let predicateAdmins = NSPredicate(format: "roleRaw = %d AND roomID = %lld", adminsRole , (room?.channelRoom?.id)!)

             membersChannel =  try! Realm().objects(IGChannelMember.self).filter(predicateMemberChannel)
             moderators =  try! Realm().objects(IGChannelMember.self).filter(predicateModerators)
             admins =  try! Realm().objects(IGChannelMember.self).filter(predicateAdmins)

            self.notificationTokenMemberChannel = membersChannel.observe { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    // Query messages have changed, so apply them to the TableView
                    self.tableView.reloadData()
                    break
                case .error(let err):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(err)")
                    break
                }
            }
                 self.notificationTokenModerator = moderators.observe { (changes: RealmCollectionChange) in
                     switch changes {
                     case .initial:
                         self.tableView.reloadData()
                         break
                     case .update(_, let deletions, let insertions, let modifications):
                         // Query messages have changed, so apply them to the TableView
                         self.tableView.reloadData()
                         break
                     case .error(let err):
                         // An error occurred while opening the Realm file on the background worker thread
                         fatalError("\(err)")
                         break
                     }
                 }
                 self.notificationTokenAdmin = admins.observe { (changes: RealmCollectionChange) in
                     switch changes {
                     case .initial:
                         self.tableView.reloadData()
                         break
                     case .update(_, let deletions, let insertions, let modifications):
                         // Query messages have changed, so apply them to the TableView
                         self.tableView.reloadData()
                         break
                     case .error(let err):
                         // An error occurred while opening the Realm file on the background worker thread
                         fatalError("\(err)")
                         break
                     }
                 }

        } else {
            let predicate = NSPredicate(format: "roomID = %lld", (room?.groupRoom?.id)!)
            members =  try! Realm().objects(IGGroupMember.self).filter(predicate)

            self.notificationToken = members.observe { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    // Query messages have changed, so apply them to the TableView
                    self.tableView.reloadData()
                    break
                case .error(let err):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(err)")
                    break
                }
            }

        }
        
        setNavigationItem()
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          initialiseSearchBar()

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
    
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: "ALLMEMBER".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "showContactToAddMember", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if room?.type == .group {
            fetchGroupMemberFromServer()
        } else if room?.type == .channel {
            fetchChannelMemberFromServer()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if room?.type == .group {
            if members != nil {
                     return members.count
            } else {
                return 0
            }

        } else {

            switch mode {
            case "Members" :
                if membersChannel != nil {
                return membersChannel.count
                } else {
                    return 0
                }
            case "Admins" :
                if admins != nil {
                    return admins.count

                } else {
                    return 0
                }
            case "Moderators" :
                if moderators != nil {
                    return moderators.count
                } else {
                    return 0
                }
            default : return moderators.count ?? 0
            }
        }
        
    }
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if room?.type == .group {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! IGGroupInfoMemberListTableViewCell
            
            let member = members[indexPath.row]
            cell.setUser(member,myRole: myRole)
            cell.delegate = self
            
            return cell
        } else if room?.type == .channel {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelMemberCell", for: indexPath) as! IGChannelInfoMemberListTableViewCell
            
            if mode == "Members" {
                let member = membersChannel[indexPath.row]
                cell.setUser(member,myRole: myChannelRole)
                cell.delegate = self
                
                return cell

            } else if mode == "Admins" {
                let member = admins[indexPath.row]
                cell.setUser(member,myRole: myChannelRole)
                cell.delegate = self
                
                return cell

            } else {
            let member = moderators[indexPath.row]
            cell.setUser(member,myRole: myChannelRole)
            cell.delegate = self
            
            return cell

            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelMemberCell", for: indexPath) as! IGChannelInfoMemberListTableViewCell

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if room?.type == .group {

            if let roomU = IGRoom.existRoomInLocal(userId: self.members[indexPath.row].userID) {
                openChat(room: roomU)
            } else { //dont have chat
                IGGlobal.prgShow(self.view)
                IGChatGetRoomRequest.Generator.generate(peerId: self.members[indexPath.row].userID).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        IGGlobal.prgHide()
                        if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                            let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                            let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                            self.openChat(room: roomU)
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        IGGlobal.prgHide()
                        let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertC.addAction(cancel)
                        self.present(alertC, animated: true, completion: nil)
                    }
                }).send()
            }
            
        } else if room?.type == .channel {
            switch mode {
            case "Members" :

                if let roomU = IGRoom.existRoomInLocal(userId: self.membersChannel[indexPath.row].userID) {
                    openChat(room: roomU)
                } else { //dont have chat
                    IGGlobal.prgShow(self.view)
                    IGChatGetRoomRequest.Generator.generate(peerId: self.membersChannel[indexPath.row].userID).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                self.openChat(room: roomU)
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            case "Admins" :
                
                if let roomU = IGRoom.existRoomInLocal(userId: self.admins[indexPath.row].userID) {
                    openChat(room: roomU)
                } else { //dont have chat
                    IGGlobal.prgShow(self.view)
                    IGChatGetRoomRequest.Generator.generate(peerId: self.admins[indexPath.row].userID).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                self.openChat(room: roomU)
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            case "Moderators" :
                
                if let roomU = IGRoom.existRoomInLocal(userId: self.moderators[indexPath.row].userID) {
                    openChat(room: roomU)
                } else { //dont have chat
                    IGGlobal.prgShow(self.view)
                    IGChatGetRoomRequest.Generator.generate(peerId: self.moderators[indexPath.row].userID).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                self.openChat(room: roomU)
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }

            default :
                
                
                if let roomU = IGRoom.existRoomInLocal(userId: self.moderators[indexPath.row].userID) {
                    openChat(room: roomU)
                } else { //dont have chat
                    IGGlobal.prgShow(self.view)
                    IGChatGetRoomRequest.Generator.generate(peerId: self.moderators[indexPath.row].userID).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse {
                                let _ = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                let roomU = IGRoom(igpRoom: chatGetRoomResponse.igpRoom)
                                self.openChat(room: roomU)
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            let alertC = UIAlertController(title: "Error", message: "An error occured trying to create a conversation", preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
                
                
            }

        } else {
            
        }
    }
    
    func openChat(room : IGRoom){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let roomVC = storyboard.instantiateViewController(withIdentifier: "IGMessageViewController") as! IGMessageViewController
        roomVC.room = room
        //        IGFactory.shared.updateRoomLastMessageIfPossible(roomID: room.id)
        
        self.navigationController!.pushViewController(roomVC, animated: true)
    }
    
    
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    func didPressMoreButton(member: IGGroupMember) {
        showAlertMoreOptions(member)
    }
    func didPressMoreButton(member: IGChannelMember) {
        showAlertMoreOptions(channelMember: member)
    }
    
    //Group-Channel alert
    private func showAlertMoreOptions(_ member: IGGroupMember! = nil,channelMember: IGChannelMember? = nil) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        if room?.type == .channel {
            if myChannelRole == .owner {
                if channelMember!.role == .admin {
                    let optionOne = UIAlertAction(title: "REMOVE_ADMIN".localizedNew, style: .default, handler: { (action) in
                        
                            self.kickAdminChanel(userId: channelMember!.user!.id)
   
                    })
                    let optionTwo = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                            self.kickMemberChannel(userId: channelMember!.user!.id)
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
                if channelMember!.role == .moderator {
                    let optionOne = UIAlertAction(title: "REMOVE_MODERATOR".localizedNew, style: .default, handler: { (action) in
                            self.kickModeratorChannel(userId: channelMember!.user!.id)
                    })
                    let optionTwo = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                            self.kickMemberChannel(userId: channelMember!.user!.id)
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
                if channelMember!.role == .member {
                    let optionOne = UIAlertAction(title: "SET_AS_ADMIN".localizedNew, style: .default, handler: { (action) in
                            self.requestToAddAdminInChannel(channelMember!)
                    })
                    let optionTwo = UIAlertAction(title: "SET_AS_MODERATOR".localizedNew, style: .default, handler: { (action) in
                            self.requestToAddModeratorInChannel(channelMember!)
                    })
                    let optionThree = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        self.kickMemberChannel(userId: channelMember!.user!.id)

                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(optionThree)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
            } else if myChannelRole == .admin {
                
                if channelMember!.role == .moderator {
                    let optionOne = UIAlertAction(title: "REMOVE_MODERATOR".localizedNew, style: .default, handler: { (action) in
                        self.kickModeratorChannel(userId: channelMember!.user!.id)
                    })
                    let optionTwo = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                            self.kickMemberChannel(userId: channelMember!.user!.id)
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
                if member.role == .member {
                    let optionOne = UIAlertAction(title: "SET_AS_ADMIN".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                    })
                    let optionTwo = UIAlertAction(title: "SET_AS_MODERATOR".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                    })
                    let optionThree = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(optionThree)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
            }
            
        } else {
            if myRole == .owner {
                if member.role == .admin {
                    let optionOne = UIAlertAction(title: "REMOVE_ADMIN".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                            self.kickAdminChanel(userId: channelMember!.user!.id)
                        } else {
                            self.kickAdmin(userId: member.user!.id)
                        }
                    })
                    let optionTwo = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                            self.kickMemberChannel(userId: channelMember!.user!.id)
                        } else {
                            self.kickMember(userId: member.user!.id)
                        }
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
                if member.role == .moderator {
                    let optionOne = UIAlertAction(title: "REMOVE_MODERATOR".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                            self.kickModeratorChannel(userId: channelMember!.user!.id)
                        } else {
                            self.kickModerator(userId: member.userID)
                        }
                    })
                    let optionTwo = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                            self.kickMemberChannel(userId: channelMember!.user!.id)
                        } else {
                            self.kickMember(userId: member.user!.id)
                        }
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
                if member.role == .member {
                    let optionOne = UIAlertAction(title: "SET_AS_ADMIN".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                            self.requestToAddAdminInChannel(channelMember!)
                        } else {
                            self.requestToAddAdminInGroup(member)
                        }
                    })
                    let optionTwo = UIAlertAction(title: "SET_AS_MODERATOR".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                            self.requestToAddModeratorInChannel(channelMember!)
                        } else {
                            self.requestToAddModeratorInGroup(member)
                        }
                    })
                    let optionThree = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                        if self.room?.type == .channel {
                            self.kickMemberChannel(userId: channelMember!.user!.id)
                        } else {
                            self.kickMember(userId: member.user!.id)
                        }
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(optionThree)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
            } else if myRole == .admin {
                
                if member.role == .moderator {
                    let optionOne = UIAlertAction(title: "REMOVE_MODERATOR".localizedNew, style: .default, handler: { (action) in
                        if self.room?.type == .channel {
                        } else {
                            self.kickModerator(userId: member.user!.id)
                        }
                    })
                    let optionTwo = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                        if self.room?.type == .channel {
                        } else {
                            self.kickMember(userId: member.user!.id)
                        }
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
                if member.role == .member {
                    let optionOne = UIAlertAction(title: "SET_AS_ADMIN".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                        if self.room?.type == .channel {
                        } else {
                            self.requestToAddAdminInGroup(member)
                        }
                    })
                    let optionTwo = UIAlertAction(title: "SET_AS_MODERATOR".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                        if self.room?.type == .channel {
                        } else {
                            self.requestToAddModeratorInGroup(member)
                        }
                    })
                    let optionThree = UIAlertAction(title: "KICK_MEMBER".localizedNew, style: .default, handler: { (action) in
                        //            self.changedChannelTypeToPublic()
                        if self.room?.type == .channel {
                        } else {
                            self.kickMember(userId: member.user!.id)
                        }
                    })
                    
                    let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
                    
                    alertController.addAction(optionOne)
                    alertController.addAction(optionTwo)
                    alertController.addAction(optionThree)
                    alertController.addAction(cancel)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                    
                    
                }
            }
            
        }
 

    }
    func kickAlert(title: String, message: String, alertClouser: @escaping ((_ state :AlertState) -> Void)){
        let option = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .destructive, handler: { (action) in
            alertClouser(AlertState.Ok)
        })
        let cancel = UIAlertAction(title: "GLOBAL_NO".localizedNew, style: .cancel, handler: { (action) in
            alertClouser(AlertState.No)
        })
        
        option.addAction(ok)
        option.addAction(cancel)
        self.present(option, animated: true, completion: nil)
    }
    
    

    
    ////Channel
    
    
    func kickAdminChanel(userId: Int64) {
        if let channelRoom = room {
            kickAlert(title: "REMOVE_ADMIN".localizedNew, message: "ARE_U_SURE_REMOVE_ADMIN".localizedNew, alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGChannelKickAdminRequest.Generator.generate(roomId: channelRoom.id , memberId: userId).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let channelKickAdminResponse as IGPChannelKickAdminResponse:
                                let _ = IGChannelKickAdminRequest.Handler.interpret( response : channelKickAdminResponse)
                                self.tableView.reloadData()
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        IGGlobal.prgHide()
                        switch errorCode {
                        case .timeout:
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        default:
                            break
                        }
                        
                    }).send()
                }
            })
        }
    }
    
    func kickModeratorChannel(userId: Int64) {
        if let channelRoom = room {
            kickAlert(title: "REMOVE_MODERATOR".localizedNew, message: "ARE_U_SURE_REMOVE_MODERATOR".localizedNew, alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGChannelKickModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: userId).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let channelKickModeratorResponse as IGPChannelKickModeratorResponse:
                                IGChannelKickModeratorRequest.Handler.interpret( response : channelKickModeratorResponse)
                                self.tableView.reloadData()
                                
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        IGGlobal.prgHide()
                        switch errorCode {
                        case .timeout:
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        default:
                            break
                        }
                        
                    }).send()
                }
            })
        }
    }

    
    func kickMemberChannel(userId: Int64) {
        if let _ = room {
            kickAlert(title: "KICK_MEMBER".localizedNew, message: "ARE_U_SURE_KICK_USER".localizedNew, alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGChannelKickMemberRequest.Generator.generate(roomID: (self.room?.id)!, memberID: userId).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let kickMemberResponse as IGPChannelKickMemberResponse:
                                let _ = IGChannelKickMemberRequest.Handler.interpret(response: kickMemberResponse)
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        IGGlobal.prgHide()
                        switch errorCode {
                        case .timeout:
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        default:
                            break
                        }
                        
                    }).send()
                }
            })
        }
    }
    
    
    
    //Group
    func kickAdmin(userId: Int64) {
        if let groupRoom = room {
            kickAlert(title: "REMOVE_ADMIN".localizedNew, message: "ARE_U_SURE_REMOVE_ADMIN".localizedNew, alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGGroupKickAdminRequest.Generator.generate(roomID: groupRoom.id , memberID: userId).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let groupKickAdminResponse as IGPGroupKickAdminResponse:
                                IGGroupKickAdminRequest.Handler.interpret( response : groupKickAdminResponse)
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        IGGlobal.prgHide()
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
            })
        }
    }
    
    func kickModerator(userId: Int64) {
        if let groupRoom = room {
            kickAlert(title: "REMOVE_MODERATOR".localizedNew, message: "ARE_U_SURE_REMOVE_MODERATOR", alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGGroupKickModeratorRequest.Generator.generate(memberId: userId, roomId: groupRoom.id).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let groupKickModeratorResponse as IGPGroupKickModeratorResponse:
                                IGGroupKickModeratorRequest.Handler.interpret( response : groupKickModeratorResponse)
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        IGGlobal.prgHide()
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
            })
        }
    }
    
    func kickMember(userId: Int64) {
        if room != nil {
            kickAlert(title: "KICK_MEMBER".localizedNew, message: "ARE_U_SURE_KICK_USER".localizedNew, alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGGroupKickMemberRequest.Generator.generate(memberId: userId, roomId: (self.room?.id)!).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            if let kickMemberResponse = protoResponse as? IGPGroupKickMemberResponse {
                                IGGroupKickMemberRequest.Handler.interpret(response: kickMemberResponse)
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
                        IGGlobal.prgHide()
                        switch errorCode {
                        case .timeout:
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        default:
                            break
                        }
                    }).send()
                }
            })
        }
    }
    //channel
    
    func requestToAddAdminInChannel(_ member: IGChannelMember) {
            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGChannelAddAdminRequest.Generator.generate(roomID: channelRoom.id, memberID: member.user!.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        if let channelAddAdminResponse = protoResponse as? IGPChannelAddAdminResponse {
                            IGChannelAddAdminRequest.Handler.interpret(response: channelAddAdminResponse, memberRole: .admin)
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .canNotAddThisUserAsAdminToGroup:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "There is an error to adding this contact in channel", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    default:
                        break
                    }
                    
                }).send()
            }
    }
    //Group
    func requestToAddAdminInGroup(_ member: IGGroupMember) {
            if let groupRoom = room {
                IGGlobal.prgShow(self.view)
                IGGroupAddAdminRequest.Generator.generate(roomID: groupRoom.id, memberID: member.user!.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        if let grouplAddAdminResponse = protoResponse as? IGPGroupAddAdminResponse {
                            IGGroupAddAdminRequest.Handler.interpret(response: grouplAddAdminResponse, memberRole: .admin)
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .canNotAddThisUserAsAdminToGroup:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Error", message: "There is an error to adding this contact in group", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    default:
                        break
                    }
                    
                }).send()
            }
    }
    //channel
    func requestToAddModeratorInChannel(_ member: IGChannelMember) {

            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGChannelAddModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: member.user!.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        if let channelAddModeratorResponse = protoResponse as? IGPChannelAddModeratorResponse {
                            IGChannelAddModeratorRequest.Handler.interpret(response: channelAddModeratorResponse, memberRole: .moderator)
                        }
                    }
                    
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .canNotAddThisUserAsModeratorToGroup:
                        DispatchQueue.main.async {
                            let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew, preferredStyle: .alert)
                            
                            let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                        
                    default:
                        break
                    }
                    
                }).send()
                
            }

    }
    //Group
    func requestToAddModeratorInGroup(_ member: IGGroupMember) {

            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGGroupAddModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: member.user!.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        if let groupAddModeratorResponse = protoResponse as? IGPGroupAddModeratorResponse {
                            IGGroupAddModeratorRequest.Handler.interpret(response: groupAddModeratorResponse, memberRole: .moderator)
                        }
                    }
                    
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    case .canNotAddThisUserAsModeratorToGroup:
                        DispatchQueue.main.async {
                            let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew, preferredStyle: .alert)
                            
                            let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                        
                    default:
                        break
                    }
                    
                }).send()
                
            }

    }
    
    func fetchChannelMemberFromServer() {
        IGGlobal.prgShow(self.view)
        switch mode {
        case "Members" :
            filterRole = .all
        case "Admins" :
            filterRole = .admin
        case "Moderators" :
            filterRole = .moderator
        default : filterRole = .all
        }
        IGChannelGetMemberListRequest.Generator.generate(roomId: roomId, offset: Int32(self.allMemberChannel.count), limit: 40, filterRole: filterRole).success({ (protoResponse) in
            IGGlobal.prgHide()
            DispatchQueue.main.async {
                switch protoResponse {
                case let getChannelMemberList as IGPChannelGetMemberListResponse:
                    let igpMembers =  IGChannelGetMemberListRequest.Handler.interpret(response: getChannelMemberList, roomId: (self.room?.id)!)
                    for member in igpMembers {
                        let igmember = IGChannelMember(igpMember: member, roomId: self.roomId)
                        self.allMemberChannel.append(igmember)
                        self.tableView.reloadData()

                    }
                    self.tableView.reloadData()
                    
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    func fetchGroupMemberFromServer() {
        IGGlobal.prgShow(self.view)
        
        IGGroupGetMemberListRequest.Generator.generate(roomId: roomId, offset: Int32(self.allMember.count), limit: 40, filterRole: filterRole).success({ (protoResponse) in
            IGGlobal.prgHide()
            DispatchQueue.main.async {
                switch protoResponse {
                case let getGroupMemberList as IGPGroupGetMemberListResponse:
                    let igpMembers =  IGGroupGetMemberListRequest.Handler.interpret(response: getGroupMemberList, roomId: (self.room?.id)!)
                    for member in igpMembers {
                        let igmember = IGGroupMember(igpMember: member, roomId: self.roomId)
                        self.allMember.append(igmember)
                    }
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if room?.type == .group {
            if segue.identifier == "showContactToAddMember" {
                let destinationTv = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
                destinationTv.mode = "Members"
                destinationTv.room = room
            }
            if segue.identifier == "GoToChangeGroupPublicLink" {
                let destination = segue.destination as! IGGroupInfoEditTypeTableViewController
                destination.room = room
            }

        } else {
            if segue.identifier == "showContactToAddMember" {
                let destinationTv = segue.destination as! IGChooseMemberFromContactsToCreateGroupViewController
                destinationTv.mode = "Members"
                destinationTv.room = room
            }

        }
    }
}
