//
//  ProvideFeedbackPage1ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/14/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage1ViewController: UIViewController {
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
        performSegue(withIdentifier: "unwindFromPage1", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
}
