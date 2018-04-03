//
//  EditContactViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/19/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class EditContactViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case preInitial(PreInitial)
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct PreInitial {
            let invokeGetContact: (String) -> Void
        }
        
        struct Initial {
            let contactInfo: Contact
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
    
    private var saveContactAction: Target? {
        didSet {
            submitButton.addTarget(saveContactAction, action: #selector(Target.action), for: .touchUpInside)
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
    
    // MARK: Keyboard dismissal handlers
    
    // Dismisses keyboard when "Done" button is clicked and performs cleanup
    @IBAction private func editingDidEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: Overrides
    
    // Dismisses keyboard when the user touches outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let contactID = contactID {
            invokeGetContact?(contactID)
        }
    }
    
    // MARK: Properties
    
    private var invokeGetContact: ((String) -> Void)?
    public var contactID: String?
    private var contactGroupID: String?
    public var correspondingIndexPath: IndexPath?
    
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
        invokeGetContact = state.invokeGetContact
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        view.isHidden = false
        contactGroupID = state.contactInfo.groupID
        (presentingViewController?.childViewControllers[1] as? EmergencyContactsViewController)?.waitingIndicator.stopAnimating()
        
        let name = state.contactInfo.name.components(separatedBy: " ")
        firstName.text = name[0]
        lastName.text = name[1]
        phone.text = state.contactInfo.phone
        
        saveContactAction = Target { [unowned self] _ in
            state.submit(Contact(
                id: self.contactID!,
                name: self.firstName.text! + " " + self.lastName.text!,
                phone: self.phone.text!,
                groupID: self.contactGroupID
            ))
        }
    }
    
    private func renderWaitingState(with message: String? = nil) {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        
        saveContactAction = Target { [unowned self] _ in
            state.submit(Contact(
                id: self.contactID!,
                name: self.firstName.text! + " " + self.lastName.text!,
                phone: self.phone.text!,
                groupID: self.contactGroupID
            ))
        }
    }
    
    private func renderSuccessState() {
        dismiss(animated: true)
        
        let viewController = presentingViewController!.childViewControllers[1] as! EmergencyContactsViewController
        viewController.contactsForCell[correspondingIndexPath!.row]["phone"] = Contact.formatPhoneNumber(phoneNumber: phone.text!)
        
        viewController.tableView.reloadData()
    }
}
