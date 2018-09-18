//
//  LoginSceneCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/26/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class LoginSceneCoordinator: NSObject {
    private typealias ViewModel = LoginSceneViewController.ViewModel
    @IBOutlet private var viewController: LoginSceneViewController!
    
    private var invokeReadyForUpdate: (() -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()

        let initialState = ViewModel.initial(.init(
            rememberedUsername: "",
            rememberedPassword: "",
            submit: { self.login(credentials: $0) }
        ))
        
        invokeReadyForUpdate = {
            self.viewController.render(state: initialState)
        }
        
        viewController.render(state: .preInitial(.init(invokeReadyForUpdate: invokeReadyForUpdate)))
        viewController.render(state: initialState)
    }
    
    private func login(credentials: ViewModel.Credentials) {
        viewController.render(state: ViewModel.waiting)
        
        ESPMobileAPI.login(loginID: credentials.loginID, password: credentials.password) { result in
            switch result {
            case .successWithData: break
            case .success:
                self.viewController.render(state: ViewModel.success)
            case .failure(let failure):
                self.viewController.render(state: ViewModel.failure(.init(
                    message: failure.message,
                    submit: { self.login(credentials: $0) }
                )))
            }
        }
    }
}
