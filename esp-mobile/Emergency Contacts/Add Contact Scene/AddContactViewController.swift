//
//  AddContactViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/5/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class AddContactViewController: UIViewController {
    
    // MARK: - View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case contactLoadBypass(ContactLoadBypass)
        case addSuccess
        
        struct Initial {
            let deviceContacts: [Contact]
            let invokeAddContact: (String, String) -> Void
        }
        
        struct Failure {
            let message: String
        }
        
        struct ContactLoadBypass {
            let invokeAddContact: (String, String) -> Void
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.tableFooterView = UIView()
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
    
    @IBOutlet private var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    // MARK: - Properties
    
    private var contactsForCell: [[[String: String?]]] = []
    private var effectiveContactsForCell: [[[String: String?]]] = []
    private var invokeAddContact: ((String, String) -> Void)?
    
    // MARK: - State configuration
    
     func render(state: ViewModel) {
        switch state {
        case .initial(let initial):          renderInitialState(state: initial)
        case .waiting:                       renderWaitingState()
        case .failure(let failure):          renderFailureState(state: failure)
        case .contactLoadBypass(let bypass): renderContactLoadBypassState(state: bypass)
        case .addSuccess:                    renderAddSuccessState()
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        contactsForCell = state.deviceContacts.sectionalRepresentation()
        effectiveContactsForCell = contactsForCell
        invokeAddContact = state.invokeAddContact
        tableView.reloadData()
    }
    
    private func renderWaitingState() {
        errorView.isHidden = true
        waitingIndicator.startAnimating()
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        errorView.isHidden = false
        waitingIndicator.stopAnimating()
        errorMessage.text = state.message
    }
    
    private func renderContactLoadBypassState(state: ViewModel.ContactLoadBypass) {
        errorView.isHidden = true
        waitingIndicator.stopAnimating()
        invokeAddContact = state.invokeAddContact
    }
    
    private func renderAddSuccessState() {
        errorView.isHidden = true
        waitingIndicator.stopAnimating()
        navigationController?.popViewController(animated: true)
    }
    
     func modalSuccessTransition() {
        renderAddSuccessState()
    }
}

// MARK: - UITableViewDelegate / UITableViewDataSource

extension AddContactViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return effectiveContactsForCell[section - 1].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + effectiveContactsForCell.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        
        return String(Array(effectiveContactsForCell[section - 1][0]["name"]!!)[0]).uppercased()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "manualContactCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceContactCell", for: indexPath) as! DeviceContactCell
        
        let contactName = effectiveContactsForCell[indexPath.section - 1][indexPath.row]["name"]!
        cell.initialLabel.text = String(Array(contactName!)[0]).uppercased()
        cell.nameLabel.text = contactName
        cell.phoneNumberLabel.text = effectiveContactsForCell[indexPath.section - 1][indexPath.row]["phone"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            let selectedContact = effectiveContactsForCell[indexPath.section - 1][indexPath.row]
            let name = selectedContact["name"]!!
            let phone = Location.getCallable(phoneNumber: selectedContact["phone"]!!)
            
            invokeAddContact?(name, phone)
        }
    }
}

// MARK: - UISearchBarDelegate

extension AddContactViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil {
            let allContacts = contactsForCell.flatMap { $0 }
            let allSearchResults = allContacts.filter { contact -> Bool in
                return contact["name"]!!.lowercased().contains(searchBar.text!.lowercased())
            }
            
            if allSearchResults.count > 0 {
                var searchResultsForCell: [[[String: String?]]] = []
                var currentSectionKey: String = ""
                var currentSection: [[String: String?]] = []
                for (i, contact) in allSearchResults.enumerated() {
                    if currentSectionKey.isEmpty {
                        currentSectionKey = String(Array(contact["name"]!!)[0]).uppercased()
                        currentSection.append(contact)
                        
                        if allSearchResults.count - 1 == i {
                            searchResultsForCell.append(currentSection)
                        }
                    } else {
                        let currentKey = String(Array(contact["name"]!!)[0]).uppercased()
                        if currentKey != currentSectionKey {
                            searchResultsForCell.append(currentSection)
                            currentSection = [contact]
                            currentSectionKey = currentKey
                            
                            if allSearchResults.count - 1 == i {
                                searchResultsForCell.append(currentSection)
                            }
                        } else {
                            currentSection.append(contact)
                        }
                    }
                }
                
                effectiveContactsForCell = searchResultsForCell
            } else {
                effectiveContactsForCell = []
            }
        } else {
            effectiveContactsForCell = contactsForCell
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        effectiveContactsForCell = contactsForCell
        tableView.reloadData()
    }
}

final class DeviceContactCell: UITableViewCell {
    @IBOutlet fileprivate var nameColor: UIImageView! {
        didSet {
            nameColor.backgroundColor = UIColor.lightGray
            nameColor.layer.borderWidth = 1.0
            nameColor.layer.masksToBounds = false
            nameColor.layer.borderColor = UIColor.black.cgColor
            nameColor.layer.cornerRadius = nameColor.frame.size.width / 2
            nameColor.clipsToBounds = true
        }
    }
    
    @IBOutlet fileprivate var initialLabel: UILabel!
    @IBOutlet fileprivate var nameLabel: UILabel!
    @IBOutlet fileprivate var phoneNumberLabel: UILabel!
}
