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
import IGProtoBuff
import SwiftProtobuf
import RealmSwift
import MBProgressHUD
import SnapKit
import RxSwift

class IGPhoneBookTableViewController: BaseTableViewController, IGCallFromContactListObserver {

    class User: NSObject {
        let registredUser: IGRegisteredUser
        @objc let name: String
        var section: Int?
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
    
    var customHeaderView: UIView!
    var isInSearchMode : Bool = false
    var searchController : UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = ""
        searchController.searchBar.setValue("CANCEL_BTN".RecentTableViewlocalized, forKey: "cancelButtonText")
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        return searchController
    }()

    private var contacts: Results<IGRegisteredUser>!
    private var searchedContacts: Results<IGRegisteredUser>!
    private var forceCall: Bool = false
    private var pageName : String! = "NEW_CALL"
    private var lastContentOffset: CGFloat = 0
    private var navigationControll : IGNavigationController!
    private let collation = UILocalizedIndexedCollation.current()
    private var realmNotificationToken: NotificationToken?
    private var footerLabel: UILabel!
    private var allowInitObserver = true
    private let contactDisposeBag = DisposeBag()
    private var txtContactStates: UILabel!
    var connectionStatus: IGAppManager.ConnectionStatus?
    internal static var callDelegate: IGCallFromContactListObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRxSwiftObservers()
        initObserver()
        
