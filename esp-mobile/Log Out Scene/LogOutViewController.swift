//
//  LogOutViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/8/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import UIKit

final class LogOutViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case initial(Initial)
        case waiting
        
        struct Initial {
            let invokeLogOut: () -> Void
            let invokeStoreParentReference: (LogOutViewController) -> Void
        }
    }
    
    // MARK: IBOutlets

    @IBOutlet weak private var modalView: UIView! {
        didSet {
            modalView.layer.cornerRadius = 5
            modalView.layer.masksToBounds = false
            modalView.layer.shadowColor = UIColor.black.cgColor
            modalView.layer.shadowOpacity = 0.5
            modalView.layer.shadowOffset = CGSize(width: 7, height: 5)
        }
    }
    
    @IBAction private func performLogOut(_ sender: UIButton) {
        dismiss(animated: false)
        invokeLogOut?()
    }
    
    @IBAction private func dismiss(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Properties
    
    private var invokeLogOut: (() -> Void)?
    private var invokeStoreParentReference: ((LogOutViewController) -> Void)?
    
    // MARK: Overrides
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        invokeStoreParentReference?(self)
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch state {
            case .initial(let initial): self.renderInitialState(state: initial)
            case .waiting:              self.renderWaitingState()
            }
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        invokeLogOut = state.invokeLogOut
        invokeStoreParentReference = state.invokeStoreParentReference
    }
    
    private func renderWaitingState() {
        (presentingViewController?.childViewControllers[0] as? SafetyZonesViewController)?.forceWaitingState(with: "Logging out...")
    }
}
