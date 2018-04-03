//
//  DeleteAccountCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/19/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class DeleteAccountCoordinator: NSObject {
    private typealias ViewModel = DeleteAccountViewController.ViewModel
    @IBOutlet weak private var viewController: DeleteAccountViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
    
        viewController.render(state: .initial(.init(invokeDeleteAccount:  { self.deleteAccount() })))
    }
    
    private func deleteAccount() {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.deleteUser {
            switch ($0) {
            case .successWithData: break
            case .success:
                ESPMobileAPI.logout {
                    switch ($0) {
                    case .successWithData: break
                    case .success: self.viewController.render(state: .success)
                    case .failure:
                        self.viewController.render(state: .failure(.init(
                            message: "Unable to log you out after deleting your account. Please log out manually."
                        )))
                    }
                }
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
}
