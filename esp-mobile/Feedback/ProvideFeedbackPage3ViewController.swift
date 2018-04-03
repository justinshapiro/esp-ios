//
//  ProvideFeedbackPage3ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/16/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage3ViewController: UIViewController, FeedbackProtocol {
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var easyNearYouSwitch: UISegmentedControl!
    @IBOutlet weak private var minRadiusSwitch: UISegmentedControl!
    @IBOutlet weak private var safetyZonesOnMapField: UITextView! {
        didSet {
            safetyZonesOnMapField.layer.cornerRadius = 5
            safetyZonesOnMapField.layer.borderColor = UIColor.black.cgColor
            safetyZonesOnMapField.layer.borderWidth = 1
            safetyZonesOnMapField.delegate = self
        }
    }
    
    @IBOutlet weak private var detailProvidedField: UITextView! {
        didSet {
            detailProvidedField.layer.cornerRadius = 5
            detailProvidedField.layer.borderColor = UIColor.black.cgColor
            detailProvidedField.layer.borderWidth = 1
            detailProvidedField.delegate = self
        }
    }
    
    @IBOutlet weak private var categoriesField: UITextView! {
        didSet {
            categoriesField.layer.cornerRadius = 5
            categoriesField.layer.borderColor = UIColor.black.cgColor
            categoriesField.layer.borderWidth = 1
            categoriesField.delegate = self
        }
    }
    
    @IBOutlet weak private var positiveExperienceField: UITextView! {
        didSet {
            positiveExperienceField.layer.cornerRadius = 5
            positiveExperienceField.layer.borderColor = UIColor.black.cgColor
            positiveExperienceField.layer.borderWidth = 1
            positiveExperienceField.delegate = self
        }
    }
    
    @IBOutlet weak private var negativeExperienceField: UITextView! {
        didSet {
            negativeExperienceField.layer.cornerRadius = 5
            negativeExperienceField.layer.borderColor = UIColor.black.cgColor
            negativeExperienceField.layer.borderWidth = 1
            negativeExperienceField.delegate = self
        }
    }
    
    @IBOutlet weak private var lookFeelSlider: UISlider!
    @IBOutlet weak private var lookFeelLabel: UILabel!
    @IBAction private func lookFeelSliderChanged(_ sender: UISlider) {
        lookFeelLabel.text = "\(Int(sender.value)) out of 10"
    }
    
    @IBOutlet weak private var nextPageButton: UIButton! {
        didSet {
            nextPageButton.layer.cornerRadius = 5
        }
    }
    
    @IBAction private func exitRequested(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(feedbackPosition.rawValue, forKey: "feedbackPosition")
        performSegue(withIdentifier: "unwindFromPage3", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    
    var feedback: Feedback?
    var feedbackPosition: FeedbackPosition = .page3
    
    // MARK: Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ProvideFeedbackPage4ViewController else { return }
        collectFeedback()
        viewController.feedback = feedback
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectFeedback()
        (parent?.childViewControllers.last as? ProvideFeedbackPage2ViewController)?.feedback = feedback
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
        
        feedback?._3a = easyNearYouSwitch.titleForSegment(at: easyNearYouSwitch.selectedSegmentIndex)!
        feedback?._3b = minRadiusSwitch.titleForSegment(at: minRadiusSwitch.selectedSegmentIndex)!
        feedback?._3c = safetyZonesOnMapField.text
        feedback?._3d = detailProvidedField.text
        feedback?._3e = categoriesField.text
        feedback?._3f = positiveExperienceField.text
        feedback?._3g = negativeExperienceField.text
        feedback?._3h = "\(Int(lookFeelSlider.value))"
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
    }
    
    func restoreFeedback() {
        guard let savedFeedback = UserDefaults.standard.dictionaryWithValues(forKeys: ["3a", "3b", "3c", "3d", "3e", "3f", "3g", "3h"]) as? [String: String] else { return }
        
        easyNearYouSwitch.selectedSegmentIndex = easyNearYouSwitch.index(for: savedFeedback["3a"]!) ?? 0
        minRadiusSwitch.selectedSegmentIndex = minRadiusSwitch.index(for: savedFeedback["3b"]!) ?? 0
        safetyZonesOnMapField.text = savedFeedback["3c"]!
        detailProvidedField.text = savedFeedback["3d"]!
        categoriesField.text = savedFeedback["3e"]!
        positiveExperienceField.text = savedFeedback["3f"]!
        negativeExperienceField.text = savedFeedback["3g"]!
        lookFeelSlider.value = Float(savedFeedback["3h"]!) ?? lookFeelSlider.value
        lookFeelSliderChanged(lookFeelSlider)
    }
}
