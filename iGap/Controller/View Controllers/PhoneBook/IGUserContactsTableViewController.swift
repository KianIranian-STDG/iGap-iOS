//
//  IGUserContactsTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class IGUserContactsTableViewController: BaseTableViewController,MFMessageComposeViewControllerDelegate {
    var userContacts = [CNContact]()
    
    var searchController : UISearchController = {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = ""
        searchController.searchBar.setValue("CANCEL_BTN".localizedNew, forKey: "cancelButtonText")
        searchController.hidesNavigationBarDuringPresentation = false
        
        let gradient = CAGradientLayer()
        let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

        gradient.frame = defaultNavigationBarFrame
        gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
        gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
//        gradient.locations = orangeGradientLocation as [NSNumber]

        
        searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
            }

            
            print("FOUND TEXTFIELD")
            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                print("FOUND LABEL")
                placeHolderInsideSearchField.textColor = UIColor.white
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
                


            }
        }
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.scrollsToTop = false
        self.tableView.bounces = false

        let store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        // 2
        if authorizationStatus == .notDetermined {
            // 3
            store.requestAccess(for: .contacts) { [weak self] didAuthorize,
                error in
                if didAuthorize {
                    self?.retrieveContacts(from: store)
                }
            }
        } else if authorizationStatus == .authorized {
            retrieveContacts(from: store)
        }
    }
    
    
    //Mark:- retrive contacts
    func retrieveContacts(from store: CNContactStore) {
//        let containerId = store.defaultContainerIdentifier()
//        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        // 4
        let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                           CNContactFamilyNameKey as CNKeyDescriptor,
                           CNContactPhoneNumbersKey as CNKeyDescriptor]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        fetchRequest.sortOrder = CNContactSortOrder.givenName
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) in
                self.userContacts.append(contact)
            })
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
//        let contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
//        userContacts = contacts.sorted(by: { $0.givenName < $1.givenName })
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadWithAnimation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if navigationItem.searchController == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initialiseSearchBar()

    }
    
    private func initialiseSearchBar() {
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

            let imageV = textField.leftView as! UIImageView
            imageV.image = nil
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    view.backgroundColor = .clear
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
                
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
            }

            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeHolderInsideSearchField.textColor = UIColor.white
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
                
            }
            
        }
    }
    
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            if #available(iOS 13.0, *) {
                if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                    // appearance has changed
                    // Update your user interface based on the appearance
                    self.setSearchBarGradient()
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
        private func setSearchBarGradient() {
            let gradient = CAGradientLayer()
            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

            gradient.frame = defaultNavigationBarFrame
            gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
            gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
    //        gradient.locations = orangeGradientLocation as [NSNumber]
            
            searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            
        }
    private func sendText(number: String!) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "HEY_JOIN_IGAP".localizedNew
            controller.recipients = [number]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userContacts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IGUserContactsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "IGUserContactsTableViewCell") as! IGUserContactsTableViewCell
        let contact = userContacts[indexPath.row]
        
        cell.nameLbl.text = "\(contact.givenName) \(contact.familyName)"
//        cell.avatarView.backgroundColor = UIColor.clear
        cell.phoneNumberLbl.text = "\(contact.phoneNumbers.first?.value.stringValue ?? "")".inLocalizedLanguage()

        return cell

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = userContacts[indexPath.row]
        DispatchQueue.main.async {
            self.sendText(number: "\(contact.phoneNumbers.first?.value.stringValue ?? "")".trimmingCharacters(in: .whitespaces))

        }
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
