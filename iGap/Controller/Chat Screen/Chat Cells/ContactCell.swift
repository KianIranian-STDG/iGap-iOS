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
import SnapKit

class ContactCell: AbstractCell {
    
    @IBOutlet var mainBubbleView: UIView!
    @IBOutlet weak var mainBubbleViewWidth: NSLayoutConstraint!
    @IBOutlet weak var mainBubbleViewHeight: NSLayoutConstraint!
    
    var contactTop: Constraint!
    
    var nameLabel: UILabel?
    var phonesLabel: UILabel?
    var emailsLabel: UILabel?
    var avatarImageView: UIImageView?
    var phoneIconLbl: UILabel?
    var emailIconLbl: UILabel?
    var btnAddContact: UIButton!
    var btnCall: UIButton!
    
    class func nib() -> UINib {
        return UINib(nibName: "ContactCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    class func getContactHeight(_ contact: IGRoomMessageContact) -> CGFloat {
        let numberOfInfos = contact.emails.count + contact.phones.count
        let height = numberOfInfos * 15
        return CGFloat(height)
    }
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        initializeView()
        super.setMessage(message, room: room, isIncommingMessage: isIncommingMessage, shouldShowAvatar: shouldShowAvatar, messageSizes: messageSizes, isPreviousMessageFromSameSender: isPreviousMessageFromSameSender, isNextMessageFromSameSender: isNextMessageFromSameSender)
        makeContact()
        setContact()
        manageContacgtGustureRecognizers()
    }
    
    private func initializeView(){
        /********** view **********/
        mainBubbleViewAbs = mainBubbleView
        mainBubbleViewWidthAbs = mainBubbleViewWidth
        mainBubbleViewHeightAbs = mainBubbleViewHeight
    }
    
    private func hasEmail() -> Bool{
        return (finalRoomMessage.contact?.emails.count)! > 0
    }
    
    private func setContact(){
        //TODO - fix "Realm access from incorrect thread" and use from following code instead fetch room message from realm again
        //let contact: IGRoomMessageContact = finalRoomMessage.contact!
        let predicate = NSPredicate(format: "primaryKeyId = %@", finalRoomMessage.primaryKeyId!)
        guard let contact: IGRoomMessageContact = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first?.contact else {
            return
        }
        
        if isIncommingMessage {
            if hasEmail() {
                addEmailView()
                emailIconLbl?.text = "🖂"
                emailIconLbl?.textColor = UIColor(named: themeColor.messageTextColor.rawValue)
                emailsLabel?.textColor = UIColor.dialogueBoxInfo()
            } else {
                removeEmailView()
            }
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Incomming")
            phoneIconLbl?.text = ""
            nameLabel?.textColor = UIColor.dialogueBoxInfo()
            phonesLabel?.textColor = UIColor.dialogueBoxInfo()
        } else {
            if hasEmail() {
                addEmailView()
                emailIconLbl?.text = "🖂"
                emailIconLbl?.textColor = UIColor(named: themeColor.messageTextColor.rawValue)
                emailsLabel?.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
            } else {
                removeEmailView()
            }
            avatarImageView?.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Outgoing")
            phoneIconLbl?.text = ""
            phoneIconLbl?.textColor = UIColor(named: themeColor.messageTextColor.rawValue)
            nameLabel?.textColor = UIColor.dialogueBoxInfo()
            phonesLabel?.textColor = UIColor.dialogueBoxInfo()
        }
        
        let firstName = contact.firstName == nil ? "" : contact.firstName! + " "
        let lastName = contact.lastName == nil ? "" : contact.lastName!
        self.nameLabel?.text = String(format: "%@%@", firstName, lastName)
        
        self.phonesLabel!.text = ""
        for phone in contact.phones {
            self.phonesLabel!.text = self.phonesLabel!.text! + phone.innerString + "\n"
        }
        
        if hasEmail() {
            self.emailsLabel!.text = ""
            for email in contact.emails {
                self.emailsLabel!.text = self.emailsLabel!.text! + email.innerString + "\n"
            }
        }
    }
    
    private func makeContact(){
        if avatarImageView == nil {
            avatarImageView = UIImageView()
            mainBubbleViewAbs.addSubview(avatarImageView!)
        }
        
        if nameLabel == nil {
            nameLabel = UILabel()
            nameLabel!.font = UIFont.igFont(ofSize: 14, weight: .medium)
            mainBubbleViewAbs.addSubview(nameLabel!)
        }
        
        if phonesLabel == nil {
            phonesLabel = UILabel()
            phonesLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
            phonesLabel!.numberOfLines = 0
            mainBubbleViewAbs.addSubview(phonesLabel!)
        }
        
        if phoneIconLbl == nil {
            phoneIconLbl = UILabel()
            phoneIconLbl!.textAlignment = .center
            phoneIconLbl!.font = UIFont.iGapFonticon(ofSize: 9)
            mainBubbleViewAbs.addSubview(phoneIconLbl!)
        }
        
        if btnAddContact == nil {
            btnAddContact = UIButton()
            btnAddContact.setTitle(IGStringsManager.AddContact.rawValue.localized, for: UIControl.State.normal)
            manageContactButtonView(btn: btnAddContact, color: UIColor.iGapBlue())
            mainBubbleViewAbs.addSubview(btnAddContact)
        }
        
        if btnCall == nil {
            btnCall = UIButton()
            btnCall.setTitle(IGStringsManager.CALL.rawValue.localized, for: UIControl.State.normal)
            manageContactButtonView(btn: btnCall, color: UIColor(named: themeColor.labelGrayColor.rawValue)!)
            mainBubbleViewAbs.addSubview(btnCall)
        }
        
        avatarImageView!.snp.makeConstraints { (make) in
            
            if contactTop != nil { contactTop.deactivate() }
            
            if isForward {
                contactTop = make.top.equalTo(forwardViewAbs.snp.bottom).offset(8.0).constraint
            } else if isReply {
                contactTop = make.top.equalTo(replyViewAbs.snp.bottom).offset(8.0).constraint
            } else {
                contactTop = make.top.equalTo(mainBubbleViewAbs.snp.top).offset(8.0).constraint
            }
            
            if contactTop != nil { contactTop.activate() }
            
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(12.0)
            make.width.equalTo(42.0)
            make.height.equalTo(42.0)
        }
        
        nameLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(avatarImageView!.snp.top)
        }
        
        phonesLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(22)
            make.top.equalTo(nameLabel!.snp.bottom).offset(2.0)
            make.right.equalTo(mainBubbleViewAbs.snp.right).offset(10)
        }
        
        phoneIconLbl!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(phonesLabel!.snp.top).offset(4.0)
            make.width.equalTo(9.0)
            make.height.equalTo(9.0)
        }
        
        btnAddContact.snp.makeConstraints { (make) in
            make.leading.equalTo(mainBubbleViewAbs.snp.leading).offset(5)
            make.bottom.equalTo(mainBubbleViewAbs.snp.bottom).offset(-30)
            make.height.equalTo(35)
            make.width.equalTo(140)
        }
        
        btnCall.snp.makeConstraints { (make) in
            make.leading.equalTo(btnAddContact.snp.trailing).offset(5)
            make.trailing.equalTo(mainBubbleViewAbs.snp.trailing).offset(-5)
            make.top.equalTo(btnAddContact.snp.top)
            make.bottom.equalTo(btnAddContact.snp.bottom)
        }
    }
    
    private func addEmailView() {
        if emailIconLbl == nil {
            emailIconLbl = UILabel()
            emailIconLbl!.textAlignment = .center
            emailIconLbl?.font = UIFont.iGapFonticon(ofSize: 9)
            mainBubbleViewAbs.addSubview(emailIconLbl!)
        }
        
        if emailsLabel == nil {
            emailsLabel = UILabel()
            emailsLabel!.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
            emailsLabel!.numberOfLines = 0
            mainBubbleViewAbs.addSubview(emailsLabel!)
        }
        
        emailIconLbl!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(10)
            make.top.equalTo(phonesLabel!.snp.bottom).offset(-10)
            make.width.equalTo(9.0)
            make.height.equalTo(9.0)
        }
        
        emailsLabel!.snp.makeConstraints { (make) in
            make.left.equalTo(avatarImageView!.snp.right).offset(22)
            make.top.equalTo(emailIconLbl!.snp.top).offset(-4.0)
            make.right.equalTo(mainBubbleViewAbs.snp.right).offset(10)
        }
    }
    
    private func removeEmailView(){
        if emailsLabel != nil {
            emailsLabel?.removeFromSuperview()
            emailsLabel = nil
        }
        
        if emailIconLbl != nil {
            emailIconLbl?.removeFromSuperview()
            emailIconLbl = nil
        }
    }
    
    private func manageContactButtonView(btn: UIButton, color: UIColor){
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = color.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 14, weight: .medium)
        btn.setTitleColor(color, for: .normal)
    }
    
    private func manageContacgtGustureRecognizers() {
        let btnCallGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnCall(_:)))
        btnCall?.addGestureRecognizer(btnCallGesture)
        
        let btnAddContactGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnAddContact(_:)))
        btnAddContact?.addGestureRecognizer(btnAddContactGesture)
    }
    
    private func startCall(number: String){
        let tel: String! = "tel://\(number.inEnglishNumbersNew().digits)"
        if let url = URL(string: tel!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func didTapOnCall(_ gestureRecognizer: UITapGestureRecognizer) {
        
        if !(IGGlobal.shouldMultiSelect) {
            if finalRoomMessage.contact!.phones.count == 1 {
                startCall(number: finalRoomMessage.contact!.phones.toArray().first!.innerString)
                return
            }
            
            let option = UIAlertController(title: IGStringsManager.CallQuestion.rawValue.localized, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
            
            for phone in finalRoomMessage.contact!.phones {
                let action = UIAlertAction(title: phone.innerString, style: .default, handler: { (action) in
                    self.startCall(number: action.title!)
                })
                option.addAction(action)
            }
            
            let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
            option.addAction(cancel)
            UIApplication.topViewController()!.present(option, animated: true, completion: {})
        }
    }
    
    @objc func didTapOnAddContact(_ gestureRecognizer: UITapGestureRecognizer) {
        if !(IGGlobal.shouldMultiSelect) {

            let option = UIAlertController(title: nil, message: IGStringsManager.AddContactsQuestion.rawValue.localized, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { (action) in
                var phones: [String] = []
                for phone in self.finalRoomMessage.contact!.phones {
                    phones.append(phone.innerString)
                }
                
                var emails: [String] = []
                for email in self.finalRoomMessage.contact!.emails {
                    emails.append(email.innerString)
                }
                
                var displayName = self.finalRoomMessage.contact!.firstName
                if let lastName = self.finalRoomMessage.contact!.lastName {
                    displayName = " " + lastName
                }
                
                IGContactManager.sharedManager.saveContactToDevicePhoneBook(name: displayName!, phoneNumber: phones, emailAddress: emails as [NSString])
            })
            option.addAction(ok)
            
            let cancel = UIAlertAction(title: IGStringsManager.GlobalNo.rawValue.localized, style: .cancel, handler: nil)
            option.addAction(cancel)
            
            UIApplication.topViewController()!.present(option, animated: true, completion: {})
        }
    }
}



