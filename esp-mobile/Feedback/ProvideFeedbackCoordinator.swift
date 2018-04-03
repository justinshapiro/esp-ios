//
//  ProvideFeedbackCoordinator.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/14/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import Foundation

final class ProvideFeedbackCoordinator: NSObject {
    private typealias ViewModel = ProvideFeedbackPage6ViewController.ViewModel
    @IBOutlet weak private var viewController: ProvideFeedbackPage6ViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
    }
}
