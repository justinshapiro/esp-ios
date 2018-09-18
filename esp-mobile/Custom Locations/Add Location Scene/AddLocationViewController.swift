//
//  AddLocationsViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/7/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit
import MapKit

final class AddLocationViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - View Model

    enum ViewModel {
        case initial(Initial)
        case waiting
        case pendingSearchSelection
        case failure(Failure)
        case success
        
        struct Initial {
            let userLocation: CLLocation
            let searchResultsQuery: (String, @escaping ([Location]) -> Void) -> Void
            let addPreselectedLocation: (Location) -> Void
        }
        
        struct Failure {
            let message: String
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
        }
    }
    
    @IBOutlet private var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBAction private func doReset(_ sender: UIButton) {
        setRegion(from: 1, with: userLocation)
        searchBar.text = nil
    }
    
    @IBOutlet private var resetButton: UIButton! {
        didSet {
            resetButton.isEnabled = false
        }
    }
    
    @IBOutlet private var doneButton: UIButton! {
        didSet {
            doneButton.isEnabled = false
        }
    }
    
    @IBOutlet private var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    @IBOutlet private var waitingIndicator: UIActivityIndicatorView! {
        didSet {
            waitingIndicator.stopAnimating()
            waitingIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    @IBOutlet private var effectiveErrorView: UIView! {
        didSet {
            effectiveErrorView.layer.cornerRadius = 5
            effectiveErrorView.layer.shadowColor = UIColor.black.cgColor
            effectiveErrorView.layer.shadowOpacity = 0.5
            effectiveErrorView.layer.shadowRadius = 1
            effectiveErrorView.layer.shadowOffset = CGSize(width: 3, height: 3)
        }
    }
    
    @IBOutlet private var errorView: UIView!
    @IBOutlet private var errorMessage: UILabel!
    @IBAction private func errorDismissal(_ sender: UIButton) {
        errorView.isHidden = true
    }
    
    // MARK: - Properties
    
    private var searchResults: [Location] = []
    private var searchResultsQuery: ((String, @escaping ([Location]) -> Void) -> Void)?
    private var addPreselectedLocation: ((Location) -> Void)?
    private var userLocation: CLLocation?
    
    // MARK: - Overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addLocationInfo" {
            let viewController = segue.destination as? GiveLocationInfoViewController
            viewController?.latitudeFromMap = mapView.centerCoordinate.latitude
            viewController?.longitudeFromMap = mapView.centerCoordinate.longitude
        }
    }
    
    // MARK: - Helper functions
    
    private func setRegion(from miles: Int, with userLocation: CLLocation?) {
        if userLocation != nil {
            let scalingFactor = abs((cos(2 * .pi * userLocation!.coordinate.latitude / 360.0)))
            
            let span = MKCoordinateSpan(
                latitudeDelta: Double(miles) / 69.0,
                longitudeDelta:  Double(miles) / (scalingFactor * 69.0)
            )
            
            let region = MKCoordinateRegion(
                center: userLocation!.coordinate,
                span: span
            )
            
            self.mapView.setRegion(region, animated: false)
        }
    }
    
    // MARK: - State configuration
    
     func render(state: ViewModel) {
        switch state {
        case .initial(let initial):   renderInitialState(state: initial)
        case .waiting:                renderWaitingState()
        case .pendingSearchSelection: renderPendingSearchSelectionState()
        case .failure(let failure):   renderFailureState(state: failure)
        case .success:                renderSuccessState()
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        userLocation = state.userLocation
        setRegion(from: 1, with: userLocation)
        
        self.searchResultsQuery = state.searchResultsQuery
        self.addPreselectedLocation = state.addPreselectedLocation
        
        resetButton.isEnabled = true
        doneButton.isEnabled = true
        errorView.isHidden = true
    }
    
    private func renderWaitingState() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        waitingIndicator.startAnimating()
        errorView.isHidden = true
    }
    
    private func renderPendingSearchSelectionState() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        resetButton.isEnabled = true
        doneButton.isEnabled = true
        tableView.isHidden = false
    }
    
    private func renderSuccessState() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        resetButton.isEnabled = false
        doneButton.isEnabled = false
        errorView.isHidden = true
        
        navigationController?.popViewController(animated: true)
    }
    
     func modalSuccessTransition() {
        renderSuccessState()
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count == 0 ? 1 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count > 0 && indexPath.row != searchResults.count {
            tableView.allowsSelection = true
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressCell
            cell.locationName.text = searchResults[indexPath.row].name
            cell.locationAddress.text = searchResults[indexPath.row].address
            return cell
        }
        
        tableView.allowsSelection = false
        return tableView.dequeueReusableCell(withIdentifier: "noResultsCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        doneButton.isEnabled = false
        resetButton.isEnabled = false
        tableView.isHidden = true
        
        let selectedLocation = searchResults[indexPath.row]
        setRegion(from: 1, with: CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude))
        addPreselectedLocation?(selectedLocation)
    }
}

// MARK: - UISearchBarDelegate

extension AddLocationViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        searchResults = []
        searchBar.text = nil
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let query = searchBar.text, !query.replacingOccurrences(of: " ", with: "").isEmpty else {
            tableView.isHidden = true
            return
        }
        
        self.searchResults = []
        
        searchResultsQuery?(query) {
            self.searchResults = $0
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }
        
        self.tableView.reloadData()
        self.tableView.isHidden = false
    }
}

final class AddressCell: UITableViewCell {
    @IBOutlet fileprivate var locationName: UILabel!
    @IBOutlet fileprivate var locationAddress: UILabel!
}
