//
//  ManualContactCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/5/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class ManualContactCoordinator: NSObject {
    private typealias ViewModel = ManualContactViewController.ViewModel
    @IBOutlet private var viewController: ManualContactViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        viewController.render(state: .initial(.init(submit: { self.addManualContact(contact: $0) })))
    }
    
    private func addManualContact(contact: Contact) {
        viewController.render(state: .waiting)
        
        if contact.name.isEmpty {
            viewController.render(state: .failure(.init(
                message: "Contact name is required.",
                submit: { self.addManualContact(contact: $0) }
            )))
        } else if contact.phone.isEmpty {
            viewController.render(state: .failure(.init(
                message: "Contact phone number is required.",
                submit: { self.addManualContact(contact: $0) }
            )))
        } else {
            ESPMobileAPI.addContact(contact: contact) {
                switch ($0) {
                case .successWithData: break
                case .success: self.viewController.render(state: .success)
                case .failure(let failure):
                    self.viewController.render(state: .failure(.init(
                        message: failure.message,
                        submit: { self.addManualContact(contact: $0) }
                        )))
                }
            }
        }
    }
}
