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
import SnapKit

class IGAdminRightsTableViewController: BaseTableViewController {

    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var txtContactName: UILabel!
    @IBOutlet weak var txtContactStatus: UILabel!
    
    @IBOutlet weak var txtDismissAdmin: UILabel!
    
    var userInfo: IGRegisteredUser!
    var room: IGRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        avatarView.setUser(userInfo)
        txtContactName.text = userInfo.displayName
        txtContactStatus.text = IGRegisteredUser.IGLastSeenStatus.fromIGP(status: userInfo?.lastSeenStatus, lastSeen: userInfo?.lastSeen)
        
        self.tableView.tableFooterView?.alpha = 0.0
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 25, title: "Admin Rights", iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            
        }
    }
    
    func openChat(room : IGRoom){
        let roomVC = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        roomVC.room = room
        roomVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(roomVC, animated: true)
    }
    
    func kickAdminChannel(userId: Int64) {
        if let channelRoom = room {
            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: IGStringsManager.RemoveAdmin.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: IGStringsManager.SureToRemoveAdminRoleFrom.rawValue.localized, doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, done: {
                IGGlobal.prgShow(self.view)
                IGChannelKickAdminRequest.Generator.generate(roomId: channelRoom.id , memberId: userId).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelKickAdminResponse as IGPChannelKickAdminResponse:
                            let _ = IGChannelKickAdminRequest.Handler.interpret(response: channelKickAdminResponse)
                            self.navigationController?.popViewController(animated: true)
                        default:
                            break
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                    switch errorCode {
                    case .timeout:
                        break
                    default:
                        break
                    }
                    
                }).send()
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 7
        } else if section == 2 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let headerTitle = UILabel()
        headerView.addSubview(headerTitle)
        headerTitle.font = UIFont.igFont(ofSize: 17, weight: .bold)
        headerTitle.textColor = UIColor.iGapBlue()
        headerTitle.text = "What can this admin do?"
        headerTitle.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.left).offset(20)
            make.height.equalTo(25)
            make.centerY.equalTo(headerView.snp.centerY)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 {
            return 0
        }
        return 35
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let room = IGRoom.existRoomInLocal(userId: userInfo.id) {
                openChat(room: room)
            }
        } else if indexPath.section == 1 {
            //
        } else if indexPath.section == 2 {
            self.navigationController?.popViewController(animated: true)
            //kickAdminChannel(userId: userInfo.id)
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
