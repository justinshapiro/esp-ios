//
//  Target.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/12/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation

@objc final class Target: NSObject {
    private let action: (Any) -> ()
    
    init(action: @escaping (Any) -> ()) {
        self.action = action
    }
    
    @objc func action(sender: Any) {
        self.action(sender)
    }
}
