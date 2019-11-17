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
import Contacts
import RealmSwift
import IGProtoBuff
import MBProgressHUD

class IGMemberAddOrUpdateState: BaseViewController {
    
    @IBOutlet weak var selectedContactsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var contactViewBottomConstraizt: NSLayoutConstraint!
    @IBOutlet weak var contactViewHeightConstraint: NSLayoutConstraint!
    
    var baseUser: IGRegisteredUser?

    class User: NSObject {
        let registredUser: IGRegisteredUser
        @objc let name: String
        var section:Int?
        init(registredUser: IGRegisteredUser){
            self.registredUser = registredUser
            self.name = registredUser.displayName
        }
    }
    
    class Section  {
        var users = [User]()
        func addUser(_ user:User) {
            self.users.append(user)
        }
    }
    
    var collectionIndexPath:IndexPath?
    var selectedIndexPath: IndexPath?
    var selectedUsers: [User] = []
    var selectUser: User?
    var mode: String?
    var roomID: Int64?
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var contactTableSelectedIndexPath : IndexPath?
    var room: IGRoom?
    var hud = MBProgressHUD()
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1")
    var contactSections: [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var doneActionsCount: Int = 0
    private var existErrorUserIds : [Int64] = []
    
    var sections: [Section] {
        if self.contactSections != nil {
            return self.contactSections!
        }
        let users: [User] = contacts.map { (registredUser) -> User in
            let user = User(registredUser: registredUser)
            user.section = self.collation.section(for: user, collationStringSelector: #selector(getter: User.name))
            return user
        }
        
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        for user in users {
            if !(user.registredUser.id == baseUser?.id) {
                sections[user.section!].addUser(user)
            }
        }
        
        for section in sections {
            section.users = self.collation.sortedArray(from: section.users, collationStringSelector: #selector(getter: User.name)) as! [User]
        }
        
        self.contactSections = sections
        return self.contactSections!
    }
    
    func dismmisDelegate(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomID = self.room?.id
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        collectionView.dataSource = self
        self.contactsTableView.allowsMultipleSelection = true
        self.contactsTableView.allowsMultipleSelectionDuringEditing = true
        self.contactsTableView.setEditing(true, animated: true)
        self.contactsTableView.sectionIndexBackgroundColor = UIColor.clear
        self.selectedContactsView.addSubview(collectionView)
        self.contactViewBottomConstraizt.constant = -self.contactViewHeightConstraint.constant
        setNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        navigationControllerr.navigationBar.isHidden = false
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.searchController = nil
    }
    
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.navigationController = self.navigationController as? IGNavigationController

        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        if mode == "Admin" {
            navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.AddAdmin.rawValue.localized, iGapFont: true)
        }
        
        if mode == "Moderator" {
            navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.AddModerator.rawValue.localized, iGapFont: true)
        }
        
        if mode == "CreateGroup" {
            navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.NewGroup.rawValue.localized, iGapFont: true)
        }
        
