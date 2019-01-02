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


class IGCreateNewChatTableViewController: UITableViewController, UISearchResultsUpdating , UIGestureRecognizerDelegate, IGCallFromContactListObserver {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1")
    var contactSections: [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var resultSearchController = UISearchController()
    var sections : [Section]!
    var forceCall: Bool = false
    
    internal static var callDelegate: IGCallFromContactListObserver!
    
    class User: NSObject {
        let registredUser: IGRegisteredUser
        @objc let name: String
        var section :Int?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        IGCreateNewChatTableViewController.callDelegate = self
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        setNavigationItem()
        sections = fillContacts()
    }

    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        var title = "New Conversation"
        if forceCall {
            title = "New Call"
        }
        navigationItem.addModalViewItems(leftItemText: "Close", rightItemText: nil, title: title)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.leftViewContainer?.addAction {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func fillContacts(filterContact: Bool = false , searchText : String = "") -> [IGCreateNewChatTableViewController.Section] {
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
        for i in 0..<self.collation.sectionIndexTitles.count{
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
        if (self.resultSearchController.isActive) {
            return 1
        } else {
            return self.sections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.contacts.count
        } else {
            return self.sections[section].users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
        if (self.resultSearchController.isActive) {
            contactsCell.setUser(contacts[indexPath.row])
        }else{
            let user = self.sections[indexPath.section].users[indexPath.row]
            contactsCell.setUser(user.registredUser)
        }
        return contactsCell
    }
    
    override func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int)-> String {
        if !self.sections[section].users.isEmpty {
            return self.collation.sectionTitles[section]
        }
        return ""
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    func call(user: IGRegisteredUser) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false)
        }
    }
    
    func predicateForContacts(matchingName name: String) -> NSPredicate{
        return predicateForContacts(matchingName: self.resultSearchController.searchBar.text!)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            
            if forceCall {
                let user = self.sections[indexPath.section].users[indexPath.row]
                DispatchQueue.main.async {
                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.registredUser.id, isIncommmingCall: false)
                }
                return
            }
            
            IGGlobal.prgShow(self.view)
            let user = self.sections[indexPath.section].users[indexPath.row]
            IGChatGetRoomRequest.Generator.generate(peerId: user.registredUser.id).success({ (protoResponse) in
                if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse{
                    DispatchQueue.main.async {
                        IGGlobal.prgHide()
                        let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                        self.navigationController?.popToRootViewController(animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),object: nil,userInfo: ["room": roomId])
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
}

extension IGCreateNewChatTableViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sections = fillContacts(filterContact: true, searchText: searchText)
        self.tableView.reloadData()
    }
}

