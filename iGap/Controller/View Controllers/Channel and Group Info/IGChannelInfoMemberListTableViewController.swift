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

class IGChannelInfoMemberListTableViewController: UITableViewController , UIGestureRecognizerDelegate {
    
    var allMember = [IGChannelMember]()
    
    var room : IGRoom?
    var hud = MBProgressHUD()
    var filterRole : IGRoomFilterRole = .all
    var members : Results<IGChannelMember>!
    var admins : Results<IGChannelMember>!
    var moderators : Results<IGChannelMember>!
    var adminsRole = IGChannelMember.IGRole.admin.rawValue
    var moderatorRole = IGChannelMember.IGRole.moderator.rawValue

    var mode : String? = "Members"
    var notificationToken: NotificationToken?
    var notificationTokenModerator: NotificationToken?
    var notificationTokenAdmin: NotificationToken?
    var myRole : IGChannelMember.IGRole?
    var roomId: Int64!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRole = room?.channelRoom?.role
        roomId = room?.id
        setNavigationItem()
//        fetchChannelMemberFromServer()
        
        let predicate = NSPredicate(format: "roomID = %lld", (room?.channelRoom?.id)!)
        let predicateModerators = NSPredicate(format: "roleRaw = %d AND roomID = %lld", moderatorRole , (room?.channelRoom?.id)!)
        let predicateAdmins = NSPredicate(format: "roleRaw = %d AND roomID = %lld", adminsRole , (room?.channelRoom?.id)!)