        if mode == "CreateChannel" {
            navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.NewChannel.rawValue.localized, iGapFont: true)
        }
        
        if mode == "Members" {
            navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.AddMember.rawValue.localized, iGapFont: true)
        }
        
        if mode == "ConvertChatToGroup" {
            navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.AddMemberTo.rawValue.localized, iGapFont: true)
        }
        
        navigationItem.leftViewContainer?.addAction {
            if self.mode == "Admin" || self.mode == "Moderator" || self.mode == "Members" {
                if self.navigationController is IGNavigationController {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                if self.navigationController is IGNavigationController {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        navigationItem.rightViewContainer?.addAction {
            if self.mode == "Members" {
                if self.room?.type == .channel {
                    self.requestToAddmemberToChannel()
                } else {
                    self.requestToAddmember()
                }
                
            } else if self.mode == "Moderator" {
                if self.room?.type == .channel {
                    self.requestToAddModeratorInChannel()
                } else {
                    self.requestToAddModeratorInGroup()
                }
                
            } else if self.mode == "Admin"{
                if self.room?.type == .channel {
                    self.requestToAddAdminInChannel()
                } else {
                    self.requestToAddAdminInGroup()
                }
                
            } else {
                if self.mode == "CreateGroup" {
                    let createGroup = IGCreateNewGroupTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                    let selectedUsersToCreateGroup = self.selectedUsers.map({ (user) -> IGRegisteredUser in
                        return user.registredUser
                    })
                    var tmp = selectedUsersToCreateGroup
                    if !(self.baseUser == nil) {
                        tmp.append(self.baseUser!)
                    }
                    createGroup.selectedUsersToCreateGroup = tmp
                    createGroup.mode = self.mode
                    createGroup.roomId = self.roomID
                    createGroup.hidesBottomBarWhenPushed = true
                    self.navigationController!.pushViewController(createGroup, animated: true)
                } else if self.mode == "CreateChannel" {
                    self.requestToAddmemberToChannel()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if room?.type != .channel {
            if segue.identifier == "CreateGroupPage" {
                let selectedUsersToCreateGroup = selectedUsers.map({ (user) -> IGRegisteredUser in
                    return user.registredUser
                })
                let destinationVC = segue.destination as! IGCreateNewGroupTableViewController
                destinationVC.selectedUsersToCreateGroup = selectedUsersToCreateGroup
                destinationVC.mode = mode
                destinationVC.roomId = roomID
            }
        }
    }
    
    func requestToAddmember() {
        if selectedUsers.count == 0 {

            
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.chooseMemberPlease.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            return
        }
        
        for member in selectedUsers {
            IGGroupAddMemberRequest.Generator.generate(userID:member.registredUser.id, group: room!).success({ (protoResponse) in
                if let groupAddMemberResponse = protoResponse as? IGPGroupAddMemberResponse {
                    IGGroupAddMemberRequest.Handler.interpret(response: groupAddMemberResponse)
                }
                self.manageClosePage()
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                if errorCode == .groupMemberIsExist {
                    if let requsetMessage = requestWrapper.message as? IGPGroupAddMember {
                        self.existErrorUserIds.append(requsetMessage.igpMember.igpUserID)
                    }
                }
                self.manageClosePage()
            }).send()
        }
    }

    
    func requestToAddmemberToChannel() {
        if selectedUsers.count == 0 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.chooseMemberPlease.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        }
        
        for member in selectedUsers {
            IGChannelAddMemberRequest.Generator.generate(userID:member.registredUser.id, channel: room!).success({ (protoResponse) in
                if let channelAddMemberResponse = protoResponse as? IGPChannelAddMemberResponse {
                    IGChannelAddMemberRequest.Handler.interpret(response: channelAddMemberResponse)
                }
                self.manageClosePage()
            }).errorPowerful({ (errorCode, waitTime, requestWrapper) in
                if errorCode == .channelMemberIsExist {
                    if let requsetMessage = requestWrapper.message as? IGPChannelAddMember {
                        self.existErrorUserIds.append(requsetMessage.igpMember.igpUserID)
                    }
                }
                self.manageClosePage()
            }).send()
        }
    }
    
    func requestToAddAdminInChannel() {
        if selectedUsers.count == 0 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.chooseMemberPlease.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        }
        
        for member in selectedUsers {
            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGChannelAddAdminRequest.Generator.generate(roomID: channelRoom.id, memberID: member.registredUser.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        self.manageClosePage()
                        if let channelAddAdminResponse = protoResponse as? IGPChannelAddAdminResponse {
                            IGChannelAddAdminRequest.Handler.interpret(response: channelAddAdminResponse)
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    self.manageClosePage()
                    switch errorCode {
                    case .timeout:
                        break
                    case .canNotAddThisUserAsAdminToGroup:
                        break
                    default:
                        break
                    }
                    
                }).send()
            }
        }
    }
    
    
    func requestToAddModeratorInChannel() {
        if selectedUsers.count == 0 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.chooseMemberPlease.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        }
        
        for member in selectedUsers {
            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGChannelAddModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: member.registredUser.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        self.manageClosePage()
                        if let channelAddModeratorResponse = protoResponse as? IGPChannelAddModeratorResponse {
                            IGChannelAddModeratorRequest.Handler.interpret(response: channelAddModeratorResponse)
                        }
                    }
                    
                }).error ({ (errorCode, waitTime) in
                    self.manageClosePage()
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        break
                    case .canNotAddThisUserAsModeratorToGroup:
                        DispatchQueue.main.async {
                            
                            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalOK.rawValue.localized)

                        }
                        
                        
                    default:
                        break
                    }
                    
                }).send()
                
            }
        }
    }
    
    //Group
    func requestToAddAdminInGroup() {
        if selectedUsers.count == 0 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.chooseMemberPlease.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        }
        
        for member in selectedUsers {
            if let groupRoom = room {
                IGGlobal.prgShow(self.view)
                IGGroupAddAdminRequest.Generator.generate(roomID: groupRoom.id, memberID: member.registredUser.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        self.manageClosePage()
                        if let channelAddAdminResponse = protoResponse as? IGPGroupAddAdminResponse {
                            IGGroupAddAdminRequest.Handler.interpret(response: channelAddAdminResponse)
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    self.manageClosePage()
                    switch errorCode {
                    case .timeout:
                        break
                    case .canNotAddThisUserAsAdminToGroup:
                        break
                    default:
                        break
                    }
                    
                }).send()
            }
        }
    }
    
    func requestToAddModeratorInGroup() {
        if selectedUsers.count == 0 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.chooseMemberPlease.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        }
        
        for member in selectedUsers {
            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGGroupAddModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: member.registredUser.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        self.manageClosePage()
                        if let groupAddModeratorResponse = protoResponse as? IGPGroupAddModeratorResponse {
                            IGGroupAddModeratorRequest.Handler.interpret(response: groupAddModeratorResponse)
                        }
                    }
                    
                }).error ({ (errorCode, waitTime) in
                    self.manageClosePage()
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        break
                        
                    case .canNotAddThisUserAsModeratorToGroup:
                        DispatchQueue.main.async {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        }
                        break
                        
                    default:
                        break
                    }
                }).send()
            }
        }
    }
    
    private func manageClosePage(){
        DispatchQueue.main.async {
            self.doneActionsCount += 1
            if self.selectedUsers.count == self.doneActionsCount {
                if self.mode == "CreateChannel" {
                    self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom), object: nil, userInfo: ["room": self.roomID!])
                } else {
                    if self.existErrorUserIds.count == 0 {
                        if self.navigationController is IGNavigationController {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        var names = ""
                        for userId in self.existErrorUserIds {
                            if let userInfo = IGRegisteredUser.getUserInfo(id: userId) {
                                if names.isEmpty {
                                    names = userInfo.displayName
                                } else {
                                    names = names + " , " + userInfo.displayName
                                }
                            }
                        }
                        
                        var message: String!
                        if self.existErrorUserIds.count == 1 {
                            message = names + "\n" + IGStringsManager.AlreadyIsInTheMemberList.rawValue.localized
                        } else {
                            message = names + "\n" + IGStringsManager.AlreadyAreInTheMemberList.rawValue.localized
                        }
                        
                        let alertC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { action in
                            if self.navigationController is IGNavigationController {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                        alertC.addAction(ok)
                        self.present(alertC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension IGMemberAddOrUpdateState : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true{
            let currentCell = tableView.cellForRow(at: indexPath) as! IGMemberChoose?
            contactTableSelectedIndexPath = indexPath
            selectUser = currentCell?.user
            selectedUsers.append((currentCell?.user)!)
            selectedIndexPath = indexPath
            self.contactViewBottomConstraizt.constant = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.selectedContactsView.alpha = 1
                self.view.layoutIfNeeded()
            })
            collectionView.performBatchUpdates({
                let a = IndexPath(row: self.selectedUsers.count - 1, section: 0)
                self.collectionView.insertItems(at: [a])
            }, completion: { (completed) in
                //do nothing
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true{
            if selectedUsers.count > 0 {
                let tableviewcell = tableView.cellForRow(at: indexPath) as! IGMemberChoose
                let deselectedUser = tableviewcell.user
                
                for  (index, user) in selectedUsers.enumerated() {
                    if (user.registredUser.id) == deselectedUser?.registredUser.id {
                        selectedUsers.remove(at: index)
                        collectionView.performBatchUpdates({
                            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                        }, completion: { (completed) in
                            
                        })
                    }
                }
            }
            if collectionView.numberOfItems(inSection: 0) == 0 {
                
                self.contactViewBottomConstraizt.constant = -self.contactViewHeightConstraint.constant
                UIView.animate(withDuration: 0.2, animations: {
                    self.selectedContactsView.alpha = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
}

//MARK:- UITableViewDataSource
extension IGMemberAddOrUpdateState : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! IGMemberChoose
        contactsCell.lastSeenStatusLabel.textAlignment = self.TextAlignment
        let user = self.sections[indexPath.section].users[indexPath.row]
        contactsCell.user = user
        cell = contactsCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 94.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}

//MARK: - UICollectionViewDataSource
extension IGMemberAddOrUpdateState : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! IGMemberChooseBottomCollectionCell
        cell.selectedRowIndexPathForTableView = contactTableSelectedIndexPath
        cell.user = selectedUsers[indexPath.row]
        cell.cellDelegate = self
        collectionIndexPath = indexPath
        return cell
    }
}

//MARK: - IGDeleteSelectedCellDelegate
extension IGMemberAddOrUpdateState: IGDeleteSelectedCellDelegate {
    func contactViewWasSelected(cell: IGMemberChooseBottomCollectionCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let tableIndexPath = cell.selectedRowIndexPathForTableView
        contactsTableView.deselectRow(at: tableIndexPath!, animated: true)
        collectionView.performBatchUpdates({
            self.selectedUsers.remove(at: (indexPath?.row)!)
            self.collectionView.deleteItems(at: [indexPath!])
        }, completion: { (completed) in
            // do nothing
        })
        
        if collectionView.numberOfItems(inSection: 0) == 0 {
            self.contactViewBottomConstraizt.constant = -self.contactViewHeightConstraint.constant
            UIView.animate(withDuration: 0.2, animations: {
                self.selectedContactsView.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
    }
}

