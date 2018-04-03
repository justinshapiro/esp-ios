//
//  ProvideFeedbackPage2ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/16/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage2ViewController: UIViewController {
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
        performSegue(withIdentifier: "unwindFromPage2", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
}
