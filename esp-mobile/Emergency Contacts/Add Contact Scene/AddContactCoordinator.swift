//
//  AddContactCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/5/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import Contacts

final class AddContactCoordinator: NSObject {
    private typealias ViewModel = AddContactViewController.ViewModel
    @IBOutlet private var viewController: AddContactViewController!
    
    private var invokeAddContact: ((String, String) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeAddContact = { (name: String, phone: String) in
            self.addContact(name: name, phone: phone)
        }
        
        getDeviceContacts()
    }
    
    private func addContact(name: String, phone: String) {
        viewController.render(state: .waiting)
        let contact = Contact(id: nil, name: name, phone: phone, groupID: nil)
        
        ESPMobileAPI.addContact(contact: contact) {
            switch ($0) {
            case .successWithData: break
            case .success: self.viewController.render(state: .addSuccess)
            case .failure(let failure): self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
    
    private func getDeviceContacts() {
        viewController.render(state: .waiting)
        
        var contacts: [CNContact] = []
        let contactStore = CNContactStore()
        
        do {
            for container in try contactStore.containers(matching: nil) {
                contacts.append(contentsOf: try contactStore.unifiedContacts(
                    matching: CNContact.predicateForContactsInContainer(withIdentifier: container.identifier),
                    keysToFetch: [
                        CNContactPhoneNumbersKey as CNKeyDescriptor,
                        CNContactGivenNameKey as CNKeyDescriptor,
                        CNContactFamilyNameKey as CNKeyDescriptor
                    ]
                ))
            }
        } catch {
            viewController.render(state: .contactLoadBypass(.init(invokeAddContact: invokeAddContact)))
        }
        
        var deserializedContacts: [Contact] = []
        for contact in contacts {
            if contact.phoneNumbers.count > 0 {
                let rawPhoneNumber = contact.phoneNumbers[0].value.stringValue
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "1\u{00A0}", with: "")
                    .replacingOccurrences(of: "\u{00A0}", with: "")
                    .replacingOccurrences(of: "+1", with: "")
                    .replacingOccurrences(of: "+", with: "")
                    .replacingOccurrences(of: "(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .replacingOccurrences(of: "-", with: "")
                
                if Array(rawPhoneNumber).count == 10 {
                    deserializedContacts.append(Contact(
                        id: nil,
                        name: contact.givenName + " " + contact.familyName,
                        phone: rawPhoneNumber,
                        groupID: nil
                    ))
                }
            }
        }
        
        viewController.render(state: .initial(.init(
            deviceContacts: deserializedContacts,
            invokeAddContact: invokeAddContact
        )))
    }
}
