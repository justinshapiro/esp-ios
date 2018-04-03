//
//  ProvideFeedbackEndViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/17/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

final class ProvideFeedbackEndViewController: UIViewController {
    @IBAction private func exitRequested(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindFromThankYou", sender: self)
    }
    
    @IBAction private func exitBarButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromThankYou", sender: self)
    }
    
    @IBOutlet weak private var exitButton: UIButton! {
        didSet {
            exitButton.layer.cornerRadius = 5
        }
    }
}
