//
//  EditContactCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/19/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class EditContactCoordinator: NSObject {
    private typealias ViewModel = EditContactViewController.ViewModel
    @IBOutlet private var viewController: EditContactViewController!
    
    private var invokeGetContact: ((String) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeGetContact = { (contactID: String) in
            self.getContact(contactID: contactID)
        }
        
        viewController.render(state: .preInitial(.init(invokeGetContact: invokeGetContact)))
    }
    
    private func getContact(contactID: String) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.getContact(contactID: contactID) {
            switch ($0) {
            case .success: break
            case .successWithData(let data):
                guard let contactInfo = data.object as? Contact else { return }
                self.viewController.render(state: .initial(.init(
                    contactInfo: contactInfo,
                    submit: { self.updateContactPhone(contact: $0) }
                )))
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message,
                    submit: { self.updateContactPhone(contact: $0) }
                )))
            }
        }
    }
    
    private func updateContactPhone(contact: Contact) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.updateContactPhone(contactID: contact.id!, contactPhone: contact.phone) {
            switch ($0) {
            case .successWithData: break
            case .success: self.viewController.render(state: .success)
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message,
                    submit: { self.updateContactPhone(contact: $0) }
                )))
            }
        }
    }
}
