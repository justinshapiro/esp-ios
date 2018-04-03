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
    @IBOutlet weak private var viewController: ManualContactViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        viewController.render(state: .initial(.init(
            submit: { self.addManualContact(contact: $0) }
        )))
    }
    
    private func addManualContact(contact: Contact) {
        viewController.render(state: .waiting)
        
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
