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
    private var CONTACT_IMPORT_LIMIT = 25
    
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
            print(self.resultsChunk.count)
            print(self.contactIndex)
            if self.resultsChunk.count == 0 || self.contactIndex >= self.resultsChunk.count{
                self.getContactListFromServer()
                return
            }
            
            var contactsStruct = [ContactsStruct]()
            var contactsPhoneStruct = [String]()
            let result = self.resultsChunk[self.contactIndex]

            if self.results.count > 0 {
                for contact in self.results {
                    for phone in contact.phoneNumbers {
                        contactsPhoneStruct.append(phone.value.stringValue.trimmingCharacters(in: .whitespaces).inEnglishNumbers())
                    }
                }
            }

            let sortedPhonenumbers = contactsPhoneStruct.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
            
            print(sortedPhonenumbers.joined(separator: ","))
            let tmpString = (sortedPhonenumbers.joined(separator: ","))
            let md5Data = IGGlobal.MD5(string:tmpString)
            
            let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
            let tmpmd5HexFromServer = (IGAppManager.sharedManager.md5Hex())

            
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
                        contactsPhoneStruct.append(phone.value.stringValue.trimmingCharacters(in: .whitespaces).inEnglishNumbers())
                        
                        
                    }
                }
                
            }

            if (IGAppManager.sharedManager.md5Hex() == md5Hex) {
            } else {
                print(self.resultsChunk.count)
                print(self.contactIndex)
                if (self.contactIndex ) == (self.resultsChunk.count - 1) {
                    self.sendContact(phoneContacts: contactsStruct, md5Hex: md5Hex)
                    self.contactIndex += 1

                } else {
                    self.sendContact(phoneContacts: contactsStruct)
                    self.contactIndex += 1
                }
            }
        }
    }
    
    private func sendContact(phoneContacts : [ContactsStruct], md5Hex : String? = nil){
        IGUserContactsImportRequest.Generator.generateStruct(contacts: phoneContacts , md5Hex : md5Hex).success ({ (protoResponse) in
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
