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
    
    @IBOutlet weak var txtDismissAdmin: UILabel!
    
    var userInfo: IGRegisteredUser!
    var room: IGRoom!
    private var roomAccessDefault: IGPRoomAccess!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        avatarView.setUser(userInfo)
        txtContactName.text = userInfo.displayName
        txtContactStatus.text = IGRegisteredUser.IGLastSeenStatus.fromIGP(status: userInfo?.lastSeenStatus, lastSeen: userInfo?.lastSeen)
        fillRoomAccess()
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "", rightItemFontSize: 30, title: "Admin Rights", iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction { [weak self] in
            self?.requestToAddAdminInChannel()
        }
    }
    
    private func fillRoomAccess(){
        if let roomAccess = IGRealmRoomAccess.getRoomAccess(userId: userInfo.id) {
            switchModifyRoom.isOn = roomAccess.modifyRoom
            switchPostMessage.isOn = roomAccess.postMessage
            switchEditMessage.isOn = roomAccess.editMessage
            switchDeleteMessage.isOn = roomAccess.deleteMessage
            switchPinMessage.isOn = roomAccess.pinMessage
            switchAddMember.isOn = roomAccess.addMember
            switchBanMember.isOn = roomAccess.banMember
            switchGetMember.isOn = roomAccess.getMember
            switchAddAdmin.isOn = roomAccess.addAdmin
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
            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: IGStringsManager.RemoveAdmin.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: IGStringsManager.SureToRemoveAdminRoleFrom.rawValue.localized, doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, done: { [weak self] in
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
            make.leading.equalTo(headerView.snp.leading).offset(20)
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
            IGHelperChatOpener.openUserProfile(user: userInfo)
        } else if indexPath.section == 2 {
            kickAdmin()
        }
    }
}
