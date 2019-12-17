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
import YPImagePicker

class IGCreateNewChannelTableViewController: BaseTableViewController {

    @IBOutlet weak var channelAvatarImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var channelnameTextField: UITextField!
    @IBOutlet weak var lblFooter: UILabel!
    @IBOutlet weak var changeImageBtn: UIButton!

    var channelAvatarAttachment: IGFile!
    let borderName = CALayer()
    let borderDesc = CALayer()
    let width = CGFloat(0.8)
    var invitedLink : String?
    var igpRoom : IGPRoom!
    let borderColor = ThemeManager.currentTheme.LabelGrayColor
    var defaultImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomBorder()
        initNavigationBar()
        
        channelAvatarImage.isUserInteractionEnabled = false
        lblFooter.text = IGStringsManager.NewChannelHint.rawValue.localized
        lblFooter.textAlignment = lblFooter.localizedDirection
        lblFooter.font = UIFont.igFont(ofSize: 13)
        changeImageBtn.layer.cornerRadius = changeImageBtn.frame.height / 2
        changeImageBtn.clipsToBounds = true
        self.tableView.semanticContentAttribute = self.semantic
        self.view.semanticContentAttribute = self.semantic
        self.tableView.tableHeaderView?.semanticContentAttribute = self.semantic
        descriptionTextField.textAlignment = self.TextAlignment
        channelnameTextField.textAlignment = self.TextAlignment
        initTheme()
    }
    private func initTheme() {
        lblFooter.textColor = ThemeManager.currentTheme.LabelColor
        descriptionTextField.textColor = ThemeManager.currentTheme.LabelColor
        channelnameTextField.textColor = ThemeManager.currentTheme.LabelColor
        descriptionTextField.placeHolderColor = ThemeManager.currentTheme.LabelColor
        channelnameTextField.placeHolderColor = ThemeManager.currentTheme.LabelColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          let navigationControllerr = self.navigationController as! IGNavigationController
          navigationControllerr.navigationBar.isHidden = false

          descriptionTextField.placeholder = IGStringsManager.Desc.rawValue.localized
          channelnameTextField.placeholder = IGStringsManager.ChannelName.rawValue.localized
      }
    
    private func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: IGStringsManager.GlobalNext.rawValue.localized, title: IGStringsManager.NewChannel.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
        navigationItem.rightViewContainer?.addAction {
            if self.channelnameTextField.text?.isEmpty == true {
                let alert = UIAlertController(title: IGStringsManager.GlobalHint.rawValue.localized, message: IGStringsManager.MsgEnterChannelName.rawValue.localized, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: UIAlertAction.Style.default, handler: nil))
                alert.view.tintColor = UIColor.organizationalColor()
                self.present(alert, animated: true, completion: nil)
            } else {
                self.createChannel()
            }
        }
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
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
    
    func createChannel() {
        self.view.endEditing(true)
        if let roomName = self.channelnameTextField.text {
            if roomName != "" {
                IGGlobal.prgShow()
                let roomDescription = self.descriptionTextField.text
                IGChannelCreateRequest.Generator.generate(name: roomName, description: roomDescription).success({ (protoResponse) in
                    if let channelCreateRespone = protoResponse as? IGPChannelCreateResponse {
                        IGClientGetRoomRequest.Generator.generate(roomId: channelCreateRespone.igpRoomID).success({ (protoResponse) in
                            DispatchQueue.main.async {
                                self.invitedLink = IGChannelCreateRequest.Handler.interpret(response: channelCreateRespone)
                                if let getRoomProtoResponse = protoResponse as? IGPClientGetRoomResponse {
                                    if self.channelAvatarImage.image != nil, self.channelAvatarImage.image != self.defaultImage {
                                        IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                        self.igpRoom = getRoomProtoResponse.igpRoom
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            IGHelperAvatar.shared.upload(roomId: getRoomProtoResponse.igpRoom.igpID, type: .channel, file: self.channelAvatarAttachment) { (file) in
                                                DispatchQueue.main.async {
                                                    self.performSegue(withIdentifier: "GotoChooseTypeOfChannelToCreate", sender: self)
                                                }
                                            }
                                        }
                                    } else {
                                        IGClientGetRoomRequest.Handler.interpret(response: getRoomProtoResponse)
                                        self.igpRoom = getRoomProtoResponse.igpRoom
                                        IGGlobal.prgHide()
                                        self.performSegue(withIdentifier: "GotoChooseTypeOfChannelToCreate", sender: self)
                                    }
                                }
                            }
                        }).error({ (errorCode, waitTime) in
                            IGGlobal.prgHide()
                        }).send()
                    }
                }).error({ (errorCode, waitTime) in
                    
                    IGGlobal.prgHide()
                    var errorBody = ""
                    switch errorCode {
                    case .channelCreatLimitReached :
                        errorBody = IGStringsManager.RestrictionCreatRoom.rawValue.localized
                        break
                    case .timeout:
                        errorBody = IGStringsManager.GlobalTimeOut.rawValue.localized
                        break
                    default:
                        errorBody = IGStringsManager.GlobalTryAgain.rawValue.localized
                        break
                    }
                    if waitTime != nil && waitTime != 0 {
                        errorBody += IGStringsManager.GlobalTryAgain.rawValue.localized + "\n" + "\(waitTime ?? 0)"
                    }
                    DispatchQueue.main.async {
                        IGGlobal.prgHide()
                        IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: errorBody, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
                    }

                }).send()
            }
        }
    }

    @IBAction func didTapOnChangeImage() {
        choosePhotoActionSheet(sender : channelAvatarImage)
    }
    
    func roundUserImage(_ roundView:UIView){
        roundView.layer.borderWidth = 0
        roundView.layer.masksToBounds = true
        let borderUserImageColor = ThemeManager.currentTheme.LabelGrayColor
        roundView.layer.borderColor = borderUserImageColor.cgColor
        roundView.layer.cornerRadius = roundView.frame.size.height/2
        roundView.clipsToBounds = true
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerView = view as! UITableViewHeaderFooterView
        if section == 0 {
            containerView.textLabel!.text = IGStringsManager.ChannelDesc.rawValue.localized
        }
        containerView.textLabel?.font = UIFont.igFont(ofSize: 15)
        containerView.textLabel?.textAlignment = (containerView.textLabel?.localizedDirection)!
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    func choosePhotoActionSheet(sender : UIImageView){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let cameraOption = UIAlertAction(title: IGStringsManager.Camera.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.photo])
        })
        
        let ChoosePhoto = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.pickImage(screens: [.library])
        })
       
        let cancelAction = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        let removeAction = UIAlertAction(title: IGStringsManager.DeletePhoto.rawValue.localized, style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.channelAvatarImage.image = self.defaultImage
        })

        optionMenu.addAction(ChoosePhoto)
        optionMenu.addAction(cancelAction)
        if self.channelAvatarImage.image != self.defaultImage || self.channelAvatarImage.image != nil {
            optionMenu.addAction(removeAction)
        }
        let alertActions = optionMenu.actions
        for action in alertActions {
            if action.title == IGStringsManager.DeletePhoto.rawValue.localized{
                let removeColor = UIColor.red
                action.setValue(removeColor, forKey: "titleTextColor")
            }
        }
        optionMenu.view.tintColor = ThemeManager.currentTheme.LabelGrayColor

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
            optionMenu.addAction(cameraOption)} else {
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
                    self.channelAvatarAttachment = IGHelperAvatar.shared.makeAvatarFile(photo: imageInfo)
                    var image = imageInfo.originalImage
                    if let modifiedImage = imageInfo.modifiedImage {
                        image = modifiedImage
                    }
                    self.channelAvatarImage.image = image
                    self.roundUserImage(self.channelAvatarImage)
                }
            }
        }
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
        destinationVC.hidesBottomBarWhenPushed = true
    }
}
