//
//  LoginSceneViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/24/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class LoginSceneViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case preInitial(PreInitial)
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct PreInitial {
            let invokeReadyForUpdate: () -> Void
        }
        
        struct Initial {
            let rememberedUsername: String
            let rememberedPassword: String
            let submit: (Credentials) -> ()
        }
        
        struct Failure {
            let message: String
            let submit: (Credentials) -> ()
        }
        
        struct Credentials {
            let loginID: String
            let password: String
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var usernameView: UIView! {
        didSet {
            usernameView.layer.borderWidth = 1
            usernameView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBOutlet weak private var usernameIcon: UIImageView!
    @IBOutlet weak private var usernameField: UITextField!
    @IBOutlet weak private var passwordView: UIView! {
        didSet {
            passwordView.layer.borderWidth = 1
            passwordView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @IBOutlet weak private var passwordField: UITextField!
    @IBOutlet weak private var passwordIcon: UIImageView!
    @IBOutlet weak private var loginButton: UIButton! { didSet { loginButton.layer.cornerRadius = 5 } }
    @IBOutlet weak private var signUpButton: UIButton!

    @IBOutlet weak private var facebook_button: UIButton! {
        didSet {
            facebook_button.layer.masksToBounds = true
            facebook_button.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak private var waitingIndicator: UIActivityIndicatorView! {
        didSet {
            waitingIndicator.stopAnimating()
        }
    }
    
    // Dismisses keyboard when "Done" button is clicked and performs cleanup
    @IBAction private func editingDidEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
    
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
    
    @IBAction func goToDistressMode(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "distressMode")
        performSegue(withIdentifier: "login", sender: self)
    }
    
    
    // MARK: Properties
    
    private var invokeReadyForUpdate: (() -> Void)?
    private var needsUpdate = false
    private var regularLoginAction: Target? {
        didSet {
            loginButton.addTarget(regularLoginAction, action: #selector(Target.action), for: .touchUpInside)
        }
    }
    
    // MARK: Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needsUpdate {
            waitingIndicator?.startAnimating()
        }
        
        UserDefaults.standard.set(false, forKey: "distressMode")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needsUpdate {
            usernameField.text = nil
            passwordField.text = nil
            invokeReadyForUpdate?()
        }
    }
    
    // Dismisses keyboard when the user touches outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        invokeReadyForUpdate = state.invokeReadyForUpdate
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        loginButton.isEnabled = true
        loginButton.alpha = 1
        signUpButton.isEnabled = true
        signUpButton.alpha = 1
        usernameField.isEnabled = true
        usernameField.alpha = 1
        passwordField.isEnabled = true
        passwordField.alpha = 1
        errorView.isHidden = true
        
        regularLoginAction = Target { [unowned self] _ in
            state.submit(ViewModel.Credentials(
                loginID: self.usernameField.text!,
                password: self.passwordField.text!
            ))
        }
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        loginButton.isEnabled = false
        loginButton.alpha = 0.25
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.25
        usernameField.isEnabled = false
        usernameField.alpha = 0.25
        passwordField.isEnabled = false
        passwordField.alpha = 0.25
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        loginButton.isEnabled = true
        loginButton.alpha = 1
        signUpButton.isEnabled = true
        signUpButton.alpha = 1
        usernameField.isEnabled = true
        usernameField.alpha = 1
        passwordField.isEnabled = true
        passwordField.alpha = 1
        errorView.isHidden = false
        errorMessage.text = state.message
        
        regularLoginAction = Target { [unowned self] _ in
            state.submit(ViewModel.Credentials(
                loginID: self.usernameField.text!,
                password: self.passwordField.text!
            ))
        }
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        regularLoginAction = nil
        errorView.isHidden = true
        
        needsUpdate = true
        
        performSegue(withIdentifier: "login", sender: self)
    }
}
