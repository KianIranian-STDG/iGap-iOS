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

class IGMultiForwardModal: UIView, UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate{
    
    var rooms: Results<IGRoom>? = nil
    var contacts: Results<IGRegisteredUser>? = nil
    var currentUser: IGRegisteredUser!
    var isSearching : Bool!
    var forwardItem: [IGForwardStruct] = []
    var filteredForwardItem: [IGForwardStruct] = []
    var selectedItems : [IGForwardStruct] = []
    let cellIdentifier = "cellIdentifier"

    @IBOutlet weak var lblInfo : UILabel!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnSearch: UIButton!
    
    class func loadFromNib() -> IGMultiForwardModal {
        return UINib(nibName: "IGMultiForwardModal", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! IGMultiForwardModal
    }
    
    @IBAction func btnSearchTap(_ sender: Any) {
        UIView.transition(with: self.searchBar, duration: 0.2, options: .transitionFlipFromTop, animations: {
            self.searchBar.isHidden = false
            self.stackHeightConstraint.constant = 96
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.delegate = self
        let predicateChats = NSPredicate(format: "isReadOnly == false AND isDeleted == false")
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
    }
    
    private func manageView(){
        self.frame.size.height = deviceSizeModel.getShareModalSize()
        self.lblCount.font = UIFont.igFont(ofSize: 14,weight: .bold)
        self.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.btnSend.roundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 20)
        self.stackHeightConstraint.constant = 39
        
        let shareToText  = "SHARE_TO".localizedNew
        let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
        let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
        let normalText = "\n" + "SELECT_CHATS".localizedNew
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
            element.displayName = "MY_CLOUD".localizedNew
            filteredForwardItem.remove(at: index)
            filteredForwardItem.insert(element, at: 1)
        }
    }

    private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "GLOBAL_DONE".localizedNew, style: .done, target: self, action: #selector(self.doneButtonAction))
        
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
            let shareToText  = "SHARE_TO".localizedNew
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
            let shareToText  = "SHARE_TO".localizedNew
            let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
            let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
            
            let normalText = "\n" + "SELECT_CHATS".localizedNew
            let normalString = NSMutableAttributedString(string:normalText)
            attributedString.append(normalString)
            lblInfo.attributedText = attributedString
        }
    }
}
