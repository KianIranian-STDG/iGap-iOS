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
    private var txtPhoneNumbers = ASTextNode()
    private var txtPhoneIcon = ASTextNode()
    private var txtContactName = ASTextNode()
    private var txtEmails = ASTextNode()
    private var txtEmailIcon = ASTextNode()
    private var txtCover = ASTextNode()
    private var btnViewContact = ASButtonNode()
    private func hasEmail() -> Bool{
        return (message.contact?.emails.count)! > 0
    }
    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()
        
        txtCover.style.preferredSize = CGSize(width: 50, height: 50)
        txtCover.layer.cornerRadius = 25
        IGGlobal.makeAsyncText(for: txtCover, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 50, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtPhoneIcon, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        IGGlobal.makeAsyncText(for: txtEmailIcon, with: "🖂", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
        
        btnViewContact.setTitle(IGStringsManager.ViewContact.rawValue.localized, with: UIFont.igFont(ofSize: 14, weight: .bold), with: ThemeManager.currentTheme.LabelColor, for: .normal)
        btnViewContact.layer.cornerRadius = 10
        btnViewContact.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        btnViewContact.layer.borderWidth = 2.0
        btnViewContact.backgroundColor = .clear
        btnViewContact.style.height = ASDimension(unit: .points, value: 40.0)
        addSubnode(txtContactName)
        addSubnode(txtPhoneNumbers)
        addSubnode(txtPhoneIcon)
        addSubnode(txtEmails)
        addSubnode(txtEmailIcon)
        addSubnode(txtCover)
        addSubnode(btnViewContact)
        getContactDetails()
        
        
    }
    
    
    func getContactDetails() {
        DispatchQueue.main.async {
            let predicate = NSPredicate(format: "primaryKeyId = %@", self.message.primaryKeyId!)
            let contact: IGRoomMessageContact = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).first!.contact!
            print("============::::::===========")
            print(contact)
            print(self.message.contact!)
            print(self.hasEmail())
            
            
            let firstName = contact.firstName == nil ? "" : contact.firstName! + " "
            let lastName = contact.lastName == nil ? "" : contact.lastName!
            let name = String(format: "%@%@", firstName, lastName)
            IGGlobal.makeAsyncText(for: self.txtContactName, with: name, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
            if contact.phones.count == 1 {
                let phoneNumber = contact.phones.first!.innerString
                IGGlobal.makeAsyncText(for: self.txtPhoneNumbers, with: phoneNumber, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)

            } else {
                for phone in contact.phones {
                    let phoneNumber = (self.txtPhoneNumbers.attributedText?.string ?? "") + phone.innerString + "\n"
                    IGGlobal.makeAsyncText(for: self.txtPhoneNumbers, with: phoneNumber, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                    
                }
            }
            
            
            if self.hasEmail() {
                if contact.emails.count == 1 {
                    let emailAdd = contact.emails.first!.innerString
                    IGGlobal.makeAsyncText(for: self.txtEmails, with: emailAdd, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)

                } else {
                    for email in contact.emails {
                        let emailAdd = (self.txtEmails.attributedText?.string ?? "") + email.innerString + "\n"
                        IGGlobal.makeAsyncText(for: self.txtEmails, with: emailAdd, textColor: ThemeManager.currentTheme.LabelColor, size: 14, weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
                        
                    }
                }

            }
            
            
        }
        
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let phonenumberBox = ASStackLayoutSpec.horizontal()
        phonenumberBox.spacing = 10
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
        attachmentBox.spacing = 10
        attachmentBox.children = [txtCover, textBox]
        
        let finalBox = ASStackLayoutSpec.vertical()
        finalBox.justifyContent = .spaceAround
        finalBox.spacing = 5
        finalBox.children = [attachmentBox, btnViewContact]

        
        // Apply text truncation
        let elems: [ASLayoutElement] = [txtEmails,txtPhoneNumbers,txtContactName,txtCover,btnViewContact,phonenumberBox,emailBox,textBox, attachmentBox,finalBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5),
            child: finalBox
        )
        
        return insetBox
        
        
    }
    
    
    
}


