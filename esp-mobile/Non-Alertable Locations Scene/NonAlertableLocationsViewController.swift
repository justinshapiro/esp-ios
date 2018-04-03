//
//  NonAlertableLocationsViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/8/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class NonAlertableLocationsViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case preInitial(PreInitial)
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct PreInitial {
            let invokeDeleteAlertable: (String) -> Void
            let invokeReadyForUpdate: () -> Void
        }
        
        struct Initial {
            let currentLocations: [Location]
        }
        
        struct Failure {
            let message: String
        }
    }
    
    // MARK: IBOutlets
    
    @IBAction private func globalAlertDisable(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(true, forKey: "shouldNotSendNotifications")
            UserDefaults.standard.synchronize()
            
            shouldDisableExceptionCells = true
        } else {
            UserDefaults.standard.removeObject(forKey: "shouldNotSendNotifications")
            UserDefaults.standard.synchronize()
            
            shouldDisableExceptionCells = false
        }
        
        tableView.reloadData()
    }
    
    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak private var waitingIndicator: UIActivityIndicatorView! {
        didSet {
            waitingIndicator.stopAnimating()
            waitingIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    @IBOutlet weak private var effectiveErrorView: UIView! {
        didSet {
            effectiveErrorView.layer.cornerRadius = 5
            effectiveErrorView.layer.shadowColor = UIColor.black.cgColor
            effectiveErrorView.layer.shadowOpacity = 0.5
            effectiveErrorView.layer.shadowRadius = 1
            effectiveErrorView.layer.shadowOffset = CGSize(width: 3, height: 3)
        }
    }
    
    @IBOutlet weak private var errorView: UIView!
    @IBOutlet weak private var errorMessage: UILabel!
    @IBAction private func errorDismissal(_ sender: UIButton) {
        errorView.isHidden = true
    }
    
    // MARK: Properties
    
    private var locationsForCell: [[String: String]] = []
    private var shouldDisableExceptionCells = false
    private var invokeDeleteAlertable: ((String) -> Void)?
    private var invokeReadyForUpdate: (() -> Void)?
    
    // MARK: Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        waitingIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        invokeReadyForUpdate?()
    }

    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch (state) {
            case .preInitial(let preInitial): self.renderPreInitialState(state: preInitial)
            case .initial(let initial):       self.renderInitialState(state: initial)
            case .waiting:                    self.renderWaitingState()
            case .failure(let failure):       self.renderFailureState(state: failure)
            case .success:                    self.renderSuccessState()
            }
        }
    }
    
    private func renderPreInitialState(state: ViewModel.PreInitial) {
        invokeDeleteAlertable = state.invokeDeleteAlertable
        invokeReadyForUpdate = state.invokeReadyForUpdate
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        locationsForCell = state.currentLocations.tabularRepresentation()
        
        if (UserDefaults.standard.value(forKey: "shouldNotSendNotifications") as? Bool) != nil {
            shouldDisableExceptionCells = true
        }
        
        tableView.reloadData()
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        
        errorMessage.text = state.message
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
    }
}

// MARK: UITableViewDelegate / UITableViewDataSource

extension NonAlertableLocationsViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        return "Non-Alertable Locations:"
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if !shouldDisableExceptionCells {
            let delete = UITableViewRowAction(style: .default, title: "Make Alertable") { action, index in
                self.invokeDeleteAlertable?(self.locationsForCell[indexPath.row]["id"]!)
            }
            
            delete.backgroundColor = UIColor(
                red: 0,
                green: 211 / 255,
                blue: 0,
                alpha: 1
            )
            
            return [delete]
        } else {
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "disableAlertsCell", for: indexPath) as! DisableAlertsCell
            
            if shouldDisableExceptionCells {
                cell.disableAlertsSwitch.isOn = true
            } else {
                cell.disableAlertsSwitch.isOn = false
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "exceptionCell", for: indexPath) as! ExceptionCell
        
        cell.exceptionName.text = locationsForCell[indexPath.row]["name"]!
        
        let limitedLatitude = Location.limitDigits(locationsForCell[indexPath.row]["latitude"]!, to: 5)
        let limitedLongitude = Location.limitDigits(locationsForCell[indexPath.row]["longitude"]!, to: 5)
        cell.exceptionLocation.text = "Geolocation: \(limitedLatitude), \(limitedLongitude)"
        
        if shouldDisableExceptionCells {
            cell.isUserInteractionEnabled = false
            cell.exceptionLocation.alpha = 0.5
            cell.exceptionName.alpha = 0.5
            cell.exceptionIcon.alpha = 0.5
        } else {
            cell.isUserInteractionEnabled = true
            cell.exceptionLocation.alpha = 1
            cell.exceptionName.alpha = 1
            cell.exceptionIcon.alpha = 1
        }
        
        return cell
    }
}

final class DisableAlertsCell: UITableViewCell {
    @IBOutlet weak fileprivate var disableAlertsSwitch: UISwitch!
}

final class ExceptionCell: UITableViewCell {
    @IBOutlet weak fileprivate var exceptionName: UILabel!
    @IBOutlet weak fileprivate var exceptionLocation: UILabel!
    @IBOutlet weak fileprivate var exceptionIcon: UIImageView!
}
