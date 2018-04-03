//
//  ProvideFeedbackPage1ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/14/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage1ViewController: UIViewController, FeedbackProtocol {
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var rateStar1: UIButton!
    @IBOutlet weak private var rateStar2: UIButton!
    @IBOutlet weak private var rateStar3: UIButton!
    @IBOutlet weak private var rateStar4: UIButton!
    @IBOutlet weak private var rateStar5: UIButton!

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
    
    @IBOutlet weak private var usefulSlider: UISlider!
    @IBOutlet weak private var lookFeedSlider: UISlider!
    @IBOutlet weak private var recommendSwitch: UISegmentedControl!
    @IBOutlet weak private var nextPageButton: UIButton! {
        didSet {
            nextPageButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak private var usefulSliderLabel: UILabel!
    @IBAction private func usefulSliderChanged(_ sender: UISlider) {
        usefulSliderLabel.text = "\(Int(sender.value)) out of 10"
    }
    
    @IBOutlet weak private var lookFeelSliderLabel: UILabel!
    @IBAction private func lookFeelSliderChanged(_ sender: UISlider) {
        lookFeelSliderLabel.text = "\(Int(sender.value)) out of 10"
    }
    
    @IBAction private func starSelected(_ sender: UIButton) {
        let rateStars: [UIButton] = [
            rateStar1, rateStar2, rateStar3, rateStar4, rateStar5
        ]
        
        for star in rateStars {
            if star.tag <= sender.tag {
                DispatchQueue.main.async {
                    star.imageView?.image = UIImage(named: "filled_star")
                }
            } else {
                DispatchQueue.main.async {
                    star.imageView?.image = UIImage(named: "empty_star")
                }
            }
        }
    }
    
    @IBAction private func exitRequested(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(feedbackPosition.rawValue, forKey: "feedbackPosition")
        performSegue(withIdentifier: "unwindFromPage1", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Properties
    
    var feedback: Feedback?
    var feedbackPosition: FeedbackPosition = .page1
    
    // MARK: Overrides
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? ProvideFeedbackPage2ViewController else { return }
        collectFeedback()
        viewController.feedback = feedback
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectFeedback()
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
        
        feedback?.platform = "iOS"
        feedback?.feedbackRound = "1"
        feedback?._1a = "\(getStarRating())"
        feedback?._1b = positiveOpinionBox.text
        feedback?._1c = negativeOpinionBox.text
        feedback?._1d = "\(Int(usefulSlider.value))"
        feedback?._1e = "\(Int(lookFeedSlider.value))"
        feedback?._1f = recommendSwitch.titleForSegment(at: recommendSwitch.selectedSegmentIndex)!
        
        if let feedback = feedback {
            UserDefaults.standard.setValuesForKeys(feedback.tabularRepresentation())
        }
    }
    
    func restoreFeedback() {
        guard let savedFeedback = UserDefaults.standard.dictionaryWithValues(forKeys: ["1a", "1b", "1c", "1d", "1e", "1f"]) as? [String: String] else { return }
        
        let filledImage = UIImage(named: "filled_star")
        [rateStar1, rateStar2, rateStar3, rateStar4, rateStar5].enumerated().forEach { i, _ in
            if i + 1 <= Int(savedFeedback["1a"]!)! {
                switch i + 1 {
                case 1: rateStar1.imageView?.image = filledImage
                case 2: rateStar2.imageView?.image = filledImage
                case 3: rateStar3.imageView?.image = filledImage
                case 4: rateStar4.imageView?.image = filledImage
                case 5: rateStar5.imageView?.image = filledImage
                default: break
                }
            }
        }
        
        positiveOpinionBox.text = savedFeedback["1b"]!
        negativeOpinionBox.text = savedFeedback["1c"]!
        usefulSlider.value = Float(savedFeedback["1d"]!) ?? usefulSlider.value
        usefulSliderChanged(usefulSlider)
        lookFeedSlider.value = Float(savedFeedback["1e"]!) ?? lookFeedSlider.value
        lookFeelSliderChanged(lookFeedSlider)
        recommendSwitch.selectedSegmentIndex = recommendSwitch.index(for: savedFeedback["1f"]!) ?? 0
    }
    
    private func getStarRating() -> Int {
        let filledImage = UIImage(named: "filled_star")
        if rateStar5.imageView?.image == filledImage {
            return 5
        } else if rateStar4.imageView?.image == filledImage {
            return 4
        } else if rateStar3.imageView?.image == filledImage {
            return 3
        } else if rateStar2.imageView?.image == filledImage {
            return 2
        } else if rateStar1.imageView?.image == filledImage {
            return 1
        } else {
            return 0
        }
    }
}
