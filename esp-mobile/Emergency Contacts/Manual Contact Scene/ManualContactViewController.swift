//
//  ManualContactViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/5/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class ManualContactViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let submit: (Contact) -> ()
        }
        
        struct Failure {
            let message: String
            let submit: (Contact) -> ()
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var firstName: UITextField!
    @IBOutlet weak private var lastName: UITextField!
    @IBOutlet weak private var phone: UITextField!
    
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
    
    @IBOutlet weak private var modalView: UIView! {
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
    
    @IBOutlet weak private var submitButton: UIButton! {
        didSet {
            submitButton.layer.cornerRadius = 5
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
    
    // Dismisses keyboard when "Done" button is clicked and performs cleanup
    @IBAction func editingDidEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: Properties
    
    private var saveContactAction: Target? {
        didSet {
            submitButton.addTarget(saveContactAction, action: #selector(Target.action), for: .touchUpInside)
        }
    }
    
    // MARK: Overrides
    
    // Dismisses keyboard when the user touches outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch (state) {
            case .initial(let initial): self.renderInitialState(state: initial)
            case .waiting:              self.renderWaitingState()
            case .failure(let failure): self.renderFailureState(state: failure)
            case .success:              self.renderSuccessState()
            }
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        
        saveContactAction = Target { [unowned self] _ in
            state.submit(Contact(
                id: nil,
                name: self.firstName.text! + " " + self.lastName.text!,
                phone: self.phone.text!,
                groupID: nil
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
        
        saveContactAction = Target { [unowned self] _ in
            state.submit(Contact(
                id: nil,
                name: self.firstName.text! + " " + self.lastName.text!,
                phone: self.phone.text!,
                groupID: nil
            ))
        }
    }
    
    private func renderSuccessState() {
        dismiss(animated: true)
        
        guard let viewController = presentingViewController!.childViewControllers[2] as? AddContactViewController else { return }
        viewController.modalSuccessTransition()
    }
}
