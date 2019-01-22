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
    var mode : String? = "Members"
    var notificationToken: NotificationToken?
    var myRole : IGChannelMember.IGRole?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myRole = room?.channelRoom?.role
        
        setNavigationItem()
        fetchChannelMemberFromServer()
        
        let predicate = NSPredicate(format: "roomID = %lld", (room?.id)!)
        members =  try! Realm().objects(IGChannelMember.self).filter(predicate)
        self.notificationToken = members.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query messages have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }

    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        if myRole == .admin || myRole == .owner {
            navigationItem.addNavigationViewItems(rightItemText: "Add", title: "Members")
        } else {
            navigationItem.addNavigationViewItems(rightItemText: nil, title: "Members")
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
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! IGChannelInfoMemberListTableViewCell
        
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
    }
    
    private func detectSwipeOption(memberRole: IGChannelMember.IGRole!) -> (showOption:Bool, kickTitle:String) {
        var showOption = true
        var kickTitle: String = ""
        
        switch myRole! {
        case .owner:
            if memberRole == .admin {
                kickTitle = "remove admin"
            } else if memberRole == .moderator {
                kickTitle = "remove moderator"
            } else if memberRole == .member {
                kickTitle = "kick member"
            } else {
                showOption = false
            }
            break
            
        case .admin:
            if memberRole == .moderator {
                kickTitle = "remove moderator"
            } else if memberRole == .member {
                kickTitle = "kick member"
            } else {
                showOption = false
            }
            break
            
        case .moderator:
            if memberRole == .member {
                kickTitle = "kick member"
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
            kickAlert(title: "Remove Admin", message: "Are you sure you want to remove the admin role from this member?", alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.hud.mode = .indeterminate
                    IGChannelKickAdminRequest.Generator.generate(roomId: channelRoom.id , memberId: userId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let channelKickAdminResponse as IGPChannelKickAdminResponse:
                                IGChannelKickAdminRequest.Handler.interpret( response : channelKickAdminResponse)
                                self.tableView.reloadData()
                                self.hud.hide(animated: true)
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
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
                            break
                        }
                        
                    }).send()
                }
            })
        }
    }
    
    func kickModerator(userId: Int64) {
        if let channelRoom = room {
            kickAlert(title: "Remove Moderator", message: "Are you sure you want to remove the moderator role from this member?", alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.hud.mode = .indeterminate
                    IGChannelKickModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: userId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let channelKickModeratorResponse as IGPChannelKickModeratorResponse:
                                IGChannelKickModeratorRequest.Handler.interpret( response : channelKickModeratorResponse)
                                self.hud.hide(animated: true)
                                self.tableView.reloadData()
                                
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
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
                            break
                        }
                        
                    }).send()
                }
            })
        }
    }

    
    func kickMember(userId: Int64) {
        if let _ = room {
            kickAlert(title: "Kick Member", message: "Are you sure you want to kick this member?", alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.hud.mode = .indeterminate
                    IGChannelKickMemberRequest.Generator.generate(roomID: (self.room?.id)!, memberID: userId).success({
                        (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let kickMemberResponse as IGPChannelKickMemberResponse:
                                IGChannelKickMemberRequest.Handler.interpret(response: kickMemberResponse)
                                self.hud.hide(animated: true)
                            default:
                                break
                            }
                        }
                    }).error ({ (errorCode, waitTime) in
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
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGChannelGetMemberListRequest.Generator.generate(room: room!, offset: Int32(self.allMember.count), limit: 40, filterRole: filterRole).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getChannelMemberList as IGPChannelGetMemberListResponse:
                    let igpMembers =  IGChannelGetMemberListRequest.Handler.interpret(response: getChannelMemberList, roomId: (self.room?.id)!)
                    for member in igpMembers {
                        let igmember = IGChannelMember(igpMember: member, roomId: (self.room?.id)!)
                        self.allMember.append(igmember)
                    }
                    self.hud.hide(animated: true)
                    //self.tableView.reloadData()
                    
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
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
