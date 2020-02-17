/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import AsyncDisplayKit
import SnapKit
import SwiftEventBus

class IGContactNode: AbstractNode {
    
    private var contact: IGRoomMessageContact!
    
    private var txtPhoneNumbers = ASTextNode()
    private var txtPhoneIcon = ASTextNode()
    private var txtContactName = ASTextNode()
    private var txtEmails = ASTextNode()
    private var txtEmailIcon = ASTextNode()
    private var imgCover = ASImageNode()
    private func hasEmail() -> Bool{
        return (message.contact?.emails.count)! > 0
    }
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()
        
        imgCover.style.preferredSize = CGSize(width: 40, height: 40)
        imgCover.layer.cornerRadius = 20
        imgCover.image = UIImage(named: "ig_default_contact")
        imgCover.imageModificationBlock = ASImageNodeTintColorModificationBlock((isIncomming ? ThemeManager.currentTheme.SliderTintColor : ThemeManager.currentTheme.SendMessageBubleBGColor.darker())!)
        IGGlobal.makeAsyncText(for: txtPhoneIcon, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtEmailIcon, with: "🖂", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        
        if self.isIncomming {
            btnViewContact.setTitle(IGStringsManager.ViewContact.rawValue.localized, with: UIFont.igFont(ofSize: 14, weight: .bold), with: ThemeManager.currentTheme.SliderTintColor, for: .normal)
            btnViewContact.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor

        } else {
            btnViewContact.setTitle(IGStringsManager.ViewContact.rawValue.localized, with: UIFont.igFont(ofSize: 14, weight: .bold), with: ThemeManager.currentTheme.SendMessageBubleBGColor.darker(), for: .normal)
            btnViewContact.layer.borderColor = ThemeManager.currentTheme.SendMessageBubleBGColor.darker()?.cgColor

        }
        btnViewContact.layer.cornerRadius = 10
        btnViewContact.layer.borderWidth = 1.0
        btnViewContact.backgroundColor = .clear
        btnViewContact.style.height = ASDimension(unit: .points, value: 40.0)
        addSubnode(txtContactName)
        addSubnode(txtPhoneNumbers)
        addSubnode(txtPhoneIcon)
        addSubnode(txtEmails)
        addSubnode(txtEmailIcon)
        addSubnode(imgCover)
        addSubnode(btnViewContact)
        
    }
    
    override func didLoad() {
        super.didLoad()
        getContactDetails()
        btnViewContact.addTarget(self, action:  #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)
        
    }
    
    //- Hint : Check tap on user profile
    @objc func handleUserTap() {
        print("DID TAP ON CONTACT SHOW")
        if let _contact = contact {
            SwiftEventBus.postToMainThread(EventBusManager.showContactDetail, userInfo: ["contactInfo": _contact])
        }
        
    }
    
    func getContactDetails() {
        DispatchQueue.main.async {[weak self] in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.message.contact  == nil {
                let predicate = NSPredicate(format: "primaryKeyId = %@", sSelf.message.primaryKeyId!)
                sSelf.contact = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first!.contact!
            } else {
                sSelf.contact = sSelf.message.contact!
            }
            
            let firstName = sSelf.contact.firstName == nil ? "" : sSelf.contact.firstName! + " "
            let lastName = sSelf.contact.lastName == nil ? "" : sSelf.contact.lastName!
            let name = String(format: "%@%@", firstName, lastName)
            if sSelf.isIncomming {
                
                IGGlobal.makeAsyncText(for: sSelf.txtContactName, with: name, textColor: ThemeManager.currentTheme.SliderTintColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            } else {
                
                IGGlobal.makeAsyncText(for: sSelf.txtContactName, with: name, textColor: ThemeManager.currentTheme.SendMessageBubleBGColor.darker()!, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
            if sSelf.contact.phones.count > 0 {
                let phoneNumber = sSelf.contact.phones.first!.innerString
                IGGlobal.makeAsyncText(for: sSelf.txtPhoneNumbers, with: phoneNumber, textColor: ThemeManager.currentTheme.LabelColor, size: 13, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                
            }
            
            
            if sSelf.hasEmail() {
                let emailAdd = sSelf.contact.emails.first!.innerString
                IGGlobal.makeAsyncText(for: sSelf.txtEmails, with: emailAdd, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
            }
        }
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let phonenumberBox = ASStackLayoutSpec.horizontal()
        phonenumberBox.spacing = 5
        phonenumberBox.children = [txtPhoneIcon, txtPhoneNumbers]
        phonenumberBox.verticalAlignment = .center
        
        let emailBox = ASStackLayoutSpec.horizontal()
        emailBox.spacing = 10
        emailBox.children = [txtEmailIcon, txtEmails]
        emailBox.verticalAlignment = .center
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        if self.hasEmail() {
            textBox.children = [txtContactName,phonenumberBox,emailBox]
        } else {
            textBox.children = [txtContactName,phonenumberBox]
        }
        textBox.spacing = 0
        
        
        let attachmentBox = ASStackLayoutSpec.horizontal()
        attachmentBox.spacing = 5
        attachmentBox.children = [imgCover, textBox]
        
        let finalBox = ASStackLayoutSpec.vertical()
        finalBox.justifyContent = .spaceAround
        finalBox.spacing = 5
        finalBox.children = [attachmentBox, btnViewContact]

        
        // Apply text truncation
        let elems: [ASLayoutElement] = [imgCover,txtEmails,txtContactName,imgCover,btnViewContact, emailBox,textBox, attachmentBox,finalBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        txtPhoneNumbers.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: finalBox
        )
        
        return insetBox
    }
}


