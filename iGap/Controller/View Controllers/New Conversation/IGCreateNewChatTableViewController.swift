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
import SnapKit


class IGCreateNewChatTableViewController: BaseTableViewController, UISearchResultsUpdating, IGCallFromContactListObserver {
    @IBOutlet weak var viewHeader: UIView!
    fileprivate let searchController = UISearchController(searchResultsController: nil)

//    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
//        searchBar.delegate = self
        IGCreateNewChatTableViewController.callDelegate = self
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
        setNavigationItem()
        sections = fillContacts()
        creatHeader()
        
    }

    func creatHeader() {
        let viewChannel = UIView()
        let viewGroup = UIView()
        viewChannel.backgroundColor = .clear
        viewGroup.backgroundColor = .clear
        viewHeader.addSubview(viewChannel)
        viewHeader.addSubview(viewGroup)
        viewChannel.snp.makeConstraints { (make) in
            make.top.equalTo(viewHeader.snp.top).offset(20)
            make.leading.equalTo(viewHeader.snp.leading).offset(20)
            make.trailing.equalTo(viewHeader.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        viewGroup.snp.makeConstraints { (make) in
            make.top.equalTo(viewChannel.snp.bottom)
            make.leading.equalTo(viewHeader.snp.leading).offset(20)
            make.trailing.equalTo(viewHeader.snp.trailing).offset(-20)
            make.height.equalTo(30)
        }
        let lblChannel = UILabel()
        let lblGroup = UILabel()
        let btnChannel = UIButton()
        let btnGroup = UIButton()
        viewChannel.addSubview(lblChannel)
        viewGroup.addSubview(lblGroup)
        viewChannel.addSubview(btnChannel)
        viewGroup.addSubview(btnGroup)
        btnChannel.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        btnGroup.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        btnChannel.setTitleColor(.black, for: .normal)
        btnGroup.setTitleColor(.black, for: .normal)
        btnChannel.setTitle("", for: .normal)
        btnGroup.setTitle("", for: .normal)
        
        lblChannel.font = UIFont.igFont(ofSize: 15)
        lblGroup.font = UIFont.igFont(ofSize: 15)

        lblChannel.textColor = .black
        lblGroup.textColor = .black
        
        lblChannel.text = "NEW_CHANNEL".localizedNew
        lblGroup.text = "NEW_GROUP".localizedNew
        lblChannel.textAlignment = lblChannel.localizedNewDirection
        lblGroup.textAlignment = lblGroup.localizedNewDirection
        //MARK:- add buttons and labels
        btnChannel.snp.makeConstraints { (make) in
            make.trailing.equalTo(viewChannel.snp.trailing)
            make.leading.equalTo(btnChannel.snp.leading).offset(15)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        btnGroup.snp.makeConstraints { (make) in
            make.trailing.equalTo(viewGroup.snp.trailing)
            make.leading.equalTo(btnGroup.snp.leading).offset(15)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        lblChannel.snp.makeConstraints { (make) in
            make.trailing.equalTo(btnChannel.snp.leading).offset(-15)
            make.leading.equalTo(viewChannel.snp.leading).offset(15)
            make.height.equalTo(30)
        }
        lblGroup.snp.makeConstraints { (make) in
            make.trailing.equalTo(btnGroup.snp.leading).offset(-15)
            make.leading.equalTo(viewGroup.snp.leading).offset(15)
            make.height.equalTo(30)
        }
        //MARK:- tap initilizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnNewGroup))
        viewGroup.addGestureRecognizer(tap)
        viewGroup.isUserInteractionEnabled = true
        
        let tapII = UITapGestureRecognizer(target: self, action: #selector(didTapOnNewChannel))
        viewChannel.addGestureRecognizer(tapII)
        viewChannel.isUserInteractionEnabled = true




    }
    @objc func didTapOnNewGroup() {
        let createGroup = IGChooseMemberFromContactsToCreateGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
        createGroup.mode = "CreateGroup"
        self.navigationController!.pushViewController(createGroup, animated: true)

    }
    @objc func didTapOnNewChannel() {
        let createChannel = IGCreateNewChannelTableViewController.instantiateFromAppStroryboard(appStoryboard: .CreateRoom)
        self.navigationController!.pushViewController(createChannel, animated: true)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController

        if DeepLinkManager.shared.hasDeepLink() {
            navigationControllerr.navigationBar.isHidden = false
        } else {
            navigationControllerr.navigationBar.isHidden = true
        }
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.searchController = nil

    }
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        
        if navigationItem.searchController == nil {
            let gradient = CAGradientLayer()
            let sizeLength = UIScreen.main.bounds.size.height * 2
            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: 64)
            
            gradient.frame = defaultNavigationBarFrame
            gradient.colors = [UIColor(rgb: 0xB9E244).cgColor, UIColor(rgb: 0x41B120).cgColor]
            gradient.startPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).0
            gradient.endPoint = (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5)).1
            gradient.locations = orangeGradientLocation as [NSNumber]
            
            
            
            if #available(iOS 11.0, *) {
                
                if let navigationBar = self.navigationController?.navigationBar {
                    navigationBar.barTintColor = UIColor(patternImage: self.image(fromLayer: gradient))
                }
                
                
                //                IGGlobal.setLanguage()
                self.searchController.searchBar.searchBarStyle = UISearchBar.Style.default
                
                
                if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    //                    IGGlobal.setLanguage()
                    
                    if textField.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                        let centeredParagraphStyle = NSMutableParagraphStyle()
                        centeredParagraphStyle.alignment = .center
                        
                        let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.paragraphStyle: centeredParagraphStyle]
                        textField.attributedPlaceholder = NSAttributedString(string: "SEARCH_PLACEHOLDER".localizedNew, attributes: attributeDict)
                        textField.textAlignment = .center
                    }
                    
                    let imageV = textField.leftView as! UIImageView
                    imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                    imageV.tintColor = UIColor.white
                    
                    if let backgroundview = textField.subviews.first {
                        backgroundview.backgroundColor = UIColor.white.withAlphaComponent(0.75)
                        backgroundview.layer.cornerRadius = 10;
                        backgroundview.clipsToBounds = true;
                        
                    }
                }
                if navigationItem.searchController == nil {
                    navigationItem.searchController = searchController
                    navigationItem.hidesSearchBarWhenScrolling = true
                }
            } else {
                tableView.tableHeaderView = searchController.searchBar
            }
            
        }
        
        
        
        
        
        
        
        
        var title = "NEW_CONVERSATION".localizedNew
        if forceCall {
            title = "NEW_CALL".localizedNew
        }
        navigationItem.addNavigationBackItem()
//        navigationItem.addModalViewItems(leftItemText: nil, rightItemText: "GLOBAL_CLOSE".localizedNew, title: title)
//
//        // navigationItem.setChatListsNavigationItems()
//        navigationItem.rightViewContainer?.addAction {
//            let navigationItem = self.navigationItem as! IGNavigationItem
//            navigationItem.searchController = nil
//
//            self.navigationController?.popToRootViewController(animated: true)
//        }
//
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
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
        if (self.resultSearchController.isActive) {
            return self.contacts.count
        } else {
            return self.sections[section].users.count
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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

    func call(user: IGRegisteredUser,mode:String) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false)
        }
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
                    let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alertC.addAction(cancel)
                    self.present(alertC, animated: true, completion: nil)
                }
            }).send()
        }
    }

}
