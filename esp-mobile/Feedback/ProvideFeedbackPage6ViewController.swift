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
        case initial(Initial)
        case waiting
        case failure(Failure)
        case success
        
        struct Initial {
            let submit: (Feedback) -> ()
        }
        
        struct Failure {
            let message: String
            let submit: (Feedback) -> ()
        }
    }
    
    // MARK: IBOutlets
    
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
    
    @IBAction private func exitRequested(_ sender: UIBarButtonItem) {
        collectFeedback()
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
        
        UserDefaults.standard.set(feedbackPosition.rawValue, forKey: "feedbackPosition")
        performSegue(withIdentifier: "unwindFromPage6", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    
    var feedback: Feedback?
    var feedbackPosition: FeedbackPosition = .page6
    private var submitFeedbackAction: Target? {
        didSet {
            submitFeedbackButton.addTarget(submitFeedbackAction, action: #selector(Target.action), for: .touchUpInside)
        }
    }
    
    // MARK: Overrides
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectFeedback()
        (parent?.childViewControllers.last as? ProvideFeedbackPage5ViewController)?.feedback = feedback
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restoreFeedback()
    }
    
    // MARK: Helper methods
    
    private func collectFeedback() {
        if feedback == nil {
            feedback = Feedback(tabularRepresentation: UserDefaults.standard.dictionaryRepresentation())
        }
        
        feedback?._6a = alertReceivedSelection.titleForSegment(at: alertReceivedSelection.selectedSegmentIndex)!
        feedback?._6b = alertFunctionalityFeedback.text
        feedback?._6c = "\(Int(batterySlider.value))"
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
    }
    
    private func restoreFeedback() {
        guard let savedFeedback = UserDefaults.standard.dictionaryWithValues(forKeys: ["6a", "6b", "6c"]) as? [String: String] else { return }
        
        alertReceivedSelection.selectedSegmentIndex = alertReceivedSelection.index(for: savedFeedback["6a"]!) ?? 0
        alertFunctionalityFeedback.text = savedFeedback["6b"]!
        batterySlider.value = Float(savedFeedback["6c"]!) ?? batterySlider.value
        batterySliderChanged(batterySlider)
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch state {
            case .initial(let initial): self.renderInitialState(state: initial)
            case .waiting:              self.renderWaitingState()
            case .failure(let failure): self.renderFailureState(state: failure)
            case .success:              self.renderSuccessState()
            }
        }
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        submitFeedbackButton.isEnabled = true
        
        submitFeedbackAction = Target { [unowned self] _ in
            self.collectFeedback()
            if let feedback = self.feedback {
                state.submit(feedback)
            }
        }
    }
    
    private func renderWaitingState() {
        waitingIndicator.startAnimating()
        errorView.isHidden = true
        submitFeedbackButton.isEnabled = false
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        waitingIndicator.stopAnimating()
        errorView.isHidden = false
        errorMessage.text = state.message
        submitFeedbackButton.isEnabled = true
        
        submitFeedbackAction = Target { [unowned self] _ in
            self.collectFeedback()
            if let feedback = self.feedback {
                state.submit(feedback)
            }
        }
    }
    
    private func renderSuccessState() {
        waitingIndicator.stopAnimating()
        errorView.isHidden = true
        
        performSegue(withIdentifier: "thankYou", sender: self)
    }
}
