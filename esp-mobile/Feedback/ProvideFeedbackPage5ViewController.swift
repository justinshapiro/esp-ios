//
//  ProvideFeedbackPage5ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/17/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage5ViewController: UIViewController, FeedbackProtocol {
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var addingSafetyZonesIntuitive: UISegmentedControl!
    @IBOutlet weak private var positiveCommentField: UITextView! {
        didSet {
            positiveCommentField.layer.cornerRadius = 5
            positiveCommentField.layer.borderColor = UIColor.black.cgColor
            positiveCommentField.layer.borderWidth = 1
            positiveCommentField.delegate = self
        }
    }
    
    @IBOutlet weak private var negativeCommentField: UITextView! {
        didSet {
            negativeCommentField.layer.cornerRadius = 5
            negativeCommentField.layer.borderColor = UIColor.black.cgColor
            negativeCommentField.layer.borderWidth = 1
            negativeCommentField.delegate = self
        }
    }
    
    @IBOutlet weak private var nonAlertableExperience: UISegmentedControl!
    @IBOutlet weak private var nonAlertableExperienceComment: UITextView! {
        didSet {
            nonAlertableExperienceComment.layer.cornerRadius = 5
            nonAlertableExperienceComment.layer.borderColor = UIColor.black.cgColor
            nonAlertableExperienceComment.layer.borderWidth = 1
            nonAlertableExperienceComment.delegate = self
        }
    }

    @IBOutlet weak private var lookFeelSlider: UISlider!
    @IBOutlet weak private var lookFeelSliderLabel: UILabel!
    @IBAction private func lookFeelSliderChanged(_ sender: UISlider) {
        lookFeelSliderLabel.text = "\(Int(sender.value)) out of 10"
    }
    
    @IBAction private func exitRequested(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(feedbackPosition.rawValue, forKey: "feedbackPosition")
        performSegue(withIdentifier: "unwindFromPage5", sender: self)
    }
    
    @IBOutlet weak private var nextPageButton: UIButton! {
        didSet {
            nextPageButton.layer.cornerRadius = 5
        }
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    
    var feedback: Feedback?
    var feedbackPosition: FeedbackPosition = .page5
    
    // MARK: Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ProvideFeedbackPage6ViewController else { return }
        collectFeedback()
        viewController.feedback = feedback
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectFeedback()
        (parent?.childViewControllers.last as? ProvideFeedbackPage4ViewController)?.feedback = feedback
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restoreFeedback()
    }
    
    // MARK: Helper methods
    
    func collectFeedback() {
        if feedback == nil {
            feedback = Feedback(tabularRepresentation: UserDefaults.standard.dictionaryRepresentation())
        }
        
        feedback?._5a = addingSafetyZonesIntuitive.titleForSegment(at: addingSafetyZonesIntuitive.selectedSegmentIndex)!
        feedback?._5b = positiveCommentField.text
        feedback?._5c = negativeCommentField.text
        feedback?._5d = nonAlertableExperience.titleForSegment(at: nonAlertableExperience.selectedSegmentIndex)!
        feedback?._5e = nonAlertableExperienceComment.text
        feedback?._5f = "\(Int(lookFeelSlider.value))"
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
    }
    
    func restoreFeedback() {
        guard let savedFeedback = UserDefaults.standard.dictionaryWithValues(forKeys: ["5a", "5b", "5c", "5d", "5e", "5f"]) as? [String: String] else { return }
        
        addingSafetyZonesIntuitive.selectedSegmentIndex = addingSafetyZonesIntuitive.index(for: savedFeedback["5a"]!) ?? 0
        positiveCommentField.text = savedFeedback["5b"]!
        negativeCommentField.text = savedFeedback["5c"]!
        nonAlertableExperience.selectedSegmentIndex = nonAlertableExperience.index(for: savedFeedback["5d"]!) ?? 0
        nonAlertableExperienceComment.text = savedFeedback["5e"]!
        lookFeelSlider.value = Float(savedFeedback["5f"]!) ?? lookFeelSlider.value
        lookFeelSliderChanged(lookFeelSlider)
    }
}
