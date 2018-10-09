/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import RealmSwift
import MBProgressHUD
import IGProtoBuff
import MGSwipeTableCell

class IGSettingContactBlockListTableViewController: UITableViewController , UIGestureRecognizerDelegate {
    
    var chooseBlockContactFromPrivacyandSecurityPage:Bool = false
    var blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter("isBlocked == 1")
    var notificationToken: NotificationToken?
    
    var hud = MBProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        
        setNavigationItem()
        fetchBlockedContactsFromServer()
        
        let predicate = NSPredicate(format: "isBlocked == 1")
        blockedUsers = try! Realm().objects(IGRegisteredUser.self).filter(predicate)
        self.notificationToken = blockedUsers.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query messages have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    private func setNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "BlockedList")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
        setNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedCell", for: indexPath) as! IGSettingContactBlockTableViewCell
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            cell.blockedContactName.text = "Block Contact..."
            cell.blockedContactName.textColor = UIColor.organizationalColor()
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.blockedContactName.text = blockedUsers[indexPath.row].displayName
        }
        
        let btnUnblock = MGSwipeButton(title: "Unblock", backgroundColor: UIColor.swipeGray(), callback: { (sender: MGSwipeTableCell!) -> Bool in
            self.unblockedUser(blockedUserId: self.blockedUsers[indexPath.row].id)
            return true
        })
        
        let buttons = [btnUnblock]
        cell.rightButtons = buttons
        removeButtonsUnderline(buttons: buttons)
        
        cell.rightSwipeSettings.transition = MGSwipeTransition.border
        cell.rightExpansion.buttonIndex = 0
        cell.rightExpansion.fillOnTrigger = true
        cell.rightExpansion.threshold = 1.5
        
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.swipeBackgroundColor = UIColor.clear
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex{
            self.tableView.isUserInteractionEnabled = true
            performSegue(withIdentifier: "GoToChooseContactAddToBlockListPage", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "You will not recieve messages from people on the block list."
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Blocked contacts"
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock"
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row ==  self.tableView.numberOfRows(inSection: 0) - 1 {
            return false
        }
        return true
    }
    
    func fetchBlockedContactsFromServer(){
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
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func unblockedUser(blockedUserId : Int64){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserContactsUnBlockRequest.Generator.generate(unBlockedUserId: blockedUserId).success({
            (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let unBlockedProtoResponse as IGPUserContactsUnblockResponse:
                    IGUserContactsUnBlockRequest.Handler.interpret(response: unBlockedProtoResponse)
                    self.hud.hide(animated: true)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
        }).send()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            switch identifier{
            case "goBackToPrivacyAndSecurityList" :
                if let destination = segue.destination as? IGSettingPrivacy_SecurityTableViewController {
                    destination.blockedUsers = blockedUsers
                }
            default:
                break
                
            }
        }
    }
}
