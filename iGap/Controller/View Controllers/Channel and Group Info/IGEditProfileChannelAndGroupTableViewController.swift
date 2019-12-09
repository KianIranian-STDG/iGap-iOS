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
import YPImagePicker

class IGEditProfileChannelAndGroupTableViewController: BaseTableViewController, UITextFieldDelegate {
    
    // MARK: - Variables
    var dispatchGroup: DispatchGroup!
    
    var room : IGRoom?
    var avatars: [IGAvatar] = []
    var defaultImage = UIImage(named: "IG_New_Channel_Generic_Avatar")
    var channelAvatarAttachment: IGFile!
    var tmpOldName : String = ""
    var tmpOldDesc : String = ""
    var channelLink: String? = ""
    var tmpOldUserName: String? = ""
    var convertToPublic = false
    var signMessageSwitchStatus : Bool?
    var reactionSwitchStatus = false
    
    // MARK: - Outlets
    @IBOutlet weak var lblSignMessage : UILabel!
    @IBOutlet weak var lblChannelReaction : UILabel!
    @IBOutlet weak var lblChannelType : UILabel!
    @IBOutlet weak var switchSignMessage : UISwitch!
    @IBOutlet weak var switchChannelReaction : UISwitch!
    
    @IBOutlet weak var tfChannelLink : UITextField!
    @IBOutlet weak var tfNameOfRoom : UITextField!
    @IBOutlet weak var tfDescriptionOfRoom : UITextField!
    @IBOutlet weak var avatarRoom : IGAvatarView!
    
    
    // MARK: - ViewController initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tfDescriptionOfRoom.delegate = self
        tfNameOfRoom.delegate = self
        tfChannelLink.delegate = self
        getData()
        
