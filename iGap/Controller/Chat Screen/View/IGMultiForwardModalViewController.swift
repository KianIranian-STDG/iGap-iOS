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
import SwiftEventBus

class IGMultiForwardModalViewController: UIViewController, UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate{
    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var keyboardHeightSize : CGFloat!
    var MinesHeightSize : CGFloat! = 150.0
    var rooms: Results<IGRoom>? = nil
    var contacts: Results<IGRegisteredUser>? = nil
    var currentUser: IGRegisteredUser!
    var isSearching : Bool!
    var forwardItem: [IGForwardStruct] = []
    var filteredForwardItem: [IGForwardStruct] = []
    var selectedItems : [IGForwardStruct] = []
    let cellIdentifier = "cellIdentifier"
    var isInsearchMode : Bool! = false
    var selectedMessages : [IGRoomMessage] = []
    var isFromCloud : Bool = false
    @IBOutlet weak var lblInfo : UILabel!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnSendHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSearch: UIButton!
    

    
    @IBAction func btnSearchTap(_ sender: Any) {
        if isInsearchMode {
            UIView.transition(with: self.searchBar, duration: 0.2, options: .transitionFlipFromTop, animations: {
                self.searchBar.isHidden = true
                self.stackHeightConstraint.constant = 56
                self.collectionHeightConstraint.constant = deviceSizeModel.getShareModalSize() - self.btnSendHeightConstraint.constant - self.stackHeightConstraint.constant

                self.view.layoutIfNeeded()
            }, completion: nil)

        } else {
            UIView.transition(with: self.searchBar, duration: 0.2, options: .transitionFlipFromTop, animations: {
                self.searchBar.isHidden = false
                self.stackHeightConstraint.constant = 112
                self.collectionHeightConstraint.constant = deviceSizeModel.getShareModalSize() - self.btnSendHeightConstraint.constant - self.stackHeightConstraint.constant

                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        isInsearchMode = !isInsearchMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(UIDevice.current.hasNotch) {
            self.btnSendHeightConstraint.constant = 88
        } else {
            self.btnSendHeightConstraint.constant = 48
        }
        self.collectionHeightConstraint.constant = deviceSizeModel.getShareModalSize() - self.btnSendHeightConstraint.constant - self.stackHeightConstraint.constant

        searchBar.delegate = self
        let predicateChats = NSPredicate(format: "(typeRaw == 0 AND isParticipant == true) OR (typeRaw == 1 AND isParticipant == true) OR (typeRaw == 2 AND isParticipant == true AND (channelRoom.roleRaw == 1 OR channelRoom.roleRaw == 2 OR channelRoom.roleRaw == 3))")
        let predicateContacts = NSPredicate(format: "isInContacts == 1")
        let sortPropertiesChats = [SortDescriptor(keyPath: "priority", ascending: false), SortDescriptor(keyPath: "pinId", ascending: false), SortDescriptor(keyPath: "sortimgTimestamp", ascending: false)]

        self.rooms = try! Realm().objects(IGRoom.self).filter(predicateChats).sorted(by: sortPropertiesChats)
        self.contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicateContacts)

        for room in self.rooms! {
            forwardItem.append(IGForwardStruct(room))
        }
        
        /* add contact into the "muliShareContacts" array if didn't exist in room list */
        for user in self.contacts! {
            if !(forwardItem.contains(where: { $0.id == user.id })) {
                forwardItem.append(IGForwardStruct(user))
            }
        }
        
        filteredForwardItem = forwardItem

        showAccountDetail()
        addDoneButtonOnKeyboard()
        manageView()
        
        self.usersCollectionView.register(UINib(nibName:"multiForwardShareUsers", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        initTheme()

    }
    @IBAction func didTapOnSendButton(_ sender: UIButton) {
        
        SwiftEventBus.post(EventBusManager.sendForwardReq)
        self.dismiss(animated: true, completion: {
            IGHelperForward.handleForward(messages: self.selectedMessages, forwardModal: self, controller: UIApplication.topViewController(), isFromCloud: self.isFromCloud)
        })

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            keyboardHeightSize = keyboardHeight
        }

        isKeyboardPresented = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        keyboardHeightSize = 0.0
        isKeyboardPresented = false
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    private func initTheme() {
        self.usersCollectionView.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.lblInfo.textColor = ThemeManager.currentTheme.LabelColor
        self.btnSend.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnSearch.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
            textField.font = UIFont.igFont(ofSize: 13)
            textField.textColor = ThemeManager.currentTheme.LabelColor
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = ThemeManager.currentTheme.BackGroundColor
                for view in backgroundview.subviews {
                    view.backgroundColor = .clear
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"

        if currentTheme == "IGAPDay" {
            
            if currentColorSetLight == "IGAPBlack" {
                
                self.lblCount.textColor = .white
                self.lblCount.backgroundColor = ThemeManager.currentTheme.SliderTintColor

                
            } else {
                
                self.lblCount.textColor = ThemeManager.currentTheme.LabelColor
                self.lblCount.backgroundColor = ThemeManager.currentTheme.SliderTintColor
                self.lblCount.layer.borderColor = UIColor.white.cgColor
                self.lblCount.layer.borderWidth = 1.0

            }

        } else {
            self.lblCount.textColor = ThemeManager.currentTheme.LabelColor
            self.lblCount.backgroundColor = ThemeManager.currentTheme.SliderTintColor
            self.lblCount.layer.borderColor = UIColor.white.cgColor
            self.lblCount.layer.borderWidth = 1.0

        }
        self.view.backgroundColor = ThemeManager.currentTheme.BackGroundColor
    }

    private func manageView(){
//        self.view.frame.size.height = deviceSizeModel.getShareModalSize()
        self.lblCount.font = UIFont.igFont(ofSize: 14,weight: .bold)
//        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.btnSend.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.stackHeightConstraint.constant = 56
        
        let shareToText  = IGStringsManager.Shareto.rawValue.localized
        let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
        let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
        let normalText = "\n" + IGStringsManager.SelectChat.rawValue.localized
        let normalString = NSMutableAttributedString(string:normalText)
        attributedString.append(normalString)
        lblInfo.attributedText = attributedString
        lblCount.layer.cornerRadius = 10.0
        lblCount.layer.masksToBounds = true
        self.lblCount.layoutIfNeeded()
    }

    private func showAccountDetail(){
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        currentUser = realm.objects(IGRegisteredUser.self).filter(predicate).first!
        
        if let index = filteredForwardItem.firstIndex(where: { $0.displayName == currentUser.displayName }) {
            var element = filteredForwardItem[index]
            element.displayName = IGStringsManager.Cloud.rawValue.localized
            filteredForwardItem.remove(at: index)
            filteredForwardItem.insert(element, at: 1)
        }
    }

    private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: IGStringsManager.GlobalDone.rawValue.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        searchBar.inputAccessoryView = doneToolbar
    }
    
    private func selectionAnimate(cell: ForwardCell, state: CheckItem){
        
        var borderWidth: CGFloat!
        var hide: Bool!
        
        if state == .CHECK {
            hide = true
            borderWidth = 0
        } else if state == .UNCHECK {
            hide = false
            borderWidth = 2
        }
        
        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
            cell.btnCheckMark.isHidden = hide
            cell.viewHolder.layer.borderWidth = borderWidth
            self.lblCount.isHidden = false
            
            UIView.animate(withDuration: 0.5, animations: {
                cell.imgUser.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { (finished) in
                UIView.animate(withDuration: 0.5, animations: {
                    cell.imgUser.transform = CGAffineTransform.identity
                })
            }
        }, completion: nil)
    }
    
    @objc func doneButtonAction(){
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    
    /*************************************************************************************************/
    /*************************************** Overrided Methods ***************************************/
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty == false {
            isSearching = true
            filteredForwardItem = forwardItem
            filteredForwardItem = forwardItem.filter({ ($0.displayName.lowercased().contains(searchText.lowercased())) })
        } else {
            filteredForwardItem = forwardItem
            isSearching = false
        }
        usersCollectionView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    /*************************************************************************************************/
    /**************************************** Collection View ****************************************/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredForwardItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ForwardCell
        cell.backgroundColor = UIColor.clear
        cell.lblName.text = filteredForwardItem[indexPath.item].displayName
        cell.setImage(avatar: filteredForwardItem[indexPath.item].avatar, initials: filteredForwardItem[indexPath.item].initials, color: filteredForwardItem[indexPath.item].color)
        
        if selectedItems.count > 0 {
            let selectedBefore = self.selectedItems.filter{$0.id == filteredForwardItem[indexPath.item].id}.count > 0
            if selectedBefore {
                selectionAnimate(cell: cell, state: .UNCHECK)
            } else {
                selectionAnimate(cell: cell, state: .CHECK)
            }
        } else {
            cell.btnCheckMark.isHidden = true
            cell.viewHolder.layer.borderWidth = 0.0
            self.lblCount.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectItem = filteredForwardItem[indexPath.item]
        if let index = self.selectedItems.firstIndex(where: { $0.id == selectItem.id }) {
            self.selectedItems.remove(at: index)
        } else {
            self.selectedItems.append(selectItem)
        }
        
        self.usersCollectionView.reloadItems(at: [indexPath])
        lblCount.text = String(self.selectedItems.count).inPersianNumbersNew()
        if selectedItems.count > 0 {
            let shareToText  = IGStringsManager.Shareto.rawValue.localized
            let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
            let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
            var normalText = "\n"

            for selectItem in selectedItems {
                normalText = "\n" + selectItem.displayName + " , "
                let normalString = NSMutableAttributedString(string:normalText)
                attributedString.append(normalString)
                lblInfo.attributedText = attributedString
            }
        } else {
            let shareToText  = IGStringsManager.Shareto.rawValue.localized
            let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
            let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
            
            let normalText = "\n" + IGStringsManager.SelectChat.rawValue.localized
            let normalString = NSMutableAttributedString(string:normalText)
            attributedString.append(normalString)
            lblInfo.attributedText = attributedString
        }
    }
}

extension IGMultiForwardModalViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func panModalDidDismiss() {
        SwiftEventBus.post(EventBusManager.sendForwardReq)

    }
    
    

    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(deviceSizeModel.getShareModalSize())
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            self.collectionHeightConstraint.constant = UIScreen.main.bounds.size.height - keyboardHeightSize - self.stackHeightConstraint.constant - MinesHeightSize
            if UIDevice.current.hasNotch {
                return .contentHeight(deviceSizeModel.getShareModalSize() + keyboardHeightSize - 50.0)

            } else {
                return .contentHeight(deviceSizeModel.getShareModalSize() + keyboardHeightSize)

            }
        } else {
            self.collectionHeightConstraint.constant = deviceSizeModel.getShareModalSize() - self.btnSendHeightConstraint.constant - self.stackHeightConstraint.constant

            return .contentHeight(deviceSizeModel.getShareModalSize())
        }

    }
    var anchorModalToLongForm: Bool {
        return false
    }


    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    
}
