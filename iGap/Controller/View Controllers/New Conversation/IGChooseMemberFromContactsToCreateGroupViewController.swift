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

class IGChooseMemberFromContactsToCreateGroupViewController: BaseViewController , UIGestureRecognizerDelegate {
    
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
        func addUser(_ user:User){
            
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
    var addAdminOrModeratorCount: Int = 0
    
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
        let tmp = baseUser
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
        let current : String = SMLangUtil.loadLanguage()

    }
    
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        let current : String = SMLangUtil.loadLanguage()
        switch current {
        case "fa" :
            if mode == "Admin" {
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText: "ADD_BTN".localizedNew , title: "ADD_ADMIN".localizedNew)
            }
            if mode == "Moderator" {
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText: "ADD_BTN".localizedNew , title: "ADD_MODERATOR".localizedNew)
            }
            if mode == "CreateGroup" {
                
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText: "ADD_BTN".localizedNew, title: "NEW_GROUP".localizedNew)
            }
            if mode == "Members" {
                navigationItem.addModalViewItems(leftItemText:  "GLOBAL_CLOSE".localizedNew, rightItemText: "ADD_BTN".localizedNew, title: "ADD_MEMBER".localizedNew)
            }
            if mode == "ConvertChatToGroup" {
                navigationItem.addModalViewItems(leftItemText:  "GLOBAL_CLOSE".localizedNew, rightItemText: "ADD_BTN".localizedNew, title: "ADD_MEMBER_TO".localizedNew)
            }

        case "en" :
            if mode == "Admin" {
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText:  "ADD_BTN".localizedNew , title: "ADD_ADMIN".localizedNew)
            }
            if mode == "Moderator" {
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText:  "ADD_BTN".localizedNew , title: "ADD_MODERATOR".localizedNew)
            }
            if mode == "CreateGroup" {
                
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText: "GLOBAL_CREAT".localizedNew, title: "NEW_GROUP".localizedNew)
            }
            if mode == "Members" {
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText: "ADD_BTN".localizedNew , title: "Add Member")
            }
            if mode == "ConvertChatToGroup" {
                navigationItem.addModalViewItems(leftItemText: "GLOBAL_CLOSE".localizedNew, rightItemText: "GLOBAL_CREAT".localizedNew , title: "ADD_MEMBER_TO".localizedNew)
            }

        case "ar" :
            break
        default :
            break
        }

        
        navigationItem.leftViewContainer?.addAction {
            let current : String = SMLangUtil.loadLanguage()
            switch current {
            case "fa" :
                if self.mode == "Admin"  || self.mode == "Moderator" || self.mode == "Members" {
                    if self.navigationController is IGNavigationController {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }else{
                    if self.navigationController is IGNavigationController {
                        self.navigationController?.popViewController(animated: true)
                    }
                }

            case "en" :
                if self.mode == "Admin"  || self.mode == "Moderator" || self.mode == "Members" {
                    if self.navigationController is IGNavigationController {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }else{
                    if self.navigationController is IGNavigationController {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            case "ar" :
                break
            default :
                break
            }


        }
        
        navigationItem.rightViewContainer?.addAction {
            let current : String = SMLangUtil.loadLanguage()
            switch current {
            case "fa" :
                if self.mode == "Members" {
                    self.requestToAddmember()
                } else if self.mode == "Moderator" {
                    self.requestToAddModeratorInGroup()
                } else if self.mode == "Admin"{
                    self.requestToAddAdminInGroup()
                } else {
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
                    self.navigationController!.pushViewController(createGroup, animated: true)
                }
                
            case "en" :
                if self.mode == "Members" {
                    self.requestToAddmember()
                } else if self.mode == "Moderator" {
                    self.requestToAddModeratorInGroup()
                } else if self.mode == "Admin"{
                    self.requestToAddAdminInGroup()
                } else {
                    let createGroup = IGCreateNewGroupTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
                    let selectedUsersToCreateGroup = self.selectedUsers.map({ (user) -> IGRegisteredUser in
                        return user.registredUser
                    })
                    var tmp = selectedUsersToCreateGroup
                    tmp.append(self.baseUser!)
                    createGroup.selectedUsersToCreateGroup = tmp

                    createGroup.mode = self.mode
                    createGroup.roomId = self.roomID
                    self.navigationController!.pushViewController(createGroup, animated: true)
                }
                
                
            case "ar" :
                break
            default :
                break
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    func requestToAddmember() {
        if selectedUsers.count == 0 {
            self.showAlert(title: "SETTING_PS_TV_HINT".localizedNew, message: "Please choose member")
            return
        }
        
        for member in selectedUsers {
            IGGroupAddMemberRequest.Generator.generate(userID:member.registredUser.id, group: room!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupAddMemberResponse as IGPGroupAddMemberResponse:
                        let _ = IGGroupAddMemberRequest.Handler.interpret(response: groupAddMemberResponse)
                        if self.navigationController is IGNavigationController {
                            self.navigationController?.popViewController(animated: true)
                        }
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        }
    }
    
    func requestToAddAdminInGroup() {
        if selectedUsers.count == 0 {
            self.showAlert(title: "SETTING_PS_TV_HINT".localizedNew, message: "Please choose member")
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
                            IGGroupAddAdminRequest.Handler.interpret(response: channelAddAdminResponse, memberRole: .admin)
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    self.manageClosePage()
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
    }
    
    func requestToAddModeratorInGroup() {
        if selectedUsers.count == 0 {
            self.showAlert(title: "SETTING_PS_TV_HINT".localizedNew, message: "Please choose member")
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
                            IGGroupAddModeratorRequest.Handler.interpret(response: groupAddModeratorResponse, memberRole: .moderator)
                        }
                    }
                    
                }).error ({ (errorCode, waitTime) in
                    self.manageClosePage()
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
    }
    
    private func manageClosePage(){
        addAdminOrModeratorCount += 1
        if selectedUsers.count == addAdminOrModeratorCount {
            if self.navigationController is IGNavigationController {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension IGChooseMemberFromContactsToCreateGroupViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int)-> String? {
        tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
        if !self.sections[section].users.isEmpty {
            return self.collation.sectionTitles[section]
        } else {
            return ""
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true{
            let currentCell = tableView.cellForRow(at: indexPath) as! IGChooseContactToAddNewGroupTableViewCell?
            contactTableSelectedIndexPath = indexPath
            selectUser = currentCell?.user
            if self.mode == "Admin" {
                selectedUsers.append((currentCell?.user)!)
            }
            if self.mode == "Moderator" {
                selectedUsers.append((currentCell?.user)!)
            }
            if self.mode == "Members" {
                selectedUsers.append((currentCell?.user)!)
            }
            if self.mode == "CreateGroup" {
                selectedUsers.append((currentCell?.user)!)
                selectedIndexPath = indexPath
                self.contactViewBottomConstraizt.constant = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.selectedContactsView.alpha = 1
                    self.view.layoutIfNeeded()
                })
                
            }
            if self.mode == "ConvertChatToGroup" {
                selectedUsers.append((currentCell?.user)!)
                selectedIndexPath = indexPath
                self.contactViewBottomConstraizt.constant = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.selectedContactsView.alpha = 1
                    self.view.layoutIfNeeded()
                })
                
            }
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
                let tableviewcell = tableView.cellForRow(at: indexPath) as! IGChooseContactToAddNewGroupTableViewCell
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
extension IGChooseMemberFromContactsToCreateGroupViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! IGChooseContactToAddNewGroupTableViewCell
        let user = self.sections[indexPath.section].users[indexPath.row]
        contactsCell.user = user
        cell = contactsCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 94.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}

//MARK: - UICollectionViewDataSource
extension IGChooseMemberFromContactsToCreateGroupViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! IGNewGroupBottomViewCollectionCell
        cell.selectedRowIndexPathForTableView = contactTableSelectedIndexPath
        cell.user = selectedUsers[indexPath.row]
        cell.cellDelegate = self
        collectionIndexPath = indexPath
        return cell
    }
}

//MARK: - IGDeleteSelectedCellDelegate
extension IGChooseMemberFromContactsToCreateGroupViewController: IGDeleteSelectedCellDelegate {
    func contactViewWasSelected(cell: IGNewGroupBottomViewCollectionCell) {
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

