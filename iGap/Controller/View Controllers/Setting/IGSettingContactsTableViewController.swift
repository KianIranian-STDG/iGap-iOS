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
import MBProgressHUD
import IGProtoBuff
import MGSwipeTableCell
import SwiftEventBus

class IGSettingContactsTableViewController: BaseTableViewController, UISearchResultsUpdating, IGCallFromContactListObserver {
    
    class User:NSObject {
        let registredUser: IGRegisteredUser
        @objc let name:String!
        var section :Int?
        init(registredUser: IGRegisteredUser){
            self.registredUser = registredUser
            self.name = registredUser.displayName
        }
    }
    class Section  {
        var users:[User] = []
        func addUser(_ user:User){
            self.users.append(user)
        }
    }
    @IBOutlet weak var AddContactButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    var blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter("isBlocked == 1" )
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1" )
    var notificationToken: NotificationToken?
    var contactSections : [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var filteredTableData = [CNContact]()
    var resultSearchController = UISearchController()
    var hud = MBProgressHUD()
    
    internal static var callDelegate: IGCallFromContactListObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IGSettingContactsTableViewController.callDelegate = self
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        resultSearchController.searchBar.delegate = self
        searchBar.delegate = self
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.Add.rawValue.localized, title: IGStringsManager.Contacts.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.rightViewContainer?.addAction {
            self.performSegue(withIdentifier: "GoToAddNewContactPage", sender: self)
        }
        
        self.notificationToken = blockedUsers.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_,_,_,_):
                self.tableView.reloadData()
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        
        