        self.tableView.bounces = false
        self.tableView.contentOffset = CGPoint(x: 0, y: 55)
        self.tableView.tableHeaderView?.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
        self.tableView.tableFooterView = makeFooterView()
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal
            if navigationItem.searchController == nil {
                tableView.tableHeaderView = makeHeaderView()
            }
        } else {
            tableView.tableHeaderView = makeHeaderView()
        }
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isInSearchMode = false

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavigationItems()
        initObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.allowInitObserver = true
        self.realmNotificationToken?.invalidate()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                self.setSearchBarGradient()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initialiseSearchBar()
    }
    
    private func setNavigationItems() {
        if currentTabIndex == TabBarTab.Profile.rawValue {
            self.initNavigationBar(title: "NEW".localized) { }
        } else {
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.setPhoneBookNavigationItems()
            navigationItem.rightViewContainer?.addAction {
                self.goToAddContactsPage()
            }
            navigationItem.leftViewContainer?.addAction {
                self.inviteContact()
            }
        }
    }
    
    private func initObserver(){
        if allowInitObserver {
            allowInitObserver = false
            IGPhoneBookTableViewController.callDelegate = self
            contacts = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(NSPredicate(format: "isInContacts = 1")).sorted(byKeyPath: "displayName", ascending: true)
            self.realmNotificationToken = self.contacts.observe { (changes: RealmCollectionChange) in
                switch changes {
                case .initial:
                    self.tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                    self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                    self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                    self.tableView.endUpdates()
                    break
                case .error(let err):
                    fatalError("\(err)")
                    break
                }
            }
        }
    }
    
    private func initRxSwiftObservers(){
        /** Connection Observer */
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
            }
        }).disposed(by: disposeBag)
        
        /** Contact Observer */
        IGContactManager.sharedManager.contactExchangeLevel.asObservable().subscribe(onNext: { (contactExchangeLevel) in
            DispatchQueue.main.async {
                switch contactExchangeLevel {
                case .importing(let percent):
                    if IGAppManager.sharedManager.isUserLoggiedIn() {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .percent
                        self.txtContactStates?.text = "\("contacts_sending".localized) %\(percent.fetchPercent())"
                    }
                    break
                    
                case .gettingList(let percent):
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .percent
                    self.txtContactStates?.text = "\("contacts_being_saved".localized) %\(percent.fetchPercent())"
                    break
                    
                case .completed:
                    self.txtContactStates?.text = "\(self.contacts?.count ?? 0)".inLocalizedLanguage() + "CONTACTS".localized
                    break
                }
            }
        }).disposed(by: contactDisposeBag)
    }
    
    
    private func updateNavigationBarBasedOnNetworkStatus(_ status: IGAppManager.ConnectionStatus) {
        if let navigationItem = self.navigationItem as? IGNavigationItem {
            switch status {
            case .waitingForNetwork:
                navigationItem.setNavigationItemForWaitingForNetwork()
                connectionStatus = .waitingForNetwork
                IGAppManager.connectionStatusStatic = .waitingForNetwork
                break
                
            case .connecting:
                navigationItem.setNavigationItemForConnecting()
                connectionStatus = .connecting
                IGAppManager.connectionStatusStatic = .connecting
                break
                
            case .connected:
                connectionStatus = .connected
                IGAppManager.connectionStatusStatic = .connected
                break
                
            case .iGap:
                connectionStatus = .iGap
                IGAppManager.connectionStatusStatic = .iGap
                self.setNavigationItems()
                break
            }
        }
    }

    private func goToAddContactsPage() {
        let vc = IGSettingAddContactViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated:true)
    }
    
    private func makeFooterView() -> UIView {
        footerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70.0))
        footerLabel.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
        footerLabel.font = UIFont.igFont(ofSize: 16)
        footerLabel.textAlignment = .center
        footerLabel.backgroundColor = .clear
        return footerLabel
    }
    
    private func makeHeaderView() -> UIView {
        var customHeaderView: UIView!
        if currentTabIndex == TabBarTab.Profile.rawValue {
            customHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: (Int(UIScreen.main.bounds.width)), height: 64))
        } else {
            customHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: (Int(UIScreen.main.bounds.width)), height: 100))
            txtContactStates = UILabel()
            txtContactStates.font = UIFont.igFont(ofSize: 20, weight: .regular)
            customHeaderView.addSubview(txtContactStates)
            txtContactStates.snp.makeConstraints { (make) in
                make.centerX.equalTo(customHeaderView.snp.centerX)
                make.bottom.equalTo(customHeaderView.snp.bottom).offset(-10)
                make.height.equalTo(20)
                make.width.greaterThanOrEqualTo(20)
            }
            
            txtContactStates.text = "\(contacts?.count ?? 0)"
        }
        
        let searchBarView = searchController
        customHeaderView.addSubview(searchBarView.searchBar)
        return customHeaderView
    }
    
    private func setFooterLabelText() {
        guard footerLabel != nil else { return }
        footerLabel?.text = "\(self.contacts?.count ?? 0)".inLocalizedLanguage() + "searched_contacts".localized
    }

    @objc
    func didTapOnBtn(sender:UITapGestureRecognizer) {
        inviteContact()
    }
    
    private func inviteContact() {
        let vc = testVCViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func call(user: IGRegisteredUser,mode: String) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false , mode:mode)
        }
    }
    
    func didTapOnNewGroup() {
        let createGroup = IGMemberAddOrUpdateState.instantiateFromAppStroryboard(appStoryboard: .Profile)
        createGroup.mode = "CreateGroup"
        createGroup.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(createGroup, animated: true)
        
    }
    
    func didTapOnNewChannel() {
        let createChannel = IGCreateNewChannelTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
        createChannel.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(createChannel, animated: true)
    }
    
    //Mark:- Contact Delete & Edit
    private func deleteContactAlert(phone: Int64){
        let alert = UIAlertController(title: "TTL_DELETE_CONTACT".localized, message: "MSG_ARE_U_SURE_TO_DELETE".localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .destructive, handler: { action in
            self.deleteContact(phone: phone)
        })
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localized, style: .default, handler: nil)
        
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
            IGGlobal.prgHide()
        }).error ({ (errorCode, waitTime) in
            IGGlobal.prgHide()
        }).send()
    }
    
    private func contactEditAlert(phone: Int64, firstname: String, lastname: String?){
        let alert = UIAlertController(title: "BTN_EDITE_CONTACT".localized, message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "PLACE_HOLDER_F_NAME".localized
            textField.text = String(describing: firstname)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "PLACE_HOLDER_L_NAME".localized
            if lastname != nil && !(lastname?.isEmpty)! {
                textField.text = String(describing: lastname!)
            }
        }
        
        alert.addAction(UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: { [weak alert] (_) in
            let firstname = alert?.textFields![0]
            let lastname = alert?.textFields![1]
            
            if firstname?.text != nil && !(firstname?.text?.isEmpty)! {
                self.contactEdit(phone: phone, firstname: (firstname?.text)!, lastname: lastname?.text)
            } else {
                let alert = UIAlertController(title: "BTN_HINT".localized, message: "MSG_PLEASE_ENTER_F_NAME".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "CANCEL_BTN".localized, style: .default, handler: nil))
        
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
                DispatchQueue.main.async {
                    IGGlobal.prgHide()
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
        }).send()
    }

    //Mark:- TableView Delagates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if is from profile page
        if currentTabIndex == TabBarTab.Profile.rawValue {
            return (self.contacts?.count ?? 0) + 2 // the number 2 is for two items in header bellow search bar
        } else {// if is from contactpage
            return self.contacts?.count ?? 0 //+ 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if is from profile page
        if currentTabIndex == TabBarTab.Profile.rawValue {
            
            if indexPath.row == 0 {
                let phoneBookCellTypeTwo = tableView.dequeueReusableCell(withIdentifier: "phoneBookCellTypeTwo", for: indexPath) as! phoneBookCellTypeTwo
                phoneBookCellTypeTwo.lblIcon.text = ""
                phoneBookCellTypeTwo.lblText.text = "CREAT_CHANNEL".localized
                phoneBookCellTypeTwo.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                
                return phoneBookCellTypeTwo
                
            } else if indexPath.row == 1 {
                let phoneBookCellTypeTwo = tableView.dequeueReusableCell(withIdentifier: "phoneBookCellTypeTwo", for: indexPath) as! phoneBookCellTypeTwo
                phoneBookCellTypeTwo.lblIcon.text = ""
                phoneBookCellTypeTwo.lblText.text = "CREAT_GROUP".localized
                return phoneBookCellTypeTwo
                
            } else {
                let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
                contactsCell.setUser(contacts[indexPath.row - 2])
                return contactsCell
            }
            
        } else { // if is from contactpage
            let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
            contactsCell.setUser(contacts[indexPath.row])
            return contactsCell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentTabIndex == TabBarTab.Profile.rawValue {
            if indexPath.row == 0 {
                return 50
            } else if indexPath.row == 1 {
                return 50
            } else {
                return 70
            }
        } else {
            return 70
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedIndexPath: Int = 0
        if currentTabIndex == TabBarTab.Profile.rawValue {
            if indexPath.row  == 0 {
                self.didTapOnNewChannel()
            } else if indexPath.row  == 1 {
                self.didTapOnNewGroup()
            }
            selectedIndexPath = indexPath.row - 2
        } else {
            selectedIndexPath = indexPath.row
        }
        
        self.searchController.isActive = false
        
        IGGlobal.prgShow(self.view)
        var user = self.contacts[selectedIndexPath]

        if isInSearchMode {
            user = self.searchedContacts[selectedIndexPath]
        } else {
            user = self.contacts[selectedIndexPath]
        }
        IGChatGetRoomRequest.Generator.generate(peerId: user.id).success({ (protoResponse) in
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
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "ERROR_RETRY".localized, cancelText: "GLOBAL_CLOSE".localized )
            }
        }).send()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let contactInfo = contacts[indexPath.row]
        let btnEditSwipeCell = UIContextualAction(style: .normal, title: "BTN_EDITE".localized) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action
            self.contactEditAlert(phone: contactInfo.phone, firstname: contactInfo.firstName, lastname: contactInfo.lastName)
        }
        
        let btnDeleteSwipeCell = UIContextualAction(style: .normal, title: "BTN_DELETE".localized) { (contextualAction, view, boolValue) in
            boolValue(true) // pass true if you want the handler to allow the action
            self.deleteContactAlert(phone: contactInfo.phone)
        }
        
        btnEditSwipeCell.backgroundColor = UIColor.swipeDarkBlue()
        btnDeleteSwipeCell.backgroundColor = UIColor.iGapRed()
        let config = UISwipeActionsConfiguration(actions: [btnEditSwipeCell, btnDeleteSwipeCell])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
}

