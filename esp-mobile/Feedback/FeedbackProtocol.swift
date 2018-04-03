//
//  FeedbackProtocol.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/31/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

enum FeedbackPosition: Int {
    case finished, page1, page2, page3, page4, page5, page6
}

protocol FeedbackProtocol: class {
    var feedbackPosition: FeedbackPosition { get }
    var feedback: Feedback? { get set }
    func collectFeedback()
    func restoreFeedback()
}
