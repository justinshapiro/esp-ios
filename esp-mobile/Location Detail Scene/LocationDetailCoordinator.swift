//
//  LocationDetailCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/21/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import UIKit

final class LocationDetailCoordinator: NSObject {
    private typealias ViewModel = LocationDetailViewController.ViewModel
    @IBOutlet weak private var viewController: LocationDetailViewController!
    
    private var invokeUpdateAlert: ((String, String) -> Void)!
    private var invokeGetLocationInfo: ((String, String?) -> Void)!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        invokeUpdateAlert = { (locationID: String, alertValue: String) in
            self.updateAlert(for: locationID, alertValue: alertValue)
        }
        
        invokeGetLocationInfo = { (locationID: String, photoRef: String?) in
            self.getLocationInfo(locationID: locationID, photoRef: photoRef)
        }
        
        viewController.render(state: .initial(.init(
            alertValue: true,
            locationPhoto: nil,
            invokeUpdateAlert: invokeUpdateAlert,
            invokeGetLocationInfo: invokeGetLocationInfo
            )))
    }
    
    private func getLocationInfo(locationID: String, photoRef: String?) {
        viewController.render(state: .waiting)
        
        if photoRef != nil {
            ESPMobileAPI.getLocationPhoto(photoRef: photoRef!) {
                var locationPhoto: UIImage?
                switch ($0) {
                case .success: break
                case .successWithData(let data):
                    locationPhoto = data.object as? UIImage
                case .failure:
                    locationPhoto = nil
                }
                
                ESPMobileAPI.getAlerts {
                    var isAlertable = true
                    switch ($0) {
                    case .success: break
                    case .successWithData(let data):
                        let locations = data.object as! [Location]
                        for location in locations {
                            if location.locationID == locationID {
                                isAlertable = false
                                break
                            }
                        }
                        
                        self.viewController.render(state: .initial(.init(
                            alertValue: isAlertable,
                            locationPhoto: locationPhoto,
                            invokeUpdateAlert: self.invokeUpdateAlert,
                            invokeGetLocationInfo: self.invokeGetLocationInfo
                        )))
                    case .failure(let failure):
                        self.viewController.render(state: .failure(.init(message: failure.message)))
                    }
                }
            }
        } else {
            ESPMobileAPI.getAlerts {
                var isAlertable = true
                switch ($0) {
                case .success: break
                case .successWithData(let data):
                    let locations = data.object as! [Location]
                    for location in locations {
                        if location.locationID == locationID {
                            isAlertable = false
                            break
                        }
                    }
                    
                    self.viewController.render(state: .initial(.init(
                        alertValue: isAlertable,
                        locationPhoto: nil,
                        invokeUpdateAlert: self.invokeUpdateAlert,
                        invokeGetLocationInfo: self.invokeGetLocationInfo
                    )))
                case .failure(let failure):
                    self.viewController.render(state: .failure(.init(message: failure.message)))
                }
            }
        }
    }
    
    private func updateAlert(for locationID: String, alertValue: String) {
        viewController.render(state: .waiting, alertUpdate: true)
        
        // first delete alert, if it exists
        ESPMobileAPI.deleteAlert(locationID: locationID) { _ in
            if (alertValue == "false") {
                ESPMobileAPI.addAlert(locationID: locationID, alertable: alertValue) {
                    switch ($0) {
                    case .successWithData: break
                    case .success: self.viewController.render(state: .success)
                    case .failure(let failure): self.viewController.render(state: .failure(.init(message: failure.message)))
                    }
                }
            } else {
                self.viewController.render(state: .success)
            }
        }
    }
}