        members =  try! Realm().objects(IGChannelMember.self).filter(predicate)
        moderators =  try! Realm().objects(IGChannelMember.self).filter(predicateModerators)
        admins =  try! Realm().objects(IGChannelMember.self).filter(predicateAdmins)

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
        }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChannelMemberFromServer()

    }
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        if myRole == .admin || myRole == .owner {
            navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: "ALLMEMBER".localizedNew)
        } else {
            navigationItem.addNavigationViewItems(rightItemText: nil, title: "ALLMEMBER".localizedNew)
        }
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "showContactsToAddMember", sender: self)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case "Members" :
            return members.count
        case "Admins" :
            return admins.count
        case "Moderators" :
            return moderators.count
        default : return members.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! IGChannelInfoMemberListTableViewCell
        
        if mode == "Members" {
            let member = members[indexPath.row]
            cell.setUser(member)
            let swipeOption = detectSwipeOption(memberRole: member.role)
            
            if swipeOption.showOption {
                let btnKick = MGSwipeButton(title: swipeOption.kickTitle, backgroundColor: UIColor.swipeGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
                    self.detectSwipeAction(member: self.members[indexPath.row])
                    return true
                })
                
                let buttons = [btnKick]
                cell.rightButtons = buttons
                removeButtonsUnderline(buttons: buttons)
                
                cell.rightSwipeSettings.transition = MGSwipeTransition.border
                cell.rightExpansion.buttonIndex = 0
                cell.rightExpansion.fillOnTrigger = true
                cell.rightExpansion.threshold = 1.5
                cell.clipsToBounds = true
                cell.swipeBackgroundColor = UIColor.clear
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.layoutMargins = UIEdgeInsets.zero
            }
            
            cell.layer.cornerRadius = 10
            
            return cell

        } else if mode == "Admins" {
            let member = admins[indexPath.row]
            cell.setUser(member)
            let swipeOption = detectSwipeOption(memberRole: member.role)
            
            if swipeOption.showOption {
                let btnKick = MGSwipeButton(title: swipeOption.kickTitle, backgroundColor: UIColor.swipeGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
                    self.detectSwipeAction(member: self.admins[indexPath.row])
                    return true
                })
                
                let buttons = [btnKick]
                cell.rightButtons = buttons
                removeButtonsUnderline(buttons: buttons)
                
                cell.rightSwipeSettings.transition = MGSwipeTransition.border
                cell.rightExpansion.buttonIndex = 0
                cell.rightExpansion.fillOnTrigger = true
                cell.rightExpansion.threshold = 1.5
                cell.clipsToBounds = true
                cell.swipeBackgroundColor = UIColor.clear
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.layoutMargins = UIEdgeInsets.zero
            }
            
            cell.layer.cornerRadius = 10
            
            return cell

            
        } else {
            let member = moderators[indexPath.row]
            cell.setUser(member)
            let swipeOption = detectSwipeOption(memberRole: member.role)
            
            if swipeOption.showOption {
                let btnKick = MGSwipeButton(title: swipeOption.kickTitle, backgroundColor: UIColor.swipeGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
                    self.detectSwipeAction(member: self.moderators[indexPath.row])
                    return true
                })
                
                let buttons = [btnKick]
                cell.rightButtons = buttons
                removeButtonsUnderline(buttons: buttons)
                
                cell.rightSwipeSettings.transition = MGSwipeTransition.border
                cell.rightExpansion.buttonIndex = 0
                cell.rightExpansion.fillOnTrigger = true
                cell.rightExpansion.threshold = 1.5
                cell.clipsToBounds = true
                cell.swipeBackgroundColor = UIColor.clear
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cell.layoutMargins = UIEdgeInsets.zero
            }
            
            cell.layer.cornerRadius = 10
            
            return cell

        }
    }
    
    private func detectSwipeOption(memberRole: IGChannelMember.IGRole!) -> (showOption:Bool, kickTitle:String) {
        var showOption = true
        var kickTitle: String = ""
        
        switch myRole! {
        case .owner:
            if memberRole == .admin {
                kickTitle = "REMOVE_ADMIN".localizedNew
            } else if memberRole == .moderator {
                kickTitle = "REMOVE_MODERATOR".localizedNew
            } else if memberRole == .member {
                kickTitle = "KICK_MEMBER".localizedNew
            } else {
                showOption = false
            }
            break
            
        case .admin:
            if memberRole == .moderator {
                kickTitle = "REMOVE_MODERATOR".localizedNew
            } else if memberRole == .member {
                kickTitle = "KICK_MEMBER".localizedNew
            } else {
                showOption = false
            }
            break
            
        case .moderator:
            if memberRole == .member {
                kickTitle = "KICK_MEMBER".localizedNew
            } else {
                showOption = false
            }
            break
            
        case .member:
            showOption = false
            break
        }
        
        return (showOption, kickTitle)
    }
    
    private func detectSwipeAction(member: IGChannelMember) {
        switch myRole! {
        case .owner:
            if member.role == .admin {
                kickAdmin(userId: member.userID)
            } else if member.role == .moderator {
                kickModerator(userId: member.userID)
            } else if member.role == .member {
                kickMember(userId: member.userID)
            }
            break
            
        case .admin:
            if member.role == .moderator {
                kickModerator(userId: member.userID)
            } else if member.role == .member {
                kickMember(userId: member.userID)
            }
            break
            
        case .moderator:
            if member.role == .member {
                kickMember(userId: member.userID)
            }
            break
            
        case .member:
            // do nothing
            break
        }
    }
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    
    func kickAlert(title: String, message: String, alertClouser: @escaping ((_ state :AlertState) -> Void)){
        let option = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .destructive, handler: { (action) in
            alertClouser(AlertState.Ok)
        })
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            alertClouser(AlertState.No)
        })
        
        option.addAction(ok)
        option.addAction(cancel)
        self.present(option, animated: true, completion: nil)
    }
    
    func kickAdmin(userId: Int64) {
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
    
    func kickModerator(userId: Int64) {
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

    
    func kickMember(userId: Int64) {
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
    
    private func showAlertView(title: String, message: String?, subtitles: [String], alertClouser: @escaping ((_ title :String) -> Void), hasCancel: Bool = true){
        let option = UIAlertController(title: title, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        
        for subtitle in subtitles {
            let action = UIAlertAction(title: subtitle, style: .default, handler: { (action) in
                alertClouser(action.title!)
            })
            option.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        option.addAction(cancel)
        
        self.present(option, animated: true, completion: {})
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
        IGChannelGetMemberListRequest.Generator.generate(roomId: roomId, offset: Int32(self.allMember.count), limit: 40, filterRole: filterRole).success({ (protoResponse) in
            IGGlobal.prgHide()
            DispatchQueue.main.async {
                switch protoResponse {
                case let getChannelMemberList as IGPChannelGetMemberListResponse:
                    let igpMembers =  IGChannelGetMemberListRequest.Handler.interpret(response: getChannelMemberList, roomId: (self.room?.id)!)
                    for member in igpMembers {
                        let igmember = IGChannelMember(igpMember: member, roomId: self.roomId)
                        self.allMember.append(igmember)
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactsToAddMember" {
            let destination = segue.destination as! IGChooseMemberFromContactToCreateChannelViewController
            destination.mode = mode
            destination.room = room
        }
    }
}
