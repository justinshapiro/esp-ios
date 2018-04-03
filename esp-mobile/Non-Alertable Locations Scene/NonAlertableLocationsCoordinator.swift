//
//  NonAlertableLocationsCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/8/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class NonAlertableLocationsCoordinator: NSObject {
    private typealias ViewModel = NonAlertableLocationsViewController.ViewModel
    @IBOutlet weak fileprivate var viewController: NonAlertableLocationsViewController!
    
    private var invokeDeleteAlertable: ((String) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeDeleteAlertable = { (locationID: String) in
            self.deleteAlertable(locationID: locationID)
        }
        
        viewController.render(state: .preInitial(.init(
            invokeDeleteAlertable: invokeDeleteAlertable,
            invokeReadyForUpdate: { self.getAllAlerts() }
        )))
    }
    
    private func getAllAlerts() {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.getAlerts {
            switch ($0) {
            case .success: break
            case .successWithData(let data):
                self.viewController.render(state: .initial(.init(
                    currentLocations: data.object as! [Location]
                )))
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
    
    private func deleteAlertable(locationID: String) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.deleteAlert(locationID: locationID) {
            switch ($0) {
            case .successWithData: break
            case .success: self.getAllAlerts()
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
}
