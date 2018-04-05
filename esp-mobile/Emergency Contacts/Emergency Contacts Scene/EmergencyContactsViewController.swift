//
//  EmergencyContactsViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/5/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class EmergencyContactsViewController: UIViewController {

    // MARK: View Model
    
    enum ViewModel {
        case preInitial(PreInitial)
        case initial(Initial)
        case waiting
        case failure(Failure)
        
        struct PreInitial {
            let invokeDeleteContact: (String) -> Void
            let invokeReadyForUpdate: () -> Void
        }
        
        struct Initial {
            let currentContacts: [Contact]
        }
        
        struct Failure {
            let message: String
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var waitingIndicator: UIActivityIndicatorView! {
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
    
    public var contactsForCell: [[String: String?]] = []
    private var invokeDeleteContact: ((String) -> Void)?
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editContact" {
            let viewController = segue.destination as? EditContactViewController
            let indexPath = tableView.indexPath(for: sender as! ContactCell)!
            viewController?.contactID = contactsForCell[indexPath.row]["id"]!
            viewController?.correspondingIndexPath = indexPath
            waitingIndicator.startAnimating()
        } else if segue.identifier == "manageAlertGroups" {
            let viewController = segue.destination as? AlertGroupsViewController
            viewController?.contactsForGroup = contactsForCell.flatMap { if $0["group_id"]! != nil { return $0 } else { return nil } }
            viewController?.currentContacts = contactsForCell.filter { currentContact in viewController?.contactsForGroup.index { $0["id"]!! == currentContact["id"]!! } == nil }
        }
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch (state) {
            case .preInitial(let preInitial): self.renderPreInitialState(state: preInitial)
            case .initial(let initial):       self.renderInitialState(state: initial)
            case .waiting:                    self.renderWaitingState()
            case .failure(let failure):       self.renderFailureState(state: failure)
            }
        }
    }
    
    private func renderPreInitialState(state: ViewModel.PreInitial) {
        invokeDeleteContact = state.invokeDeleteContact
        invokeReadyForUpdate = state.invokeReadyForUpdate
        tableView.isUserInteractionEnabled = true
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        
        contactsForCell = state.currentContacts.tabularRepresentation()
        tableView.reloadData()
        tableView.isUserInteractionEnabled = true
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        tableView.isUserInteractionEnabled = false
        errorView.isHidden = true
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        tableView.isUserInteractionEnabled = true
    }
}

// MARK: UITableViewDelegate / UITableViewDataSource

extension EmergencyContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        return contactsForCell.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        
        return "Emergency Contacts:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "addContactCell", for: indexPath)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "manageAlertGroupsCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
        
        let contactName = contactsForCell[indexPath.row]["name"]!!
        cell.initialLabel.text = String(Array(contactName)[0]).uppercased()
        cell.nameLabel.text = contactName
        cell.phoneNumberLabel.text = contactsForCell[indexPath.row]["phone"]!
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.invokeDeleteContact?(self.contactsForCell[indexPath.row]["id"]!!)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.performSegue(withIdentifier: "editContact", sender: tableView.cellForRow(at: index))
        }
        
        return [edit, delete]
    }
}

final class ContactCell: UITableViewCell {
    @IBOutlet weak fileprivate var nameColor: UIImageView! {
        didSet {
            nameColor.backgroundColor = UIColor.lightGray
            nameColor.layer.borderWidth = 1.0
            nameColor.layer.masksToBounds = false
            nameColor.layer.borderColor = UIColor.black.cgColor
            nameColor.layer.cornerRadius = nameColor.frame.size.width / 2
            nameColor.clipsToBounds = true
        }
    }
    
    @IBOutlet weak fileprivate var initialLabel: UILabel!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var phoneNumberLabel: UILabel!
}
