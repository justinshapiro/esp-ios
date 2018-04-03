//
//  CustomLocationsCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/7/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

final class CustomLocationsCoordinator: NSObject {
    private typealias ViewModel = CustomLocationsViewController.ViewModel
    @IBOutlet weak private var viewController: CustomLocationsViewController!
    
    private var invokeDeleteCustomLocation: ((String) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeDeleteCustomLocation = { (locationID: String) in
            self.deleteCustomLocation(locationID: locationID)
        }
        
        viewController.render(state: .preInitial(.init(
            invokeDeleteCustomLocation: invokeDeleteCustomLocation,
            invokeReadyForUpdate: { self.getCustomLocations() }
        )))
    }
    
    private func getCustomLocations() {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.getUserLocations() {
            switch ($0) {
            case .success: break
            case .successWithData(let data):
                self.viewController.render(state: .initial(.init(currentLocations: data.object as! [Location])))
            case .failure(let failure): self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
    
    private func deleteCustomLocation(locationID: String) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.deleteCustomLocation(locationID: locationID) {
            switch ($0) {
            case .successWithData: break
            case .success:
                // reload contacts into view
                self.getCustomLocations()
            case .failure(let failure): self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
}
