//
//  Extensions.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/24/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

extension UIViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
}

extension UIBarButtonItem {
    func addTarget(_ target: AnyObject?, action: Selector) {
        self.target = target!
        self.action = action
    }
}

extension UIColor {
    static var espOrange: UIColor {
        get {
            return UIColor(
                red: 247.0 / 255.0,
                green: 155.0 / 255.0,
                blue: 66.0 / 255.0,
                alpha: 1
            )
        }
    }
}
