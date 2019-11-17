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

class IGSettingChooseContactToAddToBlockListTableViewController: UITableViewController , UISearchResultsUpdating ,UINavigationControllerDelegate , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var chooseBlockContactFromPrivacyandSecurityPage : Bool = true
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
    
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1")
    var contactSections : [Section]?
    var sections : [Section]!
    var notificationToken: NotificationToken?
    let collation = UILocalizedIndexedCollation.current()
    var filteredTableData = [CNContact]()
    var hud = MBProgressHUD()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItem()
        
        searchBar.delegate = self
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        
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
    
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_CONTACTS".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    func fillContacts(filterContact: Bool = false , searchText : String = "") -> [IGSettingChooseContactToAddToBlockListTableViewController.Section]{
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
        
        let users :[User] = contacts.map{ (registredUser) -> User in
            let user = User(registredUser: registredUser )
            
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ChooseContactToBlockedCell", for: indexPath) as! IGSettingChooseContactToAddToBlockListTableViewCell
        let user = self.sections[indexPath.section].users[indexPath.row]
        contactsCell.setUser(user.registredUser)
        cell = contactsCell
        return cell
    }
    
    override func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int) -> String {
        var titleOfHeader = ""
        tableView.headerView(forSection: section)?.backgroundColor = UIColor.red
        if !self.sections[section].users.isEmpty {
            titleOfHeader = self.collation.sectionTitles[section]
        } else {
            titleOfHeader = ""
        }
        return titleOfHeader
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.sections[indexPath.section].users[indexPath.row]
        blockContact(userID: user.registredUser.id)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func blockedSelectedContact(blockedUserId : Int64 ) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserContactsBlockRequest.Generator.generate(blockedUserId: blockedUserId).success({
            (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let blockedProtoResponse as IGPUserContactsBlockResponse:
                    let _ = IGUserContactsBlockRequest.Handler.interpret(response: blockedProtoResponse)
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.hud.hide(animated: true)
                break
            default:
                break
            }
        }).send()
    }
    
    func blockContact(userID: Int64){
        let blockConfirmAlertView = UIAlertController(title: "Are you sure you want to Block this contact?", message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let blockAction = UIAlertAction(title: "Block", style:.default , handler: {
            (alert: UIAlertAction) -> Void in
            self.blockedSelectedContact(blockedUserId : userID )
            if self.navigationController is IGNavigationController {
                self.navigationController?.popViewController(animated: true)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel , handler: {
            (alert: UIAlertAction) -> Void in
        })
        blockConfirmAlertView.addAction(blockAction)
        blockConfirmAlertView.addAction(cancelAction)
        let alertActions = blockConfirmAlertView.actions
        for action in alertActions {
            if action.title == "Block"{
                let blockColor = UIColor.red
                action.setValue(blockColor, forKey: "titleTextColor")
            }
        }
        blockConfirmAlertView.view.tintColor = UIColor.organizationalColor()
        if let popoverController = blockConfirmAlertView.popoverPresentationController {
            popoverController.sourceView = self.tableView
            popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
            popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(blockConfirmAlertView, animated: true, completion: nil)
    }
}

extension IGSettingChooseContactToAddToBlockListTableViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sections = fillContacts(filterContact: true, searchText: searchText)
        self.tableView.reloadData()
    }
}

