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
import IGProtoBuff
import RealmSwift
import Contacts
import RxSwift
import RxCocoa

class IGContactManager: NSObject {
    
    static let sharedManager = IGContactManager()
    static var importedContact: Bool = false
    static var syncedPhoneBookContact: Bool = false // for update contact after than notified from 'CNContactStore'
    private var contactStore = CNContactStore()
    private var contactsStruct = [ContactsStruct]()
    private var results: [CNContact] = []
    private var resultsChunk = [[CNContact]]()
    private var contactIndex = 0
    private var CONTACT_IMPORT_LIMIT = 25
    private var md5Hex: String!
    lazy var contactExchangeLevel: BehaviorRelay<ContactExchangeLevel>! = BehaviorRelay(value: .importing(percent: 0))
    
    private override init() {
        super.init()
    }
    
    struct ContactsStruct {
        var phoneNumber: String?
        var firstName: String?
        var lastName: String?
    }
    
    func manageContact() {
        if CNContactStore.authorizationStatus(for: CNEntityType.contacts) == CNAuthorizationStatus.authorized {
            if IGContactManager.importedContact {
                return
            }
            IGContactManager.importedContact = true
            savePhoneContactsToDatabase()
            sendContactsToServer()
        } else {
            getContactListFromServer()
        }
    }
    
    private func savePhoneContactsToDatabase() {
        
        self.results = []
        self.contactIndex = 0
        
        let keys = [CNContactGivenNameKey,
                    CNContactMiddleNameKey,
                    CNContactFamilyNameKey,
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactImageDataAvailableKey,
                    CNContactThumbnailImageDataKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keys as [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        resultsChunk = results.chunks(CONTACT_IMPORT_LIMIT)
    }
    
    private func sendContactsToServer() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
            if self.resultsChunk.count == 0 {
                self.getContactListFromServer()
                return
            }
            
            var contactsPhoneStruct = [String]()
            if self.results.count > 0 {
                for contact in self.results {
                    for phone in contact.phoneNumbers {
                        contactsPhoneStruct.append(phone.value.stringValue.trimmingCharacters(in: .whitespaces).inEnglishNumbersNew())
                    }
                }
            }
            
            let sortedPhonenumbers = contactsPhoneStruct.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
            let tmpString = (sortedPhonenumbers.joined(separator: ","))
            let md5Data = IGGlobal.MD5(string:tmpString)
            self.md5Hex = md5Data.map { String(format: "%02hhx", $0) }.joined()
            if (IGAppManager.sharedManager.md5Hex() != self.md5Hex) {
                self.sendContactPreparation()
            } else {
                self.getContactListFromServer()
            }
        }
    }
    
    private func sendContactPreparation(){
        if self.contactIndex >= 0 && self.contactIndex < self.resultsChunk.count { // TODO - check reason of 'self.contactIndex == -1'
            let result = self.resultsChunk[self.contactIndex]
            self.makeContactStruct(contacts: result) { (contactsStructList) in
                if (self.contactIndex) == (self.resultsChunk.count - 1) {
                    self.sendContact(phoneContacts: contactsStructList, md5Hex: self.md5Hex)
                } else {
                    self.sendContact(phoneContacts: contactsStructList)
                }
                let percent = Double((self.contactIndex * self.CONTACT_IMPORT_LIMIT)) / Double(self.results.count) * 100
                IGContactManager.sharedManager.contactExchangeLevel.accept(.importing(percent: Double(percent)))
                self.contactIndex += 1
            }
        }
    }
    
    private func makeContactStruct(contacts: [CNContact], completion: @escaping ((_ contactsStructList: [IGContactManager.ContactsStruct]) -> Void)){
        var contactsStruct: [IGContactManager.ContactsStruct] = []
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                for contact in contacts {
                    for phone in contact.phoneNumbers {
                        IGDatabaseManager.shared.realm.add(IGContact(phoneNumber: phone.value.stringValue, firstName: contact.givenName, lastName: contact.familyName), update: .modified)
                        
                        var structContact = ContactsStruct()
                        structContact.phoneNumber = phone.value.stringValue
                        structContact.firstName = contact.givenName
                        structContact.lastName = contact.familyName
                        contactsStruct.append(structContact)
                    }
                }
            }
            completion(contactsStruct)
        }
    }
    
    private func sendContact(phoneContacts : [ContactsStruct], md5Hex : String? = nil){
        IGUserContactsImportRequest.Generator.generateStruct(contacts: phoneContacts , md5Hex : md5Hex).successPowerful ({ (protoResponse, requestWrapper) in
            if let contactImportResponse = protoResponse as? IGPUserContactsImportResponse {
                IGUserContactsImportRequest.Handler.interpret(response: contactImportResponse)
                self.sendContactPreparation()
            }
            // if md5Hex is exist this reponse is latest response for import contact so now get contact list from server
            if let _ = requestWrapper.identity as? String {
                self.getContactListFromServer()
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                IGContactManager.importedContact = false
                self.contactIndex = self.contactIndex - 1
                self.sendContactPreparation()
            default:
                break
            }
        }).send()
    }
    
    
    public func getContactListFromServer() {
        IGUserContactsGetListRequest.Generator.generate().success ({ (protoResponse) in
            switch protoResponse {
            case let contactGetListResponse as IGPUserContactsGetListResponse:
                IGUserContactsGetListRequest.Handler.interpret(response: contactGetListResponse)
                break
            default:
                break
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getContactListFromServer()
            default:
                break
            }
        }).send()
    }
    
    func saveContactToDevicePhoneBook(name: String , phoneNumber: [String] , emailAddress: [NSString] = []) {
        let newContact = CNMutableContact()
        newContact.givenName = name
        var tmpPhoneNumberArray = [CNLabeledValue<CNPhoneNumber>]()
        var tmpEmailArray = [CNLabeledValue<NSString>]()
        for number in phoneNumber {
            tmpPhoneNumberArray.append(CNLabeledValue( label:CNLabelPhoneNumberiPhone, value:CNPhoneNumber(stringValue:number)))
        }
        
        for email in emailAddress {
            tmpEmailArray.append(CNLabeledValue(label: CNLabelHome, value: email))
        }
        
        newContact.phoneNumbers = tmpPhoneNumberArray
        newContact.emailAddresses = tmpEmailArray
        // Saving contact
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(newContact, toContainerWithIdentifier:nil)
        try! store.execute(saveRequest)
    }
}
