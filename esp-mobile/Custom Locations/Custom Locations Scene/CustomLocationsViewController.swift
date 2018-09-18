//
//  CustomLocationsViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/7/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class CustomLocationsViewController: UIViewController {
    
    // MARK: - View Model
    
    enum ViewModel {
        case preInitial(PreInitial)
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct PreInitial {
            let invokeDeleteCustomLocation: (String) -> Void
            let invokeReadyForUpdate: () -> Void
        }
        
        struct Initial {
            let currentLocations: [Location]
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
            tableView.tableFooterView = UIView()
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
    
    private var invokeDeleteCustomLocation: ((String) -> Void)?
    private var invokeReadyForUpdate: (() -> Void)?
    private var locationsForCell: [[String: String]] = []
    
    // MARK: - Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        waitingIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        invokeReadyForUpdate?()
    }
    
    // MARK: - State configuration
    
     func render(state: ViewModel) {
        switch state {
        case .preInitial(let preInitial): renderPreInitialState(state: preInitial)
        case .initial(let initial):       renderInitialState(state: initial)
        case .waiting:                    renderWaitingState()
        case .failure(let failure):       renderFailureState(state: failure)
        case .success:                    renderSuccessState()
        }
    }
    
    private func renderPreInitialState(state: ViewModel.PreInitial) {
        invokeDeleteCustomLocation = state.invokeDeleteCustomLocation
        invokeReadyForUpdate = state.invokeReadyForUpdate
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        locationsForCell = state.currentLocations.tabularRepresentation()
        tableView.reloadData()
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension CustomLocationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return locationsForCell.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        
        return "Custom Locations:"
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.invokeDeleteCustomLocation?(self.locationsForCell[indexPath.row]["id"]!)
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "addLocationCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationCell
        
        cell.locationName.text = locationsForCell[indexPath.row]["name"]!
        let limitedLatitude = Location.limitDigits(locationsForCell[indexPath.row]["latitude"]!, to: 5)
        let limitedLongitude = Location.limitDigits(locationsForCell[indexPath.row]["longitude"]!, to: 5)
        cell.locationGeo.text = "Geolocation: " + limitedLatitude + ", " + limitedLongitude
        
        return cell
    }
}

final class LocationCell: UITableViewCell {
    @IBOutlet fileprivate var locationIcon: UIImageView!
    @IBOutlet fileprivate var locationName: UILabel!
    @IBOutlet fileprivate var locationGeo: UILabel!
}
