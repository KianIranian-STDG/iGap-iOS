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

class IGPhoneBookTableViewController: BaseTableViewController, IGCallFromContactListObserver {

    class User: NSObject {
        let registredUser: IGRegisteredUser
        @objc let name: String
        var section :Int?
        init(registredUser: IGRegisteredUser){
            self.registredUser = registredUser
            self.name = registredUser.displayName
        }
    }
    
    var searchController : UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = ""
        searchController.searchBar.setValue("CANCEL_BTN".RecentTableViewlocalizedNew, forKey: "cancelButtonText")
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
//        gradient.locations = orangeGradientLocation as [NSNumber]
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        
        return searchController

    }()
    
    class Section  {
        var users = [User]()
        func addUser(_ user:User){
            self.users.append(user)
        }
    }
    
    private var contacts: Results<IGRegisteredUser>!
    private var filteredContacts: Results<IGRegisteredUser>!
    private var shouldShowSearchResults = false
    
//    private var resultSearchController = UISearchController()
    private var forceCall: Bool = false
    private var pageName : String! = "NEW_CALL"
    private var lastContentOffset: CGFloat = 0
    private var navigationControll : IGNavigationController!
    private let collation = UILocalizedIndexedCollation.current()
    internal static var callDelegate: IGCallFromContactListObserver!
    private var footerLabel: UILabel!
    var connectionStatus: IGAppManager.ConnectionStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.bounces = false
        self.tableView.contentOffset = CGPoint(x: 0, y: 55)
        IGPhoneBookTableViewController.callDelegate = self
        let predicate = NSPredicate(format: "isInContacts = 1")
        contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate).sorted(byKeyPath: "displayName", ascending: true)
        self.filteredContacts = self.contacts
        
        self.tableView.tableHeaderView?.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
        self.tableView.tableFooterView = makeFooterView()
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if navigationItem.searchController == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
//        if currentTabIndex == TabBarTab.Profile.rawValue {
            self.searchController.hidesNavigationBarDuringPresentation = false
