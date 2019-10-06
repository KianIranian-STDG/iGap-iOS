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
import RealmSwift
import IGProtoBuff
import MBProgressHUD

class IGCreateNewChannelTableViewController: BaseTableViewController {

    @IBOutlet weak var channelAvatarImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var channelnameTextField: UITextField!
    @IBOutlet weak var lblFooter: UILabel!
    @IBOutlet weak var changeImageBtn: UIButton!

    var channelAvatarAttachment: IGFile!
    var imagePicker = UIImagePickerController()
    let borderName = CALayer()
    let borderDesc = CALayer()
    let width = CGFloat(0.8)
    var invitedLink : String?
    var igpRoom : IGPRoom!
    let borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)!
    var hud = MBProgressHUD()
    var defaultImage = UIImage() //UIImage(named: "IG_New_Channel_Generic_Avatar")

    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder()
        channelAvatarImage.isUserInteractionEnabled = false
        initNavigationBar()
        lblFooter.text = "MSG_NEW_CHANNEL_FOOTER".localizedNew
        lblFooter.textAlignment = lblFooter.localizedNewDirection
        lblFooter.font = UIFont.igFont(ofSize: 13)
        
        changeImageBtn.layer.cornerRadius = changeImageBtn.frame.height / 2
        changeImageBtn.clipsToBounds = true
        
//        changeImageBtn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        changeImageBtn.layer.borderWidth = 0.3
        
        self.tableView.semanticContentAttribute = self.semantic
        self.view.semanticContentAttribute = self.semantic
        self.tableView.tableHeaderView?.semanticContentAttribute = self.semantic
        
        descriptionTextField.textAlignment = self.TextAlignment
        channelnameTextField.textAlignment = self.TextAlignment
        
//        navigationItem.addModalViewItems(leftItemText: "CANCEL_BTN".localizedNew, rightItemText: "NEXT_BTN".localizedNew, title: "NEW_CHANNEL".localizedNew)
//        navigationItem.leftViewContainer?.addAction {
//            self.navigationController?.popToRootViewController(animated: true)
//        }
    }
    private func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: "NEXT_BTN".localizedNew, title: "NEW_CHANNEL".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
        navigationItem.rightViewContainer?.addAction {
            if self.channelnameTextField.text?.isEmpty == true {
                let alert = UIAlertController(title: "BTN_HINT".localizedNew, message: "MSG_WRITE_YOUR_CHANNEL_NAME".localizedNew, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "GLOBAL_OK".localizedNew, style: UIAlertAction.Style.default, handler: nil))
                alert.view.tintColor = UIColor.organizationalColor()
                self.present(alert, animated: true, completion: nil)
            }else{
                self.createChannel()
            }
        }
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navigationControllerr = self.navigationController as! IGNavigationController
        
        navigationControllerr.navigationBar.isHidden = false
