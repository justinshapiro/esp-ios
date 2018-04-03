//
//  ProfileCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/30/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class ProfileCoordinator: NSObject {
    private typealias ViewModel = ProfileViewController.ViewModel
    @IBOutlet weak private var viewController: ProfileViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        getUserInfo()
    }
    
    private func getUserInfo() {
        viewController.render(state: .waiting)
        ESPMobileAPI.getUserInfo { result in
            switch (result) {
            case .success: break
            case .successWithData(let data):
                guard let userInfo = data.object as? UserInfo else { return }
                self.viewController.render(state: .initial(.init(
                    currentUserInfo: userInfo,
                    submit: { self.updateUserInfo(userInfo: $0) }
                    )))
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message,
                    submit: { self.updateUserInfo(userInfo: $0) }
                    )))
            }
        }
    }
    
    private func updateUserInfo(userInfo: UserInfo) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.updateUserName(userName: userInfo.name) { result in
            switch (result) {
            case .successWithData: break
            case .success:
                ESPMobileAPI.updateUserEmail(userEmail: userInfo.email) { result in
                    switch (result) {
                    case .successWithData: break
                    case .success: self.viewController.render(state: .success)
                    case .failure(let failure):
                        self.viewController.render(state: .failure(.init(
                            message: failure.message,
                            submit: { self.updateUserInfo(userInfo: $0) }
                            )))
                    }
                }
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(
                    message: failure.message,
                    submit: { self.updateUserInfo(userInfo: $0) }
                )))
            }
        }
    }
}
