//
//  IGMultiForwardModal.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/18/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit
import RealmSwift

/// Input view to get only one input and button to confirm action

class IGMultiForwardModal: UIView, UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate{
   
    
    
    var rooms: Results<IGRoom>? = nil
    var contacts: Results<IGRegisteredUser>? = nil
    struct multiShareUsers {
        var typeRaw:  Int
        var displayName: String
        var id: Int64
        var avatar : IGAvatar? = nil
        var initials : String = ""
        var color : String = ""
        var selected : Bool = false
    }
    var isSearching : Bool!
    var muliShareContacts: [multiShareUsers] = []
    var FilteredMuliShareContacts: [multiShareUsers] = []


    @IBOutlet weak var lblInfo : UILabel!
    @IBOutlet weak var lblCount : UILabel!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    /// Title of view
    /// Load view from nib file
    ///
    /// - Returns: instance of SMSingleInputView loaded from nib file
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
        let predicateChats = NSPredicate(format: "isReadOnly == false&&isDeleted == false")
        let predicateContacts = NSPredicate(format: "isInContacts == 1")
        let sortPropertiesChats = [SortDescriptor(keyPath: "priority", ascending: false), SortDescriptor(keyPath: "pinId", ascending: false), SortDescriptor(keyPath: "sortimgTimestamp", ascending: false)]

        self.rooms = try! Realm().objects(IGRoom.self).filter(predicateChats).sorted(by: sortPropertiesChats)
        self.contacts = try! Realm().objects(IGRegisteredUser.self).filter(predicateContacts)

        let tmpChats = self.rooms
        let tmpContacts = self.contacts
        for element in tmpChats! {
            if element.typeRaw == 0 {
                muliShareContacts.append(multiShareUsers(typeRaw: element.typeRaw, displayName: element.title!, id: (element.chatRoom?.peer?.id)!, avatar: element.chatRoom?.peer?.avatar, initials: element.initilas ?? "", color: element.colorString, selected: false))

            }
            else {
                muliShareContacts.append(multiShareUsers(typeRaw: element.typeRaw, displayName: element.title!, id: element.id, avatar: element.chatRoom?.peer?.avatar, initials: element.initilas ?? "", color: element.colorString, selected: false))

            }

        }
        for element in tmpContacts! {
            if !(muliShareContacts.contains(where: { $0.id == element.id })) {
                
                muliShareContacts.append(multiShareUsers(typeRaw: 0, displayName: element.displayName, id: element.id, avatar: element.avatar, initials: element.initials, color: element.color, selected: false))

            }
        }
        FilteredMuliShareContacts = muliShareContacts

        showAccountDetail()

        print("===================")
        print(FilteredMuliShareContacts)

        

        self.lblCount.font = UIFont.igFont(ofSize: 14,weight: .bold)
        addDoneButtonOnKeyboard()
        self.usersCollectionView.register(UINib(nibName:"multiForwardShareUsers", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)

        self.frame.size.height = deviceSizeModel.getShareModalSize()
            
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
    var currentUser: IGRegisteredUser!

    func showAccountDetail(){
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        currentUser = realm.objects(IGRegisteredUser.self).filter(predicate).first!

            if let index = FilteredMuliShareContacts.firstIndex(where: { $0.displayName == currentUser.displayName }) {
                var element = FilteredMuliShareContacts[index]
                element.displayName = "MY_CLOUD".localizedNew
                FilteredMuliShareContacts.remove(at: index)
                FilteredMuliShareContacts.insert(element, at: 1)
            }
    }

    var selectedIndex : [Int64] = []
    var selectedNames : [String] = []
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilteredMuliShareContacts.count
    }
    let cellIdentifier = "cellIdentifier"
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! multiForwardShareUsers
        
        //in this example I added a label named "title" into the MyCollectionCell class
   
        cell.backgroundColor = UIColor.clear
        cell.lblName.text = FilteredMuliShareContacts[indexPath.item].displayName
//        print(muliShareContacts[indexPath.item].avatar!)

        cell.setImage(avatar: FilteredMuliShareContacts[indexPath.item].avatar, initials: FilteredMuliShareContacts[indexPath.item].initials, color: FilteredMuliShareContacts[indexPath.item].color)
        if selectedIndex.count > 0 {
            
            if self.selectedIndex.contains(FilteredMuliShareContacts[indexPath.item].id) {
                
                UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    
                    cell.btnCheckMark.isHidden = false
                    cell.viewHolder.layer.borderWidth = 2.0
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
            else {
                UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    
                    cell.btnCheckMark.isHidden = true
                    cell.viewHolder.layer.borderWidth = 0.0
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
        }
        else {
            cell.btnCheckMark.isHidden = true
            cell.viewHolder.layer.borderWidth = 0.0
            self.lblCount.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tmpID = (FilteredMuliShareContacts[indexPath.item].id)
        if selectedIndex.contains(tmpID) {
            let index = self.selectedIndex.firstIndex(of: tmpID)!
            self.selectedIndex.remove(at: index)
            self.selectedNames.remove(at: index)
        } else {
            self.selectedIndex.append(tmpID)
            self.selectedNames.append(FilteredMuliShareContacts[indexPath.item].displayName)
        }

        self.usersCollectionView.reloadItems(at: [indexPath])
        lblCount.text = String(self.selectedIndex.count).inPersianNumbers()
        if selectedNames.count > 0 {
            let shareToText  = "SHARE_TO".localizedNew
            let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
            let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
            var normalText = "\n"

            for element in selectedNames {
                normalText = "\n" + element + " , "

                let normalString = NSMutableAttributedString(string:normalText)
                attributedString.append(normalString)
                lblInfo.attributedText = attributedString

            }
        }
        else {
            let shareToText  = "SHARE_TO".localizedNew
            let attrs = [NSAttributedString.Key.font : UIFont.igFont(ofSize: 18 , weight: .bold)]
            let attributedString = NSMutableAttributedString(string:shareToText, attributes:attrs)
            
            let normalText = "\n" + "SELECT_CHATS".localizedNew
            let normalString = NSMutableAttributedString(string:normalText)
            attributedString.append(normalString)
            lblInfo.attributedText = attributedString
        }
        



        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        FilteredMuliShareContacts.removeAll()
        
        if searchText.isEmpty == false {
            isSearching = true
            FilteredMuliShareContacts = muliShareContacts
                FilteredMuliShareContacts = muliShareContacts.filter({ ($0.displayName.lowercased().contains(searchText.lowercased())) })
        }
        else {
            FilteredMuliShareContacts = muliShareContacts

            isSearching = false
        }


        let tmp = FilteredMuliShareContacts
        usersCollectionView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != self {
//            inputTF.endEditing(true)
        }
    }
    /// Layout subview after loading view to support autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "GLOBAL_DONE".localizedNew, style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        searchBar.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        searchBar.resignFirstResponder()
        searchBar.endEditing(true)
    }
    /// Method of UITextFieldDelegate
    ///
    /// - Parameter textField: selected TextField
    /// - Returns: dismiss keyboard by selecting return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
}
