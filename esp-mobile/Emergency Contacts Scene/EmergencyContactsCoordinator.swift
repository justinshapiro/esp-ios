//
//  EmergencyContactsCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/5/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class EmergencyContactsCoordinator: NSObject {
    private typealias ViewModel = EmergencyContactsViewController.ViewModel
    @IBOutlet weak private var viewController: EmergencyContactsViewController!
    
    private var invokeDeleteContact: ((String) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeDeleteContact = { (contactID: String) in
            self.deleteContact(contactID: contactID)
        }
        
        viewController.render(state: .preInitial(.init(
            invokeDeleteContact: invokeDeleteContact,
            invokeReadyForUpdate: { self.getContacts() }
        )))
    }
    
    private func getContacts() {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.getContacts {
            switch ($0) {
            case .success: break
            case .successWithData(let data):
                self.viewController.render(state: .initial(.init(
                    currentContacts: data.object as! [Contact]
                )))
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message
                )))
            }
        }
    }
    
    private func deleteContact(contactID: String) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.deleteContact(contactID: contactID) {
            switch ($0) {
            case .successWithData: break
            case .success:
                // reload contacts into view
                self.getContacts()
            case .failure(let failure):self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
}
