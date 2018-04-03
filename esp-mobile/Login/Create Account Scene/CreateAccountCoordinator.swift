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
        viewController.render(state: .initial(.init(submit: { self.createAccount(userInfo: $0) })))
    }
    
    private func createAccount(userInfo: UserInfo) {
        viewController.render(state: .waiting)
        
        if userInfo.name == "" {
            viewController.render(state: .failure(.init(
                message: "Entering your name is required.",
                submit: { self.createAccount(userInfo: $0) }
            )))
        } else if userInfo.email == "" {
            viewController.render(state: .failure(.init(
                message: "Entering your email is required.",
                submit: { self.createAccount(userInfo: $0) }
                )))
        } else if userInfo.password == "" {
            viewController.render(state: .failure(.init(
                message: "Entering your password is required.",
                submit: { self.createAccount(userInfo: $0) }
                )))
        } else if userInfo.confirmPassword == "" {
            viewController.render(state: .failure(.init(
                message: "Entering your password twice is required.",
                submit: { self.createAccount(userInfo: $0) }
                )))
        } else if userInfo.username == "" {
            viewController.render(state: .failure(.init(
                message: "Entering your username is required.",
                submit: { self.createAccount(userInfo: $0) }
                )))
        } else if userInfo.password != userInfo.confirmPassword {
            viewController.render(state: .failure(.init(
                message: "Passwords do not match.",
                submit: { self.createAccount(userInfo: $0) }
                )))
        } else {
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
}
