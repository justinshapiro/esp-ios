//
//  AddLocationsCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/7/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import MapKit
import GooglePlaces

final class AddLocationCoordinator: NSObject, CLLocationManagerDelegate {
    private typealias ViewModel = AddLocationViewController.ViewModel
    @IBOutlet weak private var viewController: AddLocationViewController!
    
    private var locationManager: CLLocationManager!
    private let placesClient = GMSPlacesClient.shared()
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        
        // determine current location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func placePredictions(for query: String, _ completion: @escaping ([Location]) -> Void) {
        viewController.render(state: .waiting)
        let filter = GMSAutocompleteFilter()
        filter.type = query.components(separatedBy: " ")[0].rangeOfCharacter(from: .decimalDigits) != nil ? .address : .establishment
        placesClient.autocompleteQuery(query, bounds: nil, filter: filter) { (results, error) in
            if error != nil {
                completion([])
                self.viewController.render(state: .pendingSearchSelection)
                print(error!)
            } else {
                let dispatchGroup = DispatchGroup()
                var predictions: [Location] = []
                results!.enumerated().forEach { (i, result) in
                    dispatchGroup.enter()
                    
                    if let placeID = result.placeID {
                        self.placesClient.lookUpPlaceID(placeID) { (place, error) -> Void in
                            if let place = place, error == nil {
                                predictions.append(Location(
                                    latitude: place.coordinate.latitude,
                                    longitude: place.coordinate.longitude,
                                    name: place.name,
                                    address: place.formattedAddress ?? "",
                                    locationID: place.placeID,
                                    phoneNumber: place.phoneNumber ?? "",
                                    category: "custom",
                                    photoRef: nil,
                                    alertable: nil,
                                    description: "\(i)"
                                ))
                                
                                dispatchGroup.leave()
                            } else {
                                dispatchGroup.leave()
                            }
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.viewController.render(state: .pendingSearchSelection)
                    completion(predictions.sorted { $0.description! > $1.description! })
                }
            }
        }
    }
    
    private func addLocation(location: Location) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.addCustomLocation(location: location) {
            switch ($0) {
            case .successWithData: break
            case .success: self.viewController.render(state: .success)
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(message: failure.message)))
            }
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let searchResultsQuery = { (query: String, completion: @escaping ([Location]) -> Void) in
            self.placePredictions(for: query) {
                completion($0)
            }
        }
        
        let addPreselectedLocation = { (location: Location) in
            self.addLocation(location: location)
        }
        
        viewController.render(state: .initial(.init(
            userLocation: locations[0] as CLLocation,
            searchResultsQuery: searchResultsQuery,
            addPreselectedLocation: addPreselectedLocation
            )))
        
        manager.stopUpdatingLocation()
    }
}