        var title : String = "CHANNEL_TITLE"
        if room!.type == .channel {
            title = "CHANNEL_TITLE"
            self.tfDescriptionOfRoom.placeholder = IGStringsManager.ChannelDesc.rawValue.localized
            self.tfNameOfRoom.placeholder = IGStringsManager.ChannelName.rawValue.localized

        } else {
            title = "GROUP_TITLE"
            self.tfDescriptionOfRoom.placeholder = IGStringsManager.GroupDesc.rawValue.localized
            self.tfNameOfRoom.placeholder = IGStringsManager.GroupName.rawValue.localized
        }
        self.initNavigationBar(title: title.localized,rightItemText: "", iGapFont: true) {
            if self.room?.type == .channel {
                self.RequestSequenceChannel()
            } else {
                
            }
        }
        initView()
    }
    
    // MARK: - Development Funcs
    func RequestSequenceChannel(){
        
        self.dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()   // <<---
        if self.convertToPublic {
            if self.tfChannelLink.text != self.tmpOldUserName {
                self.changedChannelTypeToPublic()
            } else {
                self.dispatchGroup.leave()
            }
        } else {
            self.changedChannelTypeToPrivate()
        }
        
        dispatchGroup.enter()   // <<---
        
        if self.tfDescriptionOfRoom.text != self.tmpOldDesc {
            self.changeChannelDescription()
        } else {
            self.dispatchGroup.leave()
            
        }
        
        dispatchGroup.enter()   // <<---
        
        if self.tfNameOfRoom.text != self.tmpOldName {
            self.changeChanellName()
        } else {
            self.dispatchGroup.leave()
            
        }
        
        dispatchGroup.enter()   // <<---
        self.requestToUpdateChannelReaction(self.reactionSwitchStatus)
        self.dispatchGroup.leave()
        
        
        dispatchGroup.enter()   // <<---
        self.requestToUpdateChannelSignature(self.signMessageSwitchStatus!)
        self.dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            // whatever you want to do when both are done
            self.navigationController?.popViewController(animated: true)
        }
    }
    //group sequence
    
    func RequestSequenceGroup(){
        
        self.dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()   // <<---
        if self.convertToPublic {
            if self.tfChannelLink.text != self.tmpOldUserName {
                self.changedGroupTypeToPublic()
            } else {
                self.dispatchGroup.leave()
            }
        } else {
            self.changedGroupTypeToPrivate()
        }
        
        dispatchGroup.enter()   // <<---
        
        if self.tfDescriptionOfRoom.text != self.tmpOldDesc {
            self.changeGroupDescription()
        } else {
            self.dispatchGroup.leave()
            
        }
        
        dispatchGroup.enter()   // <<---
        
        if self.tfNameOfRoom.text != self.tmpOldName {
            self.changeGroupName()
        } else {
            self.dispatchGroup.leave()
            
        }
        dispatchGroup.notify(queue: .main) {
            // whatever you want to do when both are done
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func requestToUpdateChannelSignature(_ signatureSwitchStatus: Bool) {
        if let channelRoom = room {
            SMLoading.showLoadingPage(viewcontroller: self)
            IGChannelUpdateSignatureRequest.Generator.generate(roomId: channelRoom.id, signatureStatus: signatureSwitchStatus).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelUpdateSignatureResponse as IGPChannelUpdateSignatureResponse:
                        let _ = IGChannelUpdateSignatureRequest.Handler.interpret(response: channelUpdateSignatureResponse)
                    default:
                        break
                    }
                    SMLoading.hideLoadingPage()
                    
                    
                }
            }).error ({ (errorCode, waitTime) in
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        break
                    default:
                        break
                    }
                    SMLoading.hideLoadingPage()
                }
                
            }).send()
        }
    }
    
    func requestToUpdateChannelReaction(_ reactionSwitchStatus: Bool) {
        if let channelRoom = room {
            SMLoading.showLoadingPage(viewcontroller: self)
            IGChannelUpdateReactionStatusRequest.sendRequest(roomId: channelRoom.id, reactionStatus: reactionSwitchStatus)
            
            
        }
    }
    private func getData() {
        //Hint : -This func is responsible to get current data of room and has responsibility to check values for changes
        if room?.type == .channel {
            self.tmpOldDesc = (self.room?.channelRoom!.description)!
            self.tmpOldName = self.room!.title!
            if room?.channelRoom?.type == .privateRoom {
                channelLink = room?.channelRoom?.privateExtra?.inviteLink
                channelLink = "iGap.net/" + channelLink!
                self.convertToPublic = false
                tfChannelLink.isEnabled = false
                lblChannelType.text = IGStringsManager.PrivateChannel.rawValue.localized
                
            }
            if room?.channelRoom?.type == .publicRoom {
                channelLink = room?.channelRoom?.publicExtra?.username
                channelLink = channelLink!
                tfChannelLink.isEnabled = true
                self.convertToPublic = true
                
                lblChannelType.text = IGStringsManager.PublicChannel.rawValue.localized
                tmpOldUserName = channelLink
                
            }
            tfChannelLink.text = channelLink
            
        } else {
            self.tmpOldDesc = (self.room?.groupRoom!.description)!
            self.tmpOldName = self.room!.title!
            if room?.groupRoom?.type == .privateRoom {
                channelLink = room?.groupRoom?.privateExtra?.inviteLink
                channelLink = "iGap.net/" + channelLink!
                self.convertToPublic = false
                tfChannelLink.isEnabled = false
                lblChannelType.text = IGStringsManager.GroupType.rawValue.localized + "  " + IGStringsManager.Private.rawValue.localized
                
            }
            if room?.groupRoom?.type == .publicRoom {
                channelLink = room?.groupRoom?.publicExtra?.username
                channelLink = channelLink!
                tfChannelLink.isEnabled = true
                self.convertToPublic = true
                
                lblChannelType.text = IGStringsManager.GroupType.rawValue.localized + "  " + IGStringsManager.Public.rawValue.localized
                tmpOldUserName = channelLink
                
            }
            tfChannelLink.text = channelLink
            
            
        }
    }
    //Mark: - change channel Description
    func changeChannelDescription() {
        
        SMLoading.showLoadingPage(viewcontroller: self)
        if let desc = tfDescriptionOfRoom.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if room != nil {
                IGChannelEditRequest.Generator.generate(roomId: (room?.id)!, channelName: (room?.title)!, description: desc).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let editChannelResponse as IGPChannelEditResponse:
                            let channelEditResponse = IGChannelEditRequest.Handler.interpret(response: editChannelResponse)
                            self.tfDescriptionOfRoom.text = channelEditResponse.description
                            self.tmpOldDesc = channelEditResponse.description
                            SMLoading.hideLoadingPage()
                            self.dispatchGroup.leave()
                            
                        default:
                            break
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            SMLoading.hideLoadingPage()
                            self.dispatchGroup.leave()
                        }
                    default:
                        break
                    }
                    
                }).send()
                
            }
        }
    }
    
    func changeGroupDescription() {
        SMLoading.showLoadingPage(viewcontroller: self)
        if let desc = tfDescriptionOfRoom.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if room != nil {
                IGGroupEditRequest.Generator.generate(groupName:(room?.title)! , groupDescription: desc , groupRoomId: (room?.id)!).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let editGroupResponse as IGPGroupEditResponse:
                            let groupEditResponse = IGGroupEditRequest.Handler.interpret(response: editGroupResponse)
                            self.tfDescriptionOfRoom.text = groupEditResponse.groupDesc
                            SMLoading.hideLoadingPage()
                            self.dispatchGroup.leave()
                        default:
                            break
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            SMLoading.hideLoadingPage()
                            self.dispatchGroup.leave()
                        }
                    default:
                        break
                    }
                    
                }).send()
                
            }
        }
    }
    //funcs to convert type of channel
    func changedChannelTypeToPrivate() {
        if room!.channelRoom!.type == .privateRoom {
            self.dispatchGroup.leave()
            return
        }
        if let roomID = room?.id {
            SMLoading.showLoadingPage(viewcontroller: self)
            IGChannelRemoveUsernameRequest.Generator.generate(roomID: roomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelRemoveUsernameResponse as IGPChannelRemoveUsernameResponse:
                        IGClientGetRoomRequest.Generator.generate(roomId: roomID).success({ (protoResponse) in
                            DispatchQueue.main.async {
                                switch protoResponse {
                                case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                    IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                    self.lblChannelType.text = IGStringsManager.ChannelType.rawValue.localized + "  " + IGStringsManager.Private.rawValue.localized
                                    self.convertToPublic = false
                                    self.tableView.beginUpdates()
                                    SMLoading.hideLoadingPage()
                                    self.tableView.endUpdates()
                                    self.dispatchGroup.leave()
                                    
                                default:
                                    break
                                }
                            }
                        }).error ({ (errorCode, waitTime) in
                            switch errorCode {
                            case .timeout:
                                DispatchQueue.main.async {
                                    SMLoading.hideLoadingPage()
                                    self.dispatchGroup.leave()
                                }
                            default:
                                break
                            }
                            
                        }).send()
                        _ = IGChannelRemoveUsernameRequest.Handler.interpret(response: channelRemoveUsernameResponse)
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                    }
                default:
                    break
                }
                
            }).send()
        }
    }
    
    func changedGroupTypeToPrivate() {
        if let roomID = room?.id {
            SMLoading.showLoadingPage(viewcontroller: self)
            IGGroupRemoveUsernameRequest.Generator.generate(roomId: roomID).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupRemoveUsernameResponse as IGPGroupRemoveUsernameResponse:
                        let _ = IGGroupRemoveUsernameRequest.Handler.interpret(response: groupRemoveUsernameResponse)
                        if self.navigationController is IGNavigationController {
                            //                            self.navigationController?.popViewController(animated: true)
                        }
                        self.dispatchGroup.leave()
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                    }
                default:
                    break
                }
                
            }).send()
        }
        
    }
    
    func changedChannelTypeToPublic(){
        if room!.channelRoom!.type == .publicRoom && room?.channelRoom?.publicExtra?.username == tfChannelLink.text {
            //            _ = self.navigationController?.popViewController(animated: true)
            dispatchGroup.leave()
            return
        }
        
        if let channelUserName = tfChannelLink.text {
            if channelUserName == "" {
                SMLoading.hideLoadingPage()
                dispatchGroup.leave()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalErrorForm.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                return
            }
            
            if channelUserName.count < 5 {
                SMLoading.hideLoadingPage()
                dispatchGroup.leave()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalMinimumLetters.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                return
            }
            
            SMLoading.showLoadingPage(viewcontroller: self)
            IGChannelUpdateUsernameRequest.Generator.generate(userName:channelUserName ,room: room!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelUpdateUserName as IGPChannelUpdateUsernameResponse :
                        IGChannelUpdateUsernameRequest.Handler.interpret(response: channelUpdateUserName)
                        self.tableView.beginUpdates()
                        self.lblChannelType.text = IGStringsManager.ChannelType.rawValue.localized + "  " + IGStringsManager.Public.rawValue.localized
                        self.tmpOldUserName = self.tfChannelLink.text
                        self.tableView.endUpdates()
                        self.dispatchGroup.leave()
                        
                    default:
                        break
                    }
                    SMLoading.hideLoadingPage()
                }
            }).error ({ (errorCode, waitTime) in
                
                if self.convertToPublic {
                    self.tableView.beginUpdates()
                    self.convertToPublic = true
                    self.lblChannelType.text = IGStringsManager.ChannelType.rawValue.localized + "  " + IGStringsManager.Public.rawValue.localized
                    self.tableView.endUpdates()
                    self.dispatchGroup.leave()
                    
                } else {
                    self.tableView.beginUpdates()
                    self.convertToPublic = false
                    self.lblChannelType.text = IGStringsManager.ChannelType.rawValue.localized + "  " + IGStringsManager.Private.rawValue.localized
                    self.tableView.endUpdates()
                    self.dispatchGroup.leave()
                    
                }
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        break
                    case .channelUpdateUsernameIsInvalid:

                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.InvalidUserName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameHasAlreadyBeenTakenByAnotherUser:

                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AlreadyTakenUserName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou:

                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: "More than the allowed usernmae have been selected by you", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameForbidden:
                        
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.MSGUpdateUserNameForbidden.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .channelUpdateUsernameLock:
                        let time = waitTime
                        let remainingMiuntes = time!/60
                        let msg =  IGStringsManager.ErrorUpdateUSernameAfter.rawValue.localized + " \(remainingMiuntes)" + IGStringsManager.Minutes.rawValue.localized
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: msg, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    default:
                        break
                    }
                    
                    SMLoading.hideLoadingPage()
                }
                
            }).send()
        }
    }
    
    func changedGroupTypeToPublic(){
        
        if room!.groupRoom!.type == .publicRoom && room?.groupRoom?.publicExtra?.username == tfChannelLink.text {
            dispatchGroup.leave()
            return
        }
        
        if let groupUserName = tfChannelLink.text {
            
            if groupUserName == "" {
                SMLoading.hideLoadingPage()
                self.dispatchGroup.leave()
                
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.ErrorGroupLinkNotEmpty
                    .rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                return
            }
            
            if groupUserName.count < 5 {
                SMLoading.hideLoadingPage()
                self.dispatchGroup.leave()
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalMinimumLetters.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                return
            }
            
            SMLoading.showLoadingPage(viewcontroller: self)
            IGGroupUpdateUsernameRequest.Generator.generate(roomID: room!.id ,userName:groupUserName).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let groupUpdateUserName as IGPGroupUpdateUsernameResponse :
                        let _ = IGGroupUpdateUsernameRequest.Handler.interpret(response: groupUpdateUserName)
                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()
                        
                    case .groupUpdateUsernameIsInvalid:

                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()

                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.InvalidUserName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .groupUpdateUsernameHasAlreadyBeenTakenByAnotherUser:

                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()

                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AlreadyTakenUserName.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .groupUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou:

                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()
                        
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "Error", showIconView: true, showDoneButton: false, showCancelButton: true, message: "More than the allowed usernmae have been selected by you", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .groupUpdateUsernameForbidden:
                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()
                        
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.MSGUpdateUserNameForbidden.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    case .groupUpdateUsernameLock:
                        let time = waitTime
                        let remainingMiuntes = time!/60
                        let msg = IGStringsManager.ErrorUpdateUSernameAfter.rawValue.localized + " " + String(remainingMiuntes) + " " + IGStringsManager.Minutes.rawValue.localized
                        
                        self.dispatchGroup.leave()
                        SMLoading.hideLoadingPage()
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: msg, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                        
                    default:
                        break
                    }
                    
                }
                
            }).send()
        }
    }
    @IBAction func edtTextChange(_ sender: UITextField) {
        if let text = sender.text {
            if text.count >= 5 {
                checkUsername(username: sender.text!)
            }
        }
    }
    @IBAction func changedSignMessageSwitchValue(_ sender: Any) {
        if switchSignMessage.isOn {
            signMessageSwitchStatus = true
        } else if switchSignMessage.isOn == false {
            signMessageSwitchStatus = false
        }
    }
    
    @IBAction func switchChannelReaction(_ sender: UISwitch) {
        if switchChannelReaction.isOn {
            reactionSwitchStatus = true
        }
    }
    
    func checkUsername(username: String){
        IGChannelCheckUsernameRequest.Generator.generate(roomId:room!.id ,username: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let usernameResponse as IGPChannelCheckUsernameResponse :
                    if usernameResponse.igpStatus == IGPChannelCheckUsernameResponse.IGPStatus.available {
                        self.tfChannelLink.textColor = ThemeManager.currentTheme.LabelColor
                        if self.room!.type == .channel {
                            if self.room?.channelRoom?.type == .publicRoom {
                                self.convertToPublic = true
                            } else {
                                self.convertToPublic = true
                            }
                            
                        } else {
                            if self.room?.groupRoom?.type == .publicRoom {
                                self.convertToPublic = true
                            } else {
                                self.convertToPublic = true
                            }
                            
                        }
                        
                    } else {
                        if self.room!.type == .channel {
                            self.tfChannelLink.textColor = UIColor.iGapRed()
                            if self.room?.channelRoom?.type == .publicRoom {
                                self.convertToPublic = true
                            } else {
                                self.convertToPublic = true
                            }
                        } else {
                            self.tfChannelLink.textColor = UIColor.iGapRed()
                            if self.room?.channelRoom?.type == .publicRoom {
                                self.convertToPublic = true
                            } else {
                                self.convertToPublic = true
                            }
                        }
                        
                    }
                    break
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
            }
        }).send()
    }
    
    //Mark: - change channel name
    func changeChanellName() {
        SMLoading.showLoadingPage(viewcontroller: self)
        if let name = tfNameOfRoom.text {
            IGChannelEditRequest.Generator.generate(roomId: (room?.id)!, channelName: name, description: room?.channelRoom?.roomDescription).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let editChannelResponse as IGPChannelEditResponse:
                        let channelName = IGChannelEditRequest.Handler.interpret(response: editChannelResponse)
                        self.tfNameOfRoom.text = channelName.channelName
                        self.tmpOldName = channelName.channelName
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                    }
                default:
                    break
                }
                
            }).send()
            
        }
    }
    private func changeGroupName() {
        
        SMLoading.showLoadingPage(viewcontroller: self)
        if let name = tfNameOfRoom.text {
            IGGroupEditRequest.Generator.generate(groupName: name, groupDescription: room?.groupRoom?.roomDescription , groupRoomId: (room?.id)!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let editChannelResponse as IGPGroupEditResponse:
                        let groupName = IGGroupEditRequest.Handler.interpret(response: editChannelResponse)
                        self.tfNameOfRoom.text = groupName.groupName
                        
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                        
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                    }
                default:
                    break
                }
                
            }).send()
            
        }
    }

    private func initView() {
        self.tableView.tableFooterView = UIView()
        //Font
        lblSignMessage.font = UIFont.igFont(ofSize: 15)
        lblChannelType.font = UIFont.igFont(ofSize: 15)
        lblChannelReaction.font = UIFont.igFont(ofSize: 15)
        tfNameOfRoom.font = UIFont.igFont(ofSize: 15)
        tfDescriptionOfRoom.font = UIFont.igFont(ofSize: 15)
        tfChannelLink.font = UIFont.igFont(ofSize: 15)
        //Color
        lblSignMessage.textColor = ThemeManager.currentTheme.LabelColor
        lblChannelType.textColor = ThemeManager.currentTheme.LabelColor
        lblChannelReaction.textColor = ThemeManager.currentTheme.LabelColor
        //Direction Handler
        lblSignMessage.textAlignment = lblSignMessage.localizedDirection
        lblChannelType.textAlignment = lblSignMessage.localizedDirection
        lblChannelReaction.textAlignment = lblChannelReaction.localizedDirection
        initLabels(room: self.room!)
    }
    func initLabels(room : IGRoom!) {
        if room.type == .channel {
            lblChannelReaction.text = IGStringsManager.ShowChannelReactions.rawValue.localized
            lblSignMessage.text = IGStringsManager.SignMessages.rawValue.localized
            
            tfDescriptionOfRoom.text = room.channelRoom?.roomDescription
            tfNameOfRoom.text = room.title
            self.avatarRoom.setRoom(room!)
            let signIsOn = room.channelRoom?.isSignature
            if signIsOn! {
                switchSignMessage.isOn = true
                signMessageSwitchStatus = true
            } else {
                switchSignMessage.isOn = false
                signMessageSwitchStatus = false
            }
            let reactinsOn = room.channelRoom?.hasReaction
            if reactinsOn! {
                switchChannelReaction.isOn = true
                reactionSwitchStatus = true
                
            } else {
                switchChannelReaction.isOn = false
                reactionSwitchStatus = false
                
            }
        } else {
            tfDescriptionOfRoom.text = room.groupRoom?.roomDescription
            tfNameOfRoom.text = room.title
            self.avatarRoom.setRoom(room!)
            
        }
    }
    @IBAction func btnChangeImageTapped(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: IGStringsManager.Camera.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.photo])
        })
        let ChoosePhoto = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.library])
        })
        let removeAction = UIAlertAction(title: IGStringsManager.DeletePhoto.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.deleteAvatar()
        })
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        optionMenu.addAction(ChoosePhoto)
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == IGStringsManager.DeletePhoto.rawValue.localized{
                let removeColor = UIColor.iGapRed()
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        optionMenu.view.tintColor = UIColor.organizationalColor()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        if self.avatarRoom.avatarImageView!.image != nil {
            optionMenu.addAction(removeAction)
        }
        optionMenu.addAction(cancelAction)
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func pickImage(screens: [YPPickerScreen]){
        IGHelperAvatar.shared.pickAndUploadAvatar(roomId: self.room!.id, type: AvatarAddRequestType.fromIG(self.room!.type), screens: screens) { (file) in
            DispatchQueue.main.async {
                if let image = file.attachedImage {
                    self.avatarRoom.avatarImageView?.image = image
                } else {
                    self.avatarRoom.avatarImageView?.setImage(avatar: file)
                }
            }
        }
    }
    
    /**
     * this method will be deleted main(latest) avatar
     */
    func deleteAvatar(){
        var avatarId: Int64!
        if let channelAvatarId = self.room?.channelRoom?.avatar?.id {
            avatarId = channelAvatarId
        } else if let groupAvatarId = self.room?.groupRoom?.avatar?.id {
            avatarId = groupAvatarId
        }
        
        IGHelperAvatar.shared.delete(avatarId: avatarId, type: AvatarAddRequestType.fromIG(self.room!.type)) {
            DispatchQueue.main.async {
                self.avatarRoom.avatarImageView!.image = nil
            }
        }
    }
    
    private func showAlertChangeChannelType() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let publicChannel = UIAlertAction(title: IGStringsManager.Public.rawValue.localized, style: .default, handler: { (action) in
            if self.room?.type == .channel {
                self.tableView.beginUpdates()
                self.lblChannelType.text = IGStringsManager.ChannelType.rawValue.localized + "  " + IGStringsManager.Public.rawValue.localized
                self.tfChannelLink.text = nil
                self.tfChannelLink.isEnabled = true
                self.convertToPublic = true
                self.tableView.endUpdates()
            } else {
                self.tableView.beginUpdates()
                self.lblChannelType.text = IGStringsManager.GroupType.rawValue.localized + "  " + IGStringsManager.Public.rawValue.localized
                self.tfChannelLink.text = nil
                self.tfChannelLink.isEnabled = true
                self.convertToPublic = true
            }
        })
        
        let privateChannel = UIAlertAction(title: IGStringsManager.Private.rawValue.localized, style: .default, handler: { (action) in
            if self.room?.type == .channel {
                self.tableView.beginUpdates()
                self.lblChannelType.text = IGStringsManager.ChannelType.rawValue.localized + "  " + IGStringsManager.Private.rawValue.localized
                self.tfChannelLink.isEnabled = false
                self.convertToPublic = false
                
                self.tableView.endUpdates()
                
            } else {
                self.tableView.beginUpdates()
                self.lblChannelType.text = IGStringsManager.GroupType.rawValue.localized + "  " + IGStringsManager.Private.rawValue.localized
                self.tfChannelLink.isEnabled = false
                self.convertToPublic = false
                
                self.tableView.endUpdates()
                
            }
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertController.addAction(publicChannel)
        alertController.addAction(privateChannel)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        return
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if room!.type == .channel {
            return 4
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if room!.type == .channel {
            switch section {
            case 1 :
                return 2
            default :
                return 1
            }
        } else {
            switch section {
            case 1 :
                return 2
            default :
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
            let rowIndex = indexPath.row
            if rowIndex == 0 {
                //                self.performSegue(withIdentifier: "showChannelInfoSetType", sender: self)
                showAlertChangeChannelType()
            }
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0 :
            return 134
        case 1 :
            
            if self.convertToPublic == true {
                switch indexPath.row {
                case 0 :
                    return 52
                case 1 :
                    return 52
                default:
                    return 52
                    
                }
            } else {
                switch indexPath.row {
                case 0 :
                    return 52
                case 1 :
                    return 0
                default:
                    return 52
                    
                }
            }
        default :
            if room?.type == .channel {
                return 52
                
            } else {
                return 0
                
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSharedMadiaPage" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        }
    }
    
    //MARK: -Header and Footer
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedDirection
        switch section {
        default :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedDirection
        containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .light)
        
        switch section {
            
        case 2 :
            if room?.type == .channel {
                containerFooterView.textLabel?.text = IGStringsManager.ChannelSignMessagesFooter.rawValue.localized
                
            }
        case 3 :
            if room?.type == .channel {
                containerFooterView.textLabel?.text = IGStringsManager.ChannelReactionMessageFooter.rawValue.localized
                
            }
        default :
            break
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        if room?.type == .channel {
            switch section {
            case 0:
                return ""
            case 1:
                return IGStringsManager.Information.rawValue.localized
            case 2:
                return IGStringsManager.SignMessages.rawValue.localized
            case 3:
                return IGStringsManager.ShowChannelReactions.rawValue.localized
            default:
                return ""
            }
            
        } else {
            switch section {
            case 0:
                return ""
            case 1:
                return IGStringsManager.Information.rawValue.localized
            default:
                return ""
            }
            
        }
        
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if room?.type == .channel {
            switch section {
            case 0:
                return ""
            case 1:
                return ""
            case 2:
                return IGStringsManager.ChannelSignMessagesFooter.rawValue.localized
            case 3:
                return IGStringsManager.ChannelReactionMessageFooter.rawValue.localized
            default:
                return ""
            }
            
        } else {
            return ""
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if room?.type == .channel {
            switch section {
            case 0:
                return 0
            case 1:
                return 50
            case 2:
                return 50
            case 3:
                return 50
            default:
                return 50
            }
            
        } else {
            switch section {
            case 0:
                return 0
            case 1:
                return 50
            default:
                return 50
            }
        }
        
        
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if room?.type == .channel {
            switch section {
            case 2:
                return 50
            case 3:
                return 50
            default:
                return 10
            }
            
            
        } else {
            switch section {
            default:
                return 10
            }
        }
    }
}
