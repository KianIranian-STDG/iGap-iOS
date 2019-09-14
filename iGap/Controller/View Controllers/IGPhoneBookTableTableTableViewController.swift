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

    var contacts : Results<IGRegisteredUser>!

    var contactSections: [Section]?
    let collation = UILocalizedIndexedCollation.current()
    var resultSearchController = UISearchController()
    var sections : [Section]!
    var forceCall: Bool = false
    var pageName : String! = "NEW_CALL"
    private var lastContentOffset: CGFloat = 0
    var navigationControll : IGNavigationController!
    
    //header
    var headerView = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 80.0))

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
        self.tableView.tableHeaderView?.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)

        
        IGPhoneBookTableViewController.callDelegate = self
        let predicate = NSPredicate(format: "isInContacts = 1")
        contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicate).sorted(byKeyPath: "displayName", ascending: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationItem = self.tabBarController?.navigationItem as! IGNavigationItem
        navigationItem.setPhoneBookNavigationItems()
        navigationItem.rightViewContainer?.addAction
            {

                self.goToAddContactsPage()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            navigationItem.leftViewContainer?.addAction {

            }
        }


    }
    private func goToAddContactsPage() {
        
        let vc = IGSettingAddContactViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        self.navigationController!.pushViewController(vc, animated:true)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let bottomBorder = UIView()
        let lblIcon = UILabel()
        let lblText = UILabel()
        let btn = UIButton()
        lblIcon.text = ""
        lblText.text = "SETTING_PAGE_INVITE_FRIENDS".localizedNew
        lblIcon.font = UIFont.iGapFonticon(ofSize: 20)
        lblText.font = UIFont.igFont(ofSize: 15)
        lblText.textAlignment = lblText.localizedNewDirection
        bottomBorder.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        self.headerView.addSubview(bottomBorder)
        self.headerView.addSubview(lblIcon)
        self.headerView.addSubview(lblText)
        self.headerView.addSubview(btn)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnBtn))
        btn.isUserInteractionEnabled = true
        btn.addGestureRecognizer(tap)

        bottomBorder.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.headerView.snp.bottom)
            make.height.equalTo(1)
            make.leading.equalTo(self.headerView.snp.leading).offset(10)
            make.trailing.equalTo(self.headerView.snp.trailing).offset(-10)
        }
        lblIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.headerView.snp.centerY)
            make.height.equalTo(45)
            make.width.equalTo(45)
            make.leading.equalTo(self.headerView.snp.leading).offset(10)
        }
        lblText.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.headerView.snp.centerY)
            make.height.equalTo(45)
            make.right.equalTo(self.headerView.snp.right).offset(-55)
            make.left.equalTo(self.headerView.snp.left).offset(55)
        }
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerView.snp.top)
            make.bottom.equalTo(self.headerView.snp.bottom)
            make.left.equalTo(self.headerView.snp.left)
            make.right.equalTo(self.headerView.snp.right)
        }


    }

    @objc
    func didTapOnBtn(sender:UITapGestureRecognizer) {
        inviteAContact()
    }
    private func inviteAContact() {
        let vc = testVCViewController.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
        self.navigationController!.pushViewController(vc, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }


    
    //Mark:- TableView Delagates

    override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
      
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactsCell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath) as! IGContactTableViewCell
            contactsCell.setUser(contacts[indexPath.row])
        
        return contactsCell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
        
    }

    
    func call(user: IGRegisteredUser,mode: String) {
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).showCallPage(userId: user.id, isIncommmingCall: false , mode:mode)
        }
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
                    let alertC = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_RETRY".localizedNew, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alertC.addAction(cancel)
                    self.present(alertC, animated: true, completion: nil)
                }
            }).send()
        }
    }

}




