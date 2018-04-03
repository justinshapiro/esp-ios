//
//  ProvideFeedbackPage3ViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/16/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackPage3ViewController: UIViewController {
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
        performSegue(withIdentifier: "unwindFromPage3", sender: self)
    }
    
    @IBAction private func endEditing(_ sender: UIGestureRecognizer) {
        view.endEditing(true)
    }
}
