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
    @IBOutlet private var viewController: ProvideFeedbackPage6ViewController!
    
    override func awakeFromNib() {
        viewController.loadViewIfNeeded()
        viewController.render(state: .initial(.init(submit: { self.submitFeedback($0) })))
    }
    
    private func submitFeedback(_ feedback: Feedback) {
        viewController.render(state: .waiting)
        
        ESPMobileAPI.sendFeedback(feedback: feedback) {
            switch $0 {
            case .successWithData: break
            case .success:
                self.viewController.render(state: .success)
            case .failure(let failure):
                self.viewController.render(state: .failure(.init(message: failure.message, submit: { self.submitFeedback($0) })))
            }
        }
    }
}