// MARK:- search controller extension
extension IGPhoneBookTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    private func setSearchBarGradient() {
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    
    private func initialiseSearchBar() {
            
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    view.backgroundColor = .clear
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".RecentTableViewlocalized, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14, weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
                searchBarCancelButton.setTitleColor(UIColor.white, for: .normal)
            }

            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeHolderInsideSearchField.textColor = UIColor.white
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localized
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        
        // invalidate contacts change observer when user is searching for avoid from table view crash with incorrect index
        self.realmNotificationToken?.invalidate()
        
        let predicate: NSPredicate!
            predicate = NSPredicate(format: "displayName CONTAINS[c] %@", searchString)
        if !searchString.isEmpty {
            footerLabel?.isHidden = false
            let allContacts = IGDatabaseManager.shared.realm.objects(IGRegisteredUser.self).filter(NSPredicate(format: "isInContacts = 1")).sorted(byKeyPath: "displayName", ascending: true)
            contacts = allContacts.filter(predicate)
            searchedContacts = allContacts.filter(predicate)
            isInSearchMode = true
            self.tableView.reloadData()
        } else {
            footerLabel?.isHidden = true
            allowInitObserver = true
            self.initObserver()
        }
        
        setFooterLabelText()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        footerLabel?.isHidden = true
        isInSearchMode = false
        allowInitObserver = true
        self.initObserver()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        isInSearchMode = true

        searchController.searchBar.resignFirstResponder()
    }
}



