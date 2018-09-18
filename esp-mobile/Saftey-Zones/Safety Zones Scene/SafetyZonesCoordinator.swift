//
//  SafetyZonesCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/27/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import MapKit

final class SafetyZonesCoordinator: NSObject, CLLocationManagerDelegate {
    private typealias ViewModel = SafetyZonesViewController.ViewModel
    @IBOutlet private var viewController: SafetyZonesViewController!
    
    private var locationManager: CLLocationManager!
    private var invokeGetLocation: ((String, @escaping (Location?) -> Void) -> Void)!
    
    override func awakeFromNib() {
        if let distressMode = UserDefaults.standard.value(forKey: "distressMode") as? Bool, distressMode {
            viewController.navigationController?.navigationBar.barTintColor = .red
            viewController.navigationItem.leftBarButtonItem = nil
        } else {
            viewController.navigationItem.rightBarButtonItem = nil
        }
        
        viewController.loadViewIfNeeded()
        
        invokeGetLocation = { (locationID: String, _ completion: @escaping (Location?) -> Void) in
            self.getLocation(locationID: locationID) {
                completion($0)
            }
        }
        
        viewController.forceWaitingState(with: "Loading nearest safety-zones...")
        
        // determine current location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func prepareInitialState(region: MKCoordinateRegion, userLocation: CLLocation) {
        let userLatitude = String(userLocation.coordinate.latitude as Double)
        let userLongitude = String(userLocation.coordinate.longitude as Double)
        
        ESPMobileAPI.safetyZones(latitude: userLatitude, longitude: userLongitude, radius: String(milesToMeters(20))) { result in
            switch result {
            case .success: break
            case .successWithData(let data):
                guard let locations = data.object as? [Location] else { return }
                
                if UserDefaults.standard.value(forKey: "User Name") == nil {
                    ESPMobileAPI.getUserInfo { result in
                        switch result {
                        case .success: break
                        case .successWithData(let data):
                            guard let userInfo = data.object as? UserInfo else { return }
                            
                            // save user info to UserDefaults
                            UserDefaults.standard.set(userInfo.name, forKey: "User Name")
                            UserDefaults.standard.set(userInfo.email, forKey: "User Email")
                            UserDefaults.standard.synchronize()
                            
                        case .failure(let failure): self.viewController.render(state: ViewModel.failure(.init(message: failure.message)))
                        }
                    }
                }
                
                self.viewController.render(state: ViewModel.initial(.init(
                    userLocation: userLocation,
                    locations: locations
                )))
            case .failure(let failure): self.viewController.render(state: ViewModel.failure(.init(message: failure.message)))
            }
        }
    }
    
    private func getLocation(locationID: String, _ completion: @escaping (Location?) -> Void) {
        viewController.render(state: .waitingWithFunctionality)
        
        ESPMobileAPI.getLocation(locationID: locationID) {
            switch ($0) {
            case .success: break
            case .successWithData(let data):
                self.viewController.render(state: .success)
                completion(data.object as? Location)
            case .failure(let failure): self.viewController.render(state: .failure(.init(message: failure.message)))
                completion(nil)
            }
        }
    }
    
    // MARK: - Helper methods
    
    fileprivate func milesToMeters(_ miles: Int) -> Int {
        return Int(Double(miles) * 1609.344)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        viewController.render(state: .preInitial(.init(
            invokeGetLocation: invokeGetLocation,
            invokeReadyForUpdate: {
                self.viewController.render(state: .waitingWithFunctionality)
                self.prepareInitialState(region: region, userLocation: userLocation) }
            )))
        
        prepareInitialState(region: region, userLocation: userLocation)
        
        manager.stopUpdatingLocation()
    }
}
