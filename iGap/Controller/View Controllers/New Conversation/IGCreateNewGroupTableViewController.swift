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

class IGCreateNewGroupTableViewController: BaseTableViewController {

    @IBOutlet weak var groupNameCell: UITableViewCell!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var groupAvatarImage: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var changeImageBtn: UIButton!
    
    var groupAvatarAttachment: IGFile!
    var getRoomResponseID : Int64?
    let width = CGFloat(0.5)
    let borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)!
    var mode : String?
    var roomId : Int64?
    var selectedUsersToCreateGroup = [IGRegisteredUser]()
    var defualtImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationItem()
        addBottomBorder(textField: groupNameTextField)
        addBottomBorder(textField: descriptionTextField)
        
        groupNameCell.selectionStyle = UITableViewCell.SelectionStyle.none
        groupNameTextField.placeholder = IGStringsManager.GroupName.rawValue.localized
        descriptionTextField.placeholder = IGStringsManager.GroupDesc.rawValue.localized
        groupNameTextField.textAlignment = self.TextAlignment
        descriptionTextField.textAlignment = self.TextAlignment
        groupAvatarImage.isUserInteractionEnabled = false
        changeImageBtn.layer.cornerRadius = changeImageBtn.frame.height / 2
        changeImageBtn.clipsToBounds = true
        
        roundUserImage(groupAvatarImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupNameTextField.becomeFirstResponder()
    }
    
    private func initNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalNext.rawValue.localized, title: IGStringsManager.NewGroup.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            if self.mode == "Convert Chat To Group" {
                self.requestToConvertChatToGroup()
            } else {
                self.requestToCreateGroup()
            }
        }
    }
    
    @IBAction func didTapOnChangeImage(sender: UIButton) {
        choosePhotoActionSheet(sender : groupAvatarImage)
    }
    
    func roundUserImage(_ roundView:UIView){
        roundView.layer.borderWidth = 0
        roundView.layer.masksToBounds = true
        let borderUserImageColor = UIColor(named: themeColor.labelGrayColor.rawValue)!
        roundView.layer.borderColor = borderUserImageColor.cgColor
        roundView.layer.cornerRadius = roundView.frame.size.height/2
        roundView.clipsToBounds = true
    }

    func addBottomBorder(textField: UITextField){
        let borderName = CALayer()
        borderName.borderColor = borderColor.cgColor
        borderName.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:textField.frame.size.width, height: textField.frame.size.height)
        borderName.borderWidth = width
        textField.layer.addSublayer(borderName)
        textField.layer.masksToBounds = true
    }
    
    func choosePhotoActionSheet(sender : UIImageView){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.photo])
        })
        
        let ChoosePhoto = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
           self.pickImage(screens: [.library])
        })
        
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let removeAction = UIAlertAction(title: IGStringsManager.DeletePhoto.rawValue.localized, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.groupAvatarImage.image = self.defualtImage
        })

        optionMenu.addAction(ChoosePhoto)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        
        optionMenu.addAction(cancelAction)
        if groupAvatarImage.image != self.defualtImage {
            optionMenu.addAction(removeAction)
        }
        
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == IGStringsManager.DeletePhoto.rawValue.localized{
                let removeColor = UIColor.red
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func pickImage(screens: [YPPickerScreen]){
        IGHelperMediaPicker.shared.setScreens(screens).pick { mediaItems in
            if let imageInfo = mediaItems.singlePhoto, mediaItems.count == 1 {
                DispatchQueue.main.async {
                    self.groupAvatarAttachment = IGHelperAvatar.shared.makeAvatarFile(photo: imageInfo)
                    var image = imageInfo.originalImage
                    if let modifiedImage = imageInfo.modifiedImage {
                        image = modifiedImage
                    }
                    self.groupAvatarImage.image = image
                    self.roundUserImage(self.groupAvatarImage)
                }
            }
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerText : String = ""
        if section == 0 {
            headerText = ""
            
        }
        if section == 1{
            headerText = "   "
        }
        return headerText
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHieght : CGFloat = 0
        if section == 0 {
            headerHieght = CGFloat.leastNonzeroMagnitude
        }
        if section == 1 {
            headerHieght = 0
        }
        return headerHieght
    }
    
    func requestToCreateGroup() {
        self.view.endEditing(true)
        if let roomName = self.groupNameTextField.text {
            if roomName != "" {
                IGGlobal.prgShow()
                IGGroupCreateRequest.Generator.generate(name: roomName, description: self.descriptionTextField.text).success({ (protoResponse) in
                    if let groupCreateRespone = protoResponse as? IGPGroupCreateResponse {
                        IGClientGetRoomRequest.Generator.generate(roomId: groupCreateRespone.igpRoomID).success({ (protoResponse) in
                            if let getRoomProtoResponse = protoResponse as? IGPClientGetRoomResponse {
                                IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                for member in self.selectedUsersToCreateGroup {
                                    IGGroupAddMemberRequest.Generator.generate(userID: member.id, group: IGRoom(igpRoom:getRoomProtoResponse.igpRoom)).success({ (protoResponse) in
                                        if let groupAddMemberResponse = protoResponse as? IGPGroupAddMemberResponse {
                                            let _ = IGGroupAddMemberRequest.Handler.interpret(response: groupAddMemberResponse)
                                        }
                                    }).error({ (errorCode, waitTime) in
                                    }).send()
                                }
                                
                                if self.groupAvatarImage.image != nil, self.groupAvatarImage.image != self.defualtImage {
                                    IGHelperAvatar.shared.upload(roomId: getRoomProtoResponse.igpRoom.igpID, type: .channel, file: self.groupAvatarAttachment) { (file) in
                                        DispatchQueue.main.async {
                                            self.dismissView(roomId: getRoomProtoResponse.igpRoom.igpID)
                                        }
                                    }
                                } else {
                                    IGGlobal.prgHide()
                                    self.dismissView(roomId: getRoomProtoResponse.igpRoom.igpID)
                                }
                            }
                        }).error({ (errorCode, waitTime) in
                            IGGlobal.prgHide()
                        }).send()
                    }
                }).error({ (errorCode, waitTime) in
                    IGGlobal.prgHide()
                }).send()
            }
        }
    }
    
    func requestToConvertChatToGroup() {
        self.view.endEditing(true)
        if let roomName = self.groupNameTextField.text {
            if roomName != "" {
                IGChatConvertToGroupRequest.Generator.generate(roomId: roomId!, name: roomName, description: self.descriptionTextField.text!).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let chatConvertToGroupResponse as IGPChatConvertToGroupResponse:
                            
                            IGClientGetRoomRequest.Generator.generate(roomId: self.roomId!).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    switch protoResponse {
                                    case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                        let _ = IGChatConvertToGroupRequest.Handler.interpret(response: chatConvertToGroupResponse)
                                        IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                        if self.navigationController is IGNavigationController {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    default:
                                        break
                                    }
                                }
                            }).error ({ (errorCode, waitTime) in
                                switch errorCode {
                                case .timeout:
                                    DispatchQueue.main.async {
                                        IGGlobal.prgHide()
                                    }
                                default:
                                    break
                                }
                                
                            }).send()
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
        }
    }
    
    func dismissView(roomId: Int64){
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom), object: nil, userInfo: ["room": roomId])
        }
    }
}
