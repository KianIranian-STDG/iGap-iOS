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
import RealmSwift

class IGUserContactsTableViewController: BaseTableViewController, MFMessageComposeViewControllerDelegate {
    var userContacts = [CNContact]()
    var filterdUserContacts = [CNContact]()
    
    private var shouldShowSearchResults = false
    
    var searchController : UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = ""
        searchController.searchBar.setValue("CANCEL_BTN".RecentTableViewlocalizedNew, forKey: "cancelButtonText")
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
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
        
        return searchController
    }()
    
    var store: CNContactStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentOffset = CGPoint(x: 0, y: 55)
        self.tableView.bounces = false

        store = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        // 2
        if authorizationStatus == .notDetermined {
            // 3
            store.requestAccess(for: .contacts) { [weak self] didAuthorize,
                error in
                if didAuthorize {
                    self?.retrieveContacts(from: self!.store)
                }
            }
        } else if authorizationStatus == .authorized {
            retrieveContacts(from: store)
        }
        
        if #available(iOS 11.0, *) {
            self.searchController.searchBar.searchBarStyle = UISearchBar.Style.minimal

            if navigationItem.searchController == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    
    //Mark:- retrive contacts
    func retrieveContacts(from store: CNContactStore) {
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
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialiseSearchBar()
    }
    
    private func initialiseSearchBar() {
                
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear

//            let imageV = textField.leftView as! UIImageView
//            imageV.image = nil
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    view.backgroundColor = .clear
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }

            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".RecentTableViewlocalizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14, weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
                searchBarCancelButton.setTitleColor(UIColor.white, for: .normal)
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
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
            let user = realm.objects(IGRegisteredUser.self).filter(predicate).first
            if let phone = (user?.phone) {
                controller.body = "HEY_JOIN_IGAP".localizedNew + " " + "\(phone)"

            }

            
            
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
        if shouldShowSearchResults {
            return filterdUserContacts.count
        }
        return userContacts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: IGUserContactsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "IGUserContactsTableViewCell") as! IGUserContactsTableViewCell
        let contact: CNContact!
        if shouldShowSearchResults {
            contact = filterdUserContacts[indexPath.row]
        } else {
            contact = userContacts[indexPath.row]
        }
        
        cell.nameLbl.text = "\(contact.givenName) \(contact.familyName)"
        cell.phoneNumberLbl.text = "\(contact.phoneNumbers.first?.value.stringValue ?? "")".inLocalizedLanguage()

        return cell

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact: CNContact!
        if shouldShowSearchResults {
            contact = filterdUserContacts[indexPath.row]
        } else {
            contact = userContacts[indexPath.row]
        }
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

// MARK: search controller extension
extension IGUserContactsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else { return }
        
        let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: searchString)
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        
        // Filter the data array and get only those users that match the search text.
        if searchString.isEmpty {
            filterdUserContacts = userContacts
        } else {
            filterdUserContacts = try! self.store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
        }
        
        // Reload the tableview.
        self.tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        self.tableView.reloadData()
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
           shouldShowSearchResults = true
           self.tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
}
