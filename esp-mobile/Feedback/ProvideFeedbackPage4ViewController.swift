//
//  ProvideFeedbackPage4ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/17/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage4ViewController: UIViewController, FeedbackProtocol {
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var addingContactsIntuitive: UISegmentedControl!
    @IBOutlet weak private var alertGroupsIntuitive: UISegmentedControl!
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
    
    @IBOutlet weak private var lookFeelSlider: UISlider!
    @IBOutlet weak private var lookFeelSliderLabel: UILabel!
    @IBAction private func lookFeelSliderChanged(_ sender: UISlider) {
        lookFeelSliderLabel.text = "\(Int(sender.value)) out of 10"
    }
    
    @IBOutlet weak private var nextPageButton: UIButton! {
        didSet {
            nextPageButton.layer.cornerRadius = 5
        }
    }
    
    @IBAction private func exitRequested(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(feedbackPosition.rawValue, forKey: "feedbackPosition")
        performSegue(withIdentifier: "unwindFromPage4", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    
    var feedback: Feedback?
    var feedbackPosition: FeedbackPosition = .page4
    
    // MARK: Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ProvideFeedbackPage5ViewController else { return }
        collectFeedback()
        viewController.feedback = feedback
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectFeedback()
        (parent?.childViewControllers.last as? ProvideFeedbackPage3ViewController)?.feedback = feedback
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
        
        feedback?._4a = addingContactsIntuitive.titleForSegment(at: addingContactsIntuitive.selectedSegmentIndex)!
        feedback?._4b = alertGroupsIntuitive.titleForSegment(at: alertGroupsIntuitive.selectedSegmentIndex)!
        feedback?._4c = positiveCommentField.text
        feedback?._4d = negativeCommentField.text
        feedback?._4e = "\(Int(lookFeelSlider.value))"
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
    }
    
    func restoreFeedback() {
        guard let savedFeedback = UserDefaults.standard.dictionaryWithValues(forKeys: ["4a", "4b", "4c", "4d", "4e"]) as? [String: String] else { return }
        
        addingContactsIntuitive.selectedSegmentIndex = addingContactsIntuitive.index(for: savedFeedback["4a"]!) ?? 0
        alertGroupsIntuitive.selectedSegmentIndex = alertGroupsIntuitive.index(for: savedFeedback["4b"]!) ?? 0
        positiveCommentField.text = savedFeedback["4c"]!
        negativeCommentField.text = savedFeedback["4d"]!
        lookFeelSlider.value = Float(savedFeedback["4e"]!) ?? lookFeelSlider.value
        lookFeelSliderChanged(lookFeelSlider)
    }
}