//        } else {
//            self.searchController.hidesNavigationBarDuringPresentation = true
//        }
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateNavigationBarBasedOnNetworkStatus(connectionStatus)
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                // appearance has changed
                // Update your user interface based on the appearance
                self.setSearchBarGradient()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func setSearchBarGradient() {
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
//        gradient.locations = orangeGradientLocation as [NSNumber]
        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
    }
    
    private func initialiseSearchBar() {
            
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

//            let imageV = textField.leftView as! UIImageView
//            imageV.image = nil
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    view.backgroundColor = .clear
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".RecentTableViewlocalizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14, weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
                searchBarCancelButton.setTitleColor(UIColor.white, for: .normal)
            }

            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeHolderInsideSearchField.textColor = UIColor.white
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialiseSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationItems()
    }
    
    private func setNavigationItems() {
        if currentTabIndex == TabBarTab.Profile.rawValue {
            self.initNavigationBar(title: "NEW".localizedNew) { }
        } else {
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.setPhoneBookNavigationItems()
            navigationItem.rightViewContainer?.addAction {
                self.goToAddContactsPage()
            }
        }
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
                switch  currentTabIndex {
                case TabBarTab.Recent.rawValue:
                    let navItem = self.navigationItem as! IGNavigationItem
                    navItem.addModalViewItems(leftItemText: nil, rightItemText: nil, title: "SETTING_PAGE_ACCOUNT_PHONENUMBER".localizedNew)
                default:
                    self.setNavigationItems()
                }
                break
            }
        }
    }

    private func goToAddContactsPage() {
        let vc = IGSettingAddContactViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated:true)
    }
    
    private func makeHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70.0))
        let bottomBorder = UIView()
        let lblIcon = UILabel()
        let lblText = UILabel()
        let btn = UIButton()
        lblIcon.text = ""
        lblText.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
        lblIcon.font = UIFont.iGapFonticon(ofSize: 24)
        lblIcon.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblText.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblText.font = UIFont.igFont(ofSize: 18)
        lblText.textAlignment = lblText.localizedNewDirection
        lblIcon.textAlignment = .center
        bottomBorder.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        headerView.addSubview(bottomBorder)
        headerView.addSubview(lblIcon)
        headerView.addSubview(lblText)
        headerView.addSubview(btn)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnBtn))
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(tap)
        
        headerView.semanticContentAttribute = self.semantic
        
        bottomBorder.snp.makeConstraints { (make) in
            make.bottom.equalTo(headerView.snp.bottom)
            make.height.equalTo(1)
            make.leading.equalTo(headerView.snp.leading).offset(0)
            make.trailing.equalTo(headerView.snp.trailing).offset(0)
        }
        lblIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerView.snp.centerY)
            make.height.equalTo(45)
            make.width.equalTo(45)
            make.leading.equalTo(headerView.snp.leading).offset(12)
        }
        lblText.snp.makeConstraints { (make) in
            make.centerY.equalTo(headerView.snp.centerY)
            make.height.equalTo(45)
            make.leading.equalTo(lblIcon.snp.trailing).offset(12)
            make.trailing.equalTo(headerView.snp.trailing)
        }
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.top)
            make.bottom.equalTo(headerView.snp.bottom)
            make.left.equalTo(headerView.snp.left)
            make.right.equalTo(headerView.snp.right)
        }
        headerView.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
        
        return headerView
    }
    
    private func makeFooterView() -> UIView {
        footerLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70.0))
        
        setFooterLabelText()
        
        footerLabel.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
        footerLabel.font = UIFont.igFont(ofSize: 16)
        footerLabel.textAlignment = .center
        footerLabel.backgroundColor = .clear
        return footerLabel
    }
    
    private func setFooterLabelText() {
        guard footerLabel != nil else { return }
        if shouldShowSearchResults {
            footerLabel.text = "\(self.filteredContacts.count)".inLocalizedLanguage() + "CONTACTS".localizedNew
        } else {
            footerLabel.text = "\(self.contacts.count)".inLocalizedLanguage() + "CONTACTS".localizedNew
        }
    }

    @objc
    func didTapOnBtn(sender:UITapGestureRecognizer) {
        inviteAContact()
    }
    
    private func inviteAContact() {
        let vc = testVCViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(vc, animated: true)
    }

    //Mark:- TableView Delagates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //if is from profile page
        if currentTabIndex == TabBarTab.Profile.rawValue {
            if shouldShowSearchResults {
                if self.filteredContacts != nil {
                    return self.filteredContacts.count
                } else {
                    return 0
                }
                
            } else {
                return self.contacts.count + 2 // the number 2 is for two items in header bellow search bar
            }

        } else {// if is from contactpage
            if shouldShowSearchResults {
                if self.filteredContacts != nil {
                    return self.filteredContacts.count
                } else {
                    return 0
                }
            } else {
                return self.contacts.count + 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if is from profile page
        if currentTabIndex == TabBarTab.Profile.rawValue {
            
            if shouldShowSearchResults {
                let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
                contactsCell.setUser(self.filteredContacts[indexPath.row])
                
                return contactsCell
            } else {
                if indexPath.row == 0 {
                    let phoneBookCellTypeTwo = tableView.dequeueReusableCell(withIdentifier: "phoneBookCellTypeTwo", for: indexPath) as! phoneBookCellTypeTwo
                    phoneBookCellTypeTwo.lblIcon.text = ""
                    phoneBookCellTypeTwo.lblText.text = "CREAT_CHANNEL".localizedNew
                    phoneBookCellTypeTwo.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

                    return phoneBookCellTypeTwo

                } else if indexPath.row == 1 {
                    let phoneBookCellTypeTwo = tableView.dequeueReusableCell(withIdentifier: "phoneBookCellTypeTwo", for: indexPath) as! phoneBookCellTypeTwo
                    phoneBookCellTypeTwo.lblIcon.text = ""
                    phoneBookCellTypeTwo.lblText.text = "CREAT_GROUP".localizedNew
                    return phoneBookCellTypeTwo

                } else {
                    let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
                        contactsCell.setUser(contacts[indexPath.row-1])
                    
                    return contactsCell

                }
            }
            
        } else { // if is from contactpage
            if shouldShowSearchResults {
                let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
                contactsCell.setUser(self.filteredContacts[indexPath.row])
                return contactsCell
            } else {
                if indexPath.row == 0 {
                    let phoneBookCellTypeTwo = tableView.dequeueReusableCell(withIdentifier: "phoneBookCellTypeTwo", for: indexPath) as! phoneBookCellTypeTwo
                    phoneBookCellTypeTwo.lblIcon.text = ""

                    phoneBookCellTypeTwo.lblText.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
                    return phoneBookCellTypeTwo

                } else {
                    let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
                        contactsCell.setUser(contacts[indexPath.row-1])
                    return contactsCell
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowSearchResults {
            return 80
        } else {
            if currentTabIndex == TabBarTab.Profile.rawValue {
                if indexPath.row == 0 {
                    return 50

                } else if indexPath.row == 1 {
                    return 50

                } else {
                    return 80

                }
            } else {
                if indexPath.row == 0 {
                    return 50

                } else {
                    return 80
                }
            }
        }
    }
    
    func call(user: IGRegisteredUser,mode: String) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false , mode:mode)
        }
    }
    
    func didTapOnNewGroup() {
        let createGroup = IGChooseMemberFromContactsToCreateGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
        createGroup.mode = "CreateGroup"
        createGroup.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(createGroup, animated: true)

    }
    
    func didTapOnNewChannel() {
        let createChannel = IGCreateNewChannelTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
        createChannel.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(createChannel, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shouldShowSearchResults {
            if currentTabIndex == TabBarTab.Profile.rawValue {

                self.searchController.isActive = false
                IGGlobal.prgShow(self.view)
                let user = self.filteredContacts[indexPath.row]
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
                        let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alertC.addAction(cancel)
                        self.present(alertC, animated: true, completion: nil)
                    }
                }).send()
            } else {

                self.searchController.isActive = false
                IGGlobal.prgShow(self.view)
                let user = self.filteredContacts[indexPath.row]
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
                        let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alertC.addAction(cancel)
                        self.present(alertC, animated: true, completion: nil)
                    }
                }).send()
            }
        } else {
            if currentTabIndex == TabBarTab.Profile.rawValue {

                if indexPath.row  == 0 {
                    self.didTapOnNewChannel()

                } else if indexPath.row  == 1 {
                    self.didTapOnNewGroup()

                } else {

                    self.searchController.isActive = false
                    IGGlobal.prgShow(self.view)
                    let user = self.contacts[indexPath.row-2]
                    IGChatGetRoomRequest.Generator.generate(peerId: user.id).success({ (protoResponse) in
                        if let chatGetRoomResponse = protoResponse as? IGPChatGetRoomResponse{
                            DispatchQueue.main.async {
                                IGGlobal.prgHide()
                                let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                                self.navigationController?.popToRootViewController(animated: true)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom), object: nil, userInfo: ["room": roomId])
                            }
                        }
                    }).error({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            IGGlobal.prgHide()
                            let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            } else {

                if indexPath.row  == 0 {
                    self.inviteAContact()

                } else {

                    self.searchController.isActive = false
                    IGGlobal.prgShow(self.view)
                    let user = self.contacts[indexPath.row-1]
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
                            let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                            let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alertC.addAction(cancel)
                            self.present(alertC, animated: true, completion: nil)
                        }
                    }).send()
                }
            }
        }
        
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
}

// MARK: search controller extension
extension IGPhoneBookTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        
        let predicate: NSPredicate!
//        let searchNumber = searchString.onlyDigitChars().inEnglishNumbersNew()
//        if searchNumber != "" {
//            predicate = NSPredicate(format: "(displayName CONTAINS[c] %@) OR (phone CONTAINS %d)", searchString, searchNumber)
//        } else {
            predicate = NSPredicate(format: "displayName CONTAINS[c] %@", searchString)
//        }
        
        // Filter the data array and get only those users that match the search text.
        if !searchString.isEmpty {
            filteredContacts = contacts.filter(predicate)
        }
        
//        if searchString.isEmpty {
//            filteredContacts = contacts
//        } else {
//            filteredContacts = contacts.filter(predicate)
//        }
        
        setFooterLabelText()
     
        // Reload the tableview.
        self.tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!, UIColor(named: themeColor.navigationSecondColor.rawValue)!]
//        if let view = self.searchController.view.subviews.first {
//            view.layer.insertSublayer(gradientLayer, at: 0)
//        }
        self.tableView.reloadData()
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
           shouldShowSearchResults = true
           self.tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
}




