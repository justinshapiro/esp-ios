//
//  Extensions.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 3/24/18.
//  Copyright © 2018 Justin Shapiro. All rights reserved.
//

import UIKit

// MARK: UIViewController extensions

extension UIViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
}

// MARK: UIBarButtonItem extensions

extension UIBarButtonItem {
    func addTarget(_ target: AnyObject?, action: Selector) {
        self.target = target!
        self.action = action
    }
}

// MARK: UIColor extensions

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

// MARK: UISegmentedControl extensions

extension UISegmentedControl {
    func index(for title: String) -> Int? {
        return Array(0...numberOfSegments - 1).filter { titleForSegment(at: $0)! == title }.first
    }
}

// MARK: UIImage extensions

extension UIImage {
    func castRetina(to customSize: CGSize? = nil) -> UIImage? {
        guard let effectiveSize = customSize == nil ? size : customSize else { return nil }
        UIGraphicsBeginImageContextWithOptions(effectiveSize, false, 0)
        draw(in: CGRect(x: 0, y: 0, width: effectiveSize.width, height: effectiveSize.height))
        let resizedPinImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedPinImage
    }
}
