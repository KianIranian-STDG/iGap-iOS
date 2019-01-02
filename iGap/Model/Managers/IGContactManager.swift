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

class IGContactManager: NSObject {
    
    static let sharedManager = IGContactManager()
    static var importedContact: Bool = false
    static var syncedPhoneBookContact: Bool = false // for update contact after than notified from 'CNContactStore'
    private var contactStore = CNContactStore()
    private var contactsStruct = [ContactsStruct]()
    private var results: [CNContact] = []
    private var resultsChunk = [[CNContact]]()
    private var contactIndex = 0
    private var CONTACT_IMPORT_LIMIT = 50
    
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
            if self.resultsChunk.count == 0 || self.contactIndex >= self.resultsChunk.count{
                self.getContactListFromServer()
                return
            }
            
            var contactsStruct = [ContactsStruct]()
            let result = self.resultsChunk[self.contactIndex]
            
            let realm = try! Realm()
            try! realm.write {
                for contact in result {
                    for phone in contact.phoneNumbers {
                        realm.add(IGContact(phoneNumber: phone.value.stringValue, firstName: contact.givenName, lastName: contact.familyName), update: true)
                        
                        var structContact = ContactsStruct()
                        structContact.phoneNumber = phone.value.stringValue
                        structContact.firstName = contact.givenName
                        structContact.lastName = contact.familyName
                        contactsStruct.append(structContact)
                    }
                }
            }
            
            self.sendContact(phoneContacts: contactsStruct)
            self.contactIndex += 1
        }
    }
    
    private func sendContact(phoneContacts : [ContactsStruct]){
        IGUserContactsImportRequest.Generator.generateStruct(contacts: phoneContacts).success ({ (protoResponse) in
            if let contactImportResponse = protoResponse as? IGPUserContactsImportResponse {
                IGUserContactsImportRequest.Handler.interpret(response: contactImportResponse)
                self.sendContactsToServer()
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                IGContactManager.importedContact = false
                self.sendContactsToServer()
            default:
                break
            }
        }).send()
    }
    
    
    private func getContactListFromServer() {
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
}
