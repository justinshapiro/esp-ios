//
//  AlertGroupsViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/25/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class AlertGroupsViewController: UIViewController {
    
    // MARK: ViewModel
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        case failure(Failure)
        case softSuccess
        case success
        
        struct Initial {
            let submit: ([[String: String?]]) -> Void
            let disableAlertGroups: () -> Void
        }
        
        struct Failure {
            let message: String
            let submit: ([[String: String?]]) -> Void
            let disableAlertGroups: () -> Void
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var contactsCollectionView: UICollectionView! {
        didSet {
            contactsCollectionView.dragInteractionEnabled = true
            contactsCollectionView.dragDelegate = self
            contactsCollectionView.dropDelegate = self
            contactsCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var contactsBackgroundViewLabel: UILabel!
    @IBOutlet weak private var groupCollectionView: UICollectionView! {
        didSet {
            groupCollectionView.dragInteractionEnabled = true
            groupCollectionView.dragDelegate = self
            groupCollectionView.dropDelegate = self
            groupCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var groupBackgroundViewLabel: UILabel!
    @IBOutlet weak var groupBackgroundView: UIView! {
        didSet {
            groupBackgroundView.layer.cornerRadius = 10
            groupBackgroundView.alpha = 0.65
            groupBackgroundView.layer.shadowColor = UIColor.black.cgColor
            groupBackgroundView.layer.shadowRadius = 3
            groupBackgroundView.layer.shadowOpacity = 0.25
            groupBackgroundView.layer.shadowOffset = CGSize(width: -5, height: 5)
        }
    }
    
    @IBOutlet weak var contactsBackgroundView: UIView! {
        didSet {
            contactsBackgroundView.layer.cornerRadius = 10
            contactsBackgroundView.alpha = 0.65
            contactsBackgroundView.layer.shadowColor = UIColor.black.cgColor
            contactsBackgroundView.layer.shadowRadius = 3
            contactsBackgroundView.layer.shadowOpacity = 0.25
            contactsBackgroundView.layer.shadowOffset = CGSize(width: -5, height: 5)
        }
    }
    
    @IBOutlet weak var groupEnabledSwitch: UISwitch!
    @IBAction func groupSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            contactsCollectionView.alpha = 1
            contactsCollectionView.isUserInteractionEnabled = false
            groupCollectionView.alpha = 1
            groupCollectionView.isUserInteractionEnabled = false
        } else {
            contactsCollectionView.alpha = 0.5
            contactsCollectionView.isUserInteractionEnabled = false
            groupCollectionView.alpha = 0.5
            groupCollectionView.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
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
    
    // MARK: Properties
    
    var contactsForGroup: [[String: String?]] = []
    var currentContacts: [[String: String?]] = []
    private var updateDidOccur = false
    private var saveContactGroupAction: Target? {
        didSet {
            saveButton.addTarget(saveContactGroupAction, action: #selector(Target.action))
        }
    }
    
    private var changeAlertGroupsAction: Target? {
        didSet {
            groupEnabledSwitch.addTarget(changeAlertGroupsAction, action: #selector(Target.action), for: .touchUpInside)
        }
    }
    
    // MARK: Helper methods
    
    private func reorderItems(in collectionView: UICollectionView, coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
            var actualDestinationIndexPath = destinationIndexPath
            if actualDestinationIndexPath.row >= collectionView.numberOfItems(inSection: 0) {
                actualDestinationIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            
            collectionView.performBatchUpdates({
                if collectionView === self.groupCollectionView {
                    self.contactsForGroup.remove(at: sourceIndexPath.row)
                    self.contactsForGroup.insert(item.dragItem.localObject as! [String: String?], at: actualDestinationIndexPath.row)
                } else {
                    self.currentContacts.remove(at: sourceIndexPath.row)
                    self.currentContacts.insert(item.dragItem.localObject as! [String: String?], at: actualDestinationIndexPath.row)
                }
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [actualDestinationIndexPath])
            })
            
            coordinator.drop(items.first!.dragItem, toItemAt: actualDestinationIndexPath)
        }
    }
    
    private func copyItems(in collectionView: UICollectionView, coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        collectionView.performBatchUpdates({
            let draggedItem = coordinator.items[0].dragItem.localObject as! [String: String?]
            let indexPath = IndexPath(row: destinationIndexPath.row, section: destinationIndexPath.section)
            
            if collectionView === self.groupCollectionView {
                self.contactsForGroup.insert(draggedItem, at: indexPath.row)
                
                if let oldItemIndex = self.currentContacts.index(where: { $0["id"]! == draggedItem["id"]! }) {
                    self.currentContacts.remove(at: oldItemIndex)
                }
            } else {
                self.currentContacts.insert(draggedItem, at: indexPath.row)
                
                if let oldItemIndex = self.contactsForGroup.index(where: { $0["id"]! == draggedItem["id"]! }) {
                    self.contactsForGroup.remove(at: oldItemIndex)
                }
            }

            collectionView.insertItems(at: [indexPath])
            groupEnabledSwitch.isOn = !(currentContacts.isEmpty && contactsForGroup.isEmpty)
            contactsCollectionView.reloadData()
            contactsCollectionView.collectionViewLayout.invalidateLayout()
            groupCollectionView.reloadData()
            updateDidOccur = true
            saveButton.isEnabled = true
        })
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch state {
            case .initial(let initial): self.renderInitialState(state: initial)
            case .waiting:              self.renderWaitingState()
            case .failure(let failure): self.renderFailureState(state: failure)
            case .softSuccess:          self.renderSoftSuccessState()
            case .success:              self.renderSuccessState()
            }
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        waitingIndicator.stopAnimating()
        groupEnabledSwitch.isOn = !(currentContacts.isEmpty && contactsForGroup.isEmpty)
        saveButton.isEnabled = false
        groupEnabledSwitch.isEnabled = true
        groupCollectionView.isUserInteractionEnabled = true
        contactsCollectionView.isUserInteractionEnabled = true
        errorView.isHidden = true
        
        saveContactGroupAction = Target { [unowned self] _ in
            if self.updateDidOccur {
               state.submit(self.contactsForGroup)
            }
        }
        
        changeAlertGroupsAction = Target { [unowned self] _ in
            if !self.groupEnabledSwitch.isOn {
                state.submit(self.contactsForGroup)
            } else {
                state.disableAlertGroups()
            }
        }
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
        saveButton.isEnabled = false
        groupEnabledSwitch.isEnabled = false
        groupCollectionView.isUserInteractionEnabled = false
        contactsCollectionView.isUserInteractionEnabled = false
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        saveButton.isEnabled = updateDidOccur
        groupEnabledSwitch.isEnabled = true
        groupCollectionView.isUserInteractionEnabled = true
        contactsCollectionView.isUserInteractionEnabled = true
        
        saveContactGroupAction = Target { [unowned self] _ in
            if self.updateDidOccur {
                state.submit(self.contactsForGroup)
            }
        }
        
        changeAlertGroupsAction = Target { [unowned self] _ in
            if !self.groupEnabledSwitch.isOn {
                state.submit(self.contactsForGroup)
            } else {
                state.disableAlertGroups()
            }
        }
    }
    
    private func renderSoftSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension AlertGroupsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == contactsCollectionView {
            contactsBackgroundViewLabel.isHidden = currentContacts.count > 0
            return currentContacts.count
        } else {
            groupBackgroundViewLabel.isHidden = contactsForGroup.count > 1
            return contactsForGroup.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == contactsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "currentContactCell", for: indexPath) as! CurrentContactCell
            cell.contactName.text = currentContacts[indexPath.row]["name"]!
            cell.initialLetter.text = String(Array(currentContacts[indexPath.row]["name"]!!)[0]).uppercased()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupContactCell", for: indexPath) as! GroupContactCell
            cell.contactName.text = contactsForGroup[indexPath.row]["name"]!
            cell.initialLetter.text = String(Array(contactsForGroup[indexPath.row]["name"]!!)[0]).uppercased()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == contactsCollectionView {
            let leftRightInset = currentContacts.count > 1 ? (collectionView.bounds.width - CGFloat(((currentContacts.count - 1 ) * 134) + 124)) / 2 : (collectionView.bounds.width - 124) / 2
            if leftRightInset > 0 {
                return UIEdgeInsets(top: 0, left: leftRightInset, bottom: 0, right: leftRightInset)
            }
        }
        
        return .zero
    }
}

// MARK: UICollectionViewDragDelegate

extension AlertGroupsViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = collectionView == contactsCollectionView ? currentContacts[indexPath.row] : contactsForGroup[indexPath.row]
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let item = collectionView == contactsCollectionView ? currentContacts[indexPath.row] : contactsForGroup[indexPath.row]
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return nil
    }
}

// MARK: UICollectionViewDropDelegate

extension AlertGroupsViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation {
        case .move:
            self.reorderItems(in: collectionView, coordinator: coordinator, destinationIndexPath:destinationIndexPath)
        case .copy:
            self.copyItems(in: collectionView, coordinator: coordinator, destinationIndexPath: destinationIndexPath)
        default:
            return
        }
    }
}

final class CurrentContactCell: UICollectionViewCell {
    @IBOutlet weak fileprivate var initialImage: UIImageView! {
        didSet {
            initialImage.backgroundColor = UIColor.lightGray
            initialImage.layer.borderWidth = 1.0
            initialImage.layer.masksToBounds = false
            initialImage.layer.borderColor = UIColor.black.cgColor
            initialImage.layer.cornerRadius = initialImage.frame.size.width / 2
            initialImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak fileprivate var initialLetter: UILabel!
    @IBOutlet weak fileprivate var contactName: UILabel!
}

final class GroupContactCell: UICollectionViewCell {
    @IBOutlet weak fileprivate var initialImage: UIImageView! {
        didSet {
            initialImage.backgroundColor = UIColor.lightGray
            initialImage.layer.borderWidth = 1.0
            initialImage.layer.masksToBounds = false
            initialImage.layer.borderColor = UIColor.black.cgColor
            initialImage.layer.cornerRadius = initialImage.frame.size.width / 2
            initialImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak fileprivate var initialLetter: UILabel!
    @IBOutlet weak fileprivate var contactName: UILabel!
}