        self.notificationToken = contacts.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_,_,_,_):
                self.tableView.reloadData()
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        
        sections = fillContacts()
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchBlockedContactsFromServer()
    }
    
    func fetchBlockedContactsFromServer() {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserContactsGetBlockedListRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getBlockedListProtoResponse as IGPUserContactsGetBlockedListResponse:
                    IGUserContactsGetBlockedListRequest.Handler.interpret(response: getBlockedListProtoResponse)
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                    self.hud.hide(animated: true)
                break

            default:
                break
            }
            
        }).send()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if IGSettingAddContactViewController.reloadAfterAddContact && tableView != nil {
            IGGlobal.prgShow(self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                IGGlobal.prgHide()
                self.sections = self.fillContacts(filterContact: true)
                self.tableView.reloadData()
            }
        }
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IGSettingAddContactViewController.reloadAfterAddContact = false
    }
    
    @IBAction func addBarButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoToAddNewContactPage", sender: self)
    }
    
    var sections : [Section]!
    
    func fillContacts(filterContact: Bool = false , searchText : String = "") -> [IGSettingContactsTableViewController.Section] {
        if self.contactSections != nil && !filterContact {
            return self.contactSections!
        }
        
        if !searchText.isEmpty {
            let predicate = NSPredicate(format: "((displayName BEGINSWITH[c] %@) OR (displayName CONTAINS[c] %@)) AND (isInContacts = 1)", searchText , searchText)
            contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        } else if filterContact {
            let predicate = NSPredicate(format: "isInContacts = 1")
            contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        }
        
        let users :[User] = contacts.map{ (registeredUser) -> User in
            let user = User(registredUser: registeredUser )
            
            user.section = self.collation.section(for: user, collationStringSelector: #selector(getter: User.name))
            return user
        }
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count{
            sections.append(Section())
        }
        for user in users {
            sections[user.section!].addUser(user)
        }
        for section in sections {
            section.users = self.collation.sortedArray(from: section.users, collationStringSelector: #selector(getter: User.name)) as! [User]
        }
        self.contactSections = sections
        return self.contactSections!
    }
    
    func call(user: IGRegisteredUser,mode:String) {
        self.dismiss(animated: false, completion: {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false)
            }
        })
    }
    

    
    private func deleteContactAlert(phone: Int64){
        let alert = UIAlertController(title: IGStringsManager.Delete.rawValue.localized, message: IGStringsManager.SureToDeleteContact.rawValue.localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .destructive, handler: { action in
            self.deleteContact(phone: phone)
        })
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func deleteContact(phone: Int64){
        IGGlobal.prgShow(self.view)
        IGUserContactsDeleteRequest.Generator.generate(phone: phone).success({ (protoResponse) in
            if let deleteContactResponse = protoResponse as? IGPUserContactsDeleteResponse {
                IGUserContactsDeleteRequest.Handler.interpret(response: deleteContactResponse)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                IGGlobal.prgHide()
                self.sections = self.fillContacts(filterContact: true)
                self.tableView.reloadData()
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
    
    private func contactEditAlert(phone: Int64, firstname: String, lastname: String?){
        let alert = UIAlertController(title: IGStringsManager.dialogEdit.rawValue.localized, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = IGStringsManager.FirstName.rawValue.localized
            textField.text = String(describing: firstname)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = IGStringsManager.LastName.rawValue.localized
            if lastname != nil && !(lastname?.isEmpty)! {
                textField.text = String(describing: lastname!)
            }
        }
        
        alert.addAction(UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { [weak alert] (_) in
            let firstname = alert?.textFields![0]
            let lastname = alert?.textFields![1]
            
            if firstname?.text != nil && !(firstname?.text?.isEmpty)! {
                self.contactEdit(phone: phone, firstname: (firstname?.text)!, lastname: lastname?.text)
            } else {
                
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AddFirstName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            }
        }))
        
        alert.addAction(UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func contactEdit(phone: Int64, firstname: String, lastname: String?){
        IGGlobal.prgShow(self.view)
        IGUserContactsEditRequest.Generator.generate(phone: phone, firstname: firstname, lastname: lastname).success({ (protoResponse) in
            
            if let contactEditResponse = protoResponse as? IGPUserContactsEditResponse {
                IGUserContactsEditRequest.Handler.interpret(response: contactEditResponse)
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
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
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.resultSearchController.isActive) {
            return 1
        } else {
            return self.sections.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.filteredTableData.count
        } else if section == 0 {
            return 1
        } else {
            return self.sections[ section - 1 ].users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if !(self.resultSearchController.isActive) && indexPath.section == 0 {
            let blockListCell  = tableView.dequeueReusableCell(withIdentifier: "BlockListCell", for: indexPath) as! IGSettingContactsBlockListTableViewCell
            if SMLangUtil.loadLanguage() == "fa" {

                blockListCell.numberOfBlockedContacts.text = "\(blockedUsers.count)".inPersianNumbersNew()+" " + IGStringsManager.Contacts.rawValue.localized
                cell = blockListCell
            }
            else if SMLangUtil.loadLanguage() == "en" {

                blockListCell.numberOfBlockedContacts.text = "\(blockedUsers.count)".inEnglishNumbersNew()+" " + IGStringsManager.Contacts.rawValue.localized
                cell = blockListCell
            }
            else {

                blockListCell.numberOfBlockedContacts.text = "\(blockedUsers.count)".inPersianNumbersNew()+" " + IGStringsManager.Contacts.rawValue.localized
                cell = blockListCell
            }

        } else {
            
            let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGSettingContactTableViewCell
            //            if (self.resultSearchController.isActive) {
            //                contactsCell.contactNameLable?.text = filteredTableData[indexPath.row].givenName + filteredTableData[indexPath.row].familyName
            //            } else {
            let user = self.sections[indexPath.section - 1 ].users[indexPath.row]
            contactsCell.setUser(user.registredUser)
            //            }
            
            let delete = MGSwipeButton(title: IGStringsManager.Delete.rawValue.localized, backgroundColor: UIColor.swipeRed(), callback: { (sender: MGSwipeTableCell!) -> Bool in
                self.deleteContactAlert(phone: user.registredUser.phone)
                return true
            })
            
            let edit = MGSwipeButton(title: IGStringsManager.dialogEdit.rawValue.localized, backgroundColor: UIColor.swipeBlueGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
                self.contactEditAlert(phone: user.registredUser.phone, firstname: user.registredUser.firstName, lastname: user.registredUser.lastName)
                return true
            })
            
            contactsCell.rightButtons = [delete, edit]
            removeButtonsUnderline(buttons: [delete, edit])
            contactsCell.rightSwipeSettings.transition = MGSwipeTransition.border
            contactsCell.rightExpansion.buttonIndex = 0
            contactsCell.rightExpansion.fillOnTrigger = true
            contactsCell.rightExpansion.threshold = 1.5
            
            contactsCell.clipsToBounds = true
            contactsCell.swipeBackgroundColor = UIColor.clear
            
            cell = contactsCell
        }
        
        return cell
    }
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        if section == 0 {
            return "  "
        }
        tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
        if !self.sections[section - 1].users.isEmpty {
            return self.collation.sectionTitles[section - 1]
        }else{
            return ""
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int{
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            if indexPath.section == 0 && indexPath.row == 0 {
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToBlockListPage", sender: self)
            } else {
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                let user = self.sections[indexPath.section - 1 ].users[indexPath.row]
                IGChatGetRoomRequest.Generator.generate(peerId: user.registredUser.id).success({ (protoResponse) in
                    switch protoResponse {
                    case let chatGetRoomResponse as IGPChatGetRoomResponse:
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        self.dismiss(animated: true, completion: {
                            SwiftEventBus.postToMainThread(EventBusManager.openRoom, sender: roomId)
                        })
                        break
                    default:
                        break
                    }
                    
                }).error({ (errorCode, waitTime) in
                    DispatchQueue.main.async {
                        self.hud.hide(animated: true)
                        switch errorCode {
                        case .timeout:
                            break
                        default:
                            break
                        }
                    }
                    
                }).send()
            }
        }
    }
}

extension IGSettingContactsTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sections = fillContacts(filterContact: true, searchText: searchText)
        self.tableView.reloadData()
    }
}
