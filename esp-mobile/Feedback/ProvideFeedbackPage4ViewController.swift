//
//  ProvideFeedbackPage4ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/17/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage4ViewController: UIViewController {
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
        performSegue(withIdentifier: "unwindFromPage4", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
}
