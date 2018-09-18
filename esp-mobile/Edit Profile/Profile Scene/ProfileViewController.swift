//
//  ProfileViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/30/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let currentUserInfo: UserInfo
            let submit: (UserInfo) -> ()
        }
        
        struct Failure {
            let message: String
            let submit: (UserInfo) -> ()
        }
    }
    
    // MARK: - IBOutlets

    @IBOutlet private var firstName: UITextField! {
        didSet {
            firstName.isEnabled = false
        }
    }
    
    @IBOutlet private var lastName: UITextField! {
        didSet {
            lastName.isEnabled = false
        }
    }
    
    @IBOutlet private var email: UITextField! {
        didSet {
            email.isEnabled = false
        }
    }
    
    @IBOutlet private var username: UITextField! {
        didSet {
            username.isEnabled = false
            username.alpha = 0.5
        }
    }
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet private var fieldViews: [UIView]! {
        didSet {
            for fieldView in fieldViews {
                fieldView.layer.borderWidth = 1
                fieldView.layer.borderColor = UIColor.lightGray.cgColor
            }
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
    
    @IBOutlet private var updateButton: UIBarButtonItem!
    
    // Dismisses keyboard when "Done" button is clicked and performs cleanup
    @IBAction func editingDidEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: - Properties
    
    private var updateAction: Target? {
        didSet {
            updateButton.addTarget(updateAction, action: #selector(Target.action))
        }
    }
    
    // MARK: - Overrides
    
    // Dismisses keyboard when the user touches outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        errorView.isHidden = true
        waitingIndicator.stopAnimating()
        
        let name = state.currentUserInfo.name.components(separatedBy: " ")
        firstName.text = name[0]
        lastName.text = name[1]
        email.text = state.currentUserInfo.email
        username.text = state.currentUserInfo.username
        
        firstName.isEnabled = true
        lastName.isEnabled = true
        email.isEnabled = true
        
        updateAction = Target { [unowned self] _ in
            state.submit(UserInfo(
                name: self.firstName.text! + " " + self.lastName.text!,
                email: self.email.text!,
                username: self.username.text!,
                password: "",
                confirmPassword: "",
                oldPassword: ""
            ))
        }
    }
    
    private func renderWaitingState() {
        errorView.isHidden = true
        waitingIndicator.startAnimating()
        firstName.isEnabled = false
        lastName.isEnabled = false
        email.isEnabled = false
        
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        errorView.isHidden = false
        waitingIndicator.stopAnimating()
        firstName.isEnabled = true
        lastName.isEnabled = true
        email.isEnabled = true
        
        errorMessage.text = state.message
        effectiveErrorView.layer.backgroundColor = UIColor(
            red: 231 / 255,
            green: 76 / 255,
            blue: 61 / 255,
            alpha: 1
        ).cgColor
        
        updateAction = Target { [unowned self] _ in
            state.submit(UserInfo(
                name: self.firstName.text! + " " + self.lastName.text!,
                email: self.email.text!,
                username: self.username.text!,
                password: "",
                confirmPassword: "",
                oldPassword: ""
            ))
        }
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        firstName.isEnabled = true
        lastName.isEnabled = true
        email.isEnabled = true
        username.isEnabled = true
        
        errorView.isHidden = false
        errorMessage.text = "Successfully updated your profile information"
        effectiveErrorView.backgroundColor = UIColor(
            red: 0,
            green: 211 / 255,
            blue: 0,
            alpha: 1
        )
    }
    
     func modalSuccessTransition() {
        renderSuccessState()
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "changePasswordCell", for: indexPath)
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.lightGray.cgColor
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "deleteAccountCell", for: indexPath)
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
}
