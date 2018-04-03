//
//  AlertGroupsCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/26/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import Foundation

class AlertGroupsCoordinator: NSObject {
    private typealias ViewModel = AlertGroupsViewController.ViewModel
    @IBOutlet weak private var viewController: AlertGroupsViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        viewController.render(state: .initial(.init(submit: { self.updateContactGroups(contactsForGroup: $0) })))
    }
    
    private func updateContactGroups(contactsForGroup: [[String: String?]]) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.deleteContactGroup {
            switch $0 {
                case .successWithData: break
            case .success:
                ESPMobileAPI.addContactGroup(contactIDs: contactsForGroup.flatMap { $0["id"]!! }) {
                    switch $0 {
                    case .successWithData: break
                    case .success:
                        self.viewController.render(state: .success)
                    case .failure(let failure):
                        self.viewController.render(state: .failure(.init(
                            message: failure.message,
                            submit: { self.updateContactGroups(contactsForGroup: $0) }
                        )))
                    }
                }
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message,
                    submit: { self.updateContactGroups(contactsForGroup: $0) }
                )))
            }
        }
    }
}
