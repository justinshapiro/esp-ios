//
//  DeleteAccountViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/19/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class DeleteAccountViewController: UIViewController {
    
    // MARK: - View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let invokeDeleteAccount: () -> Void
        }
        
        struct Failure {
            let message: String
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
    
    @IBAction private func deleteButton(_ sender: UIButton) {
        invokeDeleteAccount?()
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
    
    
    @IBOutlet private var waitingIndicator: UIActivityIndicatorView! {
        didSet {
            waitingIndicator.stopAnimating()
            waitingIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    @IBOutlet private var errorView: UIView!
    @IBOutlet private var errorMessage: UILabel!
    @IBAction private func errorDismissal(_ sender: UIButton) {
        errorView.isHidden = true
    }
    
    // MARK: - Properties
    
    private var invokeDeleteAccount: (() -> Void)?
    
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
        invokeDeleteAccount = state.invokeDeleteAccount
    }
    
    private func renderWaitingState() {
        errorView.isHidden = true
        waitingIndicator.startAnimating()
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        dismiss(animated: false)
        
        navigationController?.popToRootViewController(animated: true)
        
        guard let viewController = presentingViewController?.children[0] as? SafetyZonesViewController else { return }
        viewController.modalSegue(segue: "logOut")
    }
}
