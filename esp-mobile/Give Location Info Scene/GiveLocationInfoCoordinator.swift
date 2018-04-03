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
    @IBOutlet weak private var viewController: GiveLocationInfoViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        viewController.render(state: .initial(.init(submit: { self.addLocation(location: $0) })))
    }
    
    private func addLocation(location: Location) {
        viewController.render(state: .waiting)
        
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
