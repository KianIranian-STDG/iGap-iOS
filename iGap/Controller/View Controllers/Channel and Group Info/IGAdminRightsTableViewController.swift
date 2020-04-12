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
    
    @IBOutlet weak var switchModifyRoom: UISwitch!
    @IBOutlet weak var switchPostMessage: UISwitch!
    @IBOutlet weak var switchEditMessage: UISwitch!
    @IBOutlet weak var switchDeleteMessage: UISwitch!
    @IBOutlet weak var switchPinMessage: UISwitch!
    @IBOutlet weak var switchAddMember: UISwitch!
    @IBOutlet weak var switchBanMember: UISwitch!
    @IBOutlet weak var switchGetMember: UISwitch!
    @IBOutlet weak var switchAddAdmin: UISwitch!
    
    @IBOutlet weak var modifyRoomView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var addMemberView: UIView!
    @IBOutlet weak var banMemberView: UIView!
    @IBOutlet weak var addAdminView: UIView!
    
    @IBOutlet weak var txtModifyRoom: UILabel!
    @IBOutlet weak var txtPostMessage: UILabel!
    @IBOutlet weak var txtEditMessage: UILabel!
    @IBOutlet weak var txtDeleteMessage: UILabel!
    @IBOutlet weak var txtPinMessage: UILabel!
    @IBOutlet weak var txtGetMember: UILabel!
    @IBOutlet weak var txtAddMember: UILabel!
    @IBOutlet weak var txtBanMember: UILabel!
    @IBOutlet weak var txtAddAdmin: UILabel!
    @IBOutlet weak var txtDismissAdmin: UILabel!
    
    var userInfo: IGRegisteredUser!
    var room: IGRoom!
    var isAdmin: Bool!
    private var roomAccessDefault: IGPRoomAccess!
    
    @IBAction func OnPostMessageChange(_ sender: UISwitch) {
        self.managePostAndEdit(state: sender.isOn)
    }
    
    @IBAction func onGetMemberChange(_ sender: UISwitch) {
        self.manageGetMemberAndOtherOptions(state: sender.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        avatarView.setUser(userInfo)
        txtContactName.text = userInfo.displayName
        txtContactStatus.text = IGRegisteredUser.IGLastSeenStatus.fromIGP(status: userInfo?.lastSeenStatus, lastSeen: userInfo?.lastSeen)
        fillRoomAccess()
        
        txtModifyRoom.text = IGStringsManager.ModifyRoom.rawValue.localized
        txtPostMessage.text = IGStringsManager.PostMessage.rawValue.localized
        txtEditMessage.text = IGStringsManager.EditMessage.rawValue.localized
        txtDeleteMessage.text = IGStringsManager.DeleteMessage.rawValue.localized
        txtPinMessage.text = IGStringsManager.PinMessage.rawValue.localized
        txtGetMember.text = IGStringsManager.ShowMember.rawValue.localized
        txtAddMember.text = IGStringsManager.AddMember.rawValue.localized
        txtBanMember.text = IGStringsManager.RemoveUser.rawValue.localized
        txtAddAdmin.text = IGStringsManager.AddAdmin.rawValue.localized
        txtDismissAdmin.text = IGStringsManager.RemoveAdmin.rawValue.localized
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: IGStringsManager.AdminRights.rawValue.localized, iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction { [weak self] in
            self?.requestToAddAdminInChannel()
        }
    }
    
    private func managePostAndEdit(state: Bool){
        if state {
            editView.backgroundColor = modifyRoomView.backgroundColor
            txtEditMessage.textColor = txtModifyRoom.textColor
        } else {
            txtEditMessage.textColor = UIColor.gray
            editView.backgroundColor = UIColor.lightGray.lighter(by: 20)
            switchEditMessage.setOn(false, animated: true)
        }
        switchEditMessage.isUserInteractionEnabled = state
    }
    
    private func manageGetMemberAndOtherOptions(state: Bool){
        if state {
            addMemberView.backgroundColor = modifyRoomView.backgroundColor
            banMemberView.backgroundColor = modifyRoomView.backgroundColor
            addAdminView.backgroundColor = modifyRoomView.backgroundColor
            txtAddMember.textColor = txtModifyRoom.textColor
            txtBanMember.textColor = txtModifyRoom.textColor
            txtAddAdmin.textColor = txtModifyRoom.textColor
        } else {
            addMemberView.backgroundColor = UIColor.lightGray.lighter(by: 20)
            banMemberView.backgroundColor = UIColor.lightGray.lighter(by: 20)
            addAdminView.backgroundColor = UIColor.lightGray.lighter(by: 20)
            txtAddMember.textColor = UIColor.gray
            txtBanMember.textColor = UIColor.gray
            txtAddAdmin.textColor = UIColor.gray
            switchAddMember.setOn(false, animated: true)
            switchBanMember.setOn(false, animated: true)
            switchAddAdmin.setOn(false, animated: true)
        }
        switchAddMember.isUserInteractionEnabled = state
        switchBanMember.isUserInteractionEnabled = state
        switchAddAdmin.isUserInteractionEnabled = state
    }
    
    private func fillRoomAccess(){
        if let roomAccess = IGRealmRoomAccess.getRoomAccess(roomId: room.id, userId: userInfo.id) {
            switchModifyRoom.isOn = roomAccess.modifyRoom
            switchPostMessage.isOn = roomAccess.postMessage
            switchEditMessage.isOn = roomAccess.editMessage
            switchDeleteMessage.isOn = roomAccess.deleteMessage
            switchPinMessage.isOn = roomAccess.pinMessage
            switchAddMember.isOn = roomAccess.addMember
            switchBanMember.isOn = roomAccess.banMember
            switchGetMember.isOn = roomAccess.getMember
            switchAddAdmin.isOn = roomAccess.addAdmin
            
            managePostAndEdit(state: roomAccess.postMessage)
            manageGetMemberAndOtherOptions(state: roomAccess.getMember)
        }
    }
    
    private func makeRoomAccess() -> IGPRoomAccess {
        var roomAccess = IGPRoomAccess()
        roomAccess.igpModifyRoom = switchModifyRoom.isOn
        roomAccess.igpPostMessage = switchPostMessage.isOn
        roomAccess.igpEditMessage = switchEditMessage.isOn
        roomAccess.igpDeleteMessage = switchDeleteMessage.isOn
        roomAccess.igpPinMessage = switchPinMessage.isOn
        roomAccess.igpAddMember = switchAddMember.isOn
        roomAccess.igpBanMember = switchBanMember.isOn
        roomAccess.igpGetMember = switchGetMember.isOn
        roomAccess.igpAddAdmin = switchAddAdmin.isOn
        return roomAccess
    }
    
    func requestToAddAdminInChannel() {
        
        // show kick admin view if all options was disabled
        if ((room.type == .channel && !switchPostMessage.isOn && !switchEditMessage.isOn) || (room.type == .group)) &&
            !switchModifyRoom.isOn &&
            !switchDeleteMessage.isOn &&
            !switchPinMessage.isOn &&
            !switchAddMember.isOn &&
            !switchBanMember.isOn &&
            !switchGetMember.isOn &&
            !switchAddAdmin.isOn {
            
            if isAdmin {
                kickAdmin()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            
            return
        }
        
        if room.type == .group {
            IGGlobal.prgShow(self.view)
            IGGroupAddAdminRequest.Generator.generate(roomID: room.id, memberID: userInfo.id, roomAccess: makeRoomAccess()).success({ [weak self] (protoResponse) in
                IGGlobal.prgHide()
                if let grouplAddAdminResponse = protoResponse as? IGPGroupAddAdminResponse {
                    IGGroupAddAdminRequest.Handler.interpret(response: grouplAddAdminResponse)
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    }
                case .canNotAddThisUserAsAdminToGroup:
                    DispatchQueue.main.async {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    }
                default:
                    break
                }
                
            }).send()

        } else if room.type == .channel {
            IGGlobal.prgShow(self.view)
            IGChannelAddAdminRequest.Generator.generate(roomID: room.id, memberID: userInfo.id, roomAccess: makeRoomAccess()).success({ [weak self] (protoResponse) in
                IGGlobal.prgHide()
                if let channelAddAdminResponse = protoResponse as? IGPChannelAddAdminResponse {
                    IGChannelAddAdminRequest.Handler.interpret(response: channelAddAdminResponse)
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }).error ({ (errorCode, waitTime) in
                IGGlobal.prgHide()
                switch errorCode {
                case .timeout:
                    break
                case .canNotAddThisUserAsAdminToGroup:
                    DispatchQueue.main.async {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    }
                default:
                    break
                }
                
            }).send()
        }
        
    }
    
    func kickAdmin() {
        if room.type == .group {
            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: IGStringsManager.RemoveAdmin.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: IGStringsManager.SureToRemoveAdminRoleFrom.rawValue.localized, doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, done: { [weak self] in
                if self == nil {
                    return
                }
                IGGlobal.prgShow(self!.view)
                IGGroupKickAdminRequest.Generator.generate(roomID: self!.room.id, memberID: self!.userInfo.id).success({ (protoResponse) in
                    IGGlobal.prgHide()
                    if let groupKickAdminResponse = protoResponse as? IGPGroupKickAdminResponse {
                        IGGroupKickAdminRequest.Handler.interpret( response : groupKickAdminResponse)
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
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
            
        } else if room.type == .channel {
            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: IGStringsManager.RemoveAdmin.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: IGStringsManager.SureToRemoveAdminRoleFrom.rawValue.localized, doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, done: { [weak self] in
                if self == nil {
                    return
                }
                IGGlobal.prgShow(self!.view)
                IGChannelKickAdminRequest.Generator.generate(roomId: self!.room.id, memberId: self!.userInfo.id).success({ [weak self] (protoResponse) in
                    IGGlobal.prgHide()
                    if let channelKickAdminResponse = protoResponse as? IGPChannelKickAdminResponse {
                        let _ = IGChannelKickAdminRequest.Handler.interpret(response: channelKickAdminResponse)
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if room.type == .group && indexPath.section == 1 {
            if indexPath.row >= 1 {
                return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 2, section: 1))
            }
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if room.type == .channel {
                return 9
            } else if room.type == .group {
                return 7
            }
        } else if section == 2 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            headerView.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
            let headerTitle = UILabel()
            if self.isRTL {
                headerTitle.textAlignment = .right
            } else {
                headerTitle.textAlignment = .left
            }
            headerView.addSubview(headerTitle)
            headerTitle.font = UIFont.igFont(ofSize: 17, weight: .bold)
            headerTitle.textColor = UIColor.iGapBlue()
            headerTitle.text = IGStringsManager.WhatCanThisAdminDo.rawValue.localized
            headerTitle.adjustsFontSizeToFitWidth = true
            headerTitle.minimumScaleFactor = 0.5
            
            headerTitle.snp.makeConstraints { (make) in
                make.leading.equalTo(headerView.snp.leading).offset(20)
                make.trailing.equalTo(headerView.snp.trailing).offset(-20)
                make.height.equalTo(25)
                make.centerY.equalTo(headerView.snp.centerY)
            }
            return headerView
        }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else if section == 1 {
            return 35
        } else if section == 2 {
            return 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            IGHelperChatOpener.openUserProfile(user: userInfo)
        } else if indexPath.section == 2 {
            kickAdmin()
        }
    }
}
