//
//  CreateAccountViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/11/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class CreateAccountViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let submit: (UserInfo) -> ()
        }
        
        struct Failure {
            let message: String
            let submit: (UserInfo) -> ()
        }
    }
    
    @IBOutlet weak private var firstName: UITextField!
    @IBOutlet weak private var lastName: UITextField!
    @IBOutlet weak private var email: UITextField!
    @IBOutlet weak private var username: UITextField!
    @IBOutlet weak private var password: UITextField!
    @IBOutlet weak private var confirmPassword: UITextField!
    
    @IBAction private func willCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBOutlet weak private var facebookButton: UIButton! {
        didSet {
            facebookButton.layer.masksToBounds = true
            facebookButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak private var createAccountButton: UIButton! {
        didSet {
            createAccountButton.layer.cornerRadius = 5
        }
    }
    
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
    
    @IBAction private func textFieldSelected(_ sender: UITextField) {
        activeTag = sender.tag
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
    @IBAction private func editingDidEnd(_ sender: UITextField) {
        activeTag = sender.tag
        
        sender.resignFirstResponder()
    }
    
    // MARK: Properties
    
    // storage for the height of the keyboard so we don't loose it due to asyncronous events
    private var appKeyboardSize: CGFloat?
    private var activeTag: Int = 0
    private var createAccountAction: Target? {
        didSet {
            createAccountButton.addTarget(createAccountAction, action: #selector(Target.action), for: .touchUpInside)
        }
    }
    
    // MARK: Overrides
    
    // Dismisses keyboard when the user touches outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observers that facilitate adjusting the view when the keyboard is present
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: Selector functions that adjust the view based on the visibility of the keyboard
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if activeTag > 2 {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if appKeyboardSize == nil {
                    appKeyboardSize = keyboardSize.height
                }
            
                if view.frame.origin.y == 0 {
                    view.frame.origin.y -= appKeyboardSize! / 1.5
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if activeTag > 2 {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if appKeyboardSize == nil {
                    appKeyboardSize = keyboardSize.height
                }
                
                if view.frame.origin.y != 0 {
                    view.frame.origin.y += appKeyboardSize! / 1.5
                }
            }
        }
    }
    
    // MARK: State configurations
    
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
        firstName.isEnabled = true
        lastName.isEnabled = true
        email.isEnabled = true
        username.isEnabled = true
        password.isEnabled = true
        confirmPassword.isEnabled = true
        errorView.isHidden = true
        waitingIndicator.stopAnimating()
        
        createAccountAction = Target { [unowned self] _ in
            state.submit(UserInfo(
                name: self.firstName.text! + " " + self.lastName.text!,
                email: self.email.text!,
                username: self.username.text!,
                password: self.password.text!,
                confirmPassword: self.confirmPassword.text!,
                oldPassword: ""
            ))
        }
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        firstName.isEnabled = false
        lastName.isEnabled = false
        email.isEnabled = false
        username.isEnabled = false
        password.isEnabled = false
        confirmPassword.isEnabled = false
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        firstName.isEnabled = true
        lastName.isEnabled = true
        email.isEnabled = true
        username.isEnabled = true
        password.isEnabled = true
        confirmPassword.isEnabled = true
        
        errorView.isHidden = false
        errorMessage.text = state.message
    }
    
    private func renderSuccessState() {
        waitingIndicator.startAnimating()
        firstName.isEnabled = true
        lastName.isEnabled = true
        email.isEnabled = true
        username.isEnabled = true
        password.isEnabled = true
        confirmPassword.isEnabled = true
        errorView.isHidden = true
        
        performSegue(withIdentifier: "implicitLogin", sender: self)
    }
}
