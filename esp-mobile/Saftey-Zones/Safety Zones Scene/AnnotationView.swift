//
//  AnnotationView.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 11/12/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import MapKit

final class AnnotationView: MKAnnotationView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if (hitView != nil) {
            self.superview?.bringSubview(toFront: self)
        }
        
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        
        if (!isInside) {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        
        return isInside
    }
}
