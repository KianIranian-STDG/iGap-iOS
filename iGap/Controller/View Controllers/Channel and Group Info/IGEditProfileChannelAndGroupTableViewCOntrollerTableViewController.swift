//
//  IGEditProfileChannelAndGroupTableViewCOntrollerTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/30/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import IGProtoBuff

class IGEditProfileChannelAndGroupTableViewCOntrollerTableViewController: BaseTableViewController,UITextFieldDelegate {

    // MARK: - Variables
    var dispatchGroup: DispatchGroup!

    var room : IGRoom?
    var imagePicker = UIImagePickerController()
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
        //nav init
        imagePicker.delegate = self

        self.initNavigationBar(title: "CHANNEL_TITLE".localizedNew,rightItemText: "", iGapFont: true) {

            self.RequestSequence()
        }
        
        initView()

    }
    // MARK: - Development Funcs
    func RequestSequence(){
        
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
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)

                        self.present(alert, animated: true, completion: nil)
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
        self.tmpOldDesc = (self.room?.channelRoom!.description)!
        self.tmpOldName = self.room!.title!
        if room?.channelRoom?.type == .privateRoom {
            channelLink = room?.channelRoom?.privateExtra?.inviteLink
            channelLink = "iGap.net/" + channelLink!
            self.convertToPublic = false
            tfChannelLink.isEnabled = false
            lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PRIVATE".localizedNew

        }
        if room?.channelRoom?.type == .publicRoom {
            channelLink = room?.channelRoom?.publicExtra?.username
            channelLink = channelLink!
            tfChannelLink.isEnabled = true
            self.convertToPublic = true

            lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PUBLIC".localizedNew
            tmpOldUserName = channelLink

        }
        tfChannelLink.text = channelLink
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
                            let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alert.addAction(okAction)
                            SMLoading.hideLoadingPage()
                            self.dispatchGroup.leave()
                            self.present(alert, animated: true, completion: nil)
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
                                    self.lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PRIVATE".localizedNew
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
                                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                                    alert.addAction(okAction)
                                    SMLoading.hideLoadingPage()
                                    self.dispatchGroup.leave()

                                    self.present(alert, animated: true, completion: nil)
                                }
                            default:
                                break
                            }
                            
                        }).send()
                        
                        _ = IGChannelRemoveUsernameRequest.Handler.interpret(response: channelRemoveUsernameResponse)
                        
                        if self.navigationController is IGNavigationController {
//                            _ = self.navigationController?.popViewController(animated: true)
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
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                        self.present(alert, animated: true, completion: nil)
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
                let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "ERROR_FORM".localizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                SMLoading.hideLoadingPage()
                dispatchGroup.leave()
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if channelUserName.count < 5 {
                let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_MINIMUM_LENGH".localizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                SMLoading.hideLoadingPage()
                dispatchGroup.leave()
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            SMLoading.showLoadingPage(viewcontroller: self)
            IGChannelUpdateUsernameRequest.Generator.generate(userName:channelUserName ,room: room!).success({ (protoResponse) in
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let channelUpdateUserName as IGPChannelUpdateUsernameResponse :
                        IGChannelUpdateUsernameRequest.Handler.interpret(response: channelUpdateUserName)
                        self.tableView.beginUpdates()
                        self.lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PUBLIC".localizedNew
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
                    self.lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PUBLIC".localizedNew
                    self.tableView.endUpdates()
                    self.dispatchGroup.leave()

                } else {
                    self.tableView.beginUpdates()
                    self.convertToPublic = false
                    self.lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PRIVATE".localizedNew
                    self.tableView.endUpdates()
                    self.dispatchGroup.leave()

                }
                DispatchQueue.main.async {
                    switch errorCode {
                    case .timeout:
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    case .channelUpdateUsernameIsInvalid:
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_INVALID_USERNAME".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameHasAlreadyBeenTakenByAnotherUser:
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_TAKEN_USERNAME".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameMoreThanTheAllowedUsernmaeHaveBeenSelectedByYou:
                        let alert = UIAlertController(title: "Error", message: "More than the allowed usernmae have been selected by you", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameForbidden:
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_UPDATE_USERNAME_FORBIDDEN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                        
                    case .channelUpdateUsernameLock:
                        let time = waitTime
                        let remainingMiuntes = time!/60
                        let alert = UIAlertController(title: "GLOBAL_WARNING".localizedNew, message: "MSG_CHANGE_USERNAME_AFTER".localizedNew + " \(remainingMiuntes)" + "MINUTE".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true,completion: nil)
                        break
                        
                    default:
                        break
                    }
                    
                    SMLoading.hideLoadingPage()
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
//        requestToUpdateChannelSignature(signMessageSwitchStatus!)
        
    }
    
    @IBAction func switchChannelReaction(_ sender: UISwitch) {
        if switchChannelReaction.isOn {
            reactionSwitchStatus = true
        }
//        requestToUpdateChannelReaction(reactionSwitchStatus)
    }
    func checkUsername(username: String){
        IGChannelCheckUsernameRequest.Generator.generate(roomId:room!.id ,username: username).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let usernameResponse as IGPChannelCheckUsernameResponse :
                    if usernameResponse.igpStatus == IGPChannelCheckUsernameResponse.IGPStatus.available {
                        self.tfChannelLink.textColor = UIColor.black
                        if self.room?.channelRoom?.type == .publicRoom {
                            self.convertToPublic = true
                        } else {
                            self.convertToPublic = true
                        }

                    } else {
                            self.tfChannelLink.textColor = UIColor.red
                        if self.room?.channelRoom?.type == .publicRoom {
                                self.convertToPublic = true
                            } else {
                                self.convertToPublic = true
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
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
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
                        let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        SMLoading.hideLoadingPage()
                        self.dispatchGroup.leave()
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
            
        }
    }
    private func initServices() {
        uploadImage()
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
        lblSignMessage.textColor = .black
        lblChannelType.textColor = .black
        lblChannelReaction.textColor = .black
        //Direction Handler
        lblSignMessage.textAlignment = lblSignMessage.localizedNewDirection
        lblChannelType.textAlignment = lblSignMessage.localizedNewDirection
        lblChannelReaction.textAlignment = lblChannelReaction.localizedNewDirection
        initLabels(room: self.room!)
    }
    func initLabels(room : IGRoom!) {
        lblChannelReaction.text = "CHANNELREACTION".localizedNew
        lblSignMessage.text = "CHANNELSIGNMESSAGES".localizedNew
        
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

    }
    @IBAction func btnChangeImageTapped(_ sender: UIButton) {
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
            }
        })
       
        let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let removeAction = UIAlertAction(title: "DELETE_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.avatarRoom.avatarImageView!.image = nil
            self.deleteAvatar()
        })

        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
//        self.defaultImage = UIImage(named: "IG_New_Channel_Generic_Avatar")
        if self.avatarRoom.avatarImageView!.image != nil {
            optionMenu.addAction(removeAction)
        }
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == "DELETE_PHOTO".localizedNew{
                let removeColor = UIColor.red
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        optionMenu.view.tintColor = UIColor.organizationalColor()

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    /*
     * this method will be deleted main(latest) avatar
     */
    func deleteAvatar(){
        IGChannelAvatarDeleteRequest.Generator.generate(avatarId: (self.room?.channelRoom?.avatar?.id)!, roomId: (room?.channelRoom?.id)!).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let channelAvatarDeleteResponse as IGPChannelAvatarDeleteResponse :
                    IGChannelAvatarDeleteRequest.Handler.interpret(response: channelAvatarDeleteResponse)
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
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
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
        
        self.channelAvatarAttachment = IGFile(name: filename)
        self.channelAvatarAttachment.attachedImage = scaledImage
        self.channelAvatarAttachment.fileNameOnDisk = fileNameOnDisk
        self.channelAvatarAttachment.height = Double((scaledImage.size.height))
        self.channelAvatarAttachment.width = Double((scaledImage.size.width))
        self.channelAvatarAttachment.size = (imgData?.count)!
        self.channelAvatarAttachment.data = imgData
        self.channelAvatarAttachment.type = .image
        
        let path = IGFile.path(fileNameOnDisk: fileNameOnDisk)
        FileManager.default.createFile(atPath: path.path, contents: imgData!, attributes: nil)
        
        DispatchQueue.main.async {
            self.avatarRoom.avatarImageView!.image = scaledImage
            self.uploadImage()
        }
    }
    private func uploadImage() {
        SMLoading.showLoadingPage(viewcontroller: self)

        IGUploadManager.sharedManager.upload(file: self.channelAvatarAttachment, start: {
        }, progress: { (progress) in
        }, completion: { (uploadTask) in
            if let token = uploadTask.token {
                IGChannelAddAvatarRequest.Generator.generate(attachment: token , roomID: (self.room?.channelRoom!.id)!).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelAvatarAddResponse as IGPChannelAvatarAddResponse:
                            IGChannelAddAvatarRequest.Handler.interpret(response: channelAvatarAddResponse)
                            SMLoading.hideLoadingPage()
                        default:
                            break
                        }
                    }
                }).error({ (error, waitTime) in
                    SMLoading.hideLoadingPage()
                }).send()
            }
        }, failure: {
            SMLoading.hideLoadingPage()
        })
    }
    private func showAlertChangeChannelType() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let publicChannel = UIAlertAction(title: "PUBLIC".localizedNew, style: .default, handler: { (action) in
//            self.changedChannelTypeToPublic()
            self.tableView.beginUpdates()
            self.lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PUBLIC".localizedNew
            self.tfChannelLink.text = nil
            self.tfChannelLink.isEnabled = true
            self.convertToPublic = true
            
            self.tableView.endUpdates()
        })
        
        let privateChannel = UIAlertAction(title: "PRIVATE".localizedNew, style: .default, handler: { (action) in
            self.tableView.beginUpdates()
            self.lblChannelType.text = "CHANNELTYPE".localizedNew + "  " + "PRIVATE".localizedNew
            self.tfChannelLink.isEnabled = false
            self.convertToPublic = false
            
            self.tableView.endUpdates()
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
        
        alertController.addAction(publicChannel)
        alertController.addAction(privateChannel)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        return
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 1 :
            return 2
        default :
            return 1
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
            return 52
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChannelInfoSetName" {
             let destination = segue.destination as! IGChannelInfoEditNameTableViewController
                destination.room = room
        }
        if  segue.identifier == "showChannelInfoSetDescription" {
            let destination = segue.destination as! IGChannelInfoEditDescriptionTableViewController
            destination.room = room
        }
        
        if segue.identifier ==  "showChannelInfoSetType" {
            let destination = segue.destination as! IGChannelInfoEditTypeTableViewController
            destination.room = room
        }
        if segue.identifier == "showChannelInfoSetMembers" {
            let destination = segue.destination as! IGChannelInfoMemberListTableViewController
            destination.room = room
        }
        if segue.identifier == "showSharedMadiaPage" {
            let destination = segue.destination as! IGGroupSharedMediaListTableViewController
            destination.room = room
        }
        if segue.identifier == "showAdminAndModarators" {
            let destination = segue.destination as! IGChannelInfoAdminsAndModeratorsTableViewController
            destination.room = room
        }
    }

    //MARK: -Header and Footer
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedNewDirection
        switch section {
        default :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        containerFooterView.textLabel?.textAlignment = containerFooterView.textLabel!.localizedNewDirection
        containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15,weight: .light)

        switch section {

        case 2 :
            containerFooterView.textLabel?.text = "CHANNEL_SIGN_FOOTER".localizedNew
        case 3 :
            containerFooterView.textLabel?.text = "CHANNEL_REACTIONS_FOOTER".localizedNew
        default :
            break
            
        }

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      

        switch section {
        case 0:
            return ""
        case 1:
            return "CHANNEL_INFO".localizedNew
        case 2:
            return "CHANNELSIGNMESSAGES".localizedNew
        case 3:
            return "CHANNELREACTION".localizedNew
        default:
            return ""
        }
        
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return ""
        case 1:
            return ""
        case 2:
            return "CHANNEL_SIGN_FOOTER".localizedNew
        case 3:
            return "CHANNEL_REACTIONS_FOOTER".localizedNew
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    

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
    
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        switch section {
        case 2:
            return 50
        case 3:
            return 50
        default:
            return 10
        }
        
    }
    
    // MARK: - Textfield Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        //check value of textfield name for changes
        if textField == tfNameOfRoom {
            if textField.text != tmpOldName {
//                self.changeChanellName()
            }
        }
        //check value of textfield description for changes
        if textField == tfDescriptionOfRoom {
            if textField.text != tmpOldDesc {
//                changeChannelDescription()
            }
        }
        if textField == tfChannelLink {
            if room?.channelRoom?.type == .publicRoom || self.convertToPublic == true {
                if textField.text != tmpOldUserName {
//                    if textField.text!.count >= 5 {
//                        self.checkUsername(username: textField.text!)
//                    }
                    
                }
            } else {

            }
        }
        
    }

}

extension IGEditProfileChannelAndGroupTableViewCOntrollerTableViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: {
            self.manageImage(imageInfo: convertFromUIImagePickerControllerInfoKeyDictionary(info))
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
extension IGEditProfileChannelAndGroupTableViewCOntrollerTableViewController: UINavigationControllerDelegate {}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
