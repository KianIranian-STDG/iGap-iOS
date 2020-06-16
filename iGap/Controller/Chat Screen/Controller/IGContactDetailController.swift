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


class IGContactDetailController: UIViewController, PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableContainer
    }
    
    private var contact: IGRoomMessageContact
    
    private let contactTableCellIdentifier = "contactTableCellIdentifier"
    private let tableContainer: UITableView = {
        let tbl = UITableView(frame: .zero, style: .grouped)
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.backgroundColor = .white
        return tbl
    }()
    
    private let imageViewContact : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "IG_Message_Cell_Contact_Generic_Avatar_Incomming")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let lblName : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.igFont(ofSize: 17, weight: .medium)
        return lbl
    }()
    
    init(contact: IGRoomMessageContact) {
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        view.backgroundColor = .white
        tableContainer.delegate = self
        tableContainer.dataSource = self
        tableContainer.register(UITableViewCell.self, forCellReuseIdentifier: contactTableCellIdentifier)
        view.addSubview(tableContainer)
        
        NSLayoutConstraint.activate([tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     tableContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     tableContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func startCall(with number: String){
        let tel: String! = "tel://\(number.inEnglishNumbersNew().digits)"
        if let url = URL(string: tel!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func didTapOnAddContact() {
        let option = UIAlertController(title: nil, message: IGStringsManager.AddContactsQuestion.rawValue.localized, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: {[weak self] (action) in
            guard let sSelf = self else {
                return
            }
            var phones: [String] = []
            for phone in sSelf.contact.phones {
                phones.append(phone.innerString)
            }
            
            var emails: [String] = []
            for email in sSelf.contact.emails {
                emails.append(email.innerString)
            }
            
            var displayName = sSelf.contact.firstName
            if let lastName = sSelf.contact.lastName {
                displayName = " " + lastName
            }
            
            IGContactManager.sharedManager.saveContactToDevicePhoneBook(name: displayName!, phoneNumber: phones, emailAddress: emails as [NSString])
        })
        option.addAction(ok)
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalNo.rawValue.localized, style: .cancel, handler: nil)
        option.addAction(cancel)
        
        UIApplication.topViewController()!.present(option, animated: true, completion: {})
    }
    
    func sendEmail(to email: String) {
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}

    // MARK: - Container Table View Delegate & DataSource
extension IGContactDetailController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return contact.phones.count
        case 3:
            return contact.emails.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactTableCellIdentifier, for: indexPath)
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            
            if !cell.subviews.contains(imageViewContact) {
                cell.addSubview(imageViewContact)
                NSLayoutConstraint.activate([imageViewContact.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16),
                                             imageViewContact.widthAnchor.constraint(equalToConstant: 65),
                                             imageViewContact.heightAnchor.constraint(equalToConstant: 65),
                                             imageViewContact.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
                ])
            }
            
            if !cell.subviews.contains(lblName) {
                cell.addSubview(lblName)
                NSLayoutConstraint.activate([lblName.leftAnchor.constraint(equalTo: imageViewContact.rightAnchor, constant: 8),
                                             lblName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
                                             lblName.heightAnchor.constraint(lessThanOrEqualTo: imageViewContact.heightAnchor),
                                             lblName.centerYAnchor.constraint(equalTo: imageViewContact.centerYAnchor)
                ])
                lblName.text = (contact.firstName ?? "") + " " + (contact.lastName ?? "")
            }
            
            break
            
        case 1:
            
            switch indexPath.row {
            case 0 :
                cell.textLabel?.text = IGStringsManager.CreateNewContact.rawValue.localized
                break
            default:
                break
            }
            break
            
        case 2:
            
            let resString = NSMutableAttributedString()
            resString.append(NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.iGapFonticon(ofSize: 18)]))
            resString.append(NSAttributedString(string: "  " + contact.phones[indexPath.row].innerString, attributes: [NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)]))
            
            cell.textLabel?.attributedText = resString
            
            
            
//            cell.textLabel?.text = contact.phones[indexPath.row].innerString
            break
            
        case 3:
            
            
            let resString = NSMutableAttributedString()
            resString.append(NSAttributedString(string: "🖂", attributes: [NSAttributedString.Key.font : UIFont.iGapFonticon(ofSize: 18)]))
            resString.append(NSAttributedString(string: "  " + contact.emails[indexPath.row].innerString, attributes: [NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)]))
            
            
            cell.textLabel?.attributedText = resString
            
            
//            cell.textLabel?.text = contact.emails[indexPath.row].innerString
            break
            
        default:
            break
        }
        
//        cell.textLabel?.font = UIFont.igFont(ofSize: 15, weight: .regular)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            if contact.phones.count == 0 {
                return nil
            }
            return IGStringsManager.PhoneNumbers.rawValue.localized
        case 3:
            if contact.emails.count == 0 {
                return nil
            }
            return IGStringsManager.Emails.rawValue.localized
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            didTapOnAddContact()
            break
        case 2:
            startCall(with: contact.phones[indexPath.row].innerString)
            break
        case 3:
            sendEmail(to: contact.emails[indexPath.row].innerString)
            break
        default:
            return
        }
    }
    
}



//IGGlobal.makeAsyncText(for: txtPhoneIcon, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
//IGGlobal.makeAsyncText(for: txtEmailIcon, with: "🖂", textColor: ThemeManager.currentTheme.LabelColor, size: 10, numberOfLines: 1, font: IGGlobal.fontPack.fontIcon, alignment: .center)