//        navigationItem.searchController = nil

        descriptionTextField.placeholder = "PRODUCTS_DETAILS".localizedNew
        channelnameTextField.placeholder = "CHANNEL_NAME".localizedNew
    }
    
    func addBottomBorder(){
        borderName.borderColor = borderColor.cgColor
        borderName.frame = CGRect(x: 0, y: channelnameTextField.frame.size.height - width, width:  channelnameTextField.frame.size.width, height: channelnameTextField.frame.size.height)
        borderName.borderWidth = width

        borderDesc.borderColor = borderColor.cgColor
        borderDesc.frame = CGRect(x: 0, y: descriptionTextField.frame.size.height - width, width:  descriptionTextField.frame.size.width, height: descriptionTextField.frame.size.height)
        borderDesc.borderWidth = width

        channelnameTextField.layer.addSublayer(borderName)
        channelnameTextField.layer.masksToBounds = true
        descriptionTextField.layer.addSublayer(borderDesc)
        descriptionTextField.layer.masksToBounds = true
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
            self.channelAvatarImage.image = scaledImage
        }
    }
    
    func createChannel() {
        self.view.endEditing(true)
        if let roomName = self.channelnameTextField.text {
            if roomName != "" {
                
                self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.hud.mode = .indeterminate
                
                let roomDescription = self.descriptionTextField.text
                IGChannelCreateRequest.Generator.generate(name: roomName, description: roomDescription).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        switch protoResponse {
                        case let channelCreateRespone as IGPChannelCreateResponse :
                            IGClientGetRoomRequest.Generator.generate(roomId: channelCreateRespone.igpRoomID).success({ (protoResponse) in
                                DispatchQueue.main.async {
                                    self.invitedLink = IGChannelCreateRequest.Handler.interpret(response: channelCreateRespone)
                                    
                                    switch protoResponse {
                                    case let getRoomProtoResponse as IGPClientGetRoomResponse:
                                        
                                        if self.channelAvatarImage.image != self.defaultImage {
                                            IGUploadManager.sharedManager.upload(file: self.channelAvatarAttachment, start: {
                                            }, progress: { (progress) in
                                            }, completion: { (uploadTask) in
                                                if let token = uploadTask.token {
                                                    IGChannelAddAvatarRequest.Generator.generate(attachment: token , roomID: getRoomProtoResponse.igpRoom.igpID).success({ (protoResponse) in
                                                        DispatchQueue.main.async {
                                                            switch protoResponse {
                                                            case let channelAvatarAddResponse as IGPChannelAvatarAddResponse:
                                                                IGChannelAddAvatarRequest.Handler.interpret(response: channelAvatarAddResponse)
                                                                self.hideProgress()
                                                                self.performSegue(withIdentifier: "GotoChooseTypeOfChannelToCreate", sender: self)
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
                                            IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                            self.igpRoom = getRoomProtoResponse.igpRoom
                                        } else {
                                            IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                            self.igpRoom = getRoomProtoResponse.igpRoom
                                            self.hideProgress()
                                            self.performSegue(withIdentifier: "GotoChooseTypeOfChannelToCreate", sender: self)
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
                    var errorTitle = ""
                    var errorBody = ""
                    switch errorCode {
                    case .channelCreatLimitReached :
                        errorTitle = "Error"
                        errorBody = "You are restricted to create more rooms"
                        break
                    case .timeout:
                        errorTitle = "Timeout"
                        errorBody = "Please try again later."
                        break
                    default:
                        errorTitle = "Unknown error"
                        errorBody = "An error occured. Please try again later.\nCode \(errorCode)"
                        break
                    }
                    if waitTime != nil &&  waitTime != 0 {
                        errorBody += "\nPlease try again in \(waitTime!) seconds."
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: errorTitle, message: errorBody, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }

                }).send()
                
                
            }
        }
    }

    func hideProgress(){
        DispatchQueue.main.async {
            self.hud.hide(animated: true)
        }
    }
    
    @IBAction func didTapOnChangeImage() {
        choosePhotoActionSheet(sender : channelAvatarImage)
    }
    
    func roundUserImage(_ roundView:UIView){
        roundView.layer.borderWidth = 0
        roundView.layer.masksToBounds = true
        let borderUserImageColor = UIColor(named: themeColor.labelGrayColor.rawValue)!
        roundView.layer.borderColor = borderUserImageColor.cgColor
        roundView.layer.cornerRadius = roundView.frame.size.height/2
        roundView.clipsToBounds = true
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerView = view as! UITableViewHeaderFooterView
        if section == 0 {
                containerView.textLabel!.text = "MSG_CHANNEL_DESC".localizedNew
        }
        containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
        containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedNewDirection)!
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    func choosePhotoActionSheet(sender : UIImageView){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let cameraOption = UIAlertAction(title: "TAKE_A_PHOTO".localizedNew, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
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
            self.channelAvatarImage.image = self.defaultImage
        })

        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if self.channelAvatarImage.image != self.defaultImage || self.channelAvatarImage.image != nil {
            optionMenu.addAction(removeAction)
        }
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == "DELETE_PHOTO".localizedNew{
                let removeColor = UIColor.red
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        optionMenu.view.tintColor = UIColor(named: themeColor.labelGrayColor.rawValue)!

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
        }
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
        }
        self.present(optionMenu, animated: true, completion: nil)
    }


    @IBAction func nextButtonClicked(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! IGNewChannelChoosePublicOrPrivateTableViewController
        destinationVC.invitedLink = invitedLink
        destinationVC.igpRoom = igpRoom
    }
}
extension IGCreateNewChannelTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: {
            self.roundUserImage(self.channelAvatarImage)
            self.manageImage(imageInfo: convertFromUIImagePickerControllerInfoKeyDictionary(info))
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension IGCreateNewChannelTableViewController: UINavigationControllerDelegate {
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
