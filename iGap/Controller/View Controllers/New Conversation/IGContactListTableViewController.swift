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

class IGContactListTableViewController: UITableViewController, UISearchResultsUpdating, UIGestureRecognizerDelegate, IGCallFromContactListObserver {
    
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1").sorted(byKeyPath: "displayName", ascending: true)
    var contactSections: [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var resultSearchController = UISearchController()
    var sections : [Section]!
    var forceCall: Bool = false
    var pageName : String! = "NEW_CALL"
    private var lastContentOffset: CGFloat = 0
    var navigationControll : IGNavigationController!
    
    //header
    var headerView = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 150.0))
    var btnHolderView : UIView!
    
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
    
    class Section {
        var users = [User]()
        func addUser(_ user:User){
            self.users.append(user)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IGContactListTableViewController.callDelegate = self
        self.tableView.sectionIndexBackgroundColor = UIColor(named: themeColor.tableViewCell.rawValue)
//        self.tableView.contentInset.top = 15.0
        self.tableView.sectionIndexBackgroundColor = .clear
        
        initNavigationBar()
        sections = fillContacts()
    }
    
    private func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        var title = "NEW_CONVERSATION".localized
        if forceCall {
            title = "NEW_CALL".localized
        }

        navigationItem.addNavigationViewItems(rightItemText: nil, title: title)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }

    
    func fillContacts(filterContact: Bool = false , searchText : String = "") -> [IGContactListTableViewController.Section] {
        if self.contactSections != nil && !filterContact {
            return self.contactSections!
        }
        
        if !searchText.isEmpty {
            let predicate = NSPredicate(format: "((displayName BEGINSWITH[c] %@) OR (displayName CONTAINS[c] %@)) AND (isInContacts = 1)", searchText , searchText)
            contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        } else if filterContact {
            let predicate = NSPredicate(format: "isInContacts = 1")
            contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate).sorted(byKeyPath: "displayName", ascending: true)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.resultSearchController.isActive) {
            return 1
        } else {
            return self.sections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.isActive {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)-> String {
        if !self.sections[section].users.isEmpty {
            return self.collation.sectionTitles[section]
        }
        return ""
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.collation.section(forSectionIndexTitle: index)
    }
    
    func call(user: IGRegisteredUser,mode: String) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false , mode:mode)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            
            if forceCall {
                //                let user = self.sections[indexPath.section].users[indexPath.row]
                //                DispatchQueue.main.async {
                //                    (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.registredUser.id, isIncommmingCall: false)
                //                }
                //                return
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
                    let alertC = UIAlertController(title: "GLOBAL_WARNING".localized, message: "ERROR_RETRY".localized, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil)
                    alertC.addAction(cancel)
                    self.present(alertC, animated: true, completion: nil)
                }
            }).send()
        }
    }
}

extension IGContactListTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
//        if (self.lastContentOffset > scrollView.contentOffset.y) {
//            // move up
//            DispatchQueue.main.async() {
//                self.tableView.contentInset.top = 0.0
//            }
//        }
//        else if (self.lastContentOffset < scrollView.contentOffset.y) && scrollView.contentOffset.y >= 0 && self.lastContentOffset >= 0  {
//            // move down
//            DispatchQueue.main.async() {
//            }
//        }
//        else if self.lastContentOffset == 0 {
//            DispatchQueue.main.async() {
//                self.tableView.contentInset.top = 15.0
//            }
//        }
        self.lastContentOffset = scrollView.contentOffset.y
        
    }
}



