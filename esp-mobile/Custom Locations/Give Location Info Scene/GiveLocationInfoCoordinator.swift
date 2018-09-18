//
//  GiveLocationInfoCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/7/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class GiveLocationInfoCoordinator: NSObject {
    private typealias ViewModel = GiveLocationInfoViewController.ViewModel
    @IBOutlet private var viewController: GiveLocationInfoViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        viewController.render(state: .initial(.init(submit: { self.addLocation(location: $0) })))
    }
    
    private func addLocation(location: Location) {
        viewController.render(state: .waiting)
        
        if location.address.isEmpty {
            viewController.render(state: .failure(.init(
                message: "An address is required.",
                submit: { self.addLocation(location: $0) }
            )))
        } else if location.name.isEmpty {
            viewController.render(state: .failure(.init(
                message: "A location name is required.",
                submit: { self.addLocation(location: $0) }
            )))
        } else if location.phoneNumber.isEmpty {
            viewController.render(state: .failure(.init(
                message: "A phone number is required.",
                submit: { self.addLocation(location: $0) }
            )))
        } else {
            ESPMobileAPI.addCustomLocation(location: location) {
                switch ($0) {
                case .successWithData: break
                case .success: self.viewController.render(state: .success)
                case .failure(let failure):
                    self.viewController.render(state: .failure(.init(
                        message: failure.message,
                        submit: { self.addLocation(location: $0) }
                        )))
                }
            }
        }
    }
}
