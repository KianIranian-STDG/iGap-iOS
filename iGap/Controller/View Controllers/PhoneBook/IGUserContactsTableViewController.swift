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
import Contacts
import MessageUI
import RealmSwift

class IGUserContactsTableViewController: BaseTableViewController, MFMessageComposeViewControllerDelegate {
    var userContacts = [CNContact]()
    var filterdUserContacts = [CNContact]()
    
    private var shouldShowSearchResults = false
    

    
    
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
    

    
    
    
    
    
    
    
    
    private func sendText(number: String!) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
            let user = realm.objects(IGRegisteredUser.self).filter(predicate).first
            if let phone = (user?.phone) {
                controller.body = IGStringsManager.HeyJoinIgap.rawValue.localized + " " + "\(phone)"

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
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

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


