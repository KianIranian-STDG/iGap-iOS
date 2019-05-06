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

class IGChannelInfoAdminsListTableViewController: BaseTableViewController , UIGestureRecognizerDelegate {

    var room : IGRoom?
    var mode : String?
    var allMembers = [IGChannelMember]()
    var adminsRole = IGChannelMember.IGRole.admin.rawValue
    var moderatorRole = IGChannelMember.IGRole.moderator.rawValue
    var notificationToken: NotificationToken?
    var members : Results<IGChannelMember>!
    var predicate : NSPredicate!
    var navigationTitle : String?
    var noDataTitle : String?
    var hud = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        if mode == "Admin" {
            navigationTitle = "ADMIN".localizedNew
            noDataTitle = "This channel has no admin."
            predicate = NSPredicate(format: "roleRaw = %d AND roomID = %lld", adminsRole , (room?.id)!)
            members =  try! Realm().objects(IGChannelMember.self).filter(predicate!)
        }
        if mode == "Moderator" {
            navigationTitle = "MODERATOR".localizedNew
            noDataTitle = "This channel has no moderator."
            predicate = NSPredicate(format: "roleRaw = %d AND roomID = %lld", moderatorRole , (room?.id)!)
            members =  try! Realm().objects(IGChannelMember.self).filter(predicate!)
        }
        self.notificationToken = members.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, _, _, _):
                self.tableView.reloadData()
                break
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        
        setNavigationItem()
    }
    
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: navigationTitle)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "showContactToAdminsOrModerators", sender: self)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if members.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        
        let rect = CGRect(x: 0,y: 0,width: self.tableView.bounds.size.width,height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        noDataLabel.text = noDataTitle
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = NSTextAlignment.center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adminCell", for: indexPath) as! IGChannelInfoAdminsTableViewCell
        cell.setUser(members[indexPath.row])
        
        var kickText = "remove admin"
        if mode == "Moderator" {
            kickText = "remove moderator"
        }
        
        let btnKick = MGSwipeButton(title: kickText, backgroundColor: UIColor.swipeGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
            if self.mode == "Admin" {
                self.kickAdmin(adminUserID: self.members[indexPath.row].userID)
            } else if self.mode == "Moderator" {
                self.kickModerator(moderatorUserId: self.members[indexPath.row].userID)
            }
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
        cell.layer.cornerRadius = 10
        
        return cell
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
    
    func kickAdmin(adminUserID: Int64) {
        if let channelRoom = room {
            kickAlert(title: "Remove Admin", message: "Are you sure you want to remove the admin role from this member?", alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGChannelKickAdminRequest.Generator.generate(roomId: channelRoom.id , memberId: adminUserID ).success({ (protoResponse) in
                        IGGlobal.prgHide()
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let channelKickAdminResponse as IGPChannelKickAdminResponse:
                                let _ = IGChannelKickAdminRequest.Handler.interpret(response : channelKickAdminResponse)
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
    
    func kickModerator(moderatorUserId: Int64) {
        if let channelRoom = room {
            kickAlert(title: "Remove Moderator", message: "Are you sure you want to remove the moderator role from this member?", alertClouser: { (state) -> Void in
                if state == AlertState.Ok {
                    IGGlobal.prgShow(self.view)
                    IGChannelKickModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: moderatorUserId).success({ (protoResponse) in
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContactToAdminsOrModerators" {
            let destination = segue.destination as! IGChooseMemberFromContactToCreateChannelViewController
            destination.mode = mode
            destination.room = room
        }
    }
}
