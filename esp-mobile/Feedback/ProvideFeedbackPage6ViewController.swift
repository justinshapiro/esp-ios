//
//  ProvideFeedbackPage6ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/17/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage6ViewController: UIViewController {
    
    // MARK: View Model
    
    enum ViewModel {
        case waiting
        case failure(Failure)
        case success
        
        struct Failure {
            let message: String
        }
    }
    
    // MARK: IBOutlets
    
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
    
    @IBOutlet weak private var alertReceivedSelection: UISegmentedControl!
    @IBOutlet weak private var alertFunctionalityFeedback: UITextView! {
        didSet {
            alertFunctionalityFeedback.layer.cornerRadius = 5
            alertFunctionalityFeedback.layer.borderColor = UIColor.black.cgColor
            alertFunctionalityFeedback.layer.borderWidth = 1
            alertFunctionalityFeedback.delegate = self
        }
    }
    
    @IBOutlet weak private var batterySlider: UISlider!
    @IBOutlet weak private var batterySliderLabel: UILabel!
    @IBAction private func batterySliderChanged(_ sender: UISlider) {
        batterySliderLabel.text = "\(Int(sender.value))%"
    }
    
    @IBOutlet weak private var submitFeedbackButton: UIButton! {
        didSet {
            submitFeedbackButton.layer.cornerRadius = 5
        }
    }
    
    @IBAction private func submitFeedbackAction(_ sender: UIButton) {
        performSegue(withIdentifier: "thankYou", sender: self)
    }
    
    
    @IBAction private func exitRequested(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindFromPage6", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: State configuration
    
    public func render(_ state: ViewModel) {
        DispatchQueue.main.async {
            switch state {
            case .waiting:              self.renderWaitingState()
            case .failure(let failure): self.renderFailureState(state: failure)
            case .success:              self.renderSuccessState()
            }
        }
    }
    
    private func renderWaitingState() {
        
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        
    }
    
    private func renderSuccessState() {
        
    }
}
