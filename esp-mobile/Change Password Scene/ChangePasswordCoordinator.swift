//
//  ChangePasswordCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/19/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class ChangePasswordCoordinator: NSObject {
    private typealias ViewModel = ChangePasswordViewController.ViewModel
    @IBOutlet weak private var viewController: ChangePasswordViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        viewController.render(state: .initial(.init(
            submit: { self.changePassword(userInfo: $0) }
        )))
    }
    
    private func changePassword(userInfo: UserInfo) {
        viewController.render(state: .waiting)
        if userInfo.password == userInfo.confirmPassword {
            ESPMobileAPI.updatePassword(oldPassword: userInfo.oldPassword, newPassword: userInfo.password) {
                switch ($0) {
                case .successWithData: break
                case .success: self.viewController.render(state: .success)
                case .failure(let failure):
                    self.viewController.render(state: .failure(.init(
                        message: failure.message,
                        submit: { self.changePassword(userInfo: $0) }
                    )))
                }
            }
        } else {
            viewController.render(state: .failure(.init(
                message: "New Passwords must match",
                submit: { self.changePassword(userInfo: $0) }
            )))
        }
    }
}
