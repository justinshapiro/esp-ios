//
//  LogOutCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/25/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import Foundation

final class LogOutCoordinator: NSObject {
    private typealias ViewModel = LogOutViewController.ViewModel
    @IBOutlet private var viewController: LogOutViewController!
    
    private var safetyZonesViewController: SafetyZonesViewController?
    private var invokeStoreParentReference: ((LogOutViewController) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeStoreParentReference = { (viewController: LogOutViewController) in
            self.storeParentReference(viewController: viewController)
        }
        
        viewController.render(state: .initial(.init(
            invokeLogOut: { self.logOut() },
            invokeStoreParentReference: invokeStoreParentReference
        )))
    }
    
    private func storeParentReference(viewController: LogOutViewController) {
        safetyZonesViewController = viewController.presentingViewController?.children[0] as? SafetyZonesViewController
    }
    
    private func logOut() {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.logout {
            switch $0 {
            case .successWithData: break
            case .success:
                self.safetyZonesViewController?.modalSegue(segue: "logOut")
            case .failure(let failure):
                self.safetyZonesViewController?.forceFailureState(with: failure.message)
            }
        }
    }
}
