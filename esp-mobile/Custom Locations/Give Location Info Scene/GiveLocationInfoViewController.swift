//
//  GiveLocationInfoViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/7/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class GiveLocationInfoViewController: UIViewController {
    
    // MARK: - View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let submit: (Location) -> ()
        }
        
        struct Failure {
            let message: String
            let submit: (Location) -> ()
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var modalView: UIView! {
        didSet {
            modalView.layer.cornerRadius = 5
            modalView.layer.masksToBounds = false
            modalView.layer.shadowColor = UIColor.black.cgColor
            modalView.layer.shadowOpacity = 0.5
            modalView.layer.shadowOffset = CGSize(width: 7, height: 5)
        }
    }
    
    @IBAction private func dismiss(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBOutlet private var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private var locationField: UILabel!
    @IBOutlet private var nameField: UITextField!
    @IBOutlet private var addressField: UITextField!
    @IBOutlet private var phoneField: UITextField!
    
    @IBOutlet private var fieldViews: [UIView]! {
        didSet {
            for fieldView in fieldViews {
                fieldView.layer.borderWidth = 1
                fieldView.layer.borderColor = UIColor.lightGray.cgColor
                fieldView.layer.shadowColor = UIColor.black.cgColor
                fieldView.layer.shadowRadius = 1
                fieldView.layer.shadowOffset = CGSize(width: 3, height: 3)
                fieldView.layer.shadowOpacity = 0.25
            }
        }
    }
    
    @IBOutlet private var descriptionField: UITextView! {
        didSet {
            descriptionField.delegate = self
            descriptionField.layer.masksToBounds = false
            descriptionField.layer.cornerRadius = 5
            descriptionField.text = textViewPlaceholder
            descriptionField.textColor = UIColor.darkGray
            descriptionField.layer.borderWidth = 1
            descriptionField.layer.borderColor = UIColor.lightGray.cgColor
            descriptionField.layer.shadowColor = UIColor.black.cgColor
            descriptionField.layer.shadowRadius = 1
            descriptionField.layer.shadowOffset = CGSize(width: 3, height: 3)
            descriptionField.layer.shadowOpacity = 0.25
            descriptionField.clipsToBounds = true
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
    
    // Dismisses keyboard when "Done" button is clicked and performs cleanup
    @IBAction private func editingDidEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: - Properties
    
    private let textViewPlaceholder = "Description (Optional)"
     var latitudeFromMap: Double?
     var longitudeFromMap: Double?
    private var saveLocationAction: Target? {
        didSet {
            saveButton.addTarget(saveLocationAction, action: #selector(Target.action), for: .touchUpInside)
        }
    }
    
    // MARK: - Overrides
    
    // Dismisses keyboard when the user touches outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = UIColor.darkGray
        }
        
        descriptionField.resignFirstResponder()
    }
    
    // MARK: - State configuration
    
     func render(state: ViewModel) {
        switch state {
        case .initial(let initial): renderInitialState(state: initial)
        case .waiting:              renderWaitingState()
        case .failure(let failure): renderFailureState(state: failure)
        case .success:              renderSuccessState()
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        
        let displayLatitude = Location.limitDigits(String(latitudeFromMap!), to: 5)
        let displayLongitude = Location.limitDigits(String(longitudeFromMap!), to: 5)
        locationField.text = "Selected Location: \(displayLatitude), \(displayLongitude)"
        
        saveLocationAction = Target { [unowned self] _ in
            state.submit(Location(
                latitude: self.latitudeFromMap!,
                longitude: self.longitudeFromMap!,
                name: self.nameField.text!,
                address: self.addressField.text!,
                locationID: "",
                phoneNumber: self.phoneField.text!,
                category: "custom",
                photoRef: nil,
                alertable: "true",
                description: self.descriptionField.text
            ))
        }
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        
        saveLocationAction = Target { [unowned self] _ in
            state.submit(Location(
                latitude: self.latitudeFromMap!,
                longitude: self.longitudeFromMap!,
                name: self.nameField.text!,
                address: self.addressField.text!,
                locationID: "",
                phoneNumber: self.phoneField.text!,
                category: "custom",
                photoRef: nil,
                alertable: "true",
                description: self.descriptionField.text
            ))
        }
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        
        dismiss(animated: true)
        
        guard let viewController = presentingViewController?.children[2] as? AddLocationViewController else { return }
        viewController.modalSuccessTransition()
    }
}
