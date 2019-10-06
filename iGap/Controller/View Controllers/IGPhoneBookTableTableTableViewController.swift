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
            searchController.searchBar.setValue("CANCEL_BTN".localizedNew, forKey: "cancelButtonText")
            
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
    
    private var contacts : Results<IGRegisteredUser>!
    private var resultSearchController = UISearchController()
    private var forceCall: Bool = false
    private var pageName : String! = "NEW_CALL"
    private var lastContentOffset: CGFloat = 0
    private var navigationControll : IGNavigationController!
    private let collation = UILocalizedIndexedCollation.current()
    internal static var callDelegate: IGCallFromContactListObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IGPhoneBookTableViewController.callDelegate = self
        let predicate = NSPredicate(format: "isInContacts = 1")
        contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate).sorted(byKeyPath: "displayName", ascending: true)
        
        self.tableView.tableHeaderView?.backgroundColor = UIColor(named: themeColor.recentTVCellColor.rawValue)
        self.tableView.tableHeaderView = makeHeaderView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initialiseSearchBar()

    }
    
    private func initialiseSearchBar() {
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

            let imageV = textField.leftView as! UIImageView
            imageV.image = nil
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    if view is UIView {
                        view.backgroundColor = .clear
                    }
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
                
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.scrollsToTop = false
        self.tableView.bounces = false
                
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if navigationItem.searchController == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }


        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setPhoneBookNavigationItems()
        navigationItem.rightViewContainer?.addAction {
            self.goToAddContactsPage()
        }
    }
    
    private func goToAddContactsPage() {
        let vc = IGSettingAddContactViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
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

    @objc
    func didTapOnBtn(sender:UITapGestureRecognizer) {
        inviteAContact()
    }
    
    private func inviteAContact() {
        let vc = testVCViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        self.navigationController!.pushViewController(vc, animated: true)
    }


    //Mark:- TableView Delagates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.contacts.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let phoneBookCellTypeTwo = tableView.dequeueReusableCell(withIdentifier: "phoneBookCellTypeTwo", for: indexPath) as! phoneBookCellTypeTwo
            phoneBookCellTypeTwo.lblText.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
            return phoneBookCellTypeTwo

        } else {
            let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
                contactsCell.setUser(contacts[indexPath.row])
            
            return contactsCell

        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func call(user: IGRegisteredUser,mode: String) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false , mode:mode)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row  == 0 {
            self.inviteAContact()

        } else {

            if resultSearchController.isActive == false {
                
                IGGlobal.prgShow(self.view)
                let user = self.contacts[indexPath.row]
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




