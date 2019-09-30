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

class IGChooseMemberFromContactToCreateChannelViewController: BaseViewController , UISearchResultsUpdating {

    @IBOutlet weak var selectedContactsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var contactViewBottomConstraizt: NSLayoutConstraint!
    @IBOutlet weak var contactViewHeightConstraint: NSLayoutConstraint!
    fileprivate let searchController = UISearchController(searchResultsController: nil)

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
    var selectUser: User?
    var collectionIndexPath:IndexPath?
    var selectedIndexPath: IndexPath?
    var selectedUsers: [User] = []
    var channelName: String?
    var channelDescription: String?
    let borderName = CALayer()
    let width = CGFloat(0.5)
    var contactTableSelectedIndexPath : IndexPath?
    var igpRoom : IGPRoom!
    var mode: String?
    var room: IGRoom?
    var hud = MBProgressHUD()
    var addAdminOrModeratorCount: Int = 0
    
    var contacts = try! Realm().objects(IGRegisteredUser.self).filter("isInContacts == 1")
    var contactSections: [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var resultSearchController = UISearchController()
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
            sections[user.section!].addUser(user)
        }
        
        for section in sections {
            section.users = self.collation.sortedArray(from: section.users, collationStringSelector: #selector(getter: User.name)) as! [User]
        }
        
        self.contactSections = sections
        return self.contactSections!
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        
        navigationControllerr.navigationBar.isHidden = false
//        let navigationItem = self.navigationItem as! IGNavigationItem
//        navigationItem.searchController = nil
        
//        if navigationItem.searchController == nil {
//            let gradient = CAGradientLayer()
//            let sizeLength = UIScreen.main.bounds.size.height * 2
//            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: 64)
//            
//            gradient.frame = defaultNavigationBarFrame
//            gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
//            gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
//            gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
//            gradient.locations = orangeGradientLocation as [NSNumber]
//            
//            
//            
//            if #available(iOS 11.0, *) {
//                
//                if let navigationBar = self.navigationController?.navigationBar {
//                    navigationBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
////                    navigationBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
//                }
//                
//                
//                //                IGGlobal.setLanguage()
//                self.searchController.searchBar.searchBarStyle = UISearchBar.Style.default
//                
//                
//                if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//                    //                    IGGlobal.setLanguage()
//                    
//                    if textField.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
//                        let centeredParagraphStyle = NSMutableParagraphStyle()
//                        centeredParagraphStyle.alignment = .center
//                        
//                        let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.paragraphStyle: centeredParagraphStyle]
//                        textField.attributedPlaceholder = NSAttributedString(string: "SEARCH_PLACEHOLDER".localizedNew, attributes: attributeDict)
//                        textField.textAlignment = .center
//                    }
//                    
//                    let imageV = textField.leftView as! UIImageView
//                    imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//                    imageV.tintColor = UIColor.white
//                    
//                    if let backgroundview = textField.subviews.first {
//                        backgroundview.backgroundColor = UIColor.white.withAlphaComponent(0.75)
//                        backgroundview.layer.cornerRadius = 10;
//                        backgroundview.clipsToBounds = true;
//                        
//                    }
//                }
//                if navigationItem.searchController == nil {
////                    navigationItem.searchController = searchController
////                    navigationItem.hidesSearchBarWhenScrolling = true
//                }
//            } else {
//            }
//            
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        collectionView.dataSource = self
        self.contactsTableView.allowsMultipleSelection = true
        self.contactsTableView.allowsMultipleSelectionDuringEditing = true
        self.contactsTableView.setEditing(true, animated: true)
        self.contactsTableView.sectionIndexBackgroundColor = UIColor.clear
        self.selectedContactsView.addSubview(collectionView)
        self.contactViewBottomConstraizt.constant = -self.contactViewHeightConstraint.constant
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
           
        
        if mode == "Admin" {
            navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: "ADD_ADMIN".localizedNew)
        }
        if mode == "Moderator" {
            navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: "ADD_MODERATOR".localizedNew)

        }
        if mode == "CreateChannel" {
            navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: "NEW_CHANNEL".localizedNew)

        }
        if mode == "Members" {
            navigationItem.addNavigationViewItems(rightItemText: "ADD_BTN".localizedNew, title: "ADD_MEMBER".localizedNew)

        }

        navigationItem.rightViewContainer?.addAction {
           
            if self.mode == "CreateChannel" {
                self.requestToCreateChannel()
            } else if self.mode == "Admin" {
                self.requestToAddAdminInChannel()
            } else if self.mode == "Moderator" {
                self.requestToAddModeratorInChannel()
            } else if self.mode == "Members" {
                self.requestToAddmember()
            }

            
        }
        
    }
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     /*   if segue.identifier == "CreateGroupPage" {
            let selectedUsersToCreateGroup = selectedUsers.map({ (user) -> IGRegisteredUser in
                return user.registredUser
            })
            let destinationVC = segue.destination as! IGCreateNewGroupTableViewController
            destinationVC.selectedUsersToCreateGroup = selectedUsersToCreateGroup
        }*/
    }
    
    func requestToAddmember() {
        
        if selectedUsers.count == 0 {
            self.showAlert(title: "BTN_HINT".localizedNew, message: "MSG_PLEASE_CHOOSE_MEMBER".localizedNew)
            return
        }
        
        for member in selectedUsers {
            IGChannelAddMemberRequest.Generator.generate(userID: member.registredUser.id, channel: room!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelAddMemberResponse as IGPChannelAddMemberResponse:
                        let _ = IGChannelAddMemberRequest.Handler.interpret(response: channelAddMemberResponse)
                        self.navigationController?.popViewController(animated: true)
                    default:
                        break
                    }
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        }
        
    }
    
    
    func requestToCreateChannel(){
        if self.selectedUsers.count > 0 {
            for member in self.selectedUsers {
                let room = IGRoom(igpRoom: igpRoom)
                IGChannelAddMemberRequest.Generator.generate(userID: member.registredUser.id , channel: room).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelAddMemberResponse as IGPChannelAddMemberResponse :
                            let _ = IGChannelAddMemberRequest.Handler.interpret(response: channelAddMemberResponse)
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
        } else {
        }
        self.openChannel()

    }
    
    private func openChannel() {
        if self.navigationController is IGNavigationController {
            self.navigationController?.popToRootViewController(animated: true)
//            self.navigationController?.navigationBar.isHidden = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoomAtProfile),object: nil,userInfo: ["room": self.igpRoom.igpID])
    }
    
    func requestToAddAdminInChannel() {
        if selectedUsers.count == 0 {
            self.showAlert(title: "BTN_HINT".localizedNew, message: "MSG_PLEASE_CHOOSE_MEMBER".localizedNew)
            return
        }
        
        for member in selectedUsers {
            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGChannelAddAdminRequest.Generator.generate(roomID: channelRoom.id, memberID: member.registredUser.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelAddAdminResponse as IGPChannelAddAdminResponse :
                            self.manageClosePage()
                            let _ = IGChannelAddAdminRequest.Handler.interpret(response: channelAddAdminResponse, memberRole: .admin)
                        default:
                            break
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
                    case .canNotAddThisUserAsAdminToChannel:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
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
    
    func requestToAddModeratorInChannel() {
        if selectedUsers.count == 0 {
            self.showAlert(title: "BTN_HINT".localizedNew, message: "MSG_PLEASE_CHOOSE_MEMBER".localizedNew)
            return
        }
        
        for member in selectedUsers {
            if let channelRoom = room {
                IGGlobal.prgShow(self.view)
                IGChannelAddModeratorRequest.Generator.generate(roomID: channelRoom.id, memberID: member.registredUser.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelAddModeratorResponse as IGPChannelAddModeratorResponse:
                            self.manageClosePage()
                            let _ = IGChannelAddModeratorRequest.Handler.interpret(response: channelAddModeratorResponse, memberRole: .moderator)
                        default:
                            break
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
                    case .canNotAddThisUserAsModeratorToChannel:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "UNSSUCCESS_OTP".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
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
    
    private func manageClosePage(){
        addAdminOrModeratorCount += 1
        if selectedUsers.count == addAdminOrModeratorCount {
            if self.navigationController is IGNavigationController {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: Search
    func setupSearchBar(){
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.contactsTableView.tableHeaderView = controller.searchBar
            return controller
        })()
        self.contactsTableView.reloadData()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //        filteredTableData.removeAll(keepingCapacity: false)
        //        let predicate = CNContact.predicateForContacts(matchingName: searchController.searchBar.text!)
        //        let keyToFetch = [CNContactFamilyNameKey,CNContactGivenNameKey]
        //        do {
        //            let resualtContacts =  try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keyToFetch as [CNKeyDescriptor])
        //
        //            filteredTableData = resualtContacts
        //        } catch {
        //            print("Handle error")
        //        }
        //        self.contactsTableView.reloadData()
    }
    
}

//MARK:- UITableViewDataSource
extension IGChooseMemberFromContactToCreateChannelViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.resultSearchController.isActive) {
            return 1
        }else{
            return self.sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.contacts.count
        }else{
            return self.sections[section].users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! IGChooseMemberToCreateChannelTableViewCell
        if (self.resultSearchController.isActive) {
            //            contactsCell.contactNameLabel?.text = filteredTableData[indexPath.row].givenName + filteredTableData[indexPath.row].familyName
        }else{
            let user = self.sections[indexPath.section].users[indexPath.row]
            contactsCell.user = user
        }
        cell = contactsCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 94.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
}

//MARK:- UITableViewDelegate
extension IGChooseMemberFromContactToCreateChannelViewController : UITableViewDelegate {

    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            if tableView.isEditing == true{
                let currentCell = tableView.cellForRow(at: indexPath) as! IGChooseMemberToCreateChannelTableViewCell?
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
                if self.mode == "CreateChannel" {
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
                        //
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if resultSearchController.isActive == false {
            if tableView.isEditing == true{
                if selectedUsers.count > 0 {
                    let tableviewcell = tableView.cellForRow(at: indexPath) as! IGChooseMemberToCreateChannelTableViewCell
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
    
}
//MARK: - SCrollView Delegates

//MARK: - UICollectionViewDataSource
extension IGChooseMemberFromContactToCreateChannelViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! IGNewChannelBottomViewCollectionCell
        cell.selectedRowIndexPathForTableView = contactTableSelectedIndexPath
        cell.user = selectedUsers[indexPath.row]
        cell.cellDelegate = self
        collectionIndexPath = indexPath
        return cell
    }
}

//MARK: - IGDeleteSelectedCellDelegate
extension IGChooseMemberFromContactToCreateChannelViewController: IGDeleteSelectedChannelMemberCellDelegate {
    func contactViewWasSelected(cell: IGNewChannelBottomViewCollectionCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let tableIndexPath = cell.selectedRowIndexPathForTableView
        contactsTableView.deselectRow(at: tableIndexPath!, animated: true)
        collectionView.performBatchUpdates({
            self.selectedUsers.remove(at: (indexPath?.row)!)
            self.collectionView.deleteItems(at: [indexPath!])
        }, completion: { (completed) in
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
