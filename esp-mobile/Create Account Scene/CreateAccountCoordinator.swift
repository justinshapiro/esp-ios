//
//  CreateAccountCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/11/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class CreateAccountCoordinator: NSObject {
    private typealias ViewModel = CreateAccountViewController.ViewModel
    @IBOutlet weak private var viewController: CreateAccountViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        viewController.render(state: .initial(.init(
            submit: { self.createAccount(userInfo: $0) }
        )))
    }
    
    private func createAccount(userInfo: UserInfo) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.addUserAndLogin(userInfo: userInfo) { result in
            switch (result) {
            case .successWithData: break
            case .success: self.viewController.render(state: .success)
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message,
                    submit: { self.createAccount(userInfo: $0) }
                )))
            }
        }
    }
}
