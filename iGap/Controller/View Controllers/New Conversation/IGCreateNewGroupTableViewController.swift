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
import MBProgressHUD

class IGCreateNewGroupTableViewController: BaseTableViewController {

    @IBOutlet weak var groupNameCell: UITableViewCell!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var groupAvatarImage: UIImageView!
    @IBOutlet weak var groupNameTextField: UITextField!
    
    var groupAvatarAttachment: IGFile!
    var getRoomResponseID : Int64?
    var imagePicker = UIImagePickerController()
    let width = CGFloat(0.5)
    let greenColor = UIColor.organizationalColor()
    var mode : String?
    var roomId : Int64?
    var selectedUsersToCreateGroup = [IGRegisteredUser]()
    var hud = MBProgressHUD()
    var defualtImage = UIImage(named: "IG_Camera_Image")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationItem()
        
        addBottomBorder(textField: groupNameTextField)
        addBottomBorder(textField: descriptionTextField)
        groupNameCell.selectionStyle = UITableViewCell.SelectionStyle.none
        groupNameTextField.placeholder = "GROUPNAME".localizedNew
        descriptionTextField.placeholder = "DESCRIPTION".localizedNew
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(didTapOnChangeImage))
        groupAvatarImage.addGestureRecognizer(tap)
        groupAvatarImage.isUserInteractionEnabled = true
        
        roundUserImage(groupAvatarImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupNameTextField.becomeFirstResponder()
    }
    
    private func initNavigationItem(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "NEXT_BTN".localizedNew, title: "NEW_GROUP".localizedNew)
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
    
    @objc func didTapOnChangeImage() {
        choosePhotoActionSheet(sender : groupAvatarImage)
    }
    
    func roundUserImage(_ roundView:UIView){
        roundView.layer.borderWidth = 0
        roundView.layer.masksToBounds = true
        let borderUserImageColor = UIColor.organizationalColor()
        roundView.layer.borderColor = borderUserImageColor.cgColor
        roundView.layer.cornerRadius = roundView.frame.size.height/2
        roundView.clipsToBounds = true
    }

    func addBottomBorder(textField: UITextField){
        let borderName = CALayer()
        borderName.borderColor = greenColor.cgColor
        borderName.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:textField.frame.size.width, height: textField.frame.size.height)
        borderName.borderWidth = width
        textField.layer.addSublayer(borderName)
        textField.layer.masksToBounds = true
    }
    
    func choosePhotoActionSheet(sender : UIImageView){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: "TAKE_A_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil{
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = true
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = .photo
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                else {
                    self.present(self.imagePicker, animated: true, completion: nil)//4
                    self.imagePicker.popoverPresentationController?.sourceView = (sender )
                    self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                    self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
                }
            }
        })
        let ChoosePhoto = UIAlertAction(title: "CHOOSE_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .photoLibrary
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            else {
                self.present(self.imagePicker, animated: true, completion: nil)//4
                self.imagePicker.popoverPresentationController?.sourceView = (sender)
                self.imagePicker.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
                self.imagePicker.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
            }
        })
        
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        let removeAction = UIAlertAction(title: "DELETE_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.defualtImage = UIImage(named: "IG_Camera_Image")
            self.groupAvatarImage.image = self.defualtImage
        })

        optionMenu.addAction(ChoosePhoto)
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        
        optionMenu.addAction(cancelAction)
        self.defualtImage = UIImage(named: "IG_Camera_Image")
        if groupAvatarImage.image != self.defualtImage {
            optionMenu.addAction(removeAction)
        }
        
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == "DELETE_PHOTO".localizedNew{
                let removeColor = UIColor.red
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
        }
        self.present(optionMenu, animated: true, completion: nil)
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
    
    private func manageImage(imageInfo: [String : Any]){
        let originalImage = imageInfo["UIImagePickerControllerOriginalImage"] as! UIImage
        let filename = "IMAGE_" + IGGlobal.randomString(length: 16)
        let randomString = IGGlobal.randomString(length: 16) + "_"
        var scaledImage = originalImage
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        let fileNameOnDisk = randomString + filename
        
        if (originalImage.size.width) > CGFloat(2000.0) || (originalImage.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: originalImage)
        }
        
        self.groupAvatarAttachment = IGFile(name: filename)
        self.groupAvatarAttachment.attachedImage = scaledImage
        self.groupAvatarAttachment.fileNameOnDisk = fileNameOnDisk
        self.groupAvatarAttachment.height = Double((scaledImage.size.height))
        self.groupAvatarAttachment.width = Double((scaledImage.size.width))
        self.groupAvatarAttachment.size = (imgData?.count)!
        self.groupAvatarAttachment.data = imgData
        self.groupAvatarAttachment.type = .image

        let path = IGFile.path(fileNameOnDisk: fileNameOnDisk)
        FileManager.default.createFile(atPath: path.path, contents: imgData!, attributes: nil)
        
        DispatchQueue.main.async {
            self.groupAvatarImage.image = scaledImage
        }
    }
    
    func requestToCreateGroup() {
        self.view.endEditing(true)
        if let roomName = self.groupNameTextField.text {
            if roomName != "" {
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                
                let roomDescription = self.descriptionTextField.text
                IGGroupCreateRequest.Generator.generate(name: roomName, description: roomDescription).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        
                        switch protoResponse {
                        case let groupCreateRespone as IGPGroupCreateResponse:
                            IGClientGetRoomRequest.Generator.generate(roomId: groupCreateRespone.igpRoomID).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    switch protoResponse {
                                    case let getRoomProtoResponse as IGPClientGetRoomResponse:
                                        
                                        IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                        
                                        for member in self.selectedUsersToCreateGroup {
                                            let groupRoom = IGRoom(igpRoom:getRoomProtoResponse.igpRoom)
                                            IGGroupAddMemberRequest.Generator.generate(userID: member.id , group: groupRoom ).success({ (protoResponse) in
                                                DispatchQueue.main.async {
                                                    switch protoResponse {
                                                    case let groupAddMemberResponse as IGPGroupAddMemberResponse :
                                                        let _ = IGGroupAddMemberRequest.Handler.interpret(response: groupAddMemberResponse)
                                                    default:
                                                        break
                                                    }
                                                }
                                            }).error({ (errorCode, waitTime) in
                                                
                                            }).send()
                                        }
                                        
                                        if self.groupAvatarImage.image != self.defualtImage {
                                            
                                            IGUploadManager.sharedManager.upload(file: self.groupAvatarAttachment, start: {
                                            }, progress: { (progress) in
                                                
                                            }, completion: { (uploadTask) in
                                                if let token = uploadTask.token {
                                                    IGGroupAvatarAddRequest.Generator.generate(attachment: token , roomID: getRoomProtoResponse.igpRoom.igpID).success({ (protoResponse) in
                                                        DispatchQueue.main.async {
                                                            switch protoResponse {
                                                            case let groupAvatarAddResponse as IGPGroupAvatarAddResponse:
                                                                IGGroupAvatarAddRequest.Handler.interpret(response: groupAvatarAddResponse)
                                                                self.hideProgress()
                                                                self.dismissView(roomId: getRoomProtoResponse.igpRoom.igpID)
                                                            default:
                                                                break
                                                            }
                                                        }
                                                    }).error({ (error, waitTime) in
                                                        self.hideProgress()
                                                    }).send()
                                                }
                                            }, failure: {
                                                self.hideProgress()
                                            })
                                        } else {
                                            self.hideProgress()
                                            self.dismissView(roomId: getRoomProtoResponse.igpRoom.igpID)
                                        }

                                    default:
                                        break
                                    }
                                }
                            }).error({ (errorCode, waitTime) in
                                self.hideProgress()
                            }).send()
                            break
                        default:
                            break
                        }
                    }
                }).error({ (errorCode, waitTime) in
                    self.hideProgress()
                }).send()
            }
        }
    }
    
    func hideProgress(){
        DispatchQueue.main.async {
            self.hud.hide(animated: true)
        }
    }
    
    func dismissView(roomId: Int64){
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGNotificationNameDidCreateARoom),
                                            object: nil,
                                            userInfo: ["room": roomId])
        }
    }
    
    func requestToConvertChatToGroup() {
        self.view.endEditing(true)
        if let roomName = self.groupNameTextField.text {
            if roomName != "" {
                let roomDescription = self.descriptionTextField.text
                IGChatConvertToGroupRequest.Generator.generate(roomId: roomId!, name: roomName, description: roomDescription!).success({ (protoResponse) in
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
                                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                                        alert.addAction(okAction)
                                        self.hud.hide(animated: true)
                                        self.present(alert, animated: true, completion: nil)
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

}
extension IGCreateNewGroupTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: {
            self.roundUserImage(self.groupAvatarImage)
            self.manageImage(imageInfo: convertFromUIImagePickerControllerInfoKeyDictionary(info))
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGCreateNewGroupTableViewController: UINavigationControllerDelegate {
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
