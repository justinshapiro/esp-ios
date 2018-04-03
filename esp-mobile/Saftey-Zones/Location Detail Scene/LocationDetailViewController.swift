//
//  LocationDetailViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/21/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class LocationDetailViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let alertValue: Bool
            let locationPhoto: UIImage?
            let invokeUpdateAlert: (String, String) -> Void
            let invokeGetLocationInfo: (String, String?) -> Void
        }
    
        struct Failure {
            let message: String
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var modalView: UIView! {
        didSet {
            modalView.layer.cornerRadius = 5
            modalView.layer.masksToBounds = true
            modalView.layer.shadowColor = UIColor.black.cgColor
            modalView.layer.shadowOpacity = 0.5
            modalView.layer.shadowOffset = CGSize(width: 7, height: 5)
            modalView.layer.borderWidth = 2
            modalView.layer.borderColor = UIColor.black.cgColor
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
    
    @IBOutlet weak private var locationIcon: UIImageView!
    @IBOutlet weak private var locationName: UILabel!
    @IBOutlet weak private var locationAddress: UILabel!
    @IBOutlet weak private var locationPhone: UILabel!
    @IBOutlet weak private var locationType: UILabel!
    @IBOutlet weak private var locationCoordinates: UILabel!
    @IBOutlet weak private var alertsLabel: UILabel!
    @IBOutlet weak private var alertSwitch: UISwitch!
    @IBAction private func alertValueChanged(_ sender: UISwitch) {
        invokeUpdateAlert?(locationFromMap!.locationID, sender.isOn ? "true" : "false")
    }
    
    @IBAction private func dismissal() {
        dismiss(animated: true)
    }
    
    // MARK: Properties
    
    public var locationFromMap: Location?
    private var shouldShowLocationDetail: Bool = false
    private var invokeUpdateAlert: ((String, String) -> Void)?
    private var invokeGetLocationInfo: ((String, String?) -> Void)?
    
    // MARK: Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if locationFromMap == nil {
            dismiss(animated: false)
        } else {
            // we still need to initialize the closures to get the rest of the details about the view
            view.isHidden = !shouldShowLocationDetail
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let location = locationFromMap {
            invokeGetLocationInfo?(location.locationID, location.photoRef)
        }
    }
    
    // MARK: Helper methods
    
    @objc private func callPhoneNumber(sender: UIButton) {
        let callablePhoneNumber = Location.getCallable(phoneNumber: locationPhone.text!)
        if let url = URL(string: "telprompt://\(callablePhoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel, alertUpdate: Bool? = nil) {
        DispatchQueue.main.async {
            switch (state) {
            case .initial(let initial):  self.renderInitialState(state: initial)
            case .waiting:               self.renderWaitingState(alertUpdate: alertUpdate)
            case .failure(let failure):  self.renderFailureState(state: failure)
            case .success:               self.renderSuccessState()
            }
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        alertSwitch.isEnabled = true
        
        locationName.text = locationFromMap!.name
        locationAddress.text = locationFromMap!.address
        locationType.text = Location.capitalize(word: locationFromMap!.category)
        invokeUpdateAlert = state.invokeUpdateAlert
        invokeGetLocationInfo = state.invokeGetLocationInfo
        
        if let photo = state.locationPhoto {
            locationIcon.layer.borderColor = UIColor.black.cgColor
            locationIcon.layer.borderWidth = 1
            locationIcon.layer.cornerRadius = 5
            locationIcon.layer.masksToBounds = false
            locationIcon.layer.shadowColor = UIColor.black.cgColor
            locationIcon.layer.shadowOpacity = 0.5
            locationIcon.layer.shadowOffset = CGSize(width: 4, height: 2)
            locationIcon.image = photo
        } else {
            if locationFromMap!.category == "custom" {
                locationIcon.image = UIImage(named: "custom_location_icon")
            }
        }
        
        view.isHidden = !shouldShowLocationDetail
        if shouldShowLocationDetail {
            (presentingViewController?.childViewControllers[0] as? SafetyZonesViewController)?.waitingIndicator.stopAnimating()
        }
    
        let limitedLatitude = Location.limitDigits(String(locationFromMap!.latitude), to: 5)
        let limitedLongitude = Location.limitDigits(String(locationFromMap!.longitude), to: 5)
        locationCoordinates.text = "\(limitedLatitude), \(limitedLongitude)"
    
        if locationFromMap!.category == "custom" {
            locationPhone.attributedText = NSAttributedString(
                string: Contact.formatPhoneNumber(phoneNumber: locationFromMap!.phoneNumber),
                attributes: [NSAttributedStringKey.underlineStyle : 1]
            )
        } else {
            locationPhone.attributedText = NSAttributedString(
                string: locationFromMap!.phoneNumber,
                attributes: [NSAttributedStringKey.underlineStyle : 1]
            )
        }
        
        if let alertsNotEnabled = UserDefaults.standard.value(forKey: "shouldNotSendNotifications") as? Bool {
            if alertsNotEnabled {
                alertSwitch.isOn = false
                alertSwitch.isEnabled = false
                alertSwitch.alpha = 0.5
                alertsLabel.alpha = 0.5
            } else {
                alertSwitch.isOn = state.alertValue
            }
        } else {
            alertSwitch.isOn = state.alertValue
        }
        
        
        let phoneButton = UIButton(frame: locationPhone.frame)
        phoneButton.addTarget(self, action: #selector(callPhoneNumber), for: .touchUpInside)
        modalView.addSubview(phoneButton)
        
        modalView.isHidden = false
        shouldShowLocationDetail = true
        
        if let distressMode = UserDefaults.standard.value(forKey: "distressMode") as? Bool, distressMode {
            alertSwitch.isHidden = true
            alertsLabel.isHidden = true
        }
    }
    
    private func renderWaitingState(with message: String? = nil, alertUpdate: Bool? = nil) {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
        alertSwitch.isEnabled = false
        
        if alertUpdate != nil && alertUpdate! == true {
            modalView.isHidden = false
        } else {
            modalView.isHidden = true
        }
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        alertSwitch.isEnabled = true
        modalView.isHidden = true
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        alertSwitch.isEnabled = true
        modalView.isHidden = false
    }
}
