//
//  ProvideFeedbackPage2ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/16/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage2ViewController: UIViewController, FeedbackProtocol {
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var experienceLength: UISegmentedControl!
    @IBOutlet weak private var experienceIntuition: UISegmentedControl!
    @IBOutlet weak private var positiveOpinionBox: UITextView! {
        didSet {
            positiveOpinionBox.layer.cornerRadius = 5
            positiveOpinionBox.layer.borderColor = UIColor.black.cgColor
            positiveOpinionBox.layer.borderWidth = 1
            positiveOpinionBox.delegate = self
        }
    }
    
    @IBOutlet weak private var negativeOpinionBox: UITextView! {
        didSet {
            negativeOpinionBox.layer.cornerRadius = 5
            negativeOpinionBox.layer.borderColor = UIColor.black.cgColor
            negativeOpinionBox.layer.borderWidth = 1
            negativeOpinionBox.delegate = self
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
        performSegue(withIdentifier: "unwindFromPage2", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    
    var feedback: Feedback?
    var feedbackPosition: FeedbackPosition = .page2
    
    // MARK: Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ProvideFeedbackPage3ViewController else { return }
        collectFeedback()
        viewController.feedback = feedback
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectFeedback()
        (parent?.childViewControllers.last as? ProvideFeedbackPage1ViewController)?.feedback = feedback
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
        
        feedback?._2a = experienceLength.titleForSegment(at: experienceLength.selectedSegmentIndex)!
        feedback?._2b = experienceIntuition.titleForSegment(at: experienceIntuition.selectedSegmentIndex)!
        feedback?._2c = positiveOpinionBox.text
        feedback?._2d = negativeOpinionBox.text
        feedback?._2e = "\(Int(lookFeelSlider.value))"
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
    }
    
    func restoreFeedback() {
        guard let savedFeedback = UserDefaults.standard.dictionaryWithValues(forKeys: ["2a", "2b", "2c", "2d", "2e"]) as? [String: String] else { return }
        
        experienceLength.selectedSegmentIndex = experienceLength.index(for: savedFeedback["2a"]!) ?? 0
        experienceIntuition.selectedSegmentIndex = experienceIntuition.index(for: savedFeedback["2b"]!) ?? 0
        positiveOpinionBox.text = savedFeedback["2c"]!
        negativeOpinionBox.text = savedFeedback["2d"]!
        lookFeelSlider.value = Float(savedFeedback["2e"]!) ?? lookFeelSlider.value
        lookFeelSliderChanged(lookFeelSlider)
    }
}
